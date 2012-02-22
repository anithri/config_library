module ConfigLibrary
  class NullResult < NilClass
    def method_missing
      self
    end
  end
end
