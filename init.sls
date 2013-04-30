#!pydsl

import re

TIMEOUT = 5
zookeeper_package_name = 'hadoop-zookeeper'
zookeeper_user = 'hadoop-zookeeper'    # This is created by the .deb package
production_hadoop_config_dir = '/etc/hadoop-zookeeper/conf.production'
zookeeper_alternatives = 'hadoop-zookeeper-conf'
zookeeper_config = '{}/zoo.cfg'.format(production_hadoop_config_dir)
zookeeper_logging = '{}/log4j.properties'.format(production_hadoop_config_dir)
zookeeper_data_dir = '/var/lib/hadoop-zookeeper'
zookeeper_init_file = '/etc/init/zookeeper.conf'
follower_port = 2888
election_port = 3888
pid_file = '/var/run/zookeeper.pid'

localhost_only = {
    'localhost': {
        'index': 0,
        'follower_port': follower_port,
        'election_port': election_port,
    },
}

zookeeper_defaults = {
    'maxClientCnxns': 50,
    'tickTime': 2000,
    'initLimit': 10,
    'syncLimit': 5,
    'dataDir': zookeeper_data_dir,
    'dataLogDir': zookeeper_data_dir,
    'clientPort': 2181,
    'zookeepers': localhost_only,
}

zookeepers = {}
for k, v in __salt__['publish.publish']('role:zookeeper', 'grains.item', 'id', 'grain', TIMEOUT).iteritems():
    m = re.match(r'^.*(\d+)$', k)
    # zookeepers have a number at the end of their name, and have 'zookeeper' as a role
    if m :
        zookeepers[k] = {
                'index': int(m.group(1)),
                'follower_port': follower_port,
                'election_port': election_port,
            }

# Package installation
state('hadoop_ppa').pkgrepo.managed(ppa='hadoop-ubuntu/stable')

state('hadoop_refresh_db')\
    .module.run(name='pkg.refresh_db')\
    .require(pkgrepo='hadoop_ppa')

state(zookeeper_package_name)\
    .pkg.installed()\
    .require(module='hadoop_refresh_db')

# Config directory and alternatives
state(production_hadoop_config_dir).file.directory()

state('/var/run/hadoop-zookeeper')\
    .file.directory(
        user='root',
        group=zookeeper_user,
        dir_mode='0775')\
    .require(pkg=zookeeper_package_name)

state(zookeeper_alternatives)\
    .alternatives.install(
        link='/etc/hadoop-zookeeper/conf',
        path=production_hadoop_config_dir,
        priority=90)\
    .require(
        file=production_hadoop_config_dir,
        pkg='hadoop-zookeeper')

# Config files
state(zookeeper_config)\
    .file.managed(
        source='salt://zookeeper/files{}'.format(zookeeper_config),
        template='jinja',
        zookeepers=zookeepers if zookeepers else localhost_only,
        defaults=zookeeper_defaults)\
    .require(file=production_hadoop_config_dir)

state(zookeeper_logging)\
    .file.managed(
        source='salt://zookeeper/files{}'.format(zookeeper_logging),
        template='jinja',
        defaults={ 'logstash_port': 4712 },
        logstash_host='ls-shipper01')\
    .require(file=production_hadoop_config_dir)
