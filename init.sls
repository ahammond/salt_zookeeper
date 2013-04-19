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
      - pkg: hadoop-zookeeper

{% set zookeeper_config = '{}/zoo.cfg'.format(production_hadoop_config_dir) %}
{{ zookeeper_config }}:
  file.managed:
    - source: {{ 'salt://zookeeper/files{}'.format(zookeeper_config) }}
    - template: jinja
    - defaults:
      maxClientCnxns: 50
      tickTime: 2000
      initLimit: 10
      syncLimit: 5
      dataDir: /var/lib/hadoop-zookeeper
      dataLogDir: /var/lib/hadoop-zookeeper
      clientPort: 2181
      zookeepers:
        localhost:
          index: 0
          follower_port: 2888
          election_port: 3888
    - require:
      - file: {{ production_hadoop_config_dir }}

{% set zookeeper_logging = '{}/log4j.properties'.format(production_hadoop_config_dir) %}
{{ zookeeper_logging }}:
  file.managed:
    - source: {{ 'salt://zookeeper/files{}'.format(zookeeper_logging) }}
    - template: jinja
    - defaults:
      logstash_port: 4712
    - logstash_host: ls-shipper01
    - require:
      - file: {{ production_hadoop_config_dir }}
