#!/usr/bin/env ruby

class Rsync

  def self.do_copy(dz, source_files, destination, remove_sent)
    files = ""
    source_files.each { |file| files += "\"#{file}\" "}
  
    # First we do a dry run to get the number of files to be copied
    stats = `rsync -a --stats --dry-run #{files} \"#{destination}\"`
    num_files = stats.split("\n")[2].split(" ")[4]
    each_file_weight = (100 / (num_files.to_f)) / 100

    overall_percent = 0
    last_output = 0

    # Now run the actual transfer and output the progress perecent
    remove_sent_option = (remove_sent ? "--remove-sent-files" : "")
    rsync = IO.popen("rsync #{remove_sent_option} -a --progress --out-format \"\" #{files} \"#{destination}\" 2>&1 | tr -u \"\r\" \"\n\"") do |f|
      while line = f.gets do
        if line =~ /%/
          line_split = line.split(" ")
          file_percent = line_split[1][0..-2]
          output = ((file_percent.to_f + overall_percent) / num_files.to_f).to_i
          dz.percent(output) if last_output != output
          last_output = output
          overall_percent += file_percent.to_f if line =~ /xfer/
        end
      end
    end
  end

end
