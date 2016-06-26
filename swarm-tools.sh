#!/bin/bash

util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }

sshcall () {
  local host=$1; shift;
  local port=$2; port=${port:-22}; shift;
  if [ "$port" -eq "$port" 2>/dev/null ]; then
    echo "\$# ssh -T -p $port $* root@$host \"$@\"";
    ssh -T -p $port $* root@$host "$@";
  else
    echo "Port for '$host' NOT FOUND, sshcall was broken."
  fi
}

function _swarm-manager-start-all(){
  # local ip="\$(util-ip-local)"
  local CONSUL0_IP="\$(_find_sw_ip ${SWARM_DISCOS[0]})"
  for h in ${SWARM_MANAGERS[@]}; do
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
ip="\$(util-ip-local)"
docker rm -f swarm_manager
echo docker run --name swarm_manager -d -p 4000:4000 swarm manage -H :4000 --replication --advertise \$ip:4000 consul://$CONSUL0_IP:8500
docker run --name swarm_manager -d -p 4000:4000 swarm manage -H :4000 --replication --advertise \$ip:4000 consul://$CONSUL0_IP:8500
EOC
  done
}
function _swarm-manager-restart-all(){
  local CONSUL0_IP="\$(_find_sw_ip ${SWARM_DISCOS[0]})"
  for h in ${SWARM_MANAGERS[@]}; do
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
ip="\$(util-ip-local)"
docker restart swarm_manager || \
docker run --name swarm_manager -d -p 4000:4000 swarm manage -H :4000 --replication --advertise \$ip:4000 consul://\$CONSUL0_IP:8500
EOC
  done
}
function _swarm-manager-stop-all(){
  for h in ${SWARM_MANAGERS[@]}; do
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
docker stop swarm_manager
EOC
  done
}
function _swarm-manager-rm-all(){
  for h in ${SWARM_MANAGERS[@]}; do
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
docker rm -f swarm_manager
EOC
  done
}

function _swarm-manager-start(){
  # local ip="\$(util-ip-local)"
  local CONSUL0_IP="\$(_find_sw_ip ${SWARM_DISCOS[0]})"
  local leader=$(_swarm-leader)
  for h in ${SWARM_MANAGERS[@]}; do
    if [ "$h" == "$leader" ]; then
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
ip="\$(util-ip-local)"
docker rm -f swarm_manager
echo docker run --name swarm_manager -d -p 4000:4000 swarm manage -H :4000 --replication --advertise \$ip:4000 consul://$CONSUL0_IP:8500
docker run --name swarm_manager -d -p 4000:4000 swarm manage -H :4000 --replication --advertise \$ip:4000 consul://$CONSUL0_IP:8500
EOC
    fi
  done
}
function _swarm-manager-restart(){
  local CONSUL0_IP="\$(_find_sw_ip ${SWARM_DISCOS[0]})"
  local leader=$(_swarm-leader)
  for h in ${SWARM_MANAGERS[@]}; do
    if [ "$h" == "$leader" ]; then
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
ip="\$(util-ip-local)"
docker restart swarm_manager || \
docker run --name swarm_manager -d -p 4000:4000 swarm manage -H :4000 --replication --advertise \$ip:4000 consul://\$CONSUL0_IP:8500
EOC
    fi
  done
}
function _swarm-manager-stop(){
  local leader=$(_swarm-leader)
  for h in ${SWARM_MANAGERS[@]}; do
    if [ "$h" == "$leader" ]; then
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
docker stop swarm_manager
EOC
    fi
  done
}
function _swarm-manager-rm(){
  local leader=$(_swarm-leader)
  for h in ${SWARM_MANAGERS[@]}; do
    if [ "$h" == "$leader" ]; then
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
docker rm -f swarm_manager
EOC
    fi
  done
}

