require 'batman/acpi_battery'

module Batman

  describe AcpiBattery do
    it 'is a subclass of Battery' do
      expect(AcpiBattery.new).to be_a Battery
    end

    describe '.new' do
      it 'accepts an optional precision parameter and sets the corresponding instance variable' do
        battery = AcpiBattery.new(0, 100)

        expect(battery.instance_variable_get(:@precision)).to eq 100
      end

      it 'sets precision to 1000 by default' do
        expect(AcpiBattery.new.instance_variable_get(:@precision)).to eq 1000
      end
    end
  end
end
