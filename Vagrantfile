$script = <<-SCRIPT
  sudo pip install ansible
  ansible-galaxy install --role-file=/vagrant/requirements.yml --roles-path=/vagrant/roles --force
  ansible-playbook -i /vagrant/hosts /vagrant/main.yml
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.define "client", autostart: false do |client|
    client.vm.box = "Bassualdo/raspberryDesktop"
    client.vm.provision "shell", inline: $script
  end
end
