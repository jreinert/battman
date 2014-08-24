require 'battman/dsl/every_block'

module Battman
  module DSL
    describe EveryBlock do

      describe '#check' do

        let(:dsl) { double('DSL') }
        let(:battery) { double('Battery') }
        let(:state) { EveryBlock.new(dsl, battery, 10) }

        before(:each) do
          allow(battery).to receive(:power_in).with(:milliwatts)
          allow(battery).to receive(:remaining_percent)
          allow(dsl).to receive(:register)
        end

        it 'expects a battery attribute and a block' do
          expect { state.check }.to raise_error(ArgumentError)
          expect { state.check(:remaining_percent) }.to raise_error(ArgumentError)
          state.check(:remaining_percent) {}
        end

        it 'allows additional arguments to pass methods' do
          state.check(:power_in, :milliwatts) {}
        end

        it 'correctly registers a block on the dsl instance' do
          task_was_called = false
          value_passed = nil
          last_value_passed = nil
          task = Proc.new do |value, last_value|
            task_was_called = true
            value_passed = value
            last_value_passed = last_value
          end

          expect(dsl).to receive(:register) do |interval, block|
            expect(interval).to eq 10

            expect(battery).to receive(:power_in).with(:milliwatts).and_return(10_000.0)
            block.call

            expect(task_was_called)
            expect(value_passed).to eq 10_000.0
            expect(last_value_passed).to be nil

            expect(battery).to receive(:power_in).with(:milliwatts).and_return(9_000.0)
            block.call

            expect(value_passed).to eq 9_000.0
            expect(last_value_passed).to eq 10_000.0
          end

          state.check(:power_in, :milliwatts, &task)
        end

      end
    end
  end
end
