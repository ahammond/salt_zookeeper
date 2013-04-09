hadoop_ppa:
  pkgrepo.managed:
    - ppa: hadoop-ubuntu/stable

hadoop_refresh_db:
  module.run:
    - name: apt.refresh_db
    - require:
        - pkgrepo: hadoop_ppa

hadoop-zookeeper:
  pkg.installed:
    - require: 
      - module: hadoop_refresh_db
