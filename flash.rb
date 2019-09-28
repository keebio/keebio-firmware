#!/usr/bin/env ruby

class Flasher
  def initialize
    @mcu = 'm32u4'
    set_avrispmkii
    @port = nil
  end

  def set_avrispmkii
    @programmer = 'avrispmkii'
    @extra_params = '-B 2'
  end

  def set_usbasp
    @programmer = 'usbasp'
    @extra_params = '-B 2 -v'
  end

  def flash(items, quiet = false)
    cmd = "avrdude -p #{@mcu} -c #{@programmer}"
    unless @port.nil?
      cmd << " -P #{@port}"
    end
    unless @extra_params.nil?
      cmd << " #{@extra_params}"
    end

    items.each do |memtype, filename|
      cmd << " -U #{memtype}:w:#{filename}"
    end
    if quiet
      cmd << " -l /dev/null"
    else
      puts cmd
    end
    `#{cmd}`
    $?.success?
  end

  def read(items, quiet = false)
    cmd = "avrdude -p #{@mcu} -c #{@programmer}"
    unless @port.nil?
      cmd << " -P #{@port}"
    end
    unless @extra_params.nil?
      cmd << " #{@extra_params}"
    end

    items.each do |memtype, filename|
      cmd << " -U #{memtype}:r:#{filename}:i"
    end
    if quiet
      cmd << " -l /dev/null"
    else
      puts cmd
    end
    `#{cmd}`
    $?.success?
  end

  def dfu_fuses
    { lfuse: '0x5e:m', hfuse: '0xd9:m', efuse: '0xc3:m' }
  end

  def make_avrisp_mkii_clone
    fw_file = 'AVRISP-MKII_ATmega32u4/AVRISP-MKII_ATmega32U4.hex'
    items = dfu_fuses.merge(flash: fw_file)
    flash_file(fw_file)
  end

  def flash_dfu_bootloader
    fw_file = 'BootloaderDFU-LUFA-32u4.hex'
    items = dfu_fuses.merge(flash: fw_file)
    flash(items)
  end

  def flash_iris_r3
    files = {
      flash: "#{__dir__}/iris-r3/keebio_iris_rev3_via_production.hex",
      eeprom: "#{__dir__}/iris-r3/20190603_iris.eep"
    }
    items = dfu_fuses.merge(files)
    flash(items)
  end

  def flash_iris_r3_eeprom
    flash(eeprom: 'iris-r3/20190603_iris.eep')
  end

  def flash_nyquist_r3
    files = {
      flash: "#{__dir__}/nyquist-r3/keebio_nyquist_rev3_default_production.hex",
      eeprom: "#{__dir__}/nyquist-r3/20190816_nyquist.eep"
    }
    items = dfu_fuses.merge(files)
    flash(items)
  end

  def flash_usbasp
    @mcu = 'm8'
    flash_file('usbasp.2011-05-28/bin/firmware/usbasp.atmega8.2011-05-28.hex')
  end

  def view_device_info
    flash({})
  end

  def device_connected?
    flash({}, quiet = true)
  end

  def flash_file(file)
    flash(flash: file)
  end

  def read_eeprom(output_file)
    read(eeprom: output_file)
  end

  def show_searching_message
    print '🔎  Searching for device (press Ctrl-C to stop).'
  end


  def bulk_flash(command, interval = 0.5)
    show_searching_message
    while true do
      success = device_connected?
      if success
        puts
        puts '🆗  Device found, flashing...'
        command.call
        flash_success = $?.success?
        if flash_success
          puts '✅  Device flashed successfully, disconnect'
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

# TODO: Add params to select action

flasher = Flasher.new()
#flasher.set_usbasp
flasher.set_avrispmkii
#flasher.view_device_info
#flasher.make_avrisp_mkii_clone
#flasher.flash_dfu_bootloader
#flasher.flash_file('/Users/danny/syncproj/qmk/keebio_levinson_rev3_bakingpy.hex')
#flasher.flash_iris_r3
#flasher.flash_iris_r3_eeprom
flasher.bulk_flash(flasher.method(:flash_nyquist_r3))
