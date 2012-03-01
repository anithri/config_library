module ConfigLibrary
  class MethodChain
    attr_accessor :library

    OP_LOOKUPS = {nil  => :_plain_element,
                  "!" => :_bang_element,
                  "=" => :_assign_element
    }

    KEY_REGEXP = /^(.+[^!=])([#{OP_LOOKUPS.keys.join("")}])?$/o

    def name_parts(sym)
      sym.to_s.match(KEY_REGEXP).captures
    end

    def initialize(library, *key_chain)
      @library = library
      @key_chain = key_chain
      @still_possible = true
    end

    def method_missing(name_sym, *args, &block)
      name, op = name_parts(name_sym)
      @key_chain << name.to_sym
      out = self.send(OP_LOOKUPS[op], name, op, args, block)
      return out if out || @nil_result || @still_possible
      super
    end

    def _plain_element(name, op, args, block)
      keys = @library.deep_keys_for(*@key_chain)
      value = @library.fetch(*@key_chain)
      @still_possible = ! keys.empty?

      return value if value && keys.empty?
      return nil if keys.empty?
      return self
    end

    def _bang_element(name, op, args, block)
      out = _plain_element(name, op, args, block)
      @still_possible = true
      if out === self
        return @library.fetch_hash(*@key_chain)
      else
        return out
      end
    end

    def _assign_element(name, op, args, block)
      @library.assign_to(@key_chain, args[0])
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
