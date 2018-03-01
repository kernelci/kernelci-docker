KernelCI Docker
===============

## Purpose

This repository eases the installation process of KernelCI through the usage of Docker containers.

It uses Docker Compose file to decribe the services of the whole application:

* reverse-proxy
* frontend
* backend
* celery task queue
* redis
* mongo

## Run the application

### Setup a Docker host

This can be the local machine, a VM or physical machine with the Docker platform installed.

> Warning: currently, the application does not work on Debian 8, please use a Debian 9 or Ubuntu 16.04 box. Some tests and improvements needs to be done to support more platforms.

Linux | Docker | Status
----- | ------ | ------
Ubuntu 16.04 | 17.11 | o
Ubuntu 16.04 | 17.09 | o
CentOS 7 | 17.09 | o
Debian 9 | 17.11 | o
Debian 9 | 17.09 | o
Debian 8 | 17.11 | x

#### Option 1: manually

If you setup a Docker host manually, make sure it runs at least Docker 17.09 (last stable version to date).

An easy way to install Docker is through the following command (it installs the lastest version, not necessarily the stable one):

```
$ curl -fsSL get.docker.com -o get-docker.sh
$ sh get-docker.sh
```

In order to install the latest stable version, the CHANNEL env variable needs to be set to "stable" beforehand.

```
export CHANNEL="stable"
$ curl -fsSL get.docker.com -o get-docker.sh
$ sh get-docker.sh
```

