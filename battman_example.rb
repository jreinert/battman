require 'battman'

Battman::Battman.new do |battman|

  battman.watch :acpi do |watcher|

    current_state = :discharging # defaulting to discharging

    watcher.every 2.seconds do |status|

      status.check(:state) do |value, last_value|
        current_state = value
        state_changed = value != last_value

        if state_changed
          `notify-send 'Battery is #{current_state}'`
        end
      end

    end

    watcher.every 60.seconds do |status|

      suspend = false

      status.check(:remaining_percent) do |value|

        if current_state == :discharging && value.in?(0...5)
          `i3lock && systemctl suspend` if suspend
          `notify-send -u critical 'Battery level is critical!'`

          if value.in?(0..2)
            `notify-send -u critical 'Suspending in 60 seconds! (plug in cable to abort)'`
            suspend = true
          end
        else
          suspend = false
        end

      end

    end

    watcher.every 5.minutes do |status|

      status.check(:remaining_percent) do |value|
        if current_state == :discharging && value.in?(5...10)
          `notify-send -u normal 'Battery is low'`
        end
      end

    end

  end

  battman.run
end
