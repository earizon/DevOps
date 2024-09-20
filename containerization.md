# Summary <!-- { $cotainer_summary -->

[{storage.host,image.registry,]]
[[runtime,security,PM.TODO,orchestration.swarn]]
## Containerization Summary <!-- { $cotainer_summary -->

* In the late 1990's UNIX/Linux web servers exposed to public
  Internet (and public attackers) were protected by "change rooting"
  the file sistem:
  ```
                          change-rooted
  Kernel                  Web Server
  File System             File System
  ───────────             ─────────────
  /                ·····> /
  ├─ usr/          ·      ├─ cgi/
  ├─ bin/          ·      └─ html/
  ├─ var/          ·
  |  ├─ www/  ······ chroot
  |     ├─ cgi/
  |     ├─ html/
  ├─ ...

  ```
* The web server can NOT see the full file-system. It is "jailed" into
  the /var/www.  /usr/, /home/, ... are never visible to the server.
  If a remote attacker manages to take control of the server, it can
  not "scape" from the jailed file-system.
* The idea of "change rooting" the file system was extended to other
  resources controlled by the Linux kernel, including the network,
  in what is called "linux namespaces". A degree of indirection around
  real resource.
* Containers are just a human-friendly way to launch linux processes
  into a change-rooted file system with a "change-rooted" network,
  change-rooted namespace, ... . Consult `man 1 nsenter` for more
  details about namespaces.
   In practice containers behave as virtual (isolated) machines, but
  they start and stop much faster, since they are no more than
  normal linux processes running in isolated file-system, network,
  pid, ...namespaces.
* Docker containers add another big advantage: **Reproducible Builds**.
  Following best patterns, containers tools and running enviroments
  have been designed to create source-to-binary builds that can be
  replicated in developer's laptops or servers in test or production
  enviroments,
<!-- $cotainer_summary } -->


## Docker commands summary  <!-- { $command -->

### Common docker options  <!-- { -->
  ```
  --config string      Location of client config files (default "/root/.docker")
  --debug              Enable debug mode
  --host list          Daemon socket(s) to connect to
  --log-level $level   := "debug"|"info"*|"warn"|"error"|"fatal"
  --tls                Use TLS; implied by --tlsverify
  --tlscacert ...      Trust certs signed only by this CA (default "/root/.docker/ca.pem")
  --tlscert string     Path to TLS certificate file       (default "/root/.docker/cert.pem")
  --tlskey string      Path to TLS key file               (default "/root/.docker/key.pem")
  --tlsverify          Use TLS and verify the remote
  --version            Print version information and quit
  ```
<!-- } -->

### Management Commands <!-- { -->

  ```
              Manage ...
  config      Docker configs
  container   containers
  network     networks
  node        Swarm nodes
  plugin      plugins
  secret      Docker secrets
  service     services
  swarm       Swarm
  system      Docker
  trust       trust on
              Docker images
  volume      volumes
  ```
<!-- } -->

### running containers  <!-- { -->
  ```
· attach      Attach local STDIN/OUT/ERR streams to a running container
· cp          Copy files/folders between a container and the local filesystem
· create      Create a new container
· exec        Run a command in a running container
· kill        Kill one or more running containers
· logs        Fetch the logs of a container
· pause       Pause all processes within one or more containers
· restart     Restart one or more containers
· rm          Remove 1+ containers
· run         Run a command in a new container
· start       Start 1+ stopped containers
· stop        Stop 1+ running containers
· top         Display running processes for container
              NOTE: '$ docker stats' is really what most people want
              when searching for a tool similar to UNIX "top".
· port        List port mappings or specific mapping for container
· unpause     Unpause all processes within 1+ containers
· wait        Block until 1+ containers stop, print their exit codes
· rename      Rename a container
· stats       Display a live stream of container(s) resource usage statistics
· update      Update configuration of 1+ containers
              (cpu-quota, shared, kernel-memory, pids-limit, ...)
  ```
<!-- } -->

### docker Image Build/Image Management Commands <!-- { -->
* Alternatives to build docker images include: [[{doc_has.comparative]]
  ```
  Artifacts  ····┐
                 v
  Dockerfile -> |docker build| -> image                  <·· Alt 1
  ----------------------------------------------------------------
  buildah: Similar to docker build, it also allows to    <·· Alt 2
  add image-layer manually from the host command line.
  (removing the need for a Dockerfile).
  (RedHat rootless 'podman' is based on buildah)
  ----------------------------------------------------------------
  Java source code → jib → OCI image                     <·· Alt 3
  ----------------------------------------------------------------
  Google Kaniko                                          <·· Alt 4
  ----------------------------------------------------------------
  ...
  ```
[[}]]

  ```
  $ docker image   ls current (local) images.
  $ docker build   Build an image from a Dockerfile
  $ docker commit  Create a new image from a container's changes
  $ docker diff    Inspect changes to files or directories on a container's filesystem
  $ docker history Show the history of an image
  $ docker images  List images
  $ docker tag     Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE

  export/import vs save/load:                                               [[{doc_has.comparative]]

  container  ···> |docker export| ··> tar    (flattens/remove  layers)
  tar        ···> |docker import| ··> image  (single layer)

  image      ···> |docker save  | ··> tar    (keeps history of layers)
  tar        ···> |docker load  | ··> image  (multi-layer)                [[}]]

  $ docker save calc > calc.tar
           ┌──────┬─··─┴──────┘
  $ tar tf calc.tar
    ├─ 41bfa732a8...   <·· busybox layer
    │  ├─ VERSION
    │  ├─ json
    │  └─ layer.tar        cmd layer
    ├─ 889226....json  <·· { ... ,
    ├─ manifest.json         "config": { "Cmd": ["/bin/sh", "-c", ...], ...  },
    └─ repositories        }

  $ docker load < calc.tar
    0d315111b484: Loading layer [========>]  1.441MB/1.441MB

  * NOTE: docker import/export vs load/save commands.
    docker load / save : Load/Save image from/to tar | STDIN
    docker export / import: Export/Import (running/stopped) container file-system.
  ```
<!-- } -->

### docker Throubleshoot/Debug Commands :  [[{troubleshooting]]
  ```
  $ docker system events  # <·· Get real time events from the server

  $ docker events \       # <·· Get real time events from the server
    --filter ... \              <·· Can be repeated (AND added) e.g:
                                    "container=7805c1d35632"
                                    "type=volume"
                                    "type=network"
    --format ... \              eg: '{{json .}}' | go-templace (https://docs.docker.com/go/formatting/9
    --since ... \               eg: '2015-01-28' '3m'
    --until ...
    └───────┬───────────┘
    EVENTS CAN COME      EVENT EMMITED
    from ...
    -------------------  -----------------------------------------
    · containers - - - - attach|commit|copy|create|destroy|detach|
                         die|exec_create|exec_detach|exec_start|
                         export|kill|oom|pause|rename|resize|
                         restart|start|stop|top|unpause|update
    · images     - - - - delete|import|load|pull|push|save|tag|untag
    · volume     - - - - create|mount|unmount|destroy
    · network    - - - - create|connect|disconnect|destroy
    · plugin     - - - - enable|disable|install|remove
    · daemon     - - - - reload
    · docker services  - create|remove|update
    · Docker Swarn nodes create|remove|update
    · Docker secrets - - create|remove|update
    · Docker configs - - create|remove|update

  $ docker system df # --verbose
  TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
  Images          96        13        13.03GB   9.378GB (71%)
  Containers      17        11        37.42MB   2.909MB (7%)
  Local Volumes   28        7         14.4GB    8.532GB (59%)
  Build Cache     844       0         50.97GB   50.97GB

  $ docker system info    # <·· Global Info
    Containers: 23
       Running: 10
        Paused: 0
       Stopped: 1
    Images: 36
    Server Version: 17.03.2-ce
    *Storage Driver: devicemapper*
     Pool Name: docker-8:0-128954-pool
     Pool Blocksize: 65.54 kB
     Base Device Size: 10.74 GB
     Backing Filesystem: ext4
     Data file: /dev/loop0
     Metadata file: /dev/loop1
         Data Space Used      : 3.014 GB *
         Data Space Total     : 107.4 GB *
         Data Space Available : 16.11 GB *
     Metadata Space Used      : 4.289 MB *
     Metadata Space Total     : 2.147 GB *
     Metadata Space Available : 2.143 GB
    *Thin Pool Min. Free Space: 10.74 GB*
     Udev Sync Supported: true
     Deferred Removal Enabled: false
     Deferred Deletion Enabled: false
     Deferred Deleted Device Count: 0
         Data loop file: /var/...devicemapper/data
     Metadata loop file: /var/.../devicemapper/metadata
     Library Version: 1.02.137 (2016-11-30)
     Logging Driver: json-file
     Cgroup Driver: cgroupfs
    Plugins:
     Volume: local
     Network: bridge host macvlan null overlay
    Swarm: inactive
    Runtimes: runc
    Default Runtime: runc
    Init Binary: docker-init
    containerd version: 4ab9917febca...
    runc       version: 54296cf40ad8143b62...
    init       version: 949e6fa
    Security Options:    [[{security]]
     seccomp
      Profile: default   [[}]]
    Kernel Version: 4.17.17-x86_64-linode116
    Operating System: Debian GNU/Linux 9 (stretch)
    OSType: linux
    Architecture: x86_64
    CPUs: 4
    Total Memory: 3.838 GiB
    Name: MyLaptop01
    ID: ZGYA:L4MN:CDCP:DANS:IEHQ:...
    *Docker Root Dir: /var/lib/docker*
    *Debug Mode (client): false*
    *Debug Mode (server): false*
    *Registry: https://index.docker.io/v1/*
    Experimental: false
    Insecure Registries:
     127.0.0.0/8
    Live Restore Enabled: false

  $ docker inspect $DOCKER_OBJ_ID # <·· Dump low-level information on image|container|...

  $ docker ps --all     List running containers summary
                        -a/-all: show also exited containers.

  $ docker version      Show Docker version information
  ```
