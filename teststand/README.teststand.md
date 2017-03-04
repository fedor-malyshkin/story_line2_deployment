## Настрока сервера для тестирования и CD

1. For tests use:
 - `docker exec -ti my_test_ubuntu /bin/bash`
 - `docker start my_test_ubuntu`

1. __Все операции проводим под `root`__

1. by SSH generate new keys for me `ssh-keygen -t rsa -b 4096 -C "your_account@example.com"`
1. add public keys to to `/home/srv_oper/.ssh/authorized_keys`
1. Run all from common docs in README.md from root of repo
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
