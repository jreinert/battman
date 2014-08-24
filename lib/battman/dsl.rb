require 'active_support/core_ext/string/inflections'
require 'battman/dsl/watch_block'

module Battman
  module DSL
    Thread.abort_on_exception = true

    def initialize
      @blocks = Hash.new {|hash, key| hash[key] = []}
      @intervals_due = Hash.new {|hash, key| hash[key] = 0}

      yield self if block_given?
    end

    def register(interval, block)
      @blocks[interval.to_i] << block
      @greatest_common_interval = @blocks.keys.inject(&:gcd)
    end

    def watch(type, index = 0, **opts)
      raise ArgumentError.new('no block given') unless block_given?

      require "battman/#{type}_battery"
      battery_class = ("Battman::" + "#{type}_battery".camelize).constantize

      yield WatchBlock.new(self, battery_class.new(index, **opts))
    end

    def run_once
      @blocks.each do |interval, blocks|
        if @intervals_due[interval] <= @greatest_common_interval
          blocks.map(&:call)
          @intervals_due[interval] = interval
        else
          @intervals_due[interval] -= @greatest_common_interval
        end
      end
    end

    def run
      loop do
        run_once
        sleep @greatest_common_interval
      end
    end

  end
end
