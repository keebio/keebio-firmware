## Creation of these files

- QMK hex files: `make keebio/nyquist/rev3:default:production`
- EEPROM
    - Setup:
        - Set RGB to rainbow mode
        - Set LED backlight to max value
    - Read EEPROM to file `avrdude -p m32u4 -c avrispmkii -B 2 -v -U eeprom:r:nyquist-r3/20190603_nyquist.eep:i`