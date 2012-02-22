module ConfigLibrary
  class MethodChain
    attr_accessor :library, :key_chain

    OP_LOOKUPS = {nil  => :_plain_element,
                  "!" => :_end_element,
                  "=" => :_assign_element
    }

    def _keep_going?(name, op, key_chain, value)
      #declaring all of these for override situations
      value.is_a?(Hash)
    end

    def initialize(library, *key_chain)
      @library = library
      @key_chain = key_chain
    end

    def method_missing(name_sym, *args)
      name, op = ConfigLibrary.name_parts(name_sym)
      warn "\nMM: #{name} -> #{op || 'nil'} -> (${args})?"
      self.send(OP_LOOKUPS[op], name, op, args) || super
    end

    def _plain_element(name, op, *args)
      warn "  PE: #{name} -> #{op} -> (#{args})?"
      @key_chain << name
      value = library.fetch_chain(@key_chain << name)
      warn "    value= #{value.inspect}"
      return nil if value.nil?
      if _keep_going?(name, op, key_chain, value)
        @key_chain << name
        return self
      else
        return value
      end
    end

    def _end_element(name, op, *args)
      warn "Side Effect END"

    end

    def _assign_element(name, op, *args)
      warn "Side Effect ASSIGN"

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
