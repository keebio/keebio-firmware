#!/usr/bin/env ruby

class Flasher
  def initialize
    @mcu = 'm32u4'
    set_usbasp
    @port = nil
  end

  def set_avrispmkii
    @programmer = 'avrispmkii'
    @extra_params = '-B 2 -v'
  end

  def set_usbasp
    @programmer = 'usbasp'
    @extra_params = '-v'
  end

  def flash(items)
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
    puts cmd
    `#{cmd}`
  end

  def dfu_fuses
    { lfuse: '0x5e:m', hfuse: '0xd9:m', efuse: '0xc3:m' }
  end

  def make_avrisp_mkii_clone
    fw_file = 'AVRISP-MKII_ATmega32u4/AVRISP-MKII_ATmega32U4.hex'
    items = dfu_fuses.merge(flash: fw_file)
    flash(items)
  end

  def flash_dfu_bootloader
    fw_file = 'BootloaderDFU-LUFA-32u4.hex'
    items = dfu_fuses.merge(flash: fw_file)
    flash(items)
  end

  def flash_iris_r3
    files = {
      flash: 'iris-r3/dump.hex',
      eeprom: 'iris-r3/dump.eep'
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

  def flash_file(file)
    flash(flash: file)
  end
end

# TODO: Add params to select action

flasher = Flasher.new()
#flasher.set_avrispmkii
flasher.view_device_info
#flasher.flash_dfu_bootloader
flasher.make_avrisp_mkii_clone
#flasher.flash_file('/Users/danny/syncproj/qmk/keebio_levinson_rev3_bakingpy.hex')
#flasher.flash_iris_r3
