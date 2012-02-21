module ConfigLibrary
  class Base

    attr_accessor :search_order, :order_strategy, :books, :counter

    VALID_ORDER_STRATEGIES = [:lifo, :fifo, :manual].freeze

    def initialize(order_strategy,initial_books)
      unless VALID_ORDER_STRATEGIES.include?(order_strategy)
        raise ArgumentError, "order_strategy (#{order_strategy}) must be one of #{VALID_ORDER_STRATEGIES}"
      end
      @counter = 0
      @books = {}
      @search_order = []

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

    def add_book(name, book = {})
      raise ArgumentError, "#{name} must respond to #intern" unless k.respond_to?(:intern)
      raise ArgumentError, "#{book} must be a kind of hash." unless v.kind_of?(Hash)

      @books[name.intern] = book
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

    def has_key?(key,order_arr = @search_order)
      order_arr.map{|b| @books[b].has_key?(key)}.any?
    end

    def books_with_key(key, order_arr = @search_order)
      order_arr.select{|b| @books[b].has_key?(key)}
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

    #TODO expand for blocks
    def fetch(key, default = nil)
      fetch_chain(key) || default
    end

    def fetch_all(key)
      all_fetch_chain(key)
    end

    #TODO handle default_values
    def fetch_chain(*key_chain)
      payload = _fetch_chain(@search_order, key_chain.flatten.compact).compact.first
      return nil if payload.nil?
      return payload[1]
    end

    def _fetch_chain(search_arr, key_chain)
      #payload? Perhaps I'm over paranoid, but i wasn't sure about returning literal false values
      #and this allowed me to skip that worry by wrapping whatever the return value is
      search_arr.map{|b| _hash_has_key_chain?(@books[b], key_chain.dup)}
    end

    def all_fetch_chain(*key_chain)
      payload =  _fetch_chain(@search_order, key_chain.flatten.compact).compact
      return [] if payload.empty?
      payload.map{|p| p[1]}
    end

    def all_with_key_chain?(*key_chain)
      @search_order.select{|b| _hash_has_key_chain?(@books[b], key_chain.flatten.compact)}
    end

    def has_key_chain?(*key_chain)
      all_with_key_chain?(key_chain).any?
    end

    #TODO consider rename to _deep_fetch
    def _hash_has_key_chain?(target_hash, key_chain)
      this_level = key_chain.shift
      return nil unless target_hash.has_key?(this_level)
      return [:boomerang,target_hash[this_level]] if key_chain.empty?
      _hash_has_key_chain?(target_hash[this_level], key_chain)
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
