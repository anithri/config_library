module ConfigLibrary
  class MethodChain
    attr_accessor :library, :key_chain

    OP_LOOKUPS = {nil  => :_plain_element,
                  "!" => :_end_element,
                  "=" => :_assign_element
    }

    def initialize(library, *key_chain)
      @library = library
      @key_chain = key_chain
    end

    def method_missing(name_sym, *key_chain)
      name, op = ConfigLibrary.name_parts(name_sym)
      super unless _sanity_check(name, *key_chain)
      self.send(OP_LOOKUPS[op], name, key_chain)
    end

    def _sanity_check(name, *key_chain)

    end

    def _plain_element(name, *key_chain)

    end

    def _end_element(name, *key_chain)

    end

    def _assign_element(name, *key_chain)

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
