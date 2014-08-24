require 'battman/dsl'
require 'battman/smapi_battery'
require 'active_support/core_ext/numeric/time'

module Battman
  describe DSL do

    let(:dsl) { Class.new { include DSL }.new }

    describe '.new' do
      it 'initializes @blocks correctly' do
        blocks = dsl.instance_variable_get(:@blocks)
        expect(blocks).not_to be nil
        expect(blocks[2]).to eq []

        blocks[4] << :foo
        blocks[4] << :bar
        expect(blocks[4]).to eq [:foo, :bar]
      end

      it 'initializes @intervals_due correctly' do
        intervals_due = dsl.instance_variable_get(:@intervals_due)

        expect(intervals_due[1]).to eq 0
        expect(intervals_due[:anything]).to eq 0
      end

      it 'yields self if given a block' do
        expect {|b| Class.new { include DSL }.new(&b) }.to yield_with_args(DSL)
      end
    end

    describe '#watch' do

      it 'instantiates a battery of given type' do
        expect(SmapiBattery).to receive(:new)

        dsl.watch(:smapi) {}
      end

      it 'expects a valid type and a block' do
        expect { dsl.watch }.to raise_error(ArgumentError)
        expect { dsl.watch(:type) }.to raise_error(ArgumentError)
        expect { dsl.watch(:invalid_type) {} }.to raise_error(LoadError)

        dsl.watch(:smapi) {}
      end

      it 'yields a WatchBlock' do
        expect {|b| dsl.watch(:smapi, &b) }.to yield_with_args(DSL::WatchBlock)
      end

    end

    describe '#register' do

      it 'adds a given block to the blocks hash' do
        first_block = Proc.new {}
        second_block = Proc.new {}
        dsl.register(1, first_block)
        dsl.register(1, second_block)

        expect(dsl.instance_variable_get(:@blocks)[1]).to eq [first_block, second_block]
      end

      it 'sets the greatest common interval correctly' do
        dsl.register(4, Proc.new {})
        expect(dsl.instance_variable_get(:@greatest_common_interval)).to eq 4

        dsl.register(8, Proc.new {})
        expect(dsl.instance_variable_get(:@greatest_common_interval)).to eq 4

        dsl.register(10, Proc.new {})
        expect(dsl.instance_variable_get(:@greatest_common_interval)).to eq 2
      end

    end

    describe '#run_once' do
      let(:blocks) do
        blocks = Hash.new {|hash, key| hash[key] = []}
        3.times do |i|
          block = double('proc')
          allow(block).to receive(:call)
          blocks[2**(i+1)] << block
        end

        blocks
      end

      let(:greatest_common_interval) { blocks.keys.inject(:gcd) }

      before(:each) do
        dsl.instance_variable_set(:@blocks, blocks)
        dsl.instance_variable_set(:@greatest_common_interval, greatest_common_interval)
      end

      it 'calls all registered blocks on the first run' do
        blocks.values.inject(&:+).each do |block|
          expect(block).to receive(:call).once
        end

        dsl.run_once
      end

      it 'sets the correct schedules for blocks in @intervals_due' do
        expected_schedule = {}
        blocks.keys.each do |interval|
          expected_schedule[interval] = interval
        end

        dsl.run_once
        expect(dsl.instance_variable_get(:@intervals_due)).to eq expected_schedule
      end

      it 'calls only scheduled blocks on consecutive runs' do
        dsl.run_once
        dsl.run_once

        blocks[greatest_common_interval].each do |block|
          expect(block).to have_received(:call).twice
        end

        dsl.run_once

        blocks[greatest_common_interval].each do |block|
          expect(block).to have_received(:call).exactly(3).times
        end

        blocks[greatest_common_interval * 2].each do |block|
          expect(block).to have_received(:call).twice
        end
      end
    end

  end
end
