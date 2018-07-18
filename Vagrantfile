# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
NODES = 0

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "bento/ubuntu-18.04"
  
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.memory = 6144
    vb.linked_clone = true
  end

  config.vm.provision "docker"
  config.vm.provision :shell, :path => "common-config.sh", :args => "#{NODES}"

  # master node
  config.vm.define :master, primary: true do |master|
    master.vm.network "private_network", ip: "10.0.15.10"
    # master.vm.network "public_network"
    master.vm.hostname = "master"
    master.vm.provision :shell, :path => "master-config.sh", :privileged => false
  end

  # slaves nodes
  (1..NODES).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.network "private_network", ip: "10.0.15.#{i + 20}"
      node.vm.hostname = "node#{i}"

      node.vm.provision "file", source: ".vagrant/machines/master/virtualbox/private_key", destination: "/home/vagrant/.ssh/master_key"
      node.vm.provision "shell" do |s|
        s.inline = <<-SHELL
          chown vagrant /home/vagrant/.ssh/master_key
          chmod 400 /home/vagrant/.ssh/master_key
        SHELL
      end
        
      node.vm.provision :shell, :path => "node-config.sh", :privileged => false
    end   
  end
  
end
