module ConfigLibrary
  class Base

    attr_reader :settings, :books, :search_order, :book_to_assign_to

    def initialize(initial_books = {}, opts = ConfigLibrary::Settings.new())
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

    def _assign_to_hash
      @books[book_to_assign_to]
    end

    def add_book(name, book = @settings.new_book_strategy.call)
      raise ArgumentError, "#{name} must respond to #intern" unless name.respond_to?(:intern)
      raise ArgumentError, "#{book} must be a kind of hash." unless book.kind_of?(Hash)

      @books[name.intern] = book
      add_to_search_order(name.intern)
    end

    def assign_to(*key_chain, value)
      raise AssignmentError, "not allowed to assign values." unless @settings.assign_ok?
      existing = fetch_chain(key_chain)
      if existing
        raise AssignmentError, "not allowed to replace existing values" unless @settings.assign_over_any?
        raise AssignmentError, "not allowed to replace existing hash" if ! @settings.assign_over_hash? && existing.is_a?(Hash)
      end
      final_key = key_chain.pop
      deepest_hash, keys_left, keys_found = _hash_for_chain(_assign_to_hash, key_chain)
      unless keys_left.empty?
        new_keys = keys_left.dup

        first_key = new_keys.shift
        deepest_hash[first_key] = _make_hash_chain(*new_keys)

        deepest_hash = _hash_for_chain(deepest_hash,keys_left)[0]
        deepest_hash
      end
      deepest_hash[final_key] = value
    end

    def _make_hash_chain(*key_chain)
      top = @settings.new_book_strategy.call
      this_key = key_chain.shift
      if this_key
        top[this_key] = _make_hash_chain(*key_chain)
      end
      top
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
      a = @search_order.map{|b| _hash_deep_fetch(@books[b], key_chain.dup)}
      a
    end

    def fetch_all_chain(*key_chain, &default)
      payload =  _fetch_chain_raw(key_chain.flatten.compact).compact
      return default.respond_to?( :call ) && default.call( key_chain ) || [] if payload.empty?
      payload.map{|p| p[1]}
    end

    alias :fetch_all :fetch_all_chain

    def books_with_key_chain(*key_chain)
      @search_order.select{|b| _hash_deep_fetch(@books[b], key_chain.flatten.compact)}
    end

    alias :books_with_key :books_with_key_chain

    def has_key_chain?(*key_chain)
      books_with_key_chain(key_chain).any?
    end

    alias :has_key? :has_key_chain?

    #TODO consider rename to _deep_fetch
    def _hash_deep_fetch(target_hash, key_chain)
      return nil unless target_hash.is_a?(Hash)
      key = key_chain.pop
      deep_hash, keys_left, keys_found = _hash_for_chain(target_hash, key_chain)
      return nil unless keys_left.empty?
      key_to_use = _check_keys(deep_hash, key)
      return _get_value(deep_hash, key_to_use)
    end

    def _find_with_object(container)
      container.each do |e|
        out = yield(e)
        return out if out
      end
    end

    def _hash_for_chain(target_hash, keys_to_find, used_keys = [])
      return [target_hash, keys_to_find, used_keys] if keys_to_find.empty?
      key_to_use = _check_keys(target_hash,keys_to_find[0])
      if key_to_use && target_hash[key_to_use].is_a?(Hash)
        used_keys << key_to_use
        keys_to_find.shift
        results = _hash_for_chain(target_hash[used_keys[-1]], keys_to_find, used_keys)
      else
        return [target_hash, keys_to_find, used_keys]
      end
    end

    def _check_keys(target_hash, key_to_check)
      @settings.alternate_key_strategy.call(key_to_check).find{|k| target_hash.has_key?(k)}
    end

    def _get_value(target_hash, key)
      return nil unless target_hash.has_key?(key)
      return [:boomerang,target_hash[key]]
    end

    def config
      MethodChain.new(self)
    end

    def method_missing(name_sym, *args, &block)
      if _name_ok_for_method_missing?(name_sym, args)
        return MethodChain.new(self, name_sym)
      else
        super
      end
    end

    def all_keys_for_key_chain(*key_chain)
      a = fetch_all_chain(key_chain)
      unless a.all?{|e| e.is_a?(Hash)}
        raise ConfigLibrary::KeyError, "not all results are hashes: #{a.inspect}"
      end
       a.map(&:keys).flatten.compact.uniq
    end

    def _name_ok_for_method_missing?(name_sym, args)
      return false unless args.empty?
      return false unless @settings.method_missing_ok?
      if @settings.method_missing_top_level_keys_only?
        return has_key?(name_sym)
      else
        return true
      end
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
