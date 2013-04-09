hadoop_ppa:
  pkgrepo.managed:
    - ppa: hadoop-ubuntu/stable

hadoop-zookeeper:
  pkg.installed:
    - require: 
      - pgkrepo: hadoop_ppa
