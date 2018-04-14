# The rpi_cluster Admin VM.

VAGRANT_API_VER = "2"

Vagrant.configure(VAGRANT_API_VER) do |config|

  # Debian stretch box
  config.vm.box = "debian/stretch64"
  config.vm.box_check_update = false
  config.vm.boot_timeout = 360

  # the hostname must remain as stretch
  config.vm.hostname = 'stretch.local'

  # VirtualBox settings
  config.vm.provider :virtualbox do |vb|
    vb.name = "BerryClusterAdmin"
    vb.memory = 2048
    vb.cpus = 4
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
  # jenkins
  config.vm.network :forwarded_port, guest: 8080, host: 5553, host_ip: "127.0.0.1"

  # provisioning exec commands
  config.vm.provision :shell, :path => "vagrantvm/vagrantfile_root.sh", :privileged => true
  config.vm.provision :shell, :path => "vagrantvm/vagrantfile_user.sh", :privileged => false
  config.vm.provision :shell, :path => "vagrantvm/jenkins/install.sh", :privileged => false
  config.vm.provision :shell, :path => "ansible/install-deploy-tools.sh", :privileged => false

  # post up message
  config.vm.post_up_message = "----[ Berry Cluster Admin VM up! ]----"

end

# EOF
