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

    def assign_to(*key_chain, values)
      raise StandardError, "not allowed to assign values." unless @settings.assign_ok?
      current_hash = books[book_to_assign_to]
      raise StandardError, "no hash for #{book_to_assign_to}" unless current_hash.is_a?(Hash)
      used_keys = []
      key_chain.each do |key|
        used_keys << key
        if current_hash.has_key?(key) && current_hash[key].is_a?(Hash)
          current_hash = current_hash[key]
        elsif current_hash.has_key?(key)
          raise ArgumentError, "key[#{key}] at end of chain[.#{used_keys.join('.')}] cannot be assigned a new element."
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
      this_level = key_chain.shift
      #TODO detect and respond to cases where hash has both string and symbol key
      alternate_key = this_level.is_a?(Symbol) ? this_level.to_s : this_level.intern
      return_value = _get_value(target_hash, this_level) || _get_value(target_hash, alternate_key)
      return return_value if key_chain.empty?
      return nil if return_value.nil?
      _hash_deep_fetch(return_value[1], key_chain)
    end

    def _get_value(target_hash, key)
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