function _swarm-node-start-all(){
  # local ip="\$(util-ip-local)"
  local CONSUL0_IP="\$(_find_sw_ip ${SWARM_DISCOS[0]})"
  for h in ${SWARM_NODES[@]}; do
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
#ip="\$(util-ip-local)"
docker rm -f swarm_node
echo docker run --name swarm_node -d swarm join --advertise=\$ip:2375 consul://$CONSUL0_IP:8500
docker run --name swarm_node -d swarm join --advertise=\$(util-ip-local):2375 consul://$CONSUL0_IP:8500
# docker run --name swarm_node -d swarm join --advertise=\$(util-ip-local):2375 consul://sw0bak00:8500
EOC
  done
}
function _swarm-node-restart-all(){
  local CONSUL0_IP="\$(_find_sw_ip ${SWARM_DISCOS[0]})"
  for h in ${SWARM_NODES[@]}; do
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)"
docker restart swarm_node || \
docker run --name swarm_node -d swarm join --advertise=\$(util-ip-local):2375 consul://$CONSUL0_IP:8500
EOC
  done
}
function _swarm-node-stop-all(){
  for h in ${SWARM_NODES[@]}; do
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
docker stop swarm_node
EOC
  done
}
function _swarm-node-rm-all(){
  for h in ${SWARM_NODES[@]}; do
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
docker rm -f swarm_node
EOC
  done
}

function _swarm-node-start(){
  local host=$1 && shift
  # local ip="\$(util-ip-local)"
  local CONSUL0_IP="\$(_find_sw_ip ${SWARM_DISCOS[0]})"
  for h in ${SWARM_NODES[@]}; do
  if [ "$host" == "$h" ]; then
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
docker rm -f swarm_node
echo docker run --name swarm_node -d swarm join --advertise=\$ip:2375 consul://$CONSUL0_IP:8500
docker run --name swarm_node -d swarm join --advertise=\$(util-ip-local):2375 consul://$CONSUL0_IP:8500
# docker run --name swarm_node -d swarm join --advertise=\$(util-ip-local):2375 consul://sw0bak00:8500
EOC
  fi
  done
}
function _swarm-node-restart(){
  local host=$1 && shift
  local CONSUL0_IP="\$(_find_sw_ip ${SWARM_DISCOS[0]})"
  for h in ${SWARM_NODES[@]}; do
  if [ "$host" == "$h" ]; then
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)"
docker restart swarm_node || \
docker run --name swarm_node -d swarm join --advertise=\$(util-ip-local):2375 consul://$CONSUL0_IP:8500
EOC
  fi
  done
}
function _swarm-node-stop(){
  local host=$1 && shift
  for h in ${SWARM_NODES[@]}; do
  if [ "$host" == "$h" ]; then
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
docker stop swarm_node
EOC
  fi
  done
}
function _swarm-node-rm(){
  local host=$1 && shift
  for h in ${SWARM_NODES[@]}; do
  if [ "$host" == "$h" ]; then
    sshcall $h <<EOC
util-ip-local () { ip addr|grep -Poi "inet ((192.168.\d+.\d+)|(172.\d+.\d+.\d+)|(10.\d+.\d+.\d+))"|grep -Poi "\d+.\d+.\d+.\d+"|grep -v '\.255'|head -n1; }
echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
docker rm -f swarm_node
EOC
  fi
  done
}


