require_relative 'config_library/base'
require_relative 'config_library/method_chain'
require_relative 'config_library/null_result'

module ConfigLibrary
  extend self

  ALLOWED_KEY_ENDINGS = "!="
  KEY_REGEXP = /^(.+[^!=])([#{ALLOWED_KEY_ENDINGS}])?$/o

  def name_parts(sym)
    sym.to_s.match(ConfigLibrary::KEY_REGEXP).captures
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
