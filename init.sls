deb http://ppa.launchpad.net/hadoop-ubuntu/stable/ubuntu precise main
  pkgrepo.managed:
    - dist: precise
    - file: /etc/apt/sources.list.d/hadoop.list
    - keyid: 691FAD9CED2410FADDDC65F5200E506584FBAFF0
    - keyserver: keyserver.ubuntu.com

hadoop-zookeeper:
  pkg.installed:
    - refresh: True
    - require: 
      - pgkrepo: deb http://ppa.launchpad.net/hadoop-ubuntu/stable/ubuntu precise main
