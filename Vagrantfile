# The rpi_cluster Admin VM.

# vars:
VM_DISK = '../rpi_cluser.vdi'
VAGRANT_API_VER = "2"

Vagrant.configure(VAGRANT_API_VER) do |config|

  # Debian stretch box
  config.vm.box = "debian/stretch64"
  config.vm.box_check_update = false

  # VM settings
  config.vm.hostname = 'stretch.local'
  config.vm.boot_timeout = 360

  ## provider specific - virtualbox
  config.vm.provider :virtualbox do |vb|
    vb.name = "BerryClusterAdmin"
    vb.memory = 2048
    vb.cpus = 4
    # add a second HD
    unless File.exist?(VM_DISK)
      vb.customize ['createhd', '--filename', VM_DISK, '--size', 2 * 1024]
    end
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller',
      '--port', 1, '--device', 0, '--type', 'hdd', '--medium', VM_DISK]
  end

  ## provider specific - VMWare Fusion
  config.vm.provider :vmware_fusion do |vw|
     vw.vmx['memsize'] = '2048'
  end

  # no ssh agent forwarding
  config.ssh.forward_agent = false

  # disable default /vagrant mount
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # sync this (.) local folder to ~/rpi_cluster/ in the VM
  config.vm.synced_folder ".", "/home/vagrant/rpi_cluster",
    owner: "vagrant", group: "vagrant", mount_options: ["uid=1000", "gid=1000"]

  ## Port forwarding
  # ssh
  config.vm.network :forwarded_port, guest: 22, host: 5559, id: 'ssh'
  # apache
  config.vm.network :forwarded_port, guest: 80, host: 5550, host_ip: "127.0.0.1"
  # hugo
  config.vm.network :forwarded_port, guest: 1313, host: 5551, host_ip: "127.0.0.1"
  # mariaDB
  config.vm.network :forwarded_port, guest: 3306, host: 5552, host_ip: "127.0.0.1"
  # websocketd
  config.vm.network :forwarded_port, guest: 8080, host: 5553, host_ip: "127.0.0.1"

  # provisioning exec commands
  config.vm.provision :shell, :path => "vagrantvm/Vagrantfile.sh", :privileged => true
  config.vm.provision :shell, :path => "vagrantvm/setup.sh", :privileged => false
  config.vm.provision :shell, :inline => "uptime", :privileged => false

  # post up message
  config.vm.post_up_message = "----[ BerryClusterAdmin VM up! ]----"

end

# EOF
