# Riaan Nolan - riaan.nolan@gmail.com
https://www.linkedin.com/in/riaannolan/

## Instructions
* Please download Virtualbox from https://www.virtualbox.org/wiki/Downloads and Vagrant from https://www.vagrantup.com/downloads.html and install
* Clone this repo
* Vagrant: Inside the local repo folder, do `vagrant up --provision`
* Vagrant: Open http://www.example in your browser
* Docker: Inside the local repo folder, do `sudo docker run -dit -p 8080:80 -v /media/riaan/external/riaan/Desktop/workspace/riaannolan/devops/html/:/usr/local/apache2/htdocs/ httpd:2.4`
* Docker: Open http://localhost:8080 in your browser

### Vagrant Basic Usage
* vagrant up --provision OR vagrant up --provision-with bootstrap
* vagrant global-status # to see which VMs are active
* vagrant global-status --prune # to remove stale VMs from Vagrant cache
* vagrant status # vagrant status
* vagrant reload
* vagrant up
* vagrant destroy
* vagrant provision
* vagrant plugin list

### Docker Basic Usage
* docker image ls
* docker ps
* docker stop

Checkout the repo! More detailed steps to follow __soon__
