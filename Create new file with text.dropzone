#!/usr/bin/ruby

# Dropzone Destination Info
# Name: Create new file with text
# Description: Creates a new text file in a specified folder with the dropped text and opens it with your default text editor.
# Handles: NSStringPboardType
# Creator: Aptonic Software
# URL: http://aptonic.com
# IconURL: http://aptonic.com/destinations/icons/text.png
# OptionsNIB: ChooseFolder

def dragged
  destination = "#{ENV['EXTRA_PATH']}"

  $dz.determinate("0")
  $dz.begin("Creating new text file...")

  output = `../CocoaDialog standard-inputbox --title "New Text File" --e --informative-text "Enter name for new text file (minus extension):"`
  filename = output.split("\n")[1]

  # Create a new file and write to it   
  File.open("#{destination}/#{filename}.txt", 'w') do |f|   
    f.puts $items[0]
  end

  system("open \"#{destination}/#{filename}.txt\"")

  $dz.finish("Text Editor Launched")
  $dz.url("0")
end

def clicked
  system("open \"#{ENV['EXTRA_PATH']}\"")
end