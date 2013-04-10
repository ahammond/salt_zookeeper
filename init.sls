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

{% set production_hadoop_config_dir = '/etc/hadoop-zookeeper/conf.production' %}
{{ production_hadoop_config_dir }}:
  file.directory

hadoop-zookeeper-conf:
  alternatives.install:
    - link: /etc/hadoop-zookeeper/conf
    - path: {{ production_hadoop_config_dir }}
    - priority: 90
    - require:
      - file: {{ production_hadoop_config_dir }}

{% set zookeeper_config = '{}/zoo.conf'.format(production_hadoop_config_dir) %}
{{ zookeeper_config }}:
  file.managed:
    - source: 'salt://zookeeper/files{}'.format(zookeeper_config)
    - template: jinja

{% set zookeeper_logging = '{}/log4j.properties'.format(production_hadoop_config_dir) %}
{{ zookeeper_logging }}:
  file.managed:
    - source: 'salt://zookeeper/files{}'.format(zookeeper_logging)
    - template: jinja
