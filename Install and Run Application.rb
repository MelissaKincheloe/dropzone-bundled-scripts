#!/usr/bin/ruby

# Dropzone Destination Info
# Name: Install and Run Application
# Description: Copies the dropped item to your applications folder, runs it and ejects the disk image if needed.
# Handles: NSFilenamesPboardType
# Creator: Aptonic Software
# URL: http://aptonic.com
# IconURL: http://aptonic.com/destinations/icons/applications.png

def dragged
  files = "\"#{$items[0]}\""
  destination = "/Applications/"
  app_path = ""
  app_name = ""
  volume_path = ""
  dmg = false

  if $items[0] =~ /\.app/
    # Directly copy application
    $dz.begin("Copying application...")
    $dz.determinate("1")
    Rsync.do_copy($dz, $items, destination, false)

    # Find new app path
    full_source_path = files.split("/")
    app_name = full_source_path[-1..-1].to_s[0..-2]
    app_path = "#{destination}#{app_name}"
  elsif $items[0] =~ /\.dmg/
    # Mount DMG, find application inside and copy
    $dz.begin("Attaching disk image...")
    $dz.determinate("0")
  
    # Use DiskImageMounter first if DMG has license agreement
    used_diskimagemounter = false
    agreement_result = `/usr/bin/hdiutil imageinfo #{files} | grep "Software License Agreement"`
    if agreement_result =~ /true/
      ls_output = `/bin/ls /Volumes/ 2>&1`
      num_volumes_before = ls_output.split("\n").length
      system("/System/Library/CoreServices/DiskImageMounter.app/Contents/MacOS/DiskImageMounter #{files}")
      ls_output = `/bin/ls /Volumes/ 2>&1`
      num_volumes_after = ls_output.split("\n").length
      if num_volumes_before == num_volumes_after
        # Volume can't have mounted
        $dz.finish("Mount Failed")
        $dz.url("0")
        Process.exit
      end
      used_diskimagemounter = true
    end
  
    mount_result = `/usr/bin/hdid #{files}`
    if mount_result =~ /hdid:\sattach failed\s/
      $dz.finish("Mount Failed")
      $dz.url("0")
      Process.exit
    end
    
    volume_path = mount_result.split("\n")[-1].split("\t")[-1]
    ls_output = `/bin/ls \"#{volume_path}\" 2>&1`
    volume_files = ls_output.split("\n")
    app_file = ""
    volume_files.each do |file| 
      if file =~ /.app/
        app_file = file
        break
      end
    end
  
    if app_file == ""
      $dz.finish("Application not found")
      $dz.url("0")
      Process.exit
    end
  
    actual_vol_name = volume_path.split("/")[-1].gsub(/.app/, "")
    system("osascript ../AppleScripts/eject.scpt \"#{actual_vol_name}\"") if used_diskimagemounter
  
    $dz.begin("Copying application...")
    $dz.determinate("1")
    Rsync.do_copy($dz, "#{volume_path}/#{app_file}", destination, false)
    app_path = "#{destination}#{app_file}"
  
    dmg = true
  else 
    $dz.finish("Not an Application")
    $dz.url("0")
    Process.exit
  end

  # Launch application
  $dz.determinate("0")
  $dz.begin("Launching application...")
  system("open \"#{app_path}\"")

  # Eject disk image if possible
  if not dmg
    ls_output = `/bin/ls /Volumes/ 2>&1`
    mounted_volumes = ls_output.split("\n")
    app_name_no_ext = app_name.gsub(/.app/, "")
    actual_vol_name = ""

    mounted_volumes.each do |vol| 
      if vol =~ /#{app_name_no_ext}/
        actual_vol_name = vol
        break
      end
    end
  
    volume_path = "/Volumes/#{actual_vol_name}" if actual_vol_name != ""
  end

  if File::exists?(volume_path)
    info = `/usr/bin/hdiutil info`
    $dz.begin("Ejecting disk image...")
    system("osascript ../AppleScripts/eject.scpt \"#{actual_vol_name}\"")
    `/usr/bin/hdiutil detach \"/Volumes/#{actual_vol_name}\" >& /dev/null`

    # Move disk image to trash
    if not dmg
      volume_name = "/Volumes/#{actual_vol_name}"
      sections = info.split("================================================")
      dmg_path = ""
      sections.each do |section|
      	if section =~ /\s#{volume_name}\n/
      		dmg_path = section.split("\n")[1].split(":")[1].strip
      		dmg_path = "\"#{dmg_path}\""
      		break
      	end
      end
    else
      dmg_path = files
    end

    `/bin/mv #{dmg_path} ~/.Trash/ >& /dev/null`
  end

  $dz.finish("Application Installed")
  $dz.url("0")
end

def clicked
  system("open /Applications/")
end