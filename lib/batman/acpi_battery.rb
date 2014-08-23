require 'batman/battery'

module Batman
  class AcpiBattery < Battery

    def initialize(index = 0, precision = 1000)
      super(index)

      @precision = precision
    end

    def path
      @path ||= "/sys/class/power_supply/BAT#{@index}"
    end

    def remaining_percent
      energy_full_file = File.join(@path, 'energy_full')
      energy_now_file = File.join(@path, 'energy_now')

      energy_full = File.read(energy_full_file)
      energy_now = File.read(energy_now_file)

      (energy_now.to_f / energy_full.to_f) * 100
    end

    def power
      power_now_file = File.join(@path, 'power_now')

      power = File.read(power_now_file).to_f / (1000 * @precision)

      state == :discharging ? -1 * power : power
    end
  end
end
