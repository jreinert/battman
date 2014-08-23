require 'batman/battery'
module Batman
  describe Battery do

    describe '.new' do

      it 'throws an AbstractError if directly instantiated' do
        expect { Battery.new }.to raise_error AbstractError
      end

      let(:subclass) { Class.new(Battery) }

      it 'allows instantiation of subclasses' do
        subclass.new
      end

      it 'accepts an index and sets the corresponding instance variable' do
        battery = subclass.new(1)

        expect(battery.instance_variable_get(:@index)).to eq 1
      end

      it 'sets index to 0 by default' do
        battery = subclass.new

        expect(battery.instance_variable_get(:@index)).to eq 0
      end

    end

    let(:battery) { Class.new(Battery).new }

    [:remaining_percent, :power, :remaining_running_time, :remaining_charging_time].each do |method|

      describe "##{method}" do

        it 'throws an NotImplementedError' do
          expect { battery.send(method) }.to raise_error NotImplementedError
        end
      end
    end
  end
end
