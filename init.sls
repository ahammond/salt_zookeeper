#!pydsl

import re

TIMEOUT = 5
production_hadoop_config_dir = '/etc/hadoop-zookeeper/conf.production'
zookeeper_config = '{}/zoo.cfg'.format(production_hadoop_config_dir)
zookeeper_logging = '{}/log4j.properties'.format(production_hadoop_config_dir)
zookeeper_data_dir = '/var/lib/hadoop-zookeeper'
follower_port = 2888
election_port = 3888

zookeeper_defaults = {
    'maxClientCnxns': 50,
    'tickTime': 2000,
    'initLimit': 10,
    'syncLimit': 5,
    'dataDir': zookeeper_data_dir,
    'dataLogDir': zookeeper_data_dir,
    'clientPort': 2181,
    'zookeepers': {
        'localhost': {
            'index': 0,
            'follower_port': follower_port,
            'election_port': election_port,
        },
    },
}

zookeepers = {}
for k, v in __salt__['publish.publish']('*', 'grains.items', '', 'glob', TIMEOUT).iteritems():
    m = re.match(r'^.*(\d+)$', k)
    # zookeepers have a number at the end of their name, and have 'zookeeper' as a role
    if m and 'zookeeper' in v.get('roles', []):
        zookeepers[k] = {
                'index': int(m.group(0)),
                'follower_port': follower_port,
                'election_port': election_port,
            }

state('hadoop_ppa').pkgrepo.managed(ppa='hadoop-ubuntu/stable')

state('hadoop_refresh_db')\
    .module.run(name='pkg.refresh_db')\
    .require(pkgrepo='hadoop_ppa')

state('hadoop-zookeeper')\
    .pkg.installed()\
    .require(module='hadoop_refresh_db')

state(production_hadoop_config_dir).file.directory()

state('hadoop-zookeeper-conf')\
    .alternatives.install(
        link='/etc/hadoop-zookeeper/conf',
        path=production_hadoop_config_dir,
        priority=90)\
    .require(
        file=production_hadoop_config_dir,
        pkg='hadoop-zookeeper')

state(zookeeper_config)\
    .file.managed(
        source='salt://zookeeper/files{}'.format(zookeeper_config),
        template='jinja',
        defaults=zookeeper_defaults)\
    .require(file=production_hadoop_config_dir)

state(zookeeper_logging)\
    .file.managed(
        source='salt://zookeeper/files{}'.format(zookeeper_logging),
        template='jinja',
        defaults={ 'logstash_port': 4712 },
        logstash_host='ls-shipper01')\
    .require(file=production_hadoop_config_dir)
