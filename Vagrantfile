Vagrant.configure("2") do |config|

  require 'open3'
  # stdout, stderr, status = Open3.capture3("ifconfig bridge100 | grep 'inet '| grep -Fv 127.0.0.1 | awk '{print $2}'")
  myIp, stderr, status = Open3.capture3("ifconfig en0 | grep 'inet '| grep -Fv 127.0.0.1 | awk '{print $2}'")
  myIp.chop!

  config.vm.define "proxy" do |proxy|
    proxy.vm.network "public_network"
    proxy.vm.network :forwarded_port, host: 3128, guest: 3128
    proxy.vm.network :forwarded_port, host: 2223, guest: 22, id: "ssh"
    proxy.vm.provider "docker" do |docker|
      docker.image = "bassualdo/centosvagrant"
      docker.has_ssh = true
    end
    proxy.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "proxy.yml"
      ansible.install = true
    end
  end

  # config.vm.define :raspemu do |docker2|
  #   docker2.ssh.username = "pi"
  #   docker2.vm.provider "docker" do |d2|
  #     d2.build_dir = "."
  #     d2.has_ssh = true
  #   end
  # end
# TODO: privisinig with ansible and install net-tools,iputlis-ping

  config.vm.define "client", autostart: false do |client|
    client.vm.network "public_network"
    client.vm.box = "raspbian"
    client.vm.network :forwarded_port, host: 2224, guest: 22, id: "ssh"
#    config.ssh.insert_key = false
#    config.ssh.port = 2224

#   client.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  end

  config.vm.define :provisioner do |docker|
    docker.vm.provider "docker" do |d|
      d.image = "bassualdo/centosvagrant"
      d.has_ssh = true
    end

    docker.vm.provision "shell" do |s|
      s.inline = "yes | yum install git"
      s.env = {
        http_proxy: "http://"+myIp+":3128",
        https_proxy: "https://"+myIp+":3128"
      }
    end

    docker.vm.provision "ansible_local" do |provisioner|
      provisioner.extra_vars = {
        http_proxy: "http://"+myIp+":3128",
        https_proxy: "https://"+myIp+":3128",
        scan_network_ip: myIp
      }
      provisioner.compatibility_mode = "2.0"
      provisioner.galaxy_role_file = 'requirements.yml'
      provisioner.playbook = "provisioner.yml"
      provisioner.install = true
      provisioner.limit          = "all" # or only "nodes" group, etc.
      provisioner.inventory_path = "hosts"
    end
  end
end