[[}]]
<!-- $command } -->

## Networks [[{networking]]
  ```
  $ docker network create  network01   <·· Create new network

  $ docker run \
    --network network01 \              <·· Run container in new network
    -h redis        \                      <·· "ping redis" will work on network01
    -name redis-server01

  $ docker run --rm -ti \
    --network  network01 \             <·· Use it. Now client can connect
    -d redis                               to server in shared network01.

  $ docker network ls                  <·· List existing networks

  $ docker disconnect \                <·· Disconnect server from network
    network01 redis-server01

  $ docker connect --alias db \        <- Connect server to network
    network01  redis-server01
  ```
[[}]]

## Docker Volumes [[{storage]]
  ```
  ───────────────────────────────────────── REUSING HOST VOLUMES:
  $ docker run -it --name alpha \        <- Create new container mounting
    -v $(pwd)/log:/var/log  \               host directory as volume
    ubuntu bash

  $ docker run \
    --volumes-from alpha                 <- Share volumes from alpha container
    --name beta
    ubuntu

  ───────────────────────────────────────── CREATING REUSABLE VOLUME
  $ docker volume create --name=www_data <- Create Volume
  $ docker run -d -p 8888:80 \
    -v www_data:/var/www/html            <- reuse in new (nginx) container
    -v logs:/var/log/nginx nginx

  $ docker run \
    -v  www_data:/website                <- reuse in (vi) container
    -w /website \                           <- Make it writable to container
    -it alpine vi index.html
  ```
[[}]]


## Container Registries [[{image.registry,PM.WiP]]

* OCI Image: Sort of ISO image with inmutable file system BUT ... formed 
  of different layers.

* Daily ussage:
  ```
  $ docker images                       # <·· List local (/var/lib/docker/...) images
  | REPOSITORY                  TAG             IMAGE ID      CREATED       SIZE
  | gitea/gitea                 1.20.1-rootless eb341527606d  4 months ago  261MB
  | postgres                    14.5            cefd1c9e490c  13 months ago 376MB
  | golang_1.17_alpine3.15_gcc  latest          6093faef6d66  17 months ago 438MB
  | ...
  | hello-world                 latest          feb5d9fea6a5  2 years ago   13.3kB       
  ```

  ```
  $ docker rmi ${IMG_NAME}:${IMG_VER}   # <·· remove (local) image

  $ docker image prune                  # <·· remove all non used images
  ```


* Registries and Repositories ("Image repo") allow for a simple way
  to publish and make new images accesible "Internet-wide".  
  REF 1: [https://docs.docker.com/registry/#what-it-is],  
  REF 2: [https://docs.docker.com/registry/introduction/]

  ```
  repository: "storage" for OCI binary images with a common http
              network protocol to "push" and "pull" new OCI images
              (actually, OCI "layers") and cryptographic hash
              protection against tampered images.
  registry  : index of 1+ repositories (ussually its own repo), and
              network protocol to query the index remotely.
  ```

## Registry Daily Ussage:

* In a shell console at server01:
  ```
  (shell console@server01) ───────────────────────────────────────────
  $ docker run -d \            <·· Start registry v2 at server01:5000
    -p 5000:5000 \
    --restart=always \
    --name registry registry:2
  ```

* In a shell console at dev-laptop:
  ```
  (shell console@local-dev-laptop) ───────────────────────────────────
  $ docker search ubuntu         <·· Search remote images @ Docker Hub:
    NAME                 DESCRIPTION    STARS     OFFICIAL   AUTOMATED
 ┌> ubuntu               Ubuntu is a... 16627     [OK]
 ·  ubuntu/nginx         Nginx, a hi... 102
 ·  ubuntu/squid         Squid is a ... 70
 ·  ...
 ·  ^^^^^^^^^^^^
 ·  
 └> To see also avaiable tags: (latest by default)···········┬────┐
                                                             ·    · 
  $ curl -s \                                                v    v
    'https://registry.hub.docker.com/v2/repositories/library/ubuntu/tags/' | \
    jq '."results"[]["name"]'
  | "latest"
  | "rolling"
  | ...
  | "23.10"
  | "23.04"
  | ...

  $ docker pull ubuntu           <·· Pull (example) image from public
                                    registry to /var/lib/docker/image
  
  $ docker image tag ubuntu \    <·· Add new tag to the image to "point"
    server01:5000/myfirstimage        to local registry
 
  $ docker login           \     <·· Optional. If user/pass is required
       -u ${LOGIN_USER}    \         (on success a local access token will
       -p ${SESSION_TOKEN} \         be created and reused in next comands)
       server01:5000 

  $ docker push \                <·· Push to registry@server01
    server01:5000/myfirstimage

  $ docker pull \                <·· final Check
    server01:5000/myfirstimage
  ```

### Add Insecure HTTP registry  [[{image.registry,troubleshooting]]
* REF: <https://www.projectatomic.io/blog/2018/05/podman-tls/>
  ```
  cat /etc/containers/registries.conf
  # ...
  [registries.search]
  registries = ['docker.io', ..., server01:5000 ]
                                  └───────────┴─ non-TLS server
  ```
[[}]]
[[image.registry}]]



## Managing Runing Containers [[{]]

```
$ docker run \                   <·· Create and run container based on imageXX
  --rm \                         <·· Remove on exit (remove to see container's logs after exit)
  --name name01 \                <·· assign name (or fail if name already assigned)
  --network network01 \          <·· attach to network01 (that must have been created previously)
  somerepo/image01

$ docker logs $container \       <·· Dump full container logs
    --since "2023-11-22T10:00" \    <·· Optional
    --until "2023-11-22T10:30" \    <·· Optional
    --tail 100 \                    <·· Optional
    --follow                        <·· "follow" future logs

$ docker stop $container  && \   <- Try to stop container properly.
  sleep 30 && \
  docker kill containerXX        <- Finally if it doesn't respond in 30 secs.

$ docker system df # --verbose
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          96        13        13.03GB   9.378GB (71%)
Containers      17        11        37.42MB   2.909MB (7%)
Local Volumes   28        7         14.4GB    8.532GB (59%)
Build Cache     844       0         50.97GB   50.97GB
```

## Prunning Storage [[troubleshooting.101,storage.host]]

* [REF](https://docs.docker.com/engine/reference/commandline/builder_prune/)
```
$ docker volume prune # <- Prune stopped containers
                      # --all           Remove all unused build cache, not just dangling ones
                      # --keep-storage  Amount of disk space to keep for cache
                      # --filter        Provide filter values (e.g. until=24h)
                      # --force
[[troubleshooting.101}]]
```

## Monitoring running containers [[{monitoring]]

* List containers instances:
  ```
   $ docker ps     # only running
   $ docker ps -a  # also finished, but not yet removed (docker rm ...)
   $ docker ps -lq # TODO:
  ```
* "top" containers showing Net IO read/writes, Disk read/writes:
  ```
   $ docker stats
   CONTAINER ID   NAME                    CPU %   MEM USAGE / LIMIT     MEM %   NET I/O          BLOCK I/O      PIDS
   c420875107a1   postgres_trinity_cache  0.00%   11.66MiB / 6.796GiB   0.17%   22.5MB / 19.7MB  309MB / 257kB  16
   fdf2396e5c72   stupefied_haibt         0.10%   21.94MiB / 6.796GiB   0.32%   356MB / 693MB    144MB / 394MB  39

   $ docker top 'containerID'
   UID       PID     PPID    C  STIME  TTY   TIME     CMD
   systemd+  26779   121423  0  06:11  ?     00:00:00 postgres: ddbbName cache 172.17.0.1(35678) idle
   ...
   systemd+  121423  121407  0  Jul06  pts/0 00:00:44 postgres
   systemd+  121465  121423  0  Jul06  ?     00:00:01 postgres: checkpointer process
   systemd+  121466  121423  0  Jul06  ?     00:00:26 postgres: writer process
   systemd+  121467  121423  0  Jul06  ?     00:00:25 postgres: wal writer process
   systemd+  121468  121423  0  Jul06  ?     00:00:27 postgres: autovacuum launcher process
   systemd+  121469  121423  0  Jul06  ?     00:00:57 postgres: stats collector process
  ```
[[}]]

## Rootless Mode [[{PM.TODO,security]]

* Docker (v20.10+)
* https://docs.docker.com/engine/security/rootless/
[[}]]

