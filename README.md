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
One command to setup a domain
```
easy-apache [domain]
```
  
## Options & Usage
```
Usage:
easy-apache [domain] [options]

Options:
-s | --ssl              Setup domain with SSL certificate
-h | --help             Help (shows available commands)
-v | --version          Check easy-apache version

Example:
easy-apache example.com -s          # setup site with ssl certificates
easy-apache example.com             # setup site (without ssl)
```

## Works on
- Ubuntu 20.04 (focal)  
(will update more once I test)
