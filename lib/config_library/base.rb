module ConfigLibrary
  class Base

    attr_reader :settings, :books, :search_order, :book_to_assign_to

    def initialize(initial_books, opts = ConfigLibrary::Settings.new())
      unless opts.kind_of?(ConfigLibrary::Settings)
        @book_to_assign_to = opts.delete(:book_to_assign_to)
        opts = ConfigLibrary::Settings.new(opts)
      end
      @settings = opts
      @books = _generate_new_book
      @search_order = []
      if initial_books.kind_of?(Hash)
        initial_books.each do |k,v|
          add_book(k,v)
        end
      else
        raise ArgumentError, "not a kind of hash: #{initial_books}'"
      end
    end

    def _generate_new_book
      @settings.new_book_strategy.call
    end

    def book_to_assign_to
      @book_to_assign_to ||= @settings.assign_to_book_strategy.call(@search_order)
    end

    def book_to_assign_to=(value)
      raise ArgumentError, "Must pass a symbol for a book name" unless value.is_a? Symbol
      raise ArgumentError, "No book named '#{value.inspect}" unless @books.has_key?(value)
      @book_to_assign_to = value
    end

    def add_book(name, book = @settings.new_book_strategy.call)
      raise ArgumentError, "#{name} must respond to #intern" unless name.respond_to?(:intern)
      raise ArgumentError, "#{book} must be a kind of hash." unless book.kind_of?(Hash)

      @books[name.intern] = book
      add_to_search_order(name.intern)
    end

    def assign_to(*key_chain, value)
      warn "\n\nAssigning chain #{key_chain} new value #{value}"
      raise AssignmentError, "not allowed to assign values." unless @settings.assign_ok?

      parent = fetch_chain(*key_chain[0,-2])
      warn "\n\nPARENT: #{parent.inspect}"
      if parent

        existing = fetch_chain(key_chain)
        if existing
          raise AssignmentError, "not allowed to replace existing values by #settings.assign_over_any" unless @settings.assign_over_any?
          raise AssignmentError, "not allowed to replace existing hash by #settings.assign_over_hash" if existing.is_a?(Hash) && ! @settings.assign_over_hash?
        end
      end


    end


    def add_to_search_order(key)
      raise ArgumentError, "#{key} not a valid book" unless @books.has_key?(key)
      settings.search_order_strategy.call(@search_order, key)
      @search_order
    end

                              # working code first #
                    ####  #####  ##### # #    # # ###### ######
                   #    # #    #   #   # ##  ## #     #  #
                   #    # #    #   #   # # ## # #    #   #####
                   #    # #####    #   # #    # #   #    #
                   #    # #        #   # #    # #  #     #
                    ####  #        #   # #    # # ###### ######


                         #        ##   ##### ###### #####
                         #       #  #    #   #      #    #
                         #      #    #   #   #####  #    #
                         #      ######   #   #      #####
                         #      #    #   #   #      #   #
                         ###### #    #   #   ###### #    #

    #TODO handle default_values
    def fetch_chain(*key_chain, &default)
      payload = _fetch_chain_raw(key_chain.flatten.compact).compact.first
      return default.respond_to?( :call ) && default.call( key_chain ) || nil if payload.nil?
      return payload[1]
    end

    alias :fetch :fetch_chain

    def _fetch_chain_raw(key_chain)
      #payload? Perhaps I'm over paranoid, but i wasn't sure about returning literal false values
      #and this allowed me to skip that worry by wrapping whatever the return value is
      @search_order.map{|b| _hash_deep_fetch(@books[b], key_chain.dup)}
    end

    def fetch_all_chain(*key_chain, &default)
      payload =  _fetch_chain_raw(key_chain.flatten.compact).compact
      return default.respond_to?( :call ) && default.call( key_chain ) || [] if payload.empty?
      payload.map{|p| p[1]}
    end

    alias :fetch_all :fetch_all_chain

    def books_with_key_chain(*key_chain)
      a = @search_order.select{|b| _hash_deep_fetch(@books[b], key_chain.flatten.compact)}
      warn "#{a.inspect} has #{key_chain.flatten.compact}"
      return a
    end

    alias :books_with_key :books_with_key_chain

    def has_key_chain?(*key_chain)
      books_with_key_chain(key_chain).any?
    end

    alias :has_key? :has_key_chain?

    #TODO consider rename to _deep_fetch
    def _hash_deep_fetch(target_hash, key_chain)
      warn "_hash_deep_fetch(#{target_hash}, #{key_chain})"
      return nil unless target_hash.is_a?(Hash)
      key = key_chain.pop
      deep_hash, keys_left, keys_found = _hash_for_chain(target_hash, key_chain)
      return nil unless keys_left.empty?
      return _get_value(deep_hash, key)
    end

    def _find_with_object(container)
      container.each do |e|
        out = yield(e)
        return out if out
      end
    end

    def _hash_for_chain(target_hash, keys_to_find, used_keys = [])
      warn "_hash_for_chain(#{target_hash},"
      warn "                #{keys_to_find},"
      warn "                #{used_keys})"
      return [target_hash, keys_to_find, used_keys] if keys_to_find.empty?
      #warn "  not "
      if target_hash.has_key?(keys_to_find[0]) && target_hash[keys_to_find[0]].is_a?(Hash)
        used_keys << keys_to_find.shift
        results = _hash_for_chain(target_hash[used_keys[-1]], keys_to_find, used_keys)
      else
        return [target_hash, keys_to_find, used_keys]
      end
    end


    def _get_value(target_hash, key)
      warn "get_value(\n          #{target_hash.inspect},\n          #{key})"
      return nil unless target_hash.has_key?(key)
      return [:boomerang,target_hash[key]]
    end

    def config
      MethodChain.new(self)
    end


                              # working code first #
                    ####  #####  ##### # #    # # ###### ######
                   #    # #    #   #   # ##  ## #     #  #
                   #    # #    #   #   # # ## # #    #   #####
                   #    # #####    #   # #    # #   #    #
                   #    # #        #   # #    # #  #     #
                    ####  #        #   # #    # # ###### ######


                         #        ##   ##### ###### #####
                         #       #  #    #   #      #    #
                         #      #    #   #   #####  #    #
                         #      ######   #   #      #####
                         #      #    #   #   #      #   #
                         ###### #    #   #   ###### #    #


  end
end
