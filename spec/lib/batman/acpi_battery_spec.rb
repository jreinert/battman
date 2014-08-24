require 'batman/acpi_battery'

module Batman

  describe AcpiBattery do
    it 'is a subclass of Battery' do
      expect(AcpiBattery.new).to be_a Battery
    end

    describe '.new' do
      it 'accepts an precision option and sets the corresponding instance variable' do
        battery = AcpiBattery.new(0, precision: 100)

        expect(battery.instance_variable_get(:@precision)).to eq 100
      end

      it 'sets precision to 1000 by default' do
        expect(AcpiBattery.new.instance_variable_get(:@precision)).to eq 1000
      end
    end

    describe '#path' do

      let(:path_prefix) { '/sys/class/power_supply' }

      it 'builds the path for a smapi battery with the correct index' do
        battery = AcpiBattery.new

        expect(battery.path).to eq File.join(path_prefix, 'BAT0')

        battery = AcpiBattery.new(1)

        expect(battery.path).to eq File.join(path_prefix, 'BAT1')
      end

      it 'sets the corresponding instance variable' do
        battery = AcpiBattery.new
        path = battery.path

        expect(battery.instance_variable_get(:@path)).to eq path
      end
    end

    let(:battery) { AcpiBattery.new }

    before(:each) do
      allow(File).to receive(:join).and_call_original
    end

    describe '#remaining_percent' do

      let(:energy_full_file) { File.join(battery.path, 'energy_full') }
      let(:energy_now_file) { File.join(battery.path, 'energy_now') }

      before(:each) do
        allow(File).to receive(:read).with(energy_full_file).and_return("1000\n")
        allow(File).to receive(:read).with(energy_now_file).and_return("100\n")
      end

      it 'reads the value from the correct files' do
        battery.remaining_percent

        expect(File).to have_received(:read).with(energy_full_file)
        expect(File).to have_received(:read).with(energy_now_file)
      end

      it 'calculates the percentage from the read file contents' do
        expect(battery.remaining_percent).to eq 10
      end

    end

    describe '#power' do

      let(:power_file) { File.join(battery.path, 'power_now') }

      it 'reads the value from the correct file' do
        allow(File).to receive(:read).with(power_file).and_return("1000000\n")
        allow(battery).to receive(:state).and_return(:charging)
        battery.power

        expect(File).to have_received(:read).with(power_file)
      end

      it 'returns the power used in watt' do
        allow(File).to receive(:read).with(power_file).and_return("1000000\n")
        allow(battery).to receive(:state).and_return(:charging)

        expect(battery.power).to eq(1.0)
      end

      it 'returns a negative value if state is :discharging' do
        allow(File).to receive(:read).with(power_file).and_return("1000000\n")
        allow(battery).to receive(:state).and_return(:discharging)

        expect(battery.power).to be < 0
      end

      it 'returns a positive value if state is either :charging or :idle' do
        allow(File).to receive(:read).with(power_file).and_return("1000000\n")
        allow(battery).to receive(:state).and_return(:charging)

        expect(battery.power).to be >= 0

        allow(battery).to receive(:state).and_return(:idle)

        expect(battery.power).to be >= 0
      end

    end

    describe "#state" do
      let(:state_file) { File.join(battery.path, 'status') }

      it 'reads the state from the correct file' do
        allow(File).to receive(:read).with(state_file).and_return("Discharging\n")
        battery.state

        expect(File).to have_received(:read).with(state_file)
      end

      it 'returns the correct state as a symbol' do
        allow(File).to receive(:read).with(state_file).and_return("Discharging\n")

        expect(battery.state).to eq :discharging
      end

      it 'returns :idle if state read from file is Unknown' do
        allow(File).to receive(:read).with(state_file).and_return("Unknown\n")

        expect(battery.state).to eq :idle
      end
    end

    describe "#remaining_energy" do
      let(:energy_file) { File.join(battery.path, 'energy_now') }

      it 'reads the value from the correct file' do
        allow(File).to receive(:read).with(energy_file).and_return("100000000\n")
        battery.remaining_energy

        expect(File).to have_received(:read).with(energy_file)
      end

      it 'returns the remaining energy in Wh' do
        allow(File).to receive(:read).with(energy_file).and_return("100000000\n")

        expect(battery.remaining_energy).to eq 100.0
      end
    end

    describe '#remaining_running_time' do
      it 'calculates the value from the current power and remaining energy' do
        allow(battery).to receive(:state).and_return(:discharging)
        allow(battery).to receive(:power).and_return(10.0)
        allow(battery).to receive(:remaining_energy).and_return(100.0)
        battery.remaining_running_time

        expect(battery).to have_received(:power)
        expect(battery).to have_received(:remaining_energy)

        expect(battery.remaining_running_time).to eq 600
      end

      it 'raises a WrongStateError if the battery is not discharging' do
        allow(battery).to receive(:power).and_return(10.0)
        allow(battery).to receive(:remaining_energy).and_return(100.0)

        allow(battery).to receive(:state).and_return(:discharging)
        battery.remaining_running_time

        allow(battery).to receive(:state).and_return(:idle)

        expect { battery.remaining_running_time }.to raise_error(WrongStateError)

        allow(battery).to receive(:state).and_return(:charging)

        expect { battery.remaining_running_time }.to raise_error(WrongStateError)
      end

    end

    describe "#full_energy" do
      let(:energy_file) { File.join(battery.path, 'energy_full') }

      it 'reads the value from the correct file' do
        allow(File).to receive(:read).with(energy_file).and_return("100000000\n")
        battery.full_energy

        expect(File).to have_received(:read).with(energy_file)
      end

      it 'returns the remaining energy in Wh' do
        allow(File).to receive(:read).with(energy_file).and_return("100000000\n")

        expect(battery.full_energy).to eq 100.0
      end
    end

    describe '#remaining_charging_time' do
      it 'calculates the value from the current power and remaining energy' do
        allow(battery).to receive(:state).and_return(:charging)
        allow(battery).to receive(:power).and_return(10.0)
        allow(battery).to receive(:remaining_energy).and_return(90.0)
        allow(battery).to receive(:full_energy).and_return(100.0)
        battery.remaining_charging_time

        expect(battery).to have_received(:power)
        expect(battery).to have_received(:remaining_energy)

        expect(battery.remaining_charging_time).to eq 60.0
      end

      it 'raises a WrongStateError if the battery is not charging' do
        allow(battery).to receive(:remaining_energy).and_return(90.0)
        allow(battery).to receive(:power).and_return(10.0)
        allow(battery).to receive(:full_energy).and_return(100.0)

        allow(battery).to receive(:state).and_return(:charging)
        battery.remaining_charging_time

        allow(battery).to receive(:state).and_return(:discharging)

        expect { battery.remaining_charging_time }.to raise_error(WrongStateError)

        allow(battery).to receive(:state).and_return(:idle)

        expect { battery.remaining_charging_time }.to raise_error(WrongStateError)
      end
    end
  end
end
