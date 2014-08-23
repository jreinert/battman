require 'batman/battery'

module Batman
  class AcpiBattery < Battery

    def initialize(index = 0, precision = 1000)
      super(index)

      @precision = precision
    end
  end
end
