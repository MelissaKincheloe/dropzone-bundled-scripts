#!/usr/bin/env ruby

class ZipFiles
  
  def self.zip(items, filename)
    $dz.begin("Copying files...")
    tmp_folder = "/tmp/dz_tmp/"
    zip_file = "\"/tmp/#{filename}\""
    system("/bin/mkdir #{tmp_folder}")
    Rsync.do_copy(items, tmp_folder, false)
    $dz.begin("Creating zip archive...")
    $dz.determinate(false)
    system("/usr/bin/ditto -c -k -X --rsrc #{tmp_folder} #{zip_file}")
    system("/bin/rm -rf #{tmp_folder}")
    return zip_file
  end
  
  def self.delete_zip(zip_file)
    system("/bin/rm -f #{zip_file}")
  end
  
end