require 'batman/dsl/every_block'

module Batman
  module DSL
    class WatchBlock

      def initialize(batman, battery)
        @batman = batman
        @battery = battery
      end

      def every(interval)
        raise ArgumentError.new('no block given') unless block_given?

        yield EveryBlock.new(@batman, @battery, interval)
      end

    end
  end
end
