require 'facets/hash/autonew'
require 'facets/enumerable/hashify'
module ConfigLibrary
  class Base

    attr_reader :books, :search_order, :assign_to_book

    def initialize(*args)
      @books = {}
      @search_order = []
      @assign_to = nil
      add_new_books(args) unless args.empty?
    end

    def _mk_new_hash(old_hash = nil)
      new_hash = Hash.autonew
      return new_hash if old_hash.nil?
      _parse_hash_deep(new_hash, old_hash, key_chain = [])
    end

    def assign_to_book
      @assign_to_book ||= search_order.first
    end

    def _parse_hash_deep(new_hash, old_hash, key_chain = [])
      old_hash.each_pair do |k,v|
        my_chain = key_chain.dup
        my_chain << k
        if v.is_a?(Hash)
          _parse_hash_deep(new_hash, v, my_chain)
        else
          new_hash[my_chain] = v
        end
      end
      new_hash
    end

    def add_new_books(*args)
      args.flatten!
      args.each do |e|
        if e.is_a?(Hash)
          e.each_pair{|k,v| add_new_book(k,v)}
        elsif e.respond_to?(:to_sym)
          add_new_book(e)
        end
      end
    end

    def add_new_book(name, hash = nil)
      raise ArgumentError, "name must respond to #intern" unless name.respond_to?(:intern)
      name = name.intern
      raise ArgumentError, "#{name.inspect} is already a book." if self.books.has_key?(name)
      new_hash = _mk_new_hash(hash)
      @books[name] = new_hash
      search_order.unshift(name)
    end

    def fetch(*key_chain)
      fetch_all(key_chain).first
    end

    def fetch_all(*key_chain)
      search_order.map{|b| _fetch_from_hash(books[b], key_chain.dup)}.compact
    end

    def fetch_all_as_hash(*key_chain)
      search_order.hashify{|b| _fetch_from_hash(books[b], key_chain.dup)}
    end

    def fetch_hash(*key_chain)
      all_keys = @search_order.
          map{|b| @books[b].keys}.
          flatten(1).
          uniq.
          select{|k| _has_kids?(k,key_chain, :deep)}.
          map!{|k| k - key_chain }
      _collapse_to_hash(key_chain,all_keys)
    end

    def _collapse_to_hash(key_chain,all_keys)
      new_hash = _mk_new_hash
      all_keys.each do |new_key_chain|
        value = fetch(key_chain + new_key_chain)
        this_hash = new_hash
        last_key = new_key_chain.pop
        new_key_chain.each do |key|
          this_hash = this_hash[key]
        end
        this_hash[last_key] = value
      end
      new_hash
    end

    def keys_for(*key_chain)
      out = search_order.map do |book|
        books[book].keys.select{|k| _has_kids?(k,key_chain) }.map(&:last)
      end
      out.flatten.uniq
    end

    def deep_keys_for(*key_chain)
      out = search_order.map do |book|
        books[book].keys.
            select{|k| _has_kids?(k,key_chain, :deep) }.
            map{|k| k - key_chain}
      end
      out.flatten(1).uniq
    end

    def _has_kids?(whole, start, deep = false)
      (whole.first(start.length) == start) && ( deep ? whole.length > start.length : whole.length == start.length + 1 )
    end

    def _fetch_from_hash(hash,*key_chain)
      key_chain.flatten!
      out = hash[key_chain]
      out == {} ? nil : out
    end

    def assign_to(*key_chain, value)
      books[assign_to_book][key_chain] = value
    end

    def books_with(*key_chain)
      results = fetch_all_as_hash(*key_chain)
      results.keys.select{|k| results[k]}
    end

    def books_with_value(*key_chain, value)
      results = fetch_all_as_hash(key_chain.dup)
      results.keys.select{|k| results[k] == value}
    end

    def has_key?(*key_chain)
      search_order.map{ |b| books[b].keys.select{|k| k.first(key_chain.length) == key_chain}}.flatten.compact.length > 0
    end

  end
end
