#!/usr/bin/env ruby

require 'device_input'
require 'linux_input'

INPUT_DIR = "/dev/input/by-id/"
DEV_PREFIX = "usb-Logitech_Gaming_Mouse_G600_"
DEV_SUFFIX = "-if01-event-kbd"

device = Dir.entries(INPUT_DIR)
  .select{ |e| e.start_with? DEV_PREFIX }
  .select{ |e| e.end_with? DEV_SUFFIX }.first

def parse_bits (value)
  return value.to_s(2).rjust(8, '0').split(//).map {|n| n == "1"}
end

unk_3_41 = parse_bits 0
unk_3_42 = parse_bits 0
misc = parse_bits 0

def button_hash(unk_3_41, unk_3_42, misc)
  buttons = Hash.new()

  buttons[:G9] = unk_3_41[7]
  buttons[:G10] = unk_3_41[6]
  buttons[:G11] = unk_3_41[5]

  buttons[:G12] = unk_3_41[4]
  buttons[:G13] = unk_3_41[3]
  buttons[:G14] = unk_3_41[2]

  buttons[:G15] = unk_3_41[1]
  buttons[:G16] = unk_3_41[0]

  buttons[:G17] = unk_3_42[7]
  buttons[:G18] = unk_3_42[6]
  buttons[:G19] = unk_3_42[5]
  buttons[:G20] = unk_3_42[4]

  buttons[:G7] = misc[1]
  buttons[:G8] = misc[0]

  buttons[:Back] = misc[4]
  buttons[:Forward] = misc[3]

  buttons[:GShift] = misc[2]

  buttons[:LeftClick] = misc[7]
  buttons[:RightClick] = misc[6]
  buttons[:MiddleClick] = misc[5]

  return buttons
end

buttons = button_hash unk_3_41, unk_3_42, misc

load "./config.rb"

File.open(INPUT_DIR + device, 'r') do |dev|
  dev.ioctl(LinuxInput::EVIOCGRAB, 1)
  DeviceInput.read_loop(dev) do |event|

    if event.type == "EV_ABS"
      if event.code == "UNK-3-41"
        unk_3_41 = parse_bits event.value
      elsif event.code == "UNK-3-42"
        unk_3_42 = parse_bits event.value
      elsif event.code == "Misc"
        misc = parse_bits event.value
      else
        puts "Unknown code #{event.code}"
      end
      new_buttons = button_hash unk_3_41, unk_3_42, misc
      new_buttons.each do |button, pressed|
        key_released button, new_buttons if !new_buttons[button] && buttons[button]
      end
      buttons = new_buttons
    end

  end
end
