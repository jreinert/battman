require 'battman/dsl/watch_block'

module Battman
  module DSL
    describe WatchBlock do
      let(:dsl) { double('DSL') }
      let(:battery) { double('Battery') }
      let(:watcher) { WatchBlock.new(dsl, battery) }

      describe '#every' do
        it 'expects an interval in seconds and a block' do
          expect { watcher.every }.to raise_error(ArgumentError)
          expect { watcher.every(10) }.to raise_error(ArgumentError)

          watcher.every(10) {}
        end

        it 'yields an object that responds to check' do
          expect {|b| watcher.every(10, &b) }.to yield_with_args do |arg|
            expect(arg).to respond_to(:check)
          end
        end
      end

    end
  end
end
