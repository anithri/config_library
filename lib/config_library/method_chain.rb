module ConfigLibrary
  class MethodChain
    attr_accessor :library

    OP_LOOKUPS = {nil  => :_plain_element,
                  "!" => :_bang_element,
                  "=" => :_assign_element
    }

    def _key_chain
      @key_chain
    end

    #declaring all of these for override situations
    def _plain_keep_going?(name, op, key_chain, value)
      value.is_a?(Hash)
    end

    def initialize(library, *key_chain)
      @library = library
      @key_chain = key_chain
    end

    def method_missing(name_sym, *args, &block)
      #warn "enter mm: #{@key_chain}"
      name, op = ConfigLibrary.name_parts(name_sym)
      @key_chain << name
      #warn "\nMM: #{name} -> #{op || 'nil'} -> (#{args})?"
      self.send(OP_LOOKUPS[op], name, op, args, block)
    end

    def _plain_element(name, op, args, block)
      #warn "  PE: #{name} -> #{op} -> (#{args})?"
      value = library.fetch_chain(@key_chain)
      #warn "    chain #{@key_chain.inspect} => #{value.inspect}"
      if value.nil?
        return ConfigLibrary::NullResult.new("ok for .#{@key_chain[0..-2].join('.')}, nil on .#{@key_chain[-1]},")
      end
      if _plain_keep_going?(name, op, @key_chain, value)
        return self
      else
        return value
      end
    end

    def _bang_element(name, op, args, block)
      value = library.fetch_chain(@key_chain)
      if value.nil?
        return ConfigLibrary::NullResult.new("ok for .#{@key_chain[0..-2].join('.')}, nil on .#{@key_chain[-1]},")
      else
        return value
      end
    end

    def _assign_element(name, op, args, block)
      @library._deep_assign(@key_chain, args)
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
