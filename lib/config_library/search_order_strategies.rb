module ConfigLibrary
  module SearchOrderStrategies
    extend self

    def manual(container, new_value)
    end

    def lifo(container, new_value)
      container.unshift(new_value)
    end

    def fifo(container, new_value)
      container.push(new_value)
    end
  end
end