## Dockviz: dependency graph [[{monitoring,troubleshooting]]
* <https://github.com/justone/dockviz>
* Show a graph of running containers-dependencies and image-dependencies.
* Example ussage:
  ```
  $ dockviz images -
  └─511136ea3c5a Virtual Size: 0.0 B
    ├─f10ebce2c0e1 Virtual Size: 103.7 MB
    │ └─82cdea7ab5b5 Virtual Size: 103.9 MB
    │   └─5dbd9cb5a02f Virtual Size: 103.9 MB
    │     └─74fe38d11401 Virtual Size: 209.6 MB Tags: ubuntu:12.04, ubuntu:precise
    ├─ef519c9ee91a Virtual Size: 100.9 MB
    └─02dae1c13f51 Virtual Size: 98.3 MB
      └─e7206bfc66aa Virtual Size: 98.5 MB
        └─cb12405ee8fa Virtual Size: 98.5 MB
          └─316b678ddf48 Virtual Size: 169.4 MB Tags: ubuntu:13.04, ubuntu:raring
  ```

  ```
  $ dockviz images -t -l                   #  <- show only labelled images
  └─511136ea3c5a Virtual Size: 0.0 B
    ├─f10ebce2c0e1 Virtual Size: 103.7 MB
    │ └─74fe38d11401 Virtual Size: 209.6 MB Tags: ubuntu:12.04, ubuntu:precise
    ├─ef519c9ee91a Virtual Size: 100.9 MB
    │ └─a7cf8ae4e998 Virtual Size: 171.3 MB Tags: ubuntu:12.10, ubuntu:quantal
    │   ├─5c0d04fba9df Virtual Size: 513.7 MB Tags: nate/mongodb:latest
    │   └─f832a63e87a4 Virtual Size: 243.6 MB Tags: redis:latest
    └─02dae1c13f51 Virtual Size: 98.3 MB
      └─316b678ddf48 Virtual Size: 169.4 MB Tags: ubuntu:13.04, ubuntu:raring
  ```

  ```
  $ dockviz images - -i *                 #  <- Show incremental size (vs cumulative)
  └─511136ea3c5a Virtual Size: 0.0 B
    ├─f10ebce2c0e1 Virtual Size: 103.7 MB
    │ └─82cdea7ab5b5 Virtual Size: 255.5 KB
    │   └─5dbd9cb5a02f Virtual Size: 1.9 KB
    │     └─74fe38d11401 Virtual Size: 105.7 MB Tags: ubuntu:12.04, ubuntu:precise
    └─02dae1c13f51 Virtual Size: 98.3 MB
      └─e7206bfc66aa Virtual Size: 190.0 KB
        └─cb12405ee8fa Virtual Size: 1.9 KB
          └─316b678ddf48 Virtual Size: 70.8 MB Tags: ubuntu:13.04, ubuntu:raring
  ```
[[}]]

# docker compose [[{orchestration.docker-compose]]

* "Self documenting" YAML file defining services, networks and volumes.
* Full ref: <https://docs.docker.com/compose/compose-file/>
* Ideal to create development/production enviroments running just on a single host
  (vs a pool of workers, like it's the case with Kubernetes, AWS EC2, ...)
* Best Patterns: https://docs.docker.com/compose/production/  [[PM.TODO]]
* Docker compose example:
  C&P from <https://github.com/bcgov/moh-prime/blob/develop/docker-compose.yml>
  ```
  ---
  version: "3"

  services:
  ######################################################### Database #
    postgres:
      restart: always                       # <- "always", "on-failure:5", "no"
      container_name: primedb
     *image: postgres:10. *                 # use pre-built image
      environment:
        POSTGRES_PASSWORD: postgres
        ...
      ports:
        - "5432:5432"
      volumes:
        - local_postgres_data:/var/lib/postgresql/data
     *networks:*                            # ← Networks to connect to
     *  - primenet*
  ########################################################## MongoDB #
    mongo:
      restart: always
      container_name: primemongodb
      image: mongo:3
      environment:
        MONGO_INITDB_ROOT_USERNAME: root
        ...
      ports:
        - 8081:8081
      volumes:
        - local_mongodb_data:/var/lib/mongodb/data
     *networks:*
     *  - primenet*
  ############################################################## API #
    dotnet-webapi:
      container_name: primeapi
      restart: always
     *build:*                               # ← use Dockerfile to build image
        context: prime-dotnet-webapi/   *WARN*: remember to rebuild image and recreate
                                              app’s containers like:
                                            ┌───────────────────────────────────────────────┐
                                            │ $ docker-compose build dotnet-webapi          │
                                            │                                               │
                                            │ $ docker-compose up \ ← stop,destroy,recreate │
                                            │   --no-deps           ← prevents from also    │
                                            │   -d dotnet-webapi      recreating any service│
                                            │                         primeapi depends on.  │
                                            └───────────────────────────────────────────────┘
      command: "..."
      environment:
        ...
     *ports:          *  ← Exposed ports outside private "primenet" network
     *  - "5000:8080" *  ← Map internal port (right) to "external" port
     *  - "5001:5001" *
     *expose:*          ←   Expose ports without publishing to host machine
     *   - "5001"*          (only accessible to linked services).
                             Use internal port.
     *networks:*
     *  - primenet*
      depends_on:
        - postgres
  ##################################################### Web Frontend #
    nginx-angular:
      build:
           context: prime-angular-frontend/
      ...
  ################################################ Local SMTP Server #
    mailhog:
      container_name: mailhog
      restart: always
      image: mailhog/mailhog:latest
      ports:
        - 25:1025
        - 1025:1025
        - 8025:8025 # visit localhost:8025 to see the list of captured emails
      ...
  ########################################################### Backup #
    backup:
      ...
      restart: on-failure
      volumes:
       *- db_backup_data:/opt/backup*
      ...

  volumes:
    local_postgres_data:
    local_mongodb_data:
    db_backup_data:

 *networks:*
    primenet:
      driver: bridge

 *Example  *
  ---
  version: '3.6'

  # reusable yaml template ############################################
  x-besu-bootnode-def:
    &besu-bootnode-def
    restart: "on-failure"
    image: hyperledger/besu:${BESU_VERSION:-latest}
    environment:
      - LOG4J_CONFIGURATION_FILE=/config/log-config.xml
    entrypoint:
      - /bin/bash
      - -c
      - |
        /opt/besu/bin/besu public-key export --to=/tmp/bootnode_pubkey;
        /opt/besu/bin/besu \
        --config-file=/config/config.toml \
        --p2p-host=$$(hostname -i) \
        --genesis-file=/config/genesis.json \
        --node-private-key-file=/opt/besu/keys/key \
        --min-gas-price=0 \
        --rpc-http-api=EEA,WEB3,ETH,NET,PERM,${BESU_CONS_API:-IBFT} \
        --rpc-ws-api=EEA,WEB3,ETH,NET,PERM,${BESU_CONS_API:-IBFT} ;

  # reusable yaml template ############################################
  x-besu-def:
    &besu-def
    restart: "on-failure"
    image: hyperledger/besu:${BESU_VERSION:-latest}
    environment:
      - LOG4J_CONFIGURATION_FILE=/config/log-config.xml
    entrypoint:
      - /bin/bash
      - -c
      - |
        while [ ! -f "/opt/besu/public-keys/bootnode_pubkey" ]; do sleep 5; done ;
        /opt/besu/bin/besu \
        --config-file=/config/config.toml \
        --p2p-host=$$(hostname -i) \
        --genesis-file=/config/genesis.json \
        --node-private-key-file=/opt/besu/keys/key \
        --min-gas-price=0 \
        --rpc-http-api=EEA,WEB3,ETH,NET,PERM,${BESU_CONS_API:-IBFT} \
        --rpc-ws-api=EEA,WEB3,ETH,NET,PERM,${BESU_CONS_API:-IBFT} ;

  services:
  # using the YAML template ####################################################
    validator1:
      << : *besu-bootnode-def
      volumes:
        - public-keys:/tmp/
        - ./config/besu/config.toml:/config/config.toml
        - ./config/besu/permissions_config.toml:/config/permissions_config.toml
        - ./config/besu/log-config.xml:/config/log-config.xml
        - ./logs/besu:/var/log/
        - ./config/besu/${BESU_CONS_ALGO:-ibft2}Genesis.json:/config/genesis.json
        - ./config/besu/networkFiles/validator1/keys:/opt/besu/keys
      networks:
        quorum-dev-quickstart:
          ipv4_address: 172.16.239.11
  # using the YAML template ####################################################
    validator2:
      << : *besu-def
      volumes:
        - public-keys:/opt/besu/public-keys/
        - ./config/besu/config.toml:/config/config.toml
        - ./config/besu/permissions_config.toml:/config/permissions_config.toml
        - ./config/besu/log-config.xml:/config/log-config.xml
        - ./logs/besu:/var/log/
        - ./config/besu/${BESU_CONS_ALGO:-ibft2}Genesis.json:/config/genesis.json
        - ./config/besu/networkFiles/validator2/keys:/opt/besu/keys
      depends_on:
        - validator1
      networks:
        quorum-dev-quickstart:
          ipv4_address: 172.16.239.12
  # using the YAML template ####################################################
    ...
  volumes:
    public-keys:
    prometheus:
    grafana:

  networks:
    quorum-dev-quickstart:
      driver: bridge
      ipam:
        config:
          - subnet: 172.16.239.0/24
  ```

## SystemD Integration <!-- { systemD -->
* STEP 1) Create some config at /etc/compose/docker-compose.yml
* STEP 2) Create systemd Service:
  ```
  $ cat /etc/systemd/system/docker-compose.service
  | (Service unit to start and manage docker compose)
  | [Unit]
  | Description=Docker Compose container starter
  | After=docker.service network-online.target
  | Requires=docker.service network-online.target
  |
  | [Service]
  | WorkingDirectory=/etc/compose
  | Type=oneshot
  | RemainAfterExit=yes
  |
  | ExecStartPre=-/usr/local/bin/docker-compose pull --quiet
  | ExecStart=/usr/local/bin/docker-compose up -d
  |
  | ExecStop=/usr/local/bin/docker-compose down
  |
  | ExecReload=/usr/local/bin/docker-compose pull --quiet
  | ExecReload=/usr/local/bin/docker-compose up -d
  |
  | [Install]
  | WantedBy=multi-user.target
  ```

  ```
  $ cat  /etc/systemd/system/docker-compose-reload.service
  | (Executing unit to trigger reload on docker-compose.service)
  | [Unit]
  | Description=Refresh images and update containers
  |
  | [Service]
  | Type=oneshot
  |
  | ExecStart=/bin/systemctl reload-or-restart docker-compose.service
  ```

  ```
  $ cat /etc/systemd/system/docker-compose-reload.timer
  | (Timer unit to plan the reloads)
  | [Unit]
  | Description=Refresh images and update containers
  | Requires=docker-compose.service
  | After=docker-compose.service
  |
  | [Timer]
  | OnCalendar=*:0/15
  |
  | [Install]
  | WantedBy=timers.target
  ```
