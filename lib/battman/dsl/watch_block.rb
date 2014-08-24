require 'battman/dsl/every_block'

module Battman
  module DSL
    class WatchBlock

      def initialize(battman, battery)
        @battman = battman
        @battery = battery
      end

      def every(interval)
        raise ArgumentError.new('no block given') unless block_given?

        yield EveryBlock.new(@battman, @battery, interval)
      end

    end
  end
end
