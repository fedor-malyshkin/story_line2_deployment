## Настрока сервера для тестирования и CD

1. For tests use:
 - `./pre_puppet.sh && /opt/puppetlabs/bin/puppet apply --logdest=console site.pp`
 - `/opt/puppetlabs/bin/puppet apply --logdest=console site.pp`
 - ` docker run -v /home/fedor/Download:/mnt -p 127.0.0.1:8080:8080 -it  --name my_test_ubuntu test_ubuntu:none "/bin/bash"`
 - `docker exec -ti my_test_ubuntu /bin/bash`
 - `docker start my_test_ubuntu`

1. __Все операции проводим под `root`__

1. SSH generate new keys for me and add public keys to to `/home/srv_oper/.ssh/authorized_keys`

1. Install Jenknis
 ```
apt-get install apt-transport-https -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
echo "deb https://pkg.jenkins.io/debian binary/" >> /etc/apt/sources.list
apt-get update &&  apt-get install apt-transport-https jenkins -y
 ```

1. Read first-run Jenkins security token in /var/log/jenknins/jenknis.log

1. Install Docker according to https://docs.docker.com/engine/installation/linux/ubuntu/ and (https://docs.docker.com/engine/installation/linux/linux-postinstall  
```sh
apt-get install -y --no-install-recommends linux-image-extra-$(uname -r) linux-image-extra-virtual lsb-release
apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://apt.dockerproject.org/gpg | apt-key add -
add-apt-repository "deb https://apt.dockerproject.org/repo/ ubuntu-$(lsb_release -cs) main"
apt-get update && apt-get -y install docker-engine

groupadd docker
usermod -aG docker jenkins
systemctl enable docker

```


1. Generate puppet module with `/opt/puppetlabs/bin/puppet module generate storyline/server_firewall`
1. Move module to `/etc/puppetlabs/code/environments/test/modules`
1. Add pre.pp with content:
```
```

and `post.pp`:
```
class server_firewall::post {
}
```

add to `site.pp`
```
```