<!-- systemD } -->
[[orchestration.docker-compose}]]

# Building images [[{image.build.dockerfile]]

## Commented Dockerfile
  ```
  ┌─ Dockerfile ───────────────────────────────
  │ FROM registry.redhat.io/ubi7/ubi           <- 72.7 MB layer
  │ # Optional but recommended Standard labels
  │ LABEL org.label-schema.build-date=2022-02-17T05:47Z
  │ LABEL org.label-schema.description=...
  │ LABEL org.label-schema.name=...,
  │ LABEL org.label-schema.schema-version=1.0,
  │ LABEL org.label-schema.url=https://docs.myapp.mycomp.net,
  │ LABEL org.label-schema.vcs-ref=4c42aec7,
  │ LABEL org.label-schema.vcs-url=https://github.com/mycomp/myapp,
  │ LABEL org.label-schema.vendor=MyComp,
  │ LABEL org.label-schema.version=1.1.0
  │
  │ ARG ENV_DEBUG=LOG                         <- ARG: Available at Image build time
  │                                              default value = LOG. Overwrite with:
  │                                              $ docker build --build-arg ENV_DEBUG=INFO
  │
  │ ENV DEBUG=${ENV_DEBUG}                    <- ENV: Available at container runtime.
  │                                              Overwrite with:
  │                                              $ docker run -e DEBUG=INFO ...
  │ ARG ENV_HTTP_PROXY                        <- No default value. Build will fail if
  │                                              not provided at build time.
  │ ARG ENV_HTTPS_PROXY                       <- No default value. Build will fail if
  │ ENV ENV_HTTP_PROXY=${ENV_HTTP_PROXY}
  │
  │ RUN dnf update                             <- 30.1 MB layer
  │ COPY target/dependencies /app/dependencies <- 10.0 MB layer
  │ COPY target/resources    /app/resources    <-  9.0 MB layer
  │ COPY target/classes      /app/classes      <-  0.5 MB layer
  │                                               └──┬──┘
  │ ENTRYPOINT java -cp \                        Put most frequently changed
  │   /app/dependencies/*:... \                  layer down the layer "stack",
  │   my.app.Main                                so that when building and/or
  │                                              uploading new images only
  │                                              them will be affected.  Probably
  │                                              the most frequently changed layer
  │                                              is also the smaller layer.
  │
  │ ENTRYPOINT java -cp \            <- Defaults to '/bin/sh -c'
  │   /app/dependencies/*:... \         - Overwrite at "docker run"-time with --entrypoint ...
  │                                     - similar to "init" process in Linux. (First command
  │                                       to be executed in a Linux box).
  │                                     - It will act, in practice, as the binary executable. Ex:
  │                                       $ alias CAT="docker run --entrypoint /bin/cat myImage"
  │                                       $ CAT /etc/passwd
  │
  │ COMMAND [ 'my.app.Main']        <- No default exist.
  │                                     - Overwrite at "docker run"-time like:
  │                                       $ docker run -i -t ubuntu my.app.Main2 arg1 arg2
  └────────────────────────────────────────────
  ```

  ```
  $ docker build \
     --pull \                                      <·· Recomended, force look for newer
                                                       remote image versions
                                                       (--no-cache can also be useful)
     --build-arg HTTP_PROXY=http://...:8080 \      <·· Arg is consumed/used at build time
                                                       Not available at runtime.
     --build-arg HTTPS_PROXY=https://..:8080 \
     -t 'registry_server'/'user_name'/'image_name':'tag' .
        ^^^^^^^^^^^^^^^^^^
        default one if not
        provided
  ```

## Parent-Child Build

  ```
  ┌ Dockerfile.base ───────────
  │ FROM node:7.10-alpine
  │
  │ RUN mkdir /src
  │ WORKDIR /src
  │ COPY package.json /src      ← Modifying package.json forces rebuild
  │                               triggering a new npm install.
  │                               WARN: It will fail if wrongly placed after npm install.
  │                                     Docker will not detect any change.
  │
  │ RUN npm install             ← slow process. Place before "moving parts"
  │                               (but after any file affecting the install
  │                                - package.json, package-lock.json, ...-)
  │
  │ ONBUILD ARG NODE_ENV        ← Modify base image adding "ONBUILD" in places that
  │                               are executed just during build in "child" image
  │                               extending base image
  │
  │ ONBUILD ENV NODE_ENV $NODE_ENV
  │
  │ CMD [ "npm", "start" ]
  └────────────────────────────

  ┌ Dockerfile.child ────
  │ FROM node-base
  │
  │ EXPOSE 8000
  │ COPY . /src       ← source code, images, CSS, ...  will change frequently
  └──────────────────── during development.  Put in last position (top layer
                        in image) so that new modification triggers just
                        rebuild of last layer.

   $ docker build -t node-base  \  <-  STEP 1) Compile base image
     -f Dockerfile.base .

  $ docker build -t node-child \   <- STEP 2: Compile child image
    -f Dockerfile.child \
      --build-arg NODE_ENV=... .

  $ docker run -p 8000:8000 \      <- STEP 3: Test
   -d node-child *
  ```

## MultiStage Go Build [[{image.build,dev_stack.golang,qa]]
@[https://docs.docker.com/develop/develop-images/multistage-build/]

  ```
  $ cat Dockerfile.multistage            <·· STAGE 1
   FROM *golang-1.14:alpine* AS *build*  ← Base Image with compiler, utility libs, ...
   ADD . /src                            │ ( Maybe "hundreds" of MBs)
   RUN cd /src ; go build  *-o app*      ←  Let's Build final  *executable*
                                         │
                                         │ Stage 2:
   FROM *alpine:1.14*                    ← Clean minimal image (maybe just ~4MB).
   WORKDIR /app                          │
   COPY*--from=build*  */src/app* /app/  ← Copy  *executable* to final image
   ENTRYPOINT ./app                      │
  ───────────────────────────────────────┘

 $*$ docker build . -f Dockerfile.multistage \ *  Build image from multistage Dockerfile
 $*  -t ${IMAGE_TAG}                           *

 $*$ docker run --rm -ti ${IMAGE_TAG}          *  Finally Test it.
 ```
[[image.build,dev_stack.golang}]]

## MultiStage NodeJS Build [[{dev_stack.nodejs,image.build,qa]]
PRESETUP:
* Check with `$ npm list --depth 3` duplicated or similar dependencies.  
  Try to fix manually in package.json
* `npm audit` (See also online services like https://snyk.io,...)
* Avoid leaking dev ENV.VARs/secrets/...:

  ```
        Alt 1:                     Alt 2: (Safer)
      ┌─ .dockerignore ────────┐   ┌─ .dockerignore ────────┐
      │ + node_modules/        │   │ # ignore by default    │
      │ + .npmrc         ← ** *│   │ *                      ← Now it's safe to just:
      │ + .env                 │   │                        │ COPY . /my/workDir
      │ + ....                 │   │ !/docker-entrypoint.sh ← Explicetely mark what we want to copy.
      └────────────────────────┘   │ !/another/file.txt     ←
                                   └────────────────────────┘
  ```
  **WARN**: Sometimes `npmrc` can contain secrets. [[{security.secret_management}]]
  
  ```
                                              STAGE 1:
  | FROM node:14.2.0-alpine3.11 AS build  <·· DONT's: Avoid non-deterministic versions (e.g: node, node:14)
  |                                           sha256 can also be use to lock to precise version.
  |                                           node:lts-alpine@sha256:aFc342a...
  |                                          
  | ADD . / appsrc/                      
  |                                           @[https://docs.npmjs.com/cli/v7/commands/npm-ci]
  | RUN npm ci --only=production          <·· ci: == npm install optimized for Continuous Integrations
  |                                               Significantly faster when:
  |                                               - There is a package-lock.json|npm-shrinkwrap.json file
  |                                               - node_modules/ folder is missing|empty.
  |                                           --only=production: Skip testing/dev dependencies.
  |                                           WARN: Avoid npm install (yarn install)
  |                                          
  | FROM node:16.10.0-alpine3.13          <·· Use stage1 image. NOTE: In node we still need the
  |                                           "big" image, since output artifacts are not self-executables.
  | RUN mkdir /app                           
  | WORKDIR /app                              We can still save some space removing un-needed sources.
  | USER node                              <·· Avoid root
  | COPY *--from=build* --chown=node:node \<·· Forget source, ... Keep only  *"dist/"* executable and
  |      /appsrc/dist  /app                   (unfortunatelly) keep also the big (tens/hundreds of MBs)
  | COPY *--from=build* --chown=node:node \   node_modules/ folder, still needed in production.
  |      /appsrc/node_modules \
  |      /app/node_modules                   
  |                                          
  | ENV NODE_ENV production                <·· Some libs enable optimization  only when PRODUCTION=true
  |                                         
  |                                         
  | ENTRYPOINT ["node", "/app/dist/cli.js"] ← TODO: Check "dumb-init" alternative. *1


  *1 NOTE: to allow nodeJS handle OS signals add some code like:
     async function handleSigInt(signal) {
         await fastify.close()
         process.exit()
     }
     process.on('SIGINT', handleSigInt)
     (Check alternatives in other languages)
  ```
[[image.build}]]

## MultiStage distroless JAVA Build [[{image.build,dev_stack.java,qa]]

* @[https://github.com/googlecontainertools/distroless/blob/master/examples/java/dockerfile]
  ```
  FROM openjdk:11-jdk-slim as build-env    <·· stage 1) compile using "bloated jdk"
  ADD . /app/examples
  WORKDIR /app
  RUN javac examples/*.java
  RUN jar cfe main.jar \
      examples.hellojava examples/*.class

  from gcr.io/distroless/java:11           <·· stage 2) copy compiled jars to distroless
  copy --from= *build-env* /app /app
  workdir /app
  cmd ["main.jar"]
  ```


 [[}]]
