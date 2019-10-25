Vagrant.configure("2") do |config|

  ENV['VAGRANT_NO_PARALLEL'] = 'yes'

  require 'open3'
  #myIp, stderr, status = Open3.capture3("ifconfig bridge100 | grep 'inet '| grep -Fv 127.0.0.1 | awk '{print $2}'")
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

    proxy.vm.provision "shell",
    inline: "easy_install pip"

    proxy.vm.provision "shell",
    inline: "pip install ansible"

    proxy.vm.provision "shell",
    inline: "ansible-galaxy install --roles-path /vagrant/roles bassinator.squid --force"

    proxy.vm.provision "shell",
    inline: "ansible-playbook --connection=local --inventory 127.0.0.1, /vagrant/proxy.yml"
  end


  config.vm.define "client", autostart: false do |client|
    client.vm.network "public_network"
    client.vm.network :forwarded_port, host: 8080, guest: 8080
    client.vm.network :forwarded_port, host: 8081, guest: 8081
    client.vm.box = "Bassualdo/raspberryDesktop"
    client.vm.provider "virtualbox"
    client.vm.provider "hyperv"
    client.ssh.username = "pi"
    client.ssh.password = "raspberry"
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
        https_proxy: "http://"+myIp+":3128"
      }
    end

    docker.vm.provision "ansible_local" do |provisioner|
      provisioner.extra_vars = {
        http_proxy: "http://"+myIp+":3128",
        https_proxy: "http://"+myIp+":3128",
        scan_network_ip: myIp
      }
      provisioner.compatibility_mode = "2.0"
      provisioner.galaxy_role_file = 'requirements.yml'
# following line to use in slow network to not force updateing ansible roles
#      provisioner.galaxy_command ='ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path}'
      provisioner.playbook = "provisioner.yml"
      provisioner.install = true
      provisioner.limit          = "all,localhost" # or only "nodes" group, etc.
      provisioner.inventory_path = "hosts"
    end
  end
end
