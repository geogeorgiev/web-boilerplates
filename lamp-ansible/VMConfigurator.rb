class VMConfigurator
  def VMConfigurator.run(config, settings)
    # Set The VM Provider
    ENV['VAGRANT_DEFAULT_PROVIDER'] = settings["provider"] ||= "virtualbox"

    # Prevent TTY Errors
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  	# Configure The Box
  	config.vm.box = "ubuntu/trusty64"
    config.vm.hostname = settings["hostname"] ||= "vagrant-1"


    # Configure A Private Network IP
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.20"

    # Configure Additional Networks
    if settings.has_key?("networks")
      settings["networks"].each do |network|
        config.vm.network network["type"], ip: network["ip"], bridge: network["bridge"] ||= nil
      end
    end



    # Configure A Few VirtualBox Settings
    config.vm.provider "virtualbox" do |vb|
      #vb.gui = true
      vb.name = settings["hostname"] ||= "vagrant-1"
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]

      #
      # You may have to comment out or tinker with the values of some of the
      # customizations, below, to suit the needs/limits of your local machine.
      #
      # Optimized for an Ubuntu 12.04 32-bit VM on a host running Windows XP SP3 32-bit
        # Set the amount of RAM, in MB, that the VM should allocate for itself, from the host
        #vb.customize ["modifyvm", :id, "--memory", "1024"]
        # Allow the VM to display the desktop environment
        #vb.customize ["modifyvm", :id, "--graphicscontroller", "vboxvga"]
        # Set the amount of RAM that the virtual graphics card should have
        #vb.customize ["modifyvm", :id, "--vram", "64"]
        # Advanced Programmable Interrupt Controllers (APICs) are a newer x86 hardware feature
        #vb.customize ["modifyvm", :id, "--ioapic", "on"]
        # Default host uses a USB mouse instead of PS2
        #vb.customize ["modifyvm", :id, "--mouse", "usb"]
        # Enable audio support for the VM & specify the audio controller
        #vb.customize ["modifyvm", :id, "--audio", "dsound", "--audiocontroller", "ac97"]
        # Enable the VM's virtual USB controller & enable the virtual USB 2.0 controller
        #vb.customize ["modifyvm", :id, "--usb", "on", "--usbehci", "on"]
        # Add IDE controller to the VM, to allow virtual media to be attached to the controller
        #vb.customize ["storagectl", :id, "--name", "IDE Controller", "--add", "ide"]
        # Give the VM access to the host's CD/DVD drive, by attaching the medium to the virtual IDE controller
        #vb.customize ["storageattach", :id, "--storagectl", "IDE Controller", "--port 0", "--device 0", "--type", "dvddrive"]
        #
        # For a 64-bit VM (courtesy of https://gist.github.com/mikekunze/7486548#file-ubuntu-desktop-vagrantfile)
        # vb.customize ["modifyvm", :id, "--memory", "2048"]
        # Set the number of virtual CPUs for the virtual machine
        # vb.customize ["modifyvm", :id, "--cpus", "2"]
        # vb.customize ["modifyvm", :id, "--graphicscontroller", "vboxvga"]
        # vb.customize ["modifyvm", :id, "--vram", "128"]
        # Enabling the I/O APIC is required for 64-bit guest operating systems, especially Windows Vista;
        # it is also required if you want to use more than one virtual CPU in a VM.
        # vb.customize ["modifyvm", :id, "--ioapic", "on"]
        # Enable the use of hardware virtualization extensions (Intel VT-x or AMD-V) in the processor of your host system
        # vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
        # Enable, if Guest Additions are installed, whether hardware 3D acceleration should be available
        # vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
        #
        # See Chapter 8. VBoxManage | VirtualBox Manual located @ virtualbox.org/manual/ch08.html
        # for more information on available options.

    end


    # Configure A Few VMware Settings
    ["vmware_fusion", "vmware_workstation"].each do |vmware|
      config.vm.provider vmware do |v|
        v.vmx["displayName"] = "ML"
        v.vmx["memsize"] = settings["memory"] ||= 2048
        v.vmx["numvcpus"] = settings["cpus"] ||= 1
        v.vmx["guestOS"] = "ubuntu-64"
      end
    end

    # Configure A Few Parallels Settings
    config.vm.provider "parallels" do |v|
      v.update_guest_tools = true
      v.optimize_power_consumption = false
      v.memory = settings["memory"] ||= 2048
      v.cpus = settings["cpus"] ||= 1
    end

    # Standardize Ports Naming Schema
    if (settings.has_key?("ports"))
      settings["ports"].each do |port|
        port["guest"] ||= port["to"]
        port["host"] ||= port["send"]
        port["protocol"] ||= "tcp"
      end
    else
      settings["ports"] = []
    end

    # Default Port Forwarding
    default_ports = {
      80   => 8000,
      443  => 44300,
      3306 => 33060,
      5432 => 54320
    }

    # Use Default Port Forwarding Unless Overridden
    default_ports.each do |guest, host|
      unless settings["ports"].any? { |mapping| mapping["guest"] == guest }
        config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
      end
    end

    # Add Custom Ports From Configuration
    if settings.has_key?("ports")
      settings["ports"].each do |port|
        config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"], auto_correct: true
      end
    end

    # Configure The Public Key For SSH Access
    if settings.include? 'authorize'
      config.vm.provision "shell" do |s|
        s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo $1 | tee -a /home/vagrant/.ssh/authorized_keys"
        s.args = [File.read(File.expand_path(settings["authorize"]))]
      end
    end

    # Copy The SSH Private Keys To The Box
    if settings.include? 'keys'
      settings["keys"].each do |key|
        config.vm.provision "shell" do |s|
          s.privileged = false
          s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
          s.args = [File.read(File.expand_path(key)), key.split('/').last]
        end
      end
    end

    # Register All Of The Configured Shared Folders
    if settings.include? 'shared_folders'

      settings["shared_folders"].each do |folder|
        mount_opts = []

        if (folder["type"] == "nfs")
            mount_opts = folder["mount_opts"] ? folder["mount_opts"] : ['actimeo=1']
        end

        config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, mount_options: mount_opts
      end
    end



  end
end