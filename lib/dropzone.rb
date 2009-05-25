#!/usr/bin/ruby

# Wraps the shell functions

class Dropzone
  $VERBOSE = nil

  def initialize()
	# Disable output buffering
	$stdout.sync = true;
  
    # Define methods for each bash function
    f = File.read("dz_functions.sh")
    lines = f.split("\n")
    lines.each do |line| 
      if line =~ /function/
        function = line.split(" ")[1] 
        selfclass.send(:define_method, function) { |x| run_bash_function(function, x) }
      end
    end
  end

  def run_bash_function(command, args)
    output = `/bin/bash -c 'source dz_functions.sh; #{command} "#{args}";'`
	  output.split("\n").each do |line|
		  puts line
		  # Block until acknowledgement
		  line = $stdin.gets
	  end
  end
  
  def selfclass
    (class << self; self; end)
  end
  
end
