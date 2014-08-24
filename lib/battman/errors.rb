module Battman
  class AbstractError < RuntimeError; end
  class NotImplementedError < RuntimeError; end
  class WrongStateError < RuntimeError; end

  class UnsupportedUnitError < ArgumentError
    def initialize(unit)
      super("unit #{unit} is not supported")
    end
  end

end
