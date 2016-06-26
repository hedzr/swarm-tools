# Docker Swarm Tools

## Without `docker swarm ...`, 

If you did, 

- without docker 1.12 and `docker swarm`
- not wanna install SwarmKits,
- more reason...

download `swarm-tools.sh` and put it to `~/bin/` or any path you specified, and `source` it in your `.bash_profile` or `.profile`:

```bash
source ~/bin/swarm-tools.sh
```

Before use `swarm` command in bash terminal, you'd better edit and prepare a configuration file as ~/.swarm.conf, such as:

```bash
# ~/.swarm.conf or ./.swarm.conf
SWARM_MANAGERS=(sw2ops00 sw2mac01)
SWARM_NODES=(sw2mac01 sw2wfc01 sw2dbg03 sw2dbg02 sw2dbg01)
SWARM_DISCOS=(sw2bak00)
```

And now, `swarm` command is ready.


## NOT BE DONE

at the version, these things not be done with `swarm` :

- create docker swarm cluster



## `swarm` Command Usages

swarm

USAGE: swarm [manager-start-all|manager-stop-all|manager-restart-all|manager-rm-all| \
              manager-start|manager-stop|manager-restart|manager-rm| \
              manager-logs| \
              leader| \
              hosts|SWARM_MANAGERS|SWARM_NODES|SWARM_NODES-live|SWARM_NODES-count| \
              node-start-all|node-stop-all|node-restart-all|node-rm-all| \
              node-start|node-stop|node-restart|node-rm| \
              run|call|pull|push|clear|clear-by-image-name| \
              add-ali|add-ali-all| \
              consul-leader|consul-peers]

* Basic Usages:
  swarm manager-add-ali  : add ali docker accelerator
  swarm manager-logs     : print the latest logs in swarm container.
  swarm manager-start/manager-rm : run or clean stop the swarm container completely.
  swarm manager-stop     : fast pause the swarm container.
  swarm manager-restart  : fast restart the paused swarm container after 'swarm stop'.
  swarm manager-images

  swarm consul-leader
  swarm consul-peers

  swarm leader   : query and print who is the current leader.
  swarm SWARM_MANAGERS :
  swarm SWARM_NODES    : list the swarm SWARM_NODES
  swarm SWARM_NODES-live
  swarm SWARM_NODES-count
  swarm clear    : remove all running or pause containers on all swarm SWARM_NODES
  swarm clear-by-image-name : ...
  swarm push
  swarm pull     : ! pull container onto each SWARM_NODES
  swarm call     : call docker command on swarm cluster
  swarm run      : run container on swarm cluster
  
  ... other docker commands, such as:
    'swarm ps' like 'docker ps' but apply to swarm cluster,
    'swarm build' like 'docker build' but the new container will be built and push to each SWARM_NODES.
    'swarm run' like 'docker run' but run a container on some node with swarm cluster scheduling stratages.
    'swarm info' like 'docker info' but show the information of swarm cluster.

* Examples:
  swarm ps
  swarm images
  swarm manager-images
  swarm run nginx

* Advanced Examples:
  1. swarm run -P --name nginx -t nginx
  2. swarm run -P --name nginx -e affinity:image=nginx -t nginx
  3. swarm run -P --name mysql -e affinity:container=nginx -t mysql
  4. 启动5个nginx实例 (由于一个swarm-node上不允许暴露到相同的端口，所以不能启动超过swarm-SWARM_NODES-count的统一端口的实例)：
     for ((i=0;i<5;i++)); do swarm run -P --name nginx-$i -p 83:80 -t nginx; done

* Samples:
  swarm run -P  -m 1G --name db mysql
  swarm run -P  -m 1G --name frontend nginx
  for ((i=0;i<5;i++)); do swarm run -P  --label zone==external --label mode==test --label status=master -e SERVICE_NAME=proxy  -m 1G --name frontend-$i -p 83:80 nginx; done
  # - on a swarm node, restart a fresh swarm_node instance:
  docker rm -f swarm_node && sleep 1 && eval "docker run --name swarm_node -d swarm join --advertise=\$(util-ip-local):2375 consul://\$(_find_sw_ip sw0bak00):8500"

  # Primary load balancer
  swarm run -d \
    --name nginx-primary-lb \
    -e constraint:zone==external \
    -e constraint:status==master \
    -e SERVICE_NAME=proxy \
    -p 80:80 \
    nginx:latest

  # Secondary load balancer
  swarm run -d \
    --name nginx-secondary-lb \
    -e constraint:zone==external \
    -e constraint:status==non-master \
    -e SERVICE_NAME=proxy \
    -p 80:80 \
    nginx:latest

  # 3 Instances of the webapp
  swarm run -d \
    --name nginx-official-web \
    -e constraint:zone==internal \
    -e SERVICE_NAME=webapp \
    -p 80 \
    nginx:latest

  swarm run -d \
    -e constraint:zone==internal \
    -e SERVICE_NAME=webapp \
    -p 80 \
    nginx:latest

  swarm run -d \
    -e constraint:zone==internal \
    -e SERVICE_NAME=webapp \
    -p 80 \
    nginx:latest

* References
  - https://www.consul.io/docs/agent/http/status.html
  - https://github.com/llitfkitfk/docker-tutorial-cn
  - https://help.aliyun.com/knowledge_detail/5974865.html
* References
  - https://docs.docker.com/swarm/overview/
  - https://docs.docker.com/swarm/install-manual/
  - https://docs.docker.com/swarm/scheduler/strategy/
  - https://docs.docker.com/swarm/scheduler/filter/
  - https://testerhome.com/topics/4580
  - https://github.com/monumentality/docker-workflow/blob/master/README.md

## LICENSE

MIT.

## Author

`hedzr` working on:

- Meta-programming
- Material Design and Developing
- SpringBoot
- DevOps Console/Monitoring
- MEAN JS
- Bootstrap-sass

