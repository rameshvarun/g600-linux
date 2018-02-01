#!/usr/bin/env ruby

require 'device_input'
require 'linux_input'

INPUT_DIR = "/dev/input/by-id/"
DEV_PREFIX = "usb-Logitech_Gaming_Mouse_G600_"
DEV_SUFFIX = "-if01-event-kbd"

device = Dir.entries(INPUT_DIR)
  .select{ |e| e.start_with? DEV_PREFIX }
  .select{ |e| e.end_with? DEV_SUFFIX }.first

File.open(INPUT_DIR + device, 'r') do |dev|
  dev.ioctl(LinuxInput::EVIOCGRAB, 1)
  DeviceInput.read_loop(dev) do |event|
    puts event
    puts "----------------"
  end
end
