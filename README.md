# Easy Apache
Easily setup Apache server by using this script, it takes you step by step and setup everything you need

<a href="https://snapcraft.io/easy-apache">
<img alt="Get it from the Snap Store" src="https://snapcraft.io/static/images/badges/en/snap-store-black.svg" />
</a>

## Install
Installing easy-apache on to your server is easy too 😛 Just copy & paste below command(s) to your server terminal

##### Using Snap (don't use snap as it gives some error, I will remove this if it gets fixed)
```
sudo snap install easy-apache
```
##### Using apt
```
sudo add-apt-repository ppa:realpvn/easy-apache
sudo apt update
sudo apt install easy-apache
```
## Run
One command to setup everything, installs Apache & SSL
```
easy-apache -f
```
That is it! 🤩
  
  
## Options & Usage
```
Usage:
easy-apache [options]

Options:
-f:   Full setup, installs apache and ssl for sites
-a:   Adding new site (includes apache install)
-s:   Install SSL certificate for sites available
-h:   Help (shows all commands)

Example
easy-apache -f   #for full installation i.e Apache & SSL certificate
easy-apache -a   #for installating Apache server & SSL certificate
easy-apache -s   #for installating SSL certificate
```


## Works on
- Ubuntu 20.04 (focal)  
(will update more once I test)
