hadoop_ppa:
  pkgrepo.managed:
    - ppa: hadoop-ubuntu/stable

hadoop_refresh_db:
  module.run:
    - name: pkg.refresh_db
    - require:
        - pkgrepo: hadoop_ppa

hadoop-zookeeper:
  pkg.installed:
    - require: 
      - module: hadoop_refresh_db

{% set smartreceipt_hadoop_config_dir = '/etc/hadoop-zookeeper/conf.smartreceipt' %}
{{ smartreceipt_hadoop_config_dir }}:
  file.directory

hadoop-zookeeper-conf:
  alternatives.install:
    - link: /etc/hadoop-zookeeper/conf
    - path: {{ smartreceipt_hadoop_config_dir }}
    - priority: 90
    - require:
      - file: {{ smartreceipt_hadoop_config_dir }}
