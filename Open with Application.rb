#!/usr/bin/ruby

# Dropzone Destination Info
# Name: Open with Application
# Description: Allows you to open dropped files with a selected application.
# Handles: NSFilenamesPboardType
# Creator: Aptonic Software
# URL: http://aptonic.com
# OptionsNIB: ChooseApplication

def dragged
  files = ""
  $items.each { |file| files += "\"#{file}\" "}

  $dz.determinate("0")
  $dz.begin("Launching Application")

  system("open -a \"#{ENV['EXTRA_PATH']}\" #{files}")

  $dz.finish("Application Launched")
  $dz.url("0")
end

def clicked
  system("open \"#{ENV['EXTRA_PATH']}\"")
end