[[image.build.dockerfile}]]

[[}]]

# Runtimes <!-- { $runtimes -->

## Runtime Comparative Summary <!-- { -->
  ```
  runC        Golang, by docker and others  <·· Alt 1
  ---------------------------------------------------
  Crun        C-based, faster than runC     <·· Alt 2
  ---------------------------------------------------
  containerd  by IBM and others             <·· Alt 2
  ---------------------------------------------------
  CRI-O:      lightweight k8s alterantive   <·· Alt 3
  ---------------------------------------------------
  rklet                                     <·· Alt 3
  ---------------------------------------------------
  ```
<!-- } -->

## runc [[{ $runc ]]

* @[https://github.com/opencontainers/runc]
* Reference runtime and cli tool donated by Docker for spawning and
  running containers according to the OCI specification.
  (@[https://www.opencontainers.org/])
* **It reads a runtime specification and configures the Linux kernel.
  Eventually it creates and starts container processes. **
  ```
   Go might not have been the best programming language for this task.
   since it does not have good support for the fork/exec model of computing
   - Go's threading model expects programs to fork a second process and then
     to exec immediately.
   - However, an OCI container runtime is expected to fork off the first
     process in the container.  It may then do some additional
     configuration, including potentially executing hook programs, before
     exec-ing the container process. The runc developers have added a lot
     of clever hacks to make this work but are still constrained by Go's
     limitations.
   crun, C based, solved those problems.
  ```
[[ $runc }]]

## crun [[{$crun]]
@[https://github.com/containers/crun/issues]  
@[https://www.redhat.com/sysadmin/introduction-crun]  

* fast, low-memory footprint container runtime by Giuseppe Scrivanoby (RedHat).
* C based: Unlike Go, C is not multi-threaded by default, and was built
  and designed around the fork/exec model.
  It could handle the fork/exec OCI runtime requirements in a much cleaner
  fashion than 'runc'. C also interacts very well with the Linux kernel.
  It is also lightweight, with much smaller sizes and memory than runc(Go):
  compiled with -Os, 'crun' binary is ~300k (vs ~15M 'runc')
  "" We have experimented running a container with just  *250K limit set*.""
  *or 50 times smaller.* and up to  *twice as fast.
* `cgroups v2` ("==" Upstream kernel, Fedora 31+) compliant from the scratch
  while runc -Docker/K8s/...-  **gets "stuck" into cgroups v1.**
  (experimental support in 'runc' for v2 as of v1.0.0-rc91, thanks to
  Kolyshkin and Akihiro Suda).
* feature-compatible with "runc" with extra experimental features.
* Given the same Podman CLI/k8s YAML we get the same containers "almost
  always" since  **the OCI runtime's job is to instrument the kernel to
  control how PID 1 of the container runs. It is up to higher-level tools
  like `conmon` or the container engine to monitor the container.**
* Sometimes users want to limit number of PIDs in containers to just one.
  With 'runc' PIDs limit can not be set too low, because the Go runtime
  spawns several threads.
  `crun`, written in C, does not have that problem.  Ex:
  ```
  $ RUNC="/usr/bin/runc" , CRUN="/usr/bin/crun"
  $ podman --runtime $RUNC run --rm --pids-limit 5 fedora echo it works
                                    └────────────┘
  →  Error: container create failed (no logs from conmon): EOF
  $ podman --runtime $CRUN run --rm --pids-limit 1 fedora echo it works
                                    └────────────┘
  →  it works
  ```
* OCI hooks supported, allowing the execution of specific programs at
  different stages of the container's lifecycle.

### runc/crun comparative

* 'crun' is more portable: Ex: Risc-V.
* Performance:
  ```
  $ CMD_RUNC="for i in {1..100}; do runc run foo < /dev/null; done"
  $ CMD_CRUN="for i in {1..100}; do crun run foo < /dev/null; done"
  $ time -v sh -c "$CMD_RUNC"
  → User time (seconds): 2.16
  → System time (seconds): 4.60
  → Elapsed (wall clock) time (h:mm:ss or m:ss): 0:06.89
  → Maximum resident set size (kbytes): 15120
  → ...
  $ time -v sh -c "$CMD_CRUN"
  → ...
  → User time (seconds): 0.53
  → System time (seconds): 1.87
  → Elapsed (wall clock) time (h:mm:ss or m:ss): 0:03.86
  → Maximum resident set size (kbytes): 3752
  → ...
  ```

### Experimental features
* redirecting hooks STDOUT/STDERR via annotations.  
  - Controlling stdout and stderr of OCI hooks
    Debugging hooks can be quite tricky because, by default,
    it's not possible to get the hook's stdout and stderr.  
  - Getting the error or debug messages may require some yoga.  
  - common trick: log to syslog to access hook-logs via journalctl.
                   (Not always possible)  
  - With 'crun' + 'Podman':
  ```
    $ podman run --annotation run.oci.hooks.stdout=/tmp/hook.stdout 
                              └───────────────────────────────────┘
                               executed hooks will write:
                                STDOUT → /tmp/hook.stdout
                                STDERR → /tmp/hook.stderr
   (proposed fo OCI runtime spec)
  ```

* crun supports running older versions of systemd on cgroup v2 using
  `--annotation run.oci.systemd.force_cgroup_v1`.  
  This forces a cgroup v1 mount inside the container for the `name=systemd` hierarchy,
  which is enough for systemd to work.
  Useful to run older container images, such as RHEL7, on a cgroup v2-enabled system.
  Ej:
  ```
  $ podman run --annotation \
    run.oci.systemd.force_cgroup_v1=/sys/fs/cgroup \ 
    centos:7 /usr/lib/systemd/systemd
  ```
* Crun as a library:  
  "We are considering to integrate it with  *conmon, the container monitor used by
   Podman and CRI-O, rather than executing an OCI runtime."
* 'crun' Extensibility:  
  """... easily to use all the kernel features, including syscalls not enabled in Go."""
  -Ex: openat2 syscall protects against link path attacks (already supported by crun).
[[$crun}]]

<!-- $runtimes } -->

## dive: explore/shrink Images [[{image.build,troubleshooting.101,qa,]]
* UI tool for exploring an image's layer contents, and discovering
  ways to shrink it. 
* REF 1: @[https://github.com/wagoodman/dive], 
* HOW-TO:     
  ```
  $ alias dive="docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"
  $ dive ${image_tag} \  # <·· Analyze Docker image
    --source docker      # <·· Opt. image "fetch" origin
                         #     docker *      : Docker engine 
                         #     podman        : Podman engine 
                         #     docker-archive: tar file from disk

  $ dive build \         # <·· Build image, then analyze it
     -t ${image_tag} . 
  ```
* CI Integration
  ```
  $ export CI=true # <·· bypass UI, return pass/fail return code. 
  $ editor .dive-ci
  + rules:
  +   lowestEfficiency: 0.95
  +   highestWastedBytes: 20MB
  +   highestUserWastedPercent: 0.20
  ```
* KeyBindings
  ```
             Description
  Ctrl+C     Exit
  Tab        Switch layer <··> filetree views
  Ctrl+F     Filter files
  PageUp/Dw  Scroll up/down a page
  Ctrl+A     Layer view: see aggregated image modifications
  Ctrl+L     Layer view: see current layer modifications
             Filetree view:
  Space      (un)collapse directory
  Ctrl+Space (un)collapse all directories
  Ctrl+A     show/hide      added files
  Ctrl+R     show/hide    removed files
  Ctrl+M     show/hide   modified files
  Ctrl+U     show/hide unmodified files
  Ctrl+B     show/hide attributes of file 
  ```

[[}]]

## distroless  [[{image.build,security,qa]]
@[https://github.com/googlecontainertools/distroless]
* "distroless" images contain only application and its runtime dependencies.
  (not package managers, shells, /tmp, /etc/passwd, ...)
  notice: in kubernetes we can also use init containers with non-light images
  containing all set of tools (sed, grep,...) for pre-setup, avoiding
  any need to include in the final image.
* C&P from: https://www.linkedin.com/posts/iximiuz_what-is-a-distroless-container-image-activity-6998607273514123264-PmHT
  What is a Distroless Container Image? Golang is famous for its
  statically linked binaries. Drop it into a "FROM scratch" container,
  and call it a day. But there is a bunch of pitfalls with this approach...  
  1. "FROM scratch" containers lack proper user management.
  (no /etc/passwd and /etc/group, no /var/, /etc/) -unless mounted at runtime).
   Just trying to create a tmp file will make things fail.
  2. "FROM scratch" containers lack CA certificates or timezone databases.
     Calling HTTPS endpoints or time conversion won't be possible.  
  3. "FROM scratch" containers lack your language runtime for any no-Golang
     platform, requiring tedious copying of app dependencies.
  4. "FROM scratch" images are slim, fast, secure, but apparently but 
     require some (maybe huge) extra work to put into production.  
  
  Luckily, projects like Chainguard Images and GoogleContainerTools' distroless
  automate many of these tedious preparation steps.  
  more about common pitfalls of scratch container images and the
  GoogleContainerTools' distroless project in my [blog post](https://lnkd.in/eyTkTX5p).
  ```
  stable:                      experimental (2019-06)
  gcr.io/distroless/static     gcr.io/distroless/python2.7
  gcr.io/distroless/base       gcr.io/distroless/python3
  gcr.io/distroless/java       gcr.io/distroless/nodejs
  gcr.io/distroless/cc         gcr.io/distroless/java/jetty
                               gcr.io/distroless/dotnet
  ```
[[}]]

## Kaniko (rootless builds) [[{image.build,PM.TODO]
NOTE: To build *JAVA images* see also @[/JAVA/java_map.html?query=jib]
@[https://github.com/GoogleContainerTools/kaniko]

* tool to build images inside an unprivileged container or Kubernetes cluster.
* It does not depend on a Docker daemon and instead executes each Dockerfile
  command in userspace and snapshots the resulting filesystem changes.
* The majority of Dockerfile commands can be executed with kaniko, with
  the current (201?) exception of SHELL, HEALTHCHECK, STOPSIGNAL, and ARG.
* Multi-Stage Dockerfiles are also unsupported currently. 
[[}]]

## buildpacks.io source ···> image  [[{image.build,pm.low_code,dev_stack.java]]
@[buildpacks.io]

* CNFC project
* Compared to Kaniko:
  ```
  Kaniko:
  source + Dockerfile + BuildTemplate(optional)  ···> OCI image

  buildpacks: (No Dockerfile needed at all)
  source                                         ···> OCI image

  (with dev stack -Java/Go/...- and dependencies autodetection )
  ```
* highly modular and customizable.
* used, among others, by Spring (spring boot 2.3+) with Gradle and 
  Maven support. e.g.: springboot gradle integration:
  ```
  bootbuildimage {
    imagename = "${docker.username}/${project.name}:${project.version}"
    environment = ["bp_jvm_version" : "11.*"]
  }
  ```
* promotes best practices in terms of security.
* defining CPU and memory limits for JVM containers is critical
  because they will be used to size properly items like JVM thread pools,
  heap memory and  non-heap memory, tunning manually is challenging,
  fortunately, if using paketo implementation of cloud native buildpacks
  (included for example in Spring boot), java memory calculator is included
  automatically and the component  will configure JVM memory based on the
  resource limits assigned to the container. otherwise, results are
  unpredictable.
[[}]]