function _swarm-manager-logs(){
  docker logs $* swarm_manager
}
function _swarm-manager-images() {
  for h in $(_swarm-SWARM_NODES); do
    echo -e "\n----------------------------------------------------------- -> $h - \$(util-ip-local)";
    sshcall $h <<< "docker images"
  done
}
function _swarm-leader () {
  local str=$(curl -v http://localhost:8500/v1/kv/docker/swarm/leader 2>/dev/null|python -m json.tool|grep "Value"|grep -o ": \".*"|grep -o "\".*\"")
  echo ${str:1:-1}|base64 -d;
  # echo ""
}


function _swarm-SWARM_MANAGERS () { echo ${SWARM_MANAGERS[@]}; }
function _swarm-SWARM_NODES () { echo ${SWARM_NODES[@]}; }
function _swarm-hosts () { echo ${ALL_NODES[@]}; }

function _swarm-SWARM_NODES-count () { _swarm-SWARM_NODES-live | wc -l; }

function _swarm-SWARM_NODES-live () {
  docker -H $(_swarm-leader) info 2>/dev/null | grep -B 1 -Pn "ID: "| grep -Poi "\d+\- ([^:]+)"|grep -Poi "[^ ]+$"
}




function _swarm-call () { echo "docker -H $(_swarm-leader) $*"; docker -H $(_swarm-leader) $*; }
function _swarm-run () {
  echo "docker -H $(_swarm-leader) run -d $*"
  docker -H $(_swarm-leader) run -d $*
}

function _swarm-clear () { docker -H $(_swarm-leader) rm -f $(docker -H $(_swarm-leader) ps -a -q); }

function _swarm-clear-by-image-name () {
  local leader=$(_swarm-leader)
  # by container id: docker -H $leader rm -f $(docker -H $leader ps -a -q -f "name=$1")
  docker -H $leader rm -f $(docker -H $leader ps -a -q -f "ancestor=$1")
}

# 通过 swarm manager 自动地 pull 容器到所有 SWARM_NODES 上
function _swarm-pull () { local leader=$(_swarm-leader); docker -H $leader pull $*; }
function _swarm-push () { local leader=$(_swarm-leader); docker -H $leader push $*; }
function _swarm-SWARM_NODES-pull () {  # 显式地在每个nodes上单独执行本机的docker pull
  #local leader=$(_swarm-leader)
  for h in $(_swarm-SWARM_NODES); do
    echo -e "\n-----------------------------------------------------------\n-> $h";
    sshcall $h <<< "docker pull $*"
  done
}
function _swarm-SWARM_NODES-push () {  # 显式地在每个nodes上单独执行本机的docker push
  #local leader=$(_swarm-leader)
  for h in $(_swarm-SWARM_NODES); do
    echo -e "\n-----------------------------------------------------------\n-> $h";
    sshcall $h <<< "docker push $*"
  done
}

function _swarm-consul-leader(){
  local str=$(curl http://localhost:8500/v1/status/leader)
  echo ${str:1:-1}
}
function _swarm-consul-peers(){
  # https://www.consul.io/docs/agent/http/status.html
  curl http://localhost:8500/v1/status/peers 2>/dev/null|python -m json.tool
}





function swarm () {
  [ $# -eq 0 ] && _swarm-usage || {
    local cmd=$1 && shift

    SWARM_MANAGERS=(sw2ops00 sw2mac01)
    SWARM_NODES=(sw2mac01 sw2wfc01 sw2dbg03 sw2dbg02 sw2dbg01)
    SWARM_DISCOS=(sw2bak00)

    [ -f ~/.swarm.conf ] && . ~/.swarm.conf
    [ -f ./.swarm.conf ] && . ./.swarm.conf

    local ALL_NODES=()

    for h in ${SWARM_MANAGERS[@]} ${SWARM_NODES[@]} ${SWARM_DISCOS}; do
        if [[ " ${ALL_NODES[@]} " =~ " ${h} " ]]; then
            false
        else
            ALL_NODES=(${ALL_NODES[@]} $h)
        fi
    done

    case $cmd in
      consul*|manager*|pull*|push*|run*|call*|clear*|node*|hosts|leader*|add-ali*|upgrade*)
        _swarm-$cmd $* && echo ""
        ;;
      usage|help|--help*)
        _swarm-usage
        ;;
      *)
        _swarm-call $cmd $*
        ;;
      esac
  }
}
function _swarm-usage () {
  cat <<EOT
USAGE: swarm [manager-start-all|manager-stop-all|manager-restart-all|manager-rm-all| \\
              manager-start|manager-stop|manager-restart|manager-rm| \\
              manager-logs| \\
              leader| \\
              hosts|SWARM_MANAGERS|SWARM_NODES|SWARM_NODES-live|SWARM_NODES-count| \\
              node-start-all|node-stop-all|node-restart-all|node-rm-all| \\
              node-start|node-stop|node-restart|node-rm| \\
              run|call|pull|push|clear|clear-by-image-name| \\
              add-ali|add-ali-all| \\
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

EOT
}
function _swarm-upgrade-docker () {
  for i in ${SW_HOSTS[@]}; do ssh -p $(_find_sw_port $i) -T $i "echo \$(hostname) done, \$(docker --version)."; done > /tmp/docker-status
  local arr=$(cat /tmp/docker-status | grep 1.10 | grep -Poi "^[^ ]+" | grep -Pvi "sw2svc|sw2rmq|sw2tcs|sw0base|sw-exm")
  for i in ${arr[@]}; do ssh -T $i "apt-get update; apt-get upgrade -y docker-engine"; done
  for i in ${SW_HOSTS[@]}; do ssh -p $(_find_sw_port $i) -T $i "echo \$(hostname) done, \$(docker --version)."; done > /tmp/docker-status.new
}
function _swarm-prepare () {
  local arr=(hello-world busybox swarm registry:2.0 nginx mysql redis rabbitmq mongo postgres node java tomcat httpd ruby golang );
  local arr=(hello-world busybox nginx mysql redis rabbitmq mongo postgres node java tomcat httpd ruby golang haproxy sentry);
  local leader=$(_swarm-leader);
  for pkg in ${arr[@]}; do
    docker -H $leader pull $pkg;
  done
}
function _swarm-run-mongo () {
  # https://github.com/docker-library/official-images/blob/master/library/mongo
  # https://hub.docker.com/_/mongo/
  local name=${1:-main-mongo}
  shift; local vol=${1:-/data/run/mongo}
  shift; local port=${1:-0}
  shift; local pkg=${1:-mongo:latest}
  [ $port -ne 0 2>/dev/null ] && local useport="-p $port:27017 "
  local leader=$(_swarm-leader);

  [ ! -d $vol ] && {
    mkdir -p $vol
    chcon -Rt svirt_sandbox_file_t $vol
  }

  echo docker -H $leader run -d --name $name $useport -v $vol:/data/db   $pkg     --storageEngine wiredTiger;
  docker -H $leader run -d \
    --name $name $useport   \
    -v $vol:/data/db \
    -e constraint:zone==external \
    -e SERVICE_NAME=my-main-mongo \
    $pkg     \
    --storageEngine wiredTiger || \
  ( echo "restarting $name..."; docker -H $leader restart $name; );
}
function _swarm-test-mongo () {
  swarm call run -it --link main-mongo:mongo --rm mongo sh -c 'exec mongo "$MONGO_PORT_27017_TCP_ADDR:$MONGO_PORT_27017_TCP_PORT/test"'

  # docker run --name some-app --link main-mongo:mongo -d application-that-uses-mongo
}

function _swarm-run-redis () {
  # https://hub.docker.com/_/redis/
  local name=${1:-main-redis}
  shift; local vol=${1:-/data/run/redis}
  shift; local port=${1:-0}
  shift; local pkg=${1:-redis:latest}
  [ $port -ne 0 2>/dev/null ] && local useport="-p $port:6379 "
  local leader=$(_swarm-leader);

  [ ! -d $vol ] && {
    mkdir -p $vol
    chcon -Rt svirt_sandbox_file_t $vol
  }

  # docker run --name some-redis -d redis
  # docker run --name some-redis -d redis redis-server --appendonly yes

  echo docker -H $leader run -d --name $name $useport -v $vol:/data/db   $pkg     --storageEngine wiredTiger;
  docker -H $leader run -d \
    --name $name $useport   \
    -v $vol:/data \
    -e constraint:zone==external \
    -e SERVICE_NAME=my-$name \
    $pkg     \
    redis-server --appendonly yes || \
  ( echo "restarting $name..."; docker -H $leader restart $name; )
}
function _swarm-test-redis () {
  swarm call run -it --link main-redis:redis --rm redis redis-cli -h redis -p 6379

  # docker run --name some-app --link some-redis:redis -d application-that-uses-redis
}

function _swarm-run-rabbitmq () {
  # https://hub.docker.com/_/rabbitmq/
  local name=${1:-main-rabbitmq}
  shift; local vol=${1:-/data/run/rabbitmq}
  shift; local port=${1:-0}
  shift; local pkg=${1:-rabbitmq:3}
  [ $port -ne 0 2>/dev/null ] && local useport="-p $port:5672 "
  local leader=$(_swarm-leader);

  [ ! -d $vol ] && {
    mkdir -p $vol
    chcon -Rt svirt_sandbox_file_t $vol
  }

  # -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=password rabbitmq:3-management
  # -e RABBITMQ_DEFAULT_VHOST=vh_suwei

  echo docker -H $leader run -d --name $name $useport -v $vol:/var/lib/rabbitmq   $pkg     --storageEngine wiredTiger;
  docker -H $leader run -d \
    --name $name --hostname $name  -e RABBITMQ_ERLANG_COOKIE=${RABBITMQ_ERLANG_COOKIE:-Nvs#JDK3sd} $useport   \
    -v $vol:/var/lib/rabbitmq \
    -e constraint:zone==external \
    -e SERVICE_NAME=my-$name \
    $pkg      || \
  ( echo "restarting $name..."; docker -H $leader restart $name; )

  docker -H $leader run -d \
    --name ${name}-management --hostname $name  -e RABBITMQ_ERLANG_COOKIE=${RABBITMQ_ERLANG_COOKIE:-Nvs#JDK3sd} -p 15672   \
    -e constraint:zone==external \
    -e SERVICE_NAME=my-${name}-management \
    -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=password -e RABBITMQ_DEFAULT_VHOST=vh_suwei \
    ${pkg}-management      || \
  ( echo "restarting $name..."; docker -H $leader restart $name; )
}



function _swarm-test(){
  for ((i=0;i<30;i++)); do docker run -d nginx; done;
  for ((i=0;i<5;i++)); do docker run -d -p 81:80 nginx; done
  docker run -d --name n1 -p 81:80 nginx
  docker run -d --name n1 -p 81:80 ops.suweia.net/nginx
}
function _swarm-add-ali(){
  # https://help.aliyun.com/knowledge_detail/5974865.html
  local op="3ldl744r.mirror.aliyuncs.com"
  local dd="/etc/default/docker"
  grep -Pi "$op" $dd || sed -i -e "s/DOCKER_OPTS=\"/DOCKER_OPTS=\"\-\-registry\-mirror=https:\/\/$op /" $dd
  # echo "DOCKER_OPTS=\"--registry-mirror=https://yeyieqis.mirror.aliyuncs.com\"" | sudo tee -a /etc/default/docker
}
function _swarm-add-ali-all(){
  local op="3ldl744r.mirror.aliyuncs.com"
  local dd="/etc/default/docker"
  for h in ${SW_HOSTS[@]}; do
    sshcall $h <<< "hostname; echo \"\"; grep -Pi \"$op\" $dd || { sed -i -e \"s/DOCKER_OPTS=\\\"/DOCKER_OPTS=\\\"\-\-registry\-mirror=https:\/\/$op /\" $dd; stop docker; start docker; }"
    #break
  done
  # echo "DOCKER_OPTS=\"--registry-mirror=https://yeyieqis.mirror.aliyuncs.com\"" | sudo tee -a /etc/default/docker
}

