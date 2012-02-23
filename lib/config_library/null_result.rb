module ConfigLibrary
  class NullResult

    def initialize(msg="")
      @msg = msg
      @tried = []
    end

    def to_a
      []
    end

    def to_s
      ""
    end

    def nil?
      true
    end

    def !
      true
    end

    def inspect
      tried = @tried.empty? ? "no callers" : "called by:#{@tried.inspect}"
      "#<NullResult:#{@msg} #{tried} >"
    end

    def method_missing(*args, &block)
      @tried << args[0]
      self
    end

  end
end
