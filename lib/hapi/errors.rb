class Hapi
  class ArgumentError < ::ArgumentError
    def << (msg)
      self.message << "\n" + msg
    end
  end
end
