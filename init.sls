hadoop_ppa:
  pkgrepo.managed:
    - ppa: hadoop-ubunti/stable

hadoop-zookeeper:
  pkg.installed:
    - require: 
      - pgkrepo: hadoop_ppa