If you do not feel like running this script, you can download a Docker edition for your platform on the [Docker Store](https://store.docker.com/search?offering=community&type=edition)

#### Option 2: with Docker Machine

Docker Machine is a great tool to spin up such hosts locally (on Virtualbox), on a cloud provider (AWS, GCE, Azure, DigitalOcean, ...). In one command line we can easily create a Docker host, the exemples bellow illustrate the usage of Docker Machine to create a Docker host named *kernelci* using different infrastructures. The installation instruction are available [here](https://docs.docker.com/machine/install-machine/)

* Exemple using Virtualbox driver

```
$ docker-machine create --driver virtualbox kernelci
```

All available options for this driver: [https://docs.docker.com/machine/drivers/virtualbox/#/options](https://docs.docker.com/machine/drivers/virtualbox/#/options)

* Exemple using DigitalOcean driver

```
$ docker-machine create --driver digitalocean --digitalocean-access-token TOKEN kernelci
```

All available options for this driver: [https://docs.docker.com/machine/drivers/digital-ocean/#/options](https://docs.docker.com/machine/drivers/digital-ocean/#/options)

* Exemple using Amazon EC2 driver

```
$ docker-machine create \
  --driver amazonec2 \
  --amazonec2-access-key=ACCESS_KEY_ID \
  --amazonec2-secret-key=SECRET_ACCESS_KEY \
  kernelci
```

All available options for this driver: [https://docs.docker.com/machine/drivers/aws/#/options](https://docs.docker.com/machine/drivers/aws/#/options)

> For DigitalOcean, AWS as for any cloud provider, some additional options such as authentication token must be provided when using Docker Machine.

* Docker Machine also allows to manage an existing server with the [Generic driver](https://docs.docker.com/machine/drivers/generic/)

### Activate swarm mode

> Make sure your local Docker client is setup to communicate with the Docker daemon you want to deploy the application on. In case you used Docker Machine to setup the host, you will need to use the command ```eval $(docker-machine env kernelci)```, this will set some environment variables so the client can send Docker related commands to the host created above.

The Docker daemon running the application needs to be in swarm mode, this can easily be configure with the following command:

```
$ docker swarm init
```

In case several IP addresses are found, an additional *--advertise-addr* option needs to be specified indicating the IP to use:

```
$ docker swarm init --advertise-addr IP
```

> A Docker daemon running in swarm mode is requested in order to use some of the latest feature and primitive such as *Config*, *Secret*, ...

### Clone the repository

Once you have a Linux box up and running, get the repository

```
$ git clone https://github.com/lucj/kernelci-docker
$ cd kernelci-docker
```

### Run the application

The startup of the application is done in several steps:

* generation of a UUID
* setup of this UUID in the database
* creation of a config for the frontend using this UUID
* deploy the application *stack*

All those steps are handled by the *start.sh* script, so the only things you need to do is running

```
./start.sh
```

The web ui is then available on port 8080 and the api on port 8081.

![Home](./images/kernelci-home.png)

### Backup / restore KernelCI from Ansible

You may have an already running version of kernelCI with data that you would like to keep.

#### Backup a mongo database

To do a backup of an existing mongo database; run the following command on the mongo Host:

```
mongodump -d kernel-ci -o kernelci_db_dump
tar czf kernelci_db_dump.tar.gz kernelci_db_dump
```

This will create a `.tar.gz` file available on the mongo Host. You can now copy/share it with the machine running kernelci-docker.

#### Restore a mongo database

To restore an existing mongo database dump (in .tar.gz format), run the following command:

```
./seed.sh -d kernelci_db_dump.tar.gz
```
/!\ This command needs to be run after `start.sh` once all the services are up and running.

#### Backup the logs

To do a backup of the boot/test logs on the previous KernelCI instance do:

```
tar czf kernelci_logs_dump.tar.gz -C /var/www/images/ kernel-ci
```

This will create a `.tar.gz` file available on the host. You can now copy/share it with the machine running kernelci-docker.

#### Restore the logs

To restore the logs from a backup (in .tar.gz format), run the following command:
```
./seed.sh -l kernelci_logs_dump.tar.gz
```
/!\ This command needs to be run after `start.sh` once all the services are up and running.

#### Backup database and log files of th current application

The _dump.sh_ script is used to do the backup of the database and of the generated logs at the same time. Those backups are saved in /tmp by default or in the folder specified with the *-d* flag. The following command create the backups in _/tmp/dump/kci_ folder:

```
$ ./dump.sh -d /tmp/dump/kci/
2018-01-26T22:03:57.223+0000	writing kernel-ci.test_case to archive '/tmp/kernelci-20180126T220403.gz'
2018-01-26T22:03:57.224+0000	writing kernel-ci.test_set to archive '/tmp/kernelci-20180126T220403.gz'
2018-01-26T22:03:57.224+0000	writing kernel-ci.test_suite to archive '/tmp/kernelci-20180126T220403.gz'
2018-01-26T22:03:57.228+0000	writing kernel-ci.api-token to archive '/tmp/kernelci-20180126T220403.gz'
2018-01-26T22:03:57.246+0000	done dumping kernel-ci.test_set (14 documents)
2018-01-26T22:03:57.246+0000	writing kernel-ci.boot to archive '/tmp/kernelci-20180126T220403.gz'
2018-01-26T22:03:57.247+0000	done dumping kernel-ci.test_suite (12 documents)
2018-01-26T22:03:57.247+0000	writing kernel-ci.lab to archive '/tmp/kernelci-20180126T220403.gz'
2018-01-26T22:03:57.248+0000	done dumping kernel-ci.api-token (4 documents)
2018-01-26T22:03:57.251+0000	writing kernel-ci.report to archive '/tmp/kernelci-20180126T220403.gz'
2018-01-26T22:03:57.252+0000	done dumping kernel-ci.test_case (96 documents)
2018-01-26T22:03:57.253+0000	writing kernel-ci.build to archive '/tmp/kernelci-20180126T220403.gz'
2018-01-26T22:03:57.260+0000	done dumping kernel-ci.boot (2 documents)
2018-01-26T22:03:57.261+0000	writing kernel-ci.job to archive '/tmp/kernelci-20180126T220403.gz'
2018-01-26T22:03:57.261+0000	done dumping kernel-ci.lab (2 documents)
2018-01-26T22:03:57.261+0000	writing kernel-ci.bisect to archive '/tmp/kernelci-20180126T220403.gz'
2018-01-26T22:03:57.277+0000	done dumping kernel-ci.report (0 documents)
2018-01-26T22:03:57.284+0000	writing kernel-ci.error_logs to archive '/tmp/kernelci-20180126T220403.gz'
2018-01-26T22:03:57.286+0000	done dumping kernel-ci.build (0 documents)
2018-01-26T22:03:57.286+0000	done dumping kernel-ci.job (0 documents)
2018-01-26T22:03:57.287+0000	writing kernel-ci.daily_stats to archive '/tmp/kernelci-20180126T220403.gz'
2018-01-26T22:03:57.287+0000	done dumping kernel-ci.bisect (0 documents)
2018-01-26T22:03:57.289+0000	done dumping kernel-ci.daily_stats (0 documents)
2018-01-26T22:03:57.296+0000	done dumping kernel-ci.error_logs (0 documents)
tmp/logs/
tar: removing leading '/' from member names
tmp/logs/AGL-kernel-tree/
tmp/logs/AGL-kernel-tree/agl-branch/
tmp/logs/AGL-kernel-tree/agl-branch/AGL-kernel-version/
tmp/logs/AGL-kernel-tree/agl-branch/AGL-kernel-version/x86_64/
tmp/logs/AGL-kernel-tree/agl-branch/AGL-kernel-version/x86_64/defconfig+CONFIG_AGL=y/
tmp/logs/AGL-kernel-tree/agl-branch/AGL-kernel-version/x86_64/defconfig+CONFIG_AGL=y/lab-baylibre-20180124T235737/
tmp/logs/AGL-kernel-tree/agl-branch/AGL-kernel-version/x86_64/defconfig+CONFIG_AGL=y/lab-baylibre-20180124T235737/boot-qemu.txt
tmp/logs/AGL-kernel-tree/agl-branch/AGL-kernel-version/x86_64/defconfig+CONFIG_AGL=y/lab-baylibre-20180124T235737/boot-qemu.json
tmp/logs/AGL-kernel-tree/agl-branch/AGL-kernel-version/x86_64/defconfig+CONFIG_AGL=y/lab-baylibre-20180124T235737/boot-qemu.html
tmp/logs/AGL-kernel-tree/agl-branch/AGL-kernel-version/x86_64/defconfig+CONFIG_AGL=y/lab-baylibre-20180126T225255/
tmp/logs/AGL-kernel-tree/agl-branch/AGL-kernel-version/x86_64/defconfig+CONFIG_AGL=y/lab-baylibre-20180126T225255/boot-qemu.txt
tmp/logs/AGL-kernel-tree/agl-branch/AGL-kernel-version/x86_64/defconfig+CONFIG_AGL=y/lab-baylibre-20180126T225255/boot-qemu.json
tmp/logs/AGL-kernel-tree/agl-branch/AGL-kernel-version/x86_64/defconfig+CONFIG_AGL=y/lab-baylibre-20180126T225255/boot-qemu.html

=> database and log files will be saved in folder /tmp/dump/kci/
```

Once it's done, both files are created and timestamped, for example:

```
$ ls -lrt /tmp/dump/kci
total 464
-rw-r--r--  1 luc  wheel    5850 Jan 26 23:03 kernelci-20180126T220403.gz
-rw-r--r--  1 luc  wheel  107873 Jan 26 23:04 kernelci-logs-20180126T220403.tar.gz
```

### Stop the application

In order to stop the application and remove all the components, run the following command:

```
./stop.sh
```

In the current version, the database is persisted on a volume defined on the Docker host.

---

## Using Docker for development

You can use kernelci-docker to run local / development versions of KernelCI. This allows you to do changes within the code and get the result instantly in the running docker instances. The source code of kernelci frontend and backend is included in this repo as submodules.

### Initialize the submodules

To get the code locally run the following commands:
```
git submodule init
git submodule update
```

Once finished, the code of kernelci frontend and backend are available in `frontend/kernelci-frontend` and `backend/kernelci-backend` respectively.

You can start doing changes locally, apply patches, or add your own git remote to fetch your changes.

### Run Docker-compose

You can run the application (backend & frontend) with Docker Compose. Behind the hood, it will use the docker-compose.yml file which defines some additional options to mount the frontend's and backend's source code so changes done in your local IDE will be taken into account directly in the running application (through nodemon).

Some wrapper scripts were developed to perform the actions needed:

Start the application with the following command:

```
$ ./dev-start.sh
```

Once the application is running, the frontend and backend source code can be modified directly from your favorite IDE. Each changes will be taken into account automatically within the running containers and the main process will be reloaded.

You can build new images with the following command:

```
$ docker-compose build SERVICE_NAME
```

### Sharing your images

If you want to share your work. You can either share your git repo or push the created docker images to a repository. It can then be fetched by others.

---

The application can then be stopped

```
$ ./dev-stop.sh
```

## Status

This is a work in progress [WIP], currently not fully functional.

Several features need to be added:
- to be aligned with the official KernelCI
- to improve and simplify the deployment and architecture of the whole application

Among the ongoing changes:

- [x] Automate the setup (create token from master key, provide token to frontend)
- [ ] Add some tests
- [ ] Check storage part
- [x] Add api documentation
- [x] Add elasticsearch and modify backend so log files are sent to ES
- [ ] Configure reverse proxy (routing with subdomains, TLS termination, ...)
- [ ] Add front and back networks to isolate the services
- [x] Add stack file to deploy the application on a Swarm
- [ ] Usage of env variable or Docker secret to provide the backend token
- [ ] Handle tagging of the application and of its components
