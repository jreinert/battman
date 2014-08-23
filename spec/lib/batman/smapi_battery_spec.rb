require 'batman/smapi_battery'

module Batman

  describe SmapiBattery do

    it 'is a subclass of Battery' do
      expect(SmapiBattery.new).to be_a Battery
    end

    describe '#path' do

      let(:path_prefix) { '/sys/devices/platform/smapi' }

      it 'builds the path for a smapi battery with the correct index' do
        battery = SmapiBattery.new

        expect(battery.path).to eq File.join(path_prefix, 'BAT0')

        battery = SmapiBattery.new(1)

        expect(battery.path).to eq File.join(path_prefix, 'BAT1')
      end

      it 'sets the corresponding instance variable' do
        battery = SmapiBattery.new
        path = battery.path

        expect(battery.instance_variable_get(:@path)).to eq path
      end
    end

    let(:battery) { SmapiBattery.new }

    before(:each) do
      allow(File).to receive(:join).and_call_original
    end

    describe '#remaining_percent' do

      let(:percent_file) { File.join(battery.path, 'remaining_percent') }

      before(:each) do
        allow(File).to receive(:read).with(percent_file).and_return("100\n")
      end

      it 'reads the value from the correct file' do
        battery.remaining_percent

        expect(File).to have_received(:read).with(percent_file)
      end

      it 'returns the integer value of the read file contents' do
        expect(battery.remaining_percent).to eq 100
      end

    end

    describe '#remaining_running_time' do
      let(:running_time_file) { File.join(battery.path, 'remaining_running_time') }

      it 'reads the value from the correct file' do
        allow(File).to receive(:read).with(running_time_file).and_return("100\n")
        battery.remaining_running_time

        expect(File).to have_received(:read).with(running_time_file)
      end

      it 'returns the number of seconds remaining' do
        allow(File).to receive(:read).with(running_time_file).and_return("100\n")

        expect(battery.remaining_running_time).to eq 6000
      end

      it 'raises a WrongStateError if the battery is not discharging' do
        allow(File).to receive(:read).with(running_time_file).and_return("not_discharging\n")

        expect { battery.remaining_running_time }.to raise_error(WrongStateError)
      end

    end

    describe '#remaining_charging_time' do
      let(:charging_time_file) { File.join(battery.path, 'remaining_charging_time') }

      it 'reads the value from the correct file' do
        allow(File).to receive(:read).with(charging_time_file).and_return("100\n")
        battery.remaining_charging_time

        expect(File).to have_received(:read).with(charging_time_file)
      end

      it 'returns the number of seconds remaining' do
        allow(File).to receive(:read).with(charging_time_file).and_return("100\n")

        expect(battery.remaining_charging_time).to eq 6000
      end

      it 'raises a WrongStateError if the battery is not charging' do
        allow(File).to receive(:read).with(charging_time_file).and_return("not_charging\n")

        expect { battery.remaining_charging_time }.to raise_error(WrongStateError)
      end
    end

    describe '#power' do
      let(:power_file) { File.join(battery.path, 'power_avg') }

      it 'reads the value from the correct file' do
        allow(File).to receive(:read).with(power_file).and_return("1000\n")
        battery.power

        expect(File).to have_received(:read).with(power_file)
      end

      it 'returns the power used in watt' do
        allow(File).to receive(:read).with(power_file).and_return("-1000\n")

        expect(battery.power).to eq(-1.0)
      end

    end

    describe "#state" do
      let(:state_file) { File.join(battery.path, 'state') }

      it 'reads the state from the correct file' do
        allow(File).to receive(:read).with(state_file).and_return("discharging\n")
        battery.state

        expect(File).to have_received(:read).with(state_file)
      end

      it 'returns the correct state as a symbol' do
        allow(File).to receive(:read).with(state_file).and_return("discharging\n")

        expect(battery.state).to eq :discharging
      end
    end

    describe "#remaining_energy" do
      let(:energy_file) { File.join(battery.path, 'remaining_capacity') }

      it 'reads the value from the correct file' do
        allow(File).to receive(:read).with(energy_file).and_return("100000\n")
        battery.remaining_energy

        expect(File).to have_received(:read).with(energy_file)
      end

      it 'returns the remaining energy in Wh' do
        allow(File).to receive(:read).with(energy_file).and_return("100000\n")
        expect(battery.remaining_energy).to eq 100.0
      end
    end
  end
end
