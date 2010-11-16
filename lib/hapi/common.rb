class Hapi::Common # parent class of others.
  extend Hapi::Mixin

  def inspect
    self.class.to_s
  end
end