## rootless buildah [[{image.build,security]]
@[https://opensource.com/article/19/3/tips-tricks-rootless-buildah]
- building containers in unprivileged environments
- library+tool for building oci images.
- complementary to podman.
- build speed: [[PM.BCKLOG]]
  @[https://www.redhat.com/sysadmin/speeding-container-buildah]
  this article will address a second problem with build speed when using dnf/yum
   commands inside containers. note that in this article i will use the name dnf
   (which is the upstream name) instead of what some downstreams use (yum) these
   comments apply to both dnf and yum.
[[}]]

## appsody (prebuilt base image) [[{image.build,dev_stack.kubernetes,qa,PM.low_code,PM.todo]]
@[https://appsody.dev/docs]
- pre-configured application stacks for rapid development
  of quality microservice-based applications.

- Stacks include language runtimes, frameworks, additional libraries and tools
  NEEDED FOR LOCAL DEVELOPMENT, providing consistency and best practices.

- it consists of:
  - base-container-image:
    - local development.
    - it defines the environment and specifies the stack behavior
      during the development lifecycle of the application.

  - project templates:
    - starting point ('hello world')
    - they can be customized/shared.

- stack layout example, my-stack:
  my-stack
  ├ readme.md               # describes stack and how to use it
  ├ stack.yaml              # different attributes and which template
  ├ image/                  # to use by default
  | ├ config/
  | | └ app-deploy.yaml     # deploy config using appsody operator
  | ├ project/
  | | ├ php/java/...stack artifacts
  | | └ dockerfile          # final   (run) image ("appsody build")
  │ ├ dockerfile-stack      # initial (dev) image and env.vars
  | └ license               # for local dev.cycle. it is independent
  └ templates/              # of dockerfile
    ├ my-template-1/
    |     └ "hello world"
    └ my-template-2/
          └ "complex application"

- GENERATED FILES:
  -*".appsody-config.yaml"*. generated by $*$ appsody init*
    it specifies the stack image used and can be overridden
    for testing purposes to point to a locally built stack.

- STABILITY LEVELS:
  - experimental ("proof of concept")
    - support  appsody init|run|build

  - incubator : not production-ready.
    - active contributions and reviews by maintainers
    - support  appsody init|run|build|test|deploy
    - limitations described in readme.md

  - stable : production-ready.
    - support all appsody cli commands
    - pass appsody stack 'validate' and 'integration' tests
      on all three operating systems that are supported by appsody
      without errors.
      example:
      - stack must not bind mount individual files as it is
        not supported on windows.
      - specify the minimum appsody, docker, and buildah versions
        required in the stack.yaml
      - support appsody build command with buildah
      - prevent creation of local files that cannot be removed
        (i.e. files owned by root or other users)
      - specify explicit versions for all required docker images
      - do not introduce any version changes to the content
        provided by the parent container images
        (no yum upgrade, apt-get dist-upgrade, npm audit fix).
         - if package contained in the parent image is out of date,
           contact its maintainers or update it individually.
      - tag stack with major version (at least 1.0.0)
      - follow docker best practices, including:
        - minimise the size of production images
        - use the official base images
        - images must not have any major security vulnerabilities
        - containers must be run by non-root users
      - include a detailed readme.md, documenting:
        - short description
        - prerequisites/setup required
        - how to access any endpoints provided
        - how users with existing projects can migrate to
          using the stack
        - how users can include additional dependencies
          needed by their application

- OFFICIAL APPSODY REPOSITORIES:
  https://github.com/appsody/stacks/releases/latest/download/stable-index.yaml
  https://github.com/appsody/stacks/releases/latest/download/incubator-index.yaml
  https://github.com/appsody/stacks/releases/latest/download/experimental-index.yaml

- by default, appsody comes with the incubator and experimental repositories
  ( *warn*: not stable by default). repositories can be added by running :
  $ appsody repo
[[}]]

## Podman [[{runtime.podman,DOC_HAS.comparative,PM.TODO]]
- Docker alternative.
- No system daemon required and daemon required running
  "at native Linux speeds".
  (no daemon getting in the way of handling client/server requests)

- "rootless" enviroment. No need for root / sudo.               [[{security}]]
  TODO: Looks like newer versions of Docker are also root. Review.
- Podman is set to be the default container engine for the single-node
  use case in Red Hat Enterprise Linux 8.
  (CRI-O for OpenShift clusters)

- easy to use and intuitive.
  - Most users can simply alias Docker to Podman (alias docker=podman)

- '$ podman generate kube' creates a Pod that can then be exported as Kubernetes-compatible YAML.

- enables users to run different containers in different user namespaces

-  OCI compliant Container Runtime (runc, crun, runv, etc)
  to interface with the OS.

- Podman  libpod library manages container ecosystem:
  - pods.
  - containers.
  - container images (pulling, tagging, ...)
  - container volumes.

- Podman Introduction:

  $ podman search busybox
  INDEX       NAME                          DESCRIPTION             STARS  OFFICIAL AUTOMATED
  docker.io   docker.io/library/busybox     Busybox base image.     1882   [OK]
  docker.io   docker.io/radial/busyboxplus  Full-chain, Internet... 30     [OK]
  ...
  $ podman run -it docker.io/library/busybox
  / #

  $ URL="https://raw.githubusercontent.com/nginxinc/docker-nginx"
  $ URL="${URL}/594ce7a8bc26c85af88495ac94d5cd0096b306f7/       "
  $ URL="${URL}/mainline/buster/Dockerfile                      "
  $ podman build -t nginx ${URL}                                   ← build Nginx web server using
                    └─┬─┘                                            official Nginx Dockerfile
                      └────────┐
                             ┌─┴─┐
  $ podman run -d -p 8080:80 nginx                                 ← run new image from local cache
                     └─┬─┘└┘
                       │   ^Port Declared @ Dockerfile
                 Effective
                 (Real)port


- To make it public publish to any other Register compatible with the
 *Open Containers Initiative (OCI) format*. The options are:
  - Private Register:
  - Public  Register:
    - quay.io
    - docker.io

  $ podman login quay.io                            # <·· Login into quay.io
  $ podman tag localhost/nginx quay.io/${USER}/nginx# <·· re-tag the image
  $ podman push quay.io/${USER}/nginx               # <·· push the image
→ Getting image source signatures
→ Copying blob 38c40d6c2c85 done
→ ..
→ Writing manifest to image destination
→ Copying config 7f3589c0b8 done
→ Writing manifest to image destination
→ Storing signatures

$*$ podman inspect quay.io/${USER}/nginx            * ← Inspect image
→ [
→     {
→         "Id": "7f3589c0b8849a9e1ff52ceb0fcea2390e2731db9d1a7358c2f5fad216a48263",
→         "Digest": "sha256:7822b5ba4c2eaabdd0ff3812277cfafa8a25527d1e234be028ed381a43ad5498",
→         "RepoTags": [
→             "quay.io/USERNAME/nginx:latest",
→             ...
→         ]
→     }
→ ]


### Podman commands:
@[https://podman.readthedocs.io/en/latest/Commands.html]
 *Image Management:*
  build        Build an image using instructions from Containerfiles
  commit       Create new image based on the changed container
  history      Show history of a specified image
  image
  └ build   Build an image using instructions from Containerfiles
    exists  Check if an image exists in local storage
    history Show history of a specified image
    prune   Remove unused images
    rm      Removes one or more images from local storage
    sign    Sign an image
    tag     Add an additional name to a local image
    tree    Prints layer hierarchy of an image in a tree format
    trust   Manage container image trust policy

  images       List images in local storage  ( == image list)
  inspect      Display the configuration of a container or image ( == image inspect)
  pull         Pull an image from a registry  (== image pull)
  push         Push an image to a specified destination (== image push)
  rmi          Removes one or more images from local storage
  search       Search registry for image
  tag          Add an additional name to a local image

 *Image Archive/Backups:*
  import       Import a tarball to create a filesystem image (== image import)
  load         Load an image from container archive ( == image load)
  save         Save image to an archive ( == image save)

 *Pod Control:*
  attach       Attach to a running container ( == container attach)
  containers Management
  └ cleanup    Cleanup network and mountpoints of one or more containers
    commit     Create new image based on the changed container
    exists     Check if a container exists in local storage
    inspect    Display the configuration of a container or image
    list       List containers
    prune      Remove all stopped containers
    runlabel   Execute the command described by an image label

 *Pod Checkpoint/Live Migration:*
  container checkpoint Checkpoints one or more containers
  container restore    Restores one or more containers from a checkpoint

  $*$ podman container checkpoint $container_id\ *← Checkpoint and prepare*migration archive*
  $*    -e /tmp/checkpoint.tar.gz                *
  $*$ podman container restore \                 *← Restore from archive at new server
  $*  -i /tmp/checkpoint.tar.gz                  *

  create       Create but do not start a container ( == container create)
  events       Show podman events
  exec         Run a process in a running container ( == container exec)
  healthcheck  Manage Healthcheck
  info         Display podman system information
  init         Initialize one or more containers ( == container init)
  kill         Kill one or more running containers with a specific signal ( == container kill)
  login        Login to a container registry
  logout       Logout of a container registry
  logs         Fetch the logs of a container ( == container logs)
  network      Manage Networks
  pause        Pause all the processes in one or more containers ( == container pause)
  play         Play a pod
  pod          Manage pods
  port         List port mappings or a specific mapping for the container ( == container port)
  ps           List containers
  restart      Restart one or more containers ( == container restart)
  rm           Remove one or more containers ( == container rm)
  run          Run a command in a new container ( == container run)
  start        Start one or more containers ( == container start)
  stats        Display a live stream of container resource usage statistics (== container stats)
  stop         Stop one or more containers ( == container stop)
  system       Manage podman
  top          Display the running processes of a container ( == container top)
  unpause      Unpause the processes in one or more containers ( == container unpause)
  unshare      Run a command in a modified user namespace
  version      Display the Podman Version Information
  volume       Manage volumes
  wait         Block on one or more containers ( == container wait)

 *Pod Control: File system*
  cp           Copy files/folders container ←→ filesystem (== container cp)
  diff         Inspect changes on container’s file systems ( == container diff)
  export       Export container’s filesystem contents as a tar archive ( ==  container export )
  mount        Mount a working container’s root filesystem  ( == container mount)
  umount       Unmounts working container’s root filesystem ( == container mount)


 *Pod Integration*
  generate     Generated structured data
    kube       kube Generate Kubernetes pod YAML from a container or pod
    systemd    systemd Generate a  *SystemD unit file* for a Podman container


### Podman SystemD Integration:

* [REF@redhat](https://www.redhat.com/sysadmin/improved-systemd-podman)
* auto-updates help to make managing containers even more straightforward.
* SystemD is used in Linux to  managing services (background
  long-running jobs listening for client requests) and their
  dependencies.
* Podman running SystemD inside a container:
  ```
  └ /run               ← tmpfs
    /run/lock          ← tmpfs
    /tmp               ← tmpfs
    /var/log/journald  ← tmpfs
    /sys/fs/cgroup      (configuration)(depends also on system running cgroup V1/V2 mode).
    └───────┬───────┘
     Podman automatically mounts next file-systems in the container when:
     - entry point of the container is either */usr/sbin/init or /usr/sbin/systemd*
     -*--systemd=always*flag is used
  ```
### Podman running inside SystemD services
* SystemD needs to know which processes are part of a service so it
  can manage them, track their health, and properly handle dependencies.
* This is problematic in Docker  (according to RedHat rival) due to the
  server-client architecture of Docker:
  - It's practically impossible to track container processes, and
    pull-requests to improve the situation have been rejected.
  - Podman implements a more traditional architecture by forking processes:
    - Each container is a descendant process of Podman.
    - Features like sd-notify and socket activation make this integration
      even more important.
      - sd-notify service manager allows a service to notify SystemD that
        the process is ready to receive connections
      - socket activation permits SystemD to launch the containerized process
        only when a packet arrives from a monitored socket.

* Compatible with audit subsystem (track records user actions).
  The forking architecture allows systemd to track processes in a
  container and hence opens the door for seamless integration of
  Podman and systemd.
  ```
  $ podman generate systemd --new $container*  ← Auto-generate containerized systemd units:
                            └─┬─┘
                            Ohterwise it will be tied to creating host
  ```
  Pods are also supported in Podman 2.0 Container units that are part
  of a pod can now be restarted.  especially helpful for auto-updates.

* Podman auto-update  (1.9+):
  To use auto-updates:
  containers must be created with `--label "io.containers.autoupdate=image"`

  run in a SystemD unit generated by:
  ```
  $ podman generate systemd --new.

  $ podman auto-update    ← Podman will first looks up running containers with the
                            "io.containers.autoupdate" label set to "image" and then
                            query the container registry for new images.
                           *If that's the case Podman restarts the corresponding *
                           *SystemD unit to stop the old container and create a  *
                           *new one with the modified image.                     *
  (still marked as experimental as of 202? while collecting user feedback)
  ```
[[}]]

# CONTAINERIZATION TROUBLESHOOTING [[{troubleshooting]]

## /var/lib/docker/.../data consumes too much space
$ sudo du -sch /var/lib/docker/devicemapper/devicemapper/data
14g     /var/lib/docker/devicemapper/devicemapper/data

($ docker logs 'container' knocks down the host server when output is processed)

* Probably logs are not configured to be rotated creating "huge" files. Fix: [[{troubleshooting.storage,monitoring.logs}]]
  ```
     $ editor /etc/docker/daemon.json
     {
       "log-driver": "json-file",
   +   "log-opts": {
   +     "max-size": "10m",
   +     "max-file": "3"
   +   }
     }

     $ sudo systemctl restart docker.service
   ```

## DNS works on host, fails at build and/or in running containers:
* SOLUTION 1) ALT 1:
  1) Add next lines to /etc/docker/daemon.json:
      {
    +   "dns": ["8.8.8.8","4.4.4.4"],
    +   "dns-search": ["companydomain",...]
      }
  2) $ sudo systemctl restart docker.service
  3) $ journalctl -u docker.service --since "1m ago"  # Check logs for related errors.

