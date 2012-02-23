module ConfigLibrary
  class Base

    attr_accessor :search_order, :order_strategy, :books, :counter, :book_to_assign_to, :ok_to_assign, :new_book_strategy

    VALID_ORDER_STRATEGIES = [:lifo, :fifo, :manual].freeze

    def initialize(order_strategy,initial_books)
      unless VALID_ORDER_STRATEGIES.include?(order_strategy)
        raise ArgumentError, "order_strategy (#{order_strategy}) must be one of #{VALID_ORDER_STRATEGIES}"
      end
      @new_book_strategy = lambda{{}}
      @counter = 0
      @books = @new_book_strategy.call
      @search_order = []
      @ok_to_assign = true
      @order_strategy = order_strategy
      if initial_books.kind_of?(Hash)
        initial_books.each do |k,v|
          raise ArgumentError, "#{k} must respond to #intern" unless k.respond_to?(:intern)
          raise ArgumentError, "#{k} has value that is not a kind of hash." unless v.kind_of?(Hash)
          @books[k.intern] = v
          add_to_search_order(k.intern)
        end
      else
        raise ArgumentError, "not a kind of hash: #{initial_books}'"
      end
    end

    def book_to_assign_to
      @book_to_assign_to ||= @search_order.first
    end

    def book_to_assign_to=(value)
      raise ArgumentError, "Must pass a symbol for a book name" unless value.is_a? Symbol
      raise ArgumentError, "No book named '#{value.inspect}" unless @books.has_key?(value)
      @book_to_assign_to = value
    end

    def add_book(name, book = @new_book_strategy.call)
      raise ArgumentError, "#{name} must respond to #intern" unless k.respond_to?(:intern)
      raise ArgumentError, "#{book} must be a kind of hash." unless v.kind_of?(Hash)

      @books[name.intern] = book
    end

    def assign_to(keychain, values)
      raise StandardError, "not allowed to assign values." unless @ok_to_assign
      current_hash = @books[@book_to_assign_to]
      raise StandardError, "no hash for #{@book_to_assign_to}" unless current_hash.is_a?(Hash)
      used_keys = []
      key_chain.each do |key|
        used_keys << key
        if used_keys == key_chain
        if current_hash.has_key?(key) && current_hash[key].is_a?(Hash)
          current_hash = current_hash[key]
        elsif current_hash.has_key?(key)
          raise ArgumentError, "key[#{key}] at end of chain[.#{used_keys.join('.')}] cannot be assigned a new element."
        end

      end
      end
    end

    def add_to_search_order(key)
      raise ArgumentError, "#{key} not a valid book" unless @books.has_key?(key)
      case @order_strategy
      when :lifo
        @search_order.unshift(key)
      when :fifo
        @search_order.push(key)
      else
        #noop
      end
      @search_order
    end

    #def has_key?(key,order_arr = @search_order)
    #  order_arr.map{|b| @books[b].has_key?(key)}.any?
    #end

    #def books_with_key(key, order_arr = @search_order)
    #  order_arr.select{|b| @books[b].has_key?(key)}
    #end

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

    #TODO expand for blocks
    #def fetch(key, default = nil)
    #  fetch_chain(key) || default
    #end

    #def fetch_all(key)
    #  all_fetch_chain(key)
    #end

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

    def method_missing?(name, *args)
      if op.nil?
        #TODO Lookup
      elsif op == "!"
        #TODO forced return
      elsif op == "="
        #TODO Assignment
      end
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
