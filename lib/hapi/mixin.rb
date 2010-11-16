##
# attr_accessor_from_config :method_name, "search_path"[, type]
# attr_reader_from_config :method_name, "search_path"[, type]
# attr_writer_from_config :method_name, "search_path"[, type]

##
# extend Hapi::Mixin to include class level methods

module Hapi::Mixin
  def attr_reader_from_config method_name, search_path, type = :default
    method_name = case type
    when :bool then
      "#{method_name}?".to_sym
    else
      method_name
    end

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
        warn "#{search_path} was not found in config."
      end
    end
  end

  def attr_writer_from_config method_name, search_path, type = :default
    define_method "#{method_name}=".to_sym do |arg|
      config.at(search_path).content = arg
    end
  end

  def attr_post_from_config method_name, search_path, type = :default
    attr_reader_from_config method_name, search_path, type unless self.respond_to? method_name
    define_method "#{method_name}!".to_sym do |arg|
      # complains if arg isn't given..
      config.at(search_path).content = arg if arg
      post_config!
      self.send(method_name)
    end
  end

  def attr_accessor_from_config *args
    attr_reader_from_config *args
    attr_writer_from_config *args
    attr_post_from_config *args
  end
end