* SOLUTION 1) ALT 2:
  1) Edit     /lib/systemd/system/docker.service
         (/usr/lib/systemd/system/docker.service)
     to look somthing like:
     ...
  +  ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock \
        --dns 8.8.8.8 --dns 8.8.4.4  --dns-search default.svc.cluster.local \
        --dns-search svc.cluster.local --dns-opt ndots:2 \
        --dns-opt timeout:2 --dns-opt attempts:2

   NOTE/WARN!!!: This configuration can be overriden by values in:
   /etc/systemd/system/docker.service.d/*.conf

  2) $ sudo systemctl daemon-reload
  3) $ sudo systemctl restart docker.service
  4) $ journalctl -u docker.service --since "1m ago"  # Check logs for related errors.

* SOLUTION 2)  try to launch with --network host flag. ex.:
      ...
      docker_opts="${docker_opts} *--network host*"
      script="wget https://repo.maven.apache.org/maven2" # ← dns can fail with bridge
      echo "${mvn_script}" | docker run ${docker_opts} ${script}

## Debug running container  [[{]]
* If the container contains a shell (discouraged for security
  reasons, but quite normal in practice) we can just
  `docker exec -ti $containerId /bin/sh`.

  The first problem is that, once inside the container,  we are limited
  to the shell and the few utilities prepackaged into the container.
  Possible we lack curl, tcpdump, vi, ... to debug any issue as we
  will do normally "outside" the container.

  Solution: Instead of `docker exec ...`  use `nsenter`( util-linux
  package) to "switch" to the container (network, filesystem, ipc, ...)
  namespace while keeping all the standard tooling of the host Linux
  system (editors, scanners, diagnostic tools, ...)

  $ cat enternetworknamespace.sh
  #!/bin/bash

  # ref: man nsenter
  # run shell with network namespace of container.
  # allows to use ping, ss/netstat, wget, trace,.. in
  # in contect of the container.
  # useful to check network setup is the appropiate one.
  cont_pid=$( sudo docker inspect -f '{{.state.pid}}' $1 )
  shift 1
  sudo nsenter -t ${cont_pid} -n
                              ^^
                         use network namespace of container

  ex ussage:
  $ ./enternetworknamespace.sh mywebcontainer01
  $ netstat -ntlp
  active internet connections (only servers)
  proto recv-q send-q local address           foreign address         state
  tcp        0      0 0.0.0.0:80              0.0.0.0:*               listen

  * netstat installed on host (vs container).
[[}]]

## Global containers `ulimit` [[{PM.TODO}]]

[[troubleshooting}]]

## Containerization: TODO/un-ordered/classify [[{PM.TODO]]
## security tunning [[{security]]
@[https://opensource.com/business/15/3/docker-security-tuning]
[[}]]

## sysdig troubleshooting&monitoring tools  [[{monitoring,security,troubleshooting,PM.TODO]]
"""... once sysdig is installed as a process (or container) on the server,
  it sees every process, every network action, and every file action
  on the host. you can use sysdig "live" or view any amount of historical
  data via a system capture file.

  example: take a look at the total cpu usage of each running container:
     $ sudo sysdig -c topcontainers\_cpu
     | cpu% container.name
     | ----------------------------------------------------
     | 80.10% postgres
     | 0.14% httpd
     | ...
     |

  example: capture historical data:
     $ sudo sysdig -w historical.scap

  example: "zoom into a client":
     $ sudo sysdig -pc -c topprocs\_cpu container. name=client
     | cpu% process container.name
     | ----------------------------------------------
     | 02.69% bash client
     | 31.04%curl client
     | 0.74% sleep client
[[}]]

## cadvisor [[{monitoring]]
* cadvisor analyzes resource usage and performance characteristics of
  running containers.

### cadvisor+prometheus+grafana
@[https://blog.couchbase.com/monitoring-docker-containers-docker-stats-cadvisor-universal-control-plane/]
@[https://dzone.com/refcardz/intro-to-docker-monitoring?chapter=6]
@[https://github.com/google/cadvisor/blob/master/docs/running.md#standalone]
[[}]]

## live restore [[{]]
 @[https://docs.docker.com/config/containers/live-restore/]
 keep containers alive during daemon downtime
[[}]]

## weave [[{ci/cd.gitops,monitoring,pm.low_code,PM.TODO]]
@[https://github.com/weaveworks/weave]

* weaveworks company: """ delivers the most productive way for developers
  to connect, observe and control docker containers. """"
* weave net repository: over 8 million downloads to date.
  - It enables to get started with docker clusters and portable
    apps in a fraction of the time required by other solutions.
  - quickly, easily, and securely network and cluster containers
    across any environment. whether on premises, in the cloud, or hybrid,
    there’s no code or configuration.
  - build an ‘invisible infrastructure’
  - powerful cloud native networking toolkit. it creates a virtual network
    that connects docker containers across multiple hosts and enables their
    automatic discovery. set up subsystems and sub-projects that provide
    dns, ipam, a distributed virtual firewall and more.
* weave scope:
  - understand your application quickly by seeing it in a real time
    interactive display. pick open source or cloud hosted options.
  - zero configuration or integration required — just launch and go.
  - automatically detects processes, containers, hosts.
    no kernel modules, agents, special libraries or coding.
  - seamless integration with docker, kubernetes, dcos and aws ecs.
* cortex: horizontally scalable, highly available, multi-tenant,
  long term storage for prometheus.
* flux:
  - flux is the operator that *MAKES GITOPS HAPPEN IN YOUR CLUSTER*.
    it ensures that the cluster config matches the one in git and
    automates your deployments.
  - continuous delivery of container images, using version control
    for each step to ensure deployment is reproducible,
    auditable and revertible. deploy code as fast as your team creates
    it, confident that you can easily revert if required.

    learn more about gitops.
  @[https://www.weave.works/technologies/gitops/]
[[}]]

## clair vulnerabilities static analysis [[{security,qa,PM.todo]]
@[https://coreos.com/clair/docs/latest/]
open source project for the static analysis of vulnerabilities in
appc and docker containers.

vulnerability data is continuously imported from a known set of sources and
correlated with the indexed contents of container images in order to produce
lists of vulnerabilities that threaten a container. when vulnerability data
changes upstream, the previous state and new state of the vulnerability along
with the images they affect can be sent via webhook to a configured endpoint.
all major components can be customized programmatically at compile-time
without forking the project.
[[}]]

## skopeo [[{image.registry,troubleshooting]]
@[https://github.com/containers/skopeo]
@[https://www.redhat.com/en/blog/skopeo-10-released]
- command line utility for moving/copying container images between different types
  of container storages. (docker.io, quay.io, internal container registry
  local storage repository or even directly into a docker daemon).
- it does not require root permissions (for most of its operations)
  or even a docker daemon.
- compatible with oci images (standards) and original docker v2 images.
[[}]]

## lazydocker UI  [[{qa.UX]]
@[https://github.com/jesseduffield/lazydocker]
a simple terminal ui for both docker and docker-compose, written in
go with the gocui library.
[[}]]

## convoy (backups volume driver) [[{storage.host,security.backups]]
@[https://rancher.com/introducing-convoy-a-docker-volume-driver-for-backup-and-recovery-of-persistent-data/]
- convoy: docker storage driver for backup and recovery of volumes.
[[}]]

## Protect from Doki malware [[{security,qa,PM.TODO]]
https://containerjournal.com/topics/container-security/protecting-containers-against-doki-malware/
[[}]]

### 2+Millions images with Critical Sec.Holes !!!  [[{]]
https://www.infoq.com/news/2020/12/dockerhub-image-vulnerabilities/
[[}]]


## OpenSCAP: Scanning Vulnerabilities [[{security.openscap]]
- Scanning Containers for Vulnerabilities on RHEL 8.2 With OpenSCAP and Podman:
@[https://www.youtube.com/watch?v=nQmIcK1vvYc]
[[}]]

## [Grype] [[{security,]]
* https://github.com/anchore/grype
* A vulnerability scanner for container images and filesystems. Easily
  install the binary to try it out. Works with Syft, the powerful SBOM
  (software bill of materials) tool for container images and
  filesystems.
[[}]]
[[PM.TODO}]]

# Advanced Topics

## Docker API <!-- { -->
* @[https://docs.docker.com/engine/api/])
* @[https://godoc.org/github.com/docker/docker/api]
* @[https://godoc.org/github.com/docker/docker/api/types]
<!-- } -->


## Container Network Iface (CNI) [[{PM.TODO]]
@[https://github.com/containernetworking/cni]
* specification and libraries for writing plugins to configure network interfaces
  in Linux containers, along with a number of supported plugins.
* CNI concerns itself only with network connectivity of containers
  and removing allocated resources when the container is deleted.
* @[https://github.com/containernetworking/cni/blob/master/SPEC.md]
* CNI concerns itself only with network connectivity of
  containers and removing allocated resources when container
  are deleted.
* specification and libraries for writing plugins
  to configure network interfaces in Linux containers,
  along with a number of supported plugins:
  - libcni, a CNI runtime implementation
  - skel, a reference plugin implementation
    github.com/cotainernetworking/cni
* Set of reference and example plugins:
  - Inteface plugins:  ptp, bridge,macvlan,...
  - "Chained" plugins: portmap, bandwithd, tuning,
    github.com/cotainernetworking/pluginds

    NOTE: Plugins are executable programs with STDIN/STDOUT
    ```
                                    ┌ Network
                  ┌·····>(STDIN)    │
    Runtime → ADD JSON    CNI ······┤
     ^        ^^^         executable│
     ·        ADD         plugin    └ Container(or Pod)
     ·        DEL         └─┬──┘      Interface
     ·        CHECK         v
     ·        VERSION    (STDOUT)
     ·                 └────┬──────┘
     ·                      │
     └···· JSON result <····┘

    RUNTIMES              3RD PARTY PLUGINS
    K8s, Mesos, podman,   Calico ,Weave, Cilium,
    CRI-O, AWS ECS, ...   ECS CNI, Bonding CNI,...
    ```

- The idea of CNI is to provide common interface between
  the runtime and the CNI (executable) plugins through
  standarised JSON messages.

  Example cli Tool  executing CNI config:
@[https://github.com/containernetworking/cni/tree/master/cnitool]
   INPUT_JSON
   {
     "cniVersion":"0.4.0",   ← Standard attribute
     "name": *"myptp"*,
     "type":"ptp",
     "ipMasq":true,
     "ipam": {               ← Plugin specific attribute
       "type":"host-local",
       "subnet":"172.16.29.0/24",
       "routes":[{"dst":"0.0.0.0/0"}]
     }
   }
   $ echo $INPUT_JSON | \                  ← Create network config
     sudo tee /etc/cni/net.d/10-myptp.conf   it can be stored on file-system
                                             or runtime artifacts (k8s etcd,...)

   $ sudo ip netns add testing             ← Create network namespace.
                       └-----┘

   $ sudo CNI_PATH=./bin \                 ← Add container to network
     cnitool add  *myptp*  \
     /var/run/netns/testing

   $ sudo CNI_PATH=./bin \                ← Check config
     cnitool check myptp \
     /var/run/netns/testing


   $ sudo ip -n testing addr               ← Test
   $ sudo ip netns exec testing \
     ping -c 1 4.2.2.2

   $ sudo CNI_PATH=./bin \                 ← Clean up
     cnitool del myptp \
     /var/run/netns/testing
   $ sudo ip netns del testing

 *Maintainers (2020):*
  - Bruce Ma (Alibaba)
  - Bryan Boreham (Weaveworks)
  - Casey Callendrello (IBM Red Hat)
  - Dan Williams (IBM Red Hat)
  - Gabe Rosenhouse (Pivotal)
  - Matt Dupre (Tigera)
  - Piotr Skamruk (CodiLime)
  - "CONTRIBUTORS"

 *Chat channels*
  - https.//slack.cncf.io  - topic #cni
[[}]]

## `/var/run/docker.sock` <!-- { -->
* [REF](https://medium.com/better-programming/about-var-run-docker-sock-3bfd276e12fd)
* Unix socket the Docker daemon listens on by default,
  used to communicate with the daemon from within a container.
* Can be mounted on containers to allow them to control Docker:
  This is potentially a security hole and must be restricted to
  "special" container (e.g: Kubernetes controlers,...)
  ```
  $ docker run -v /var/run/docker.sock:/var/run/docker.sock ....
  ```
<!-- } -->

## Dockerize non-friendly apps [[{image.build,PM.low_code,troubleshooting]]

* [REF](https://github.com/jwilder/dockerize)
* `dockerize`: Utility to simplify running applications in docker containers allowing to:
  * generate app config. files AT CONTAINER STARTUP TIME
    from templates and container environment variables.  
  * Tail multiple log files to stdout and/or stderr.  
  * Wait for other services to be available using TCP, HTTP(S),
    unix before starting the main process.  

### Typical use cases:

* application that has one or more configuration files and
  you would like to control some of the values using ENV.VARs.
* dockerize allows to set an environment variable and update the
  config file before starting the contenerized application
* other use case: forward logs from harcoded files on the filesystem
  to stdout/stderr
  (Ex: nginx logs to /var/log/nginx/access.log and /var/log/nginx/error.log by default)
[[}]]


## External Refs:

* <http://container.training/>
