# Easy Apache
Easy Apache is a simple script that helps you setup an Apache server, configure it completely, and it also helps you in installing SSL certificates for all your Apache sites. It'll ask for a few inputs, like domain name, do you want to install SSL, etc that's it.

It takes care of configuring Apache, setting up virtual hosts (vhosts), managing different directories for each site, enabling site, disabling sites, and even installing an SSL certificate to your Apache sites.

## Install
Installing easy-apache on to your server is easy too. Just copy & paste below command(s) to your server terminal
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
-f | --full:            Full Apache server setup, adding site(s), virtual hosts (vhosts) & adding SSL certificate(s)
-a | --apache:          Adding new site (includes apache install)
-s | --SSL:             Install SSL certificate for sites available
-h | --help:            Help (shows available commands)
-v | --version          Check easy-apache version

Example
easy-apache -f                  #to setup Apache, add sites & install SSL certificate
easy-apache --apache            #to install Apache server
```


## Works on
- Ubuntu 20.04 (focal)  
(will update more once I test)
