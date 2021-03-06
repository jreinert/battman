require 'battman/battery'

module Battman
  class SmapiBattery < Battery

    def path
      @path ||= "/sys/devices/platform/smapi/BAT#{@index}"
    end

    def remaining_percent
      percent_file = File.join(path, 'remaining_percent')

      File.read(percent_file).to_i
    end

    def remaining_running_time
      running_time_file = File.join(path, 'remaining_running_time')

      file_content = File.read(running_time_file)

      raise WrongStateError if file_content == "not_discharging\n"
      file_content.to_i * 60
    end

    def remaining_charging_time
      charging_time_file = File.join(path, 'remaining_charging_time')

      file_content = File.read(charging_time_file)

      raise WrongStateError if file_content == "not_charging\n"
      file_content.to_i * 60
    end

    def power
      power_file = File.join(path, 'power_avg')

      File.read(power_file).to_f / 1000
    end

    def state
      state_file = File.join(path, 'state')

      File.read(state_file).chomp.to_sym
    end

    def remaining_energy
      energy_file = File.join(path, 'remaining_capacity')

      File.read(energy_file).to_f / 1000
    end

    def full_energy
      energy_file = File.join(path, 'last_full_capacity')

      File.read(energy_file).to_f / 1000
    end

  end
end
