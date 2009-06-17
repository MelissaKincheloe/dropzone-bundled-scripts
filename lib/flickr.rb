#!/usr/bin/env ruby

# Wraps FlickrUploader

$FLICKR_UPLOADER_PATH = "FlickrUploader.app/Contents/MacOS/FlickrUploader"
$ERROR_TITLE = "Flickr Authorization Error"

class Flickr
  
  def self.authorize(fresh_auth = '0')
    auth_result = `#{$FLICKR_UPLOADER_PATH} authenticate #{fresh_auth} 2>&1`
    puts self.verify_output(auth_result, "FrobID")
  end
  
  def self.get_token(frob_id)
    get_token_result = `#{$FLICKR_UPLOADER_PATH} gettoken #{frob_id} 2>&1`
    puts self.verify_output(get_token_result, "Token")
  end
  
  def self.verify_output(result, expected)
    parts = result.split(": ")
    
    if parts[0] == expected
      return result
    elsif parts[0] == "Error"
      $dz.error($ERROR_TITLE, parts[1])
    else
      $dz.error($ERROR_TITLE, "Unexpected output received from FlickrUploader.")
    end
  end
  
  def self.do_upload(source_files, auth_token, direct_url)
    $dz.determinate(true)
    files = []

    source_files.each do |path|
      files.concat(path_contents(path))
    end
    
    if files.length == 0
      $dz.finish("No Images Found")
      $dz.url(false)
      Process.exit
    end
    
    overall_percent = 0
    last_percent = 0
    upto_file = 0
    last_file = false
    
    urls = []
    ids = []
    
    files.each do |localfile|
      is_processing = false
      filename = localfile.split(File::SEPARATOR)[-1]
      $dz.begin("Uploading #{filename}...")
      escaped_localfile = localfile.gsub('"', '\"')
      escaped_localfile.gsub!('$', '\$')
      direct_url_arg = (direct_url ? "1" : "0")
      
      flickr = IO.popen("#{$FLICKR_UPLOADER_PATH} upload #{auth_token} \"#{escaped_localfile}\" #{direct_url_arg} 2>&1") do |f|
        while line = f.gets do
          command, message = line.split(": ")
          
          case command
          when "Progress"
            file_percent = message
          when "Uploaded_ID"
            ids << message.chomp
          when "PhotoURL"
            urls << message
          when "Error"
            $dz.error("Flickr Upload Error", message)
          end
          
          last_file = true if upto_file == files.length - 1
          
          if command =~ /(Processing image)/
            is_processing = true
            file_percent = 100
            if last_file
              $dz.percent(100)
              $dz.determinate(false) 
            end
            
            if files.length == 1
              $dz.begin("Processing image...")
            else 
              $dz.begin("Processing #{filename}...")
            end
          end
          
          if not (is_processing and last_file)
            output = ((file_percent.to_f + (upto_file * 100)) / files.length.to_f).to_i
            $dz.percent(output) if output != last_percent
            last_percent = output
          end

        end
      end
      upto_file += 1
    end
    
    return [urls, ids]
  end
  
  def self.path_contents(localfile)
    allowed_exts = ["jpg", "jpeg", "gif", "tif", "tiff", "png", "bmp"]

    files = []
    filestat = File.stat(localfile)

    # Check if this is a file or directory
    if filestat.directory? then
      # Recurse through dir
      Dir.foreach localfile do |file|
        next if file == '.' or file == '..'
        local = (localfile + '/' + file).gsub('//', '/')
        begin
          p = path_contents(local)
        rescue
          next
        end
        files.concat(p)
      end

    elsif filestat.file? then
      ext = File.extname(localfile).downcase[1..-1]
      files.push(localfile) if allowed_exts.include?(ext)
    end

    return files
  end
  
end