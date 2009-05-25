#!/usr/bin/ruby

# Dropzone Destination Info
# Name: Zip & Email
# Description: Zips up the dropped files or folders and creates a new Mail attchment with the zip file.
# Handles: NSFilenamesPboardType
# Creator: Aptonic Software
# URL: http://aptonic.com
# IconURL: http://aptonic.com/destinations/icons/mail.png

def dragged
  $dz.determinate("0")

  if $items.length == 1 and not File.directory?($items[0])
    # Just add this file as an attachment
    email_file = "\"#{$items[0]}\""
    $dz.begin("Creating message with attachment")
    delete_zip = false
  else
    # Copy to temporary folder and zip up
    $dz.begin("Copying files...")
    tmp_folder = "/tmp/dz_tmp/"
    email_file = "/tmp/files.zip"
    system("/bin/mkdir #{tmp_folder}")
    Rsync.do_copy($dz, $items, tmp_folder, false)
    $dz.begin("Creating zip archive...")
    $dz.determinate("0")
    system("/usr/bin/ditto -c -k -X --rsrc #{tmp_folder} /tmp/files.zip")
    system("/bin/rm -rf #{tmp_folder}")
    delete_zip = true
  end

  system("osascript ../AppleScripts/mail.scpt #{email_file}")
  system("/bin/rm -f #{email_file}") if (delete_zip)

  $dz.finish("Message Created")
  $dz.url("0")
end

def clicked
  system("open /Applications/Mail.app")
end