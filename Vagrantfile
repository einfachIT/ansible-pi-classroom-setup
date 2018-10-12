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
      ansible.verbose = "vvv"
      ansible.playbook = "proxy.yml"
      ansible.install = true
    end
  end

  config.vm.define :provisioner do |docker|
    docker.vm.provider "docker" do |d|
      d.image = "bassualdo/centosvagrant"
      d.has_ssh = true
    end

    docker.vm.provision "ansible_local" do |provisioner|
      provisioner.verbose = "vvv"
      provisioner.extra_vars = {
        proxy_server_ip: myIp,
        scan_network_ip: myIp
      }
      provisioner.playbook = "provisioner.yml"
      provisioner.install = true
      provisioner.limit          = "all" # or only "nodes" group, etc.
      provisioner.inventory_path = "hosts"
    end
  end

  config.vm.define :raspemu do |docker2|
    docker2.ssh.username = "pi"
    docker2.vm.provider "docker" do |d2|
      d2.build_dir = "."
      d2.has_ssh = true
    end
  end
# TODO: privisinig with ansible and install net-tools,iputlis-ping
  config.vm.define :client do |client|
     client.vm.network "public_network"
     client.vm.box = "raspbian"
#    client.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  end
end
