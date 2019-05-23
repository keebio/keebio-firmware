#!/usr/bin/env ruby

class Flasher
  def initialize
    @mcu = 'm32u4'
    @programmer = 'avrispmkii'
    @port = nil
    @extra_params = '-B 2 -v'
  end

  def flash(items)
    cmd = "avrdude -p #{@mcu} -c #{@programmer}"
    if !@port.nil?
      cmd << " -P #{@port}"
    end
    if !@extra_params.nil?
      cmd << " #{@extra_params}"
    end

    items.each do |memtype, filename|
      cmd << " -U #{memtype}:w:#{filename}"
    end
    puts cmd
    %x[#{cmd}]
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
      flash: 'iris-r3/production.hex',
      eeprom: 'iris-r3/dump.eep'
    }
    items = dfu_fuses.merge(files)
    flash(items)
  end

  def view_device_info
    flash({})
  end
end

flasher = Flasher.new()
flasher.view_device_info
