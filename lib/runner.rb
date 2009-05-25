#!/usr/bin/ruby

# Dropzone calls this first
# Executes either a ruby or bash destination script
# and calls the dragged or clicked function

require 'dropzone'
require 'rsync'
require 'pastie_api'

$dz = Dropzone.new
script = ARGV[0]

if (script =~ /(.*)\.rb/)
  action = ARGV[1]
  $items = ARGV[2..-1]
  
  load script
  if action == "clicked"
    method("clicked").call
  else
    method("dragged").call
  end

elsif (script == /(.*)\.sh/)
  # TODO: Handle bash script
  
else
  puts "FILENAME ERROR"
end