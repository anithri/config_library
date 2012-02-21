class ConfigLibrary

  attr_accessor :search_order, :order_strategy, :books

  VALID_ORDER_STRATEGIES = [:lifo, :fifo, :manual].freeze
  def initialize(order_strategy,initial_books)
    unless VALID_ORDER_STRATEGIES.include?(order_strategy)
      raise ArgumentError, "order_strategy (#{order_strategy}) must be one of #{VALID_ORDER_STRATEGIES}"
    end

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

  #TODO expand for blocks
  def fetch(key, default = nil)
    _fetch_from(@search_order, key, default)
  end

  def _fetch_from(search_arr, key, default)
    return default unless has_key?(key, search_arr)
    @books[books_with_key(key, search_arr).first][key] || default
  end

  def fetch_all(key)
    _fetch_all(@search_order, key)
  end

  def _fetch_all(search_order, key)
    books_with_key(key, search_order).map{|b| @books[b][key]}
  end

  #TODO handle default_values
  def fetch_chain(*key_chain)
    #_fetch_chain(@search_array, key_chain)
  end

  def _fetch_chain(search_arr, key_chain)

  end

  def has_key_chain?(*key_chain)
    _has_key_chain?(@search_order, key_chain.flatten.compact)
  end

  def _has_key_chain?(search_arr, key_chain)
    search_arr.map{|b| _hash_has_key_chain?(@books[b], key_chain)}.any?
  end

  def _hash_has_key_chain?(target_hash, key_chain)
    this_level = key_chain.shift
    #return true if this_level.nil?
    return false unless target_hash.has_key?(this_level)
    return true unless target_hash[this_level].kind_of?(Hash)
    _hash_has_key_chain?(target_hash[this_level], key_chain)
  end


  def _deep_fetch(*key_chain)

  end
end