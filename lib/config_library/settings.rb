module ConfigLibrary
  class Settings

    OPTION_DEFAULTS = {
      assign_ok: true,
      assign_deep_ok: true,
      assign_over_hash: false,
      assign_over_any: true,
      search_order_strategy: :lifo,
      alternate_key_strategy: lambda{ |key| key.is_a?(Symbol) ? [key, key.to_s] : [key, key.intern] },
      new_book_strategy: lambda{ {} }, #empty hash
      assign_to_book_strategy: lambda{ |search_order| search_order.first }
    }

    attr_accessor *OPTION_DEFAULTS.keys

    def initialize(opts = {})
      OPTION_DEFAULTS.merge(opts).each do |k,v|
        raise ArgumentError, "unknown option: '#{k}'" unless OPTION_DEFAULTS.has_key?(k)
        self.send("#{k.to_s}=", v)
      end
    end

    def is_callable?(new_lambda)
      new_lambda.respond_to?(:call)
    end

    def is_valid_search_order_strategy?(value)
      ConfigLibrary::SearchOrderStrategies.instance_methods.include?(value) ||
          ConfigLibrary::SearchOrderStrategies.instance_methods.include?(value.intern)
    end

    def new_book_strategy=(value)
      raise ArgumentError, "value for :new_book_strategy is not callable" unless is_callable?(value)
      @new_book_strategy = value
    end

    def assign_to_book_strategy=(value)
      raise ArgumentError, "value for :assign_to_book_strategy is not callable" unless is_callable?(value)
      @assign_to_book_strategy = value
    end

    def search_order_strategy=(value)
      unless is_callable?(value) || is_valid_search_order_strategy?(value)
        msg = "#{value} is not a callable object or is not a known method in ConfigLibrary::SearchOrderStrategies"
        raise ArgumentError, msg
      end
        @search_order_strategy = value
    end

    def search_order_strategy
      return @search_order_strategy if is_callable?(@search_order_strategy)
      ConfigLibrary::SearchOrderStrategies.method(@search_order_strategy)
    end

    def assign_ok?
      @assign_ok
    end

    def assign_deep_ok?
      @assign_deep_ok
    end

    def assign_over_hash?
      @assign_over_hash
    end

    def assign_over_any?
      @assign_over_any
    end

  end
end
