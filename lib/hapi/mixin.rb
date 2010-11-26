#--
##
# attr_accessor_from_config :method_name, "search_path"[, type]
# attr_reader_from_config :method_name, "search_path"[, type]
# attr_writer_from_config :method_name, "search_path"[, type]
#++

class Hapi
  ##
  # extend Hapi::Mixin to include DLS style methods
  module Mixin
    ##
    # Description
    #   Similar to attr_reader but takes additional parameters
    #   :bool type addes a method_name? alias
    #   Also note that these methods will be undocumented
    #
    # Examples:
    #   class MyObj
    #     attr_reader_from_config :disabled, "//project//disabled", :bool
    #   end
    #
    #   MyObj.new.disabled? # => true
    #
    # Parameters:
    #
    # +method_name+::   attr_reader method name
    # +search_path+::   Nokogiri.at search path
    # +type+::          :default # => regular reader method
    #                   :bool    # => creates a boolean reader method. useful
    #                   when the config returns string "true" but True class is
    #                   desirable
    def attr_reader_from_config method_name, search_path, type = :default
      define_method method_name do
        el = config.at(search_path)
        if el
          case type
          when :bool then
            /true/i === el.content
          else
            el.content
          end
        else
          warn "`#{search_path}' was not found in config."
        end
      end
      # use alias_method instead of explicitely defining the method so I can
      # call the method_name without the ? in internal methods.
      alias_method "#{method_name}?".to_sym, method_name if :bool === type
    end

    ##
    # Description:
    #   see attr_reader_from_config
    #   update config node
    def attr_writer_from_config method_name, search_path, type = :default
      define_method "#{method_name}=".to_sym do |arg|
        config.at(search_path).content = arg
        set_dirty_flag
        arg
      end
    end

    ##
    # Description:
    #   see attr_reader_from_config
    #   (optionally) update config node and immediately post back the config
    #   `!' is added to end of method_name to signify post call
    def attr_post_from_config method_name, search_path, type = :default
      attr_reader_from_config method_name, search_path, type unless self.respond_to? method_name
      define_method "#{method_name}!".to_sym do |arg|
        # complains if arg isn't given..
        send("#{method_name}=", arg) if arg
        post_config!
        self.send(method_name)
      end
    end

    ##
    # combines attr_(reader|writer|post)_from_config
    def attr_accessor_from_config *args
      attr_reader_from_config *args
      attr_writer_from_config *args
      attr_post_from_config *args
    end
  end
end
