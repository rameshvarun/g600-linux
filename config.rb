def key_released (key, buttons)
  if buttons[:GShift]
    `xdotool key Super_L+w` if key == :G9
  end
end
