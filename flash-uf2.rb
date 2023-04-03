#!/usr/bin/env ruby

class Flasher

  def device_connected?
    File.directory?('/Volumes/RPI-RP2')
  end

  def show_searching_message
    print '🔎  Searching for device (press Ctrl-C to stop).'
  end

  def bulk_flash(file, interval = 1)
    show_searching_message
    while true do
      success = device_connected?
      if success
        puts
        puts '🆗  Device found, flashing...'
        `cp #{file} /Volumes/RPI-RP2/`
        flash_success = $?.success?
        if flash_success
          puts '✅  Device flashed - Check LEDs'
        else
          puts '🛑  Device flashing unsuccessful, try again'
        end
        play_status_sound(flash_success)
        sleep 3
        show_searching_message
      else
        print '.'
      end
      sleep interval
    end
  end

  def play_status_sound(success)
    cmd = "afplay"
    if success
      cmd << " /System/Library/Sounds/Glass.aiff"
    else
      cmd << " /System/Library/Sounds/Sosumi.aiff"
    end
    `#{cmd}`
  end

end

flasher = Flasher.new()
flasher.bulk_flash('sinc/keebio_sinc_rev3_via.uf2')
