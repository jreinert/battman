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

    [:remaining_percent, :power, :remaining_running_time,
     :remaining_charging_time, :state, :remaining_energy,
     :full_energy].each do |method|

      describe "##{method}" do

        it 'throws an NotImplementedError' do
          expect { battery.send(method) }.to raise_error NotImplementedError
        end
      end
    end


     describe '#power_in' do
       it 'requires a unit argument' do
         expect { battery.power_in }.to raise_error(ArgumentError)
       end

       it 'only accepts units from CONVERSIONS[:power]' do
         expect { battery.power_in(:unsupported_unit) }.to raise_error(UnsupportedUnitError)

         allow(battery).to receive(:power).and_return(10.0)
         battery.power_in(Battery::CONVERSIONS[:power].keys.sample)
       end

       it 'converts the power from watts to the given unit' do
         allow(battery).to receive(:power).and_return(10.0)

         expect(battery.power_in(:watts)).to eq 10.0
         expect(battery.power_in(:milliwatts)).to eq 10_000.0
       end
     end

     [:remaining_running_time, :remaining_charging_time].each do |method|
       describe "#{method}_in" do
         it 'requires a unit argument' do
           expect { battery.send(:"#{method}_in") }.to raise_error(ArgumentError)
         end

         it 'only accepts units from CONVERSIONS[:time]' do
           expect { battery.send(:"#{method}_in", :unsupported_unit) }.to raise_error(UnsupportedUnitError)

           allow(battery).to receive(method).and_return(10.0)
           battery.send(:"#{method}_in", Battery::CONVERSIONS[:time].keys.sample)
         end

         it 'converts the time from seconds to the given unit' do
           allow(battery).to receive(method).and_return(3600.0)

           expect(battery.send(:"#{method}_in", :seconds)).to eq 3600.0
           expect(battery.send(:"#{method}_in", :minutes)).to eq 60.0
           expect(battery.send(:"#{method}_in", :hours)).to eq 1.0
         end
       end
     end

     [:remaining_energy, :full_energy].each do |method|
       describe "#{method}_in" do
         it 'requires a unit argument' do
           expect { battery.send(:"#{method}_in") }.to raise_error(ArgumentError)
         end

         it 'only accepts units from CONVERSIONS[:energy]' do
           expect { battery.send(:"#{method}_in", :unsupported_unit) }.to raise_error(UnsupportedUnitError)

           allow(battery).to receive(method).and_return(10.0)
           battery.send(:"#{method}_in", Battery::CONVERSIONS[:energy].keys.sample)
         end

         it 'converts the time from watt hours to the given unit' do
           allow(battery).to receive(method).and_return(10.0)

           expect(battery.send(:"#{method}_in", :watt_hours)).to eq 10.0
           expect(battery.send(:"#{method}_in", :milliwatt_hours)).to eq 10_000.0
         end
       end
     end
  end
end
