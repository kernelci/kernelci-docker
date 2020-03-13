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
- [x] Configure reverse proxy (routing with subdomains, TLS termination, ...)
- [ ] Add front and back networks to isolate the services
- [x] Add stack file to deploy the application on a Swarm
- [ ] Usage of env variable or Docker secret to provide the backend token
- [ ] Handle tagging of the application and of its components
- [ ] Add memory constraints
