module Battman
  module DSL
    class EveryBlock

      def initialize(battman, battery, interval)
        @battery = battery
        @interval = interval
        @battman = battman
        @last_values = {}
      end

      def check(attribute, *args, &block)
        raise ArgumentError.new('no block given') unless block_given?

        unless @battery.respond_to?(attribute)
          raise ArgumentError.new("invalid method #{attribute}")
        end

        last_values_hash = (attribute.hash + args.hash).hash

        task = Proc.new do
          value = @battery.send(attribute, *args)
          block.call(value, @last_values[last_values_hash])
          @last_values[last_values_hash] = value
        end

        @battman.register(@interval, task)
      end
    end
  end
end
