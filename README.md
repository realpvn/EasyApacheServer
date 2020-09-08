# Easy Apache
Easily setup Apache server by using this script, it takes you step by step and setup everything you need

## How to use easy-apache
Install easy-apache on to your server (copy paste below lines to your terminal)
```
sudo add-apt-repository ppa:realpvn/easy-apache
sudo apt-get update
sudo apt-get install easy-apache
```

One command to setup everything, installs Apache & SSL
```
easy-apache.sh -f
```
That is it! 🤩
  
  
## Options & Usage
```
Usage:
easy-apache.sh [options]

Options:
-f:   Full setup, default option if none is provided
-a:   Adding new site (includes apache install)
-s:   Install SSL certificate for sites available
-h:   Help (shows all commands)"

Example
easy-apache.sh -f   #for full installation i.e Apache & SSL certificate
easy-apache.sh -a   #for installating Apache server & SSL certificate
easy-apache.sh -s   #for installating SSL certificate
```


## Works on
- Ubuntu 20.04 (focal)  
(will update more once I test)

Give it a ⭐ if it helped you xD
