## Настрока сервера для тестирования и CD

1. Все операции проводим под `root`
```
# emacs
apt-get update &&  apt-get install nano -y

```
1. Первоначально осуществляем установку `puppet-agent`
 ```
 # puppet packages
 apt-get update && apt-get install wget -y
 wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb && dpkg -i puppetlabs-release-pc1-xenial.deb
 apt-get update && apt-get install puppet-agent
 ```
1. Дальнейшие...
