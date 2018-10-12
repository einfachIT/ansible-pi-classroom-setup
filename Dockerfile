FROM resin/raspberry-pi2-debian:latest 
# Basic upgrades; install sudo and SSH.
RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install --no-install-recommends -y sudo openssh-server
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
RUN echo 'UseDNS no' >> /etc/ssh/sshd_config

# Remove the policy file once we're finished installing software.
# This allows invoke-rc.d and friends to work as expected.
RUN rm /usr/sbin/policy-rc.d

# Add the Vagrant user and necessary passwords.
RUN groupadd pi
RUN useradd -c "pi" -g pi -d /home/pi -m -s /bin/bash pi
RUN echo 'pi:raspberry' | chpasswd

# Allow the pi user to use sudo without a password.
RUN echo 'pi ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/pi

# Install Vagrant's insecure public key so provisioning and 'vagrant ssh' work.
RUN mkdir /home/pi/.ssh
ADD https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub /home/pi/.ssh/authorized_keys
RUN chmod 0600 /home/pi/.ssh/authorized_keys
RUN chown -R pi:pi /home/pi/.ssh
RUN chmod 0700 /home/pi/.ssh

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

