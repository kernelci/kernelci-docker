# Containers to Create

## Backend

* (maybe) Need a celery-beat container: since we are using periodic tasks, we might need to have a separate container just running celery-beat. Should be just one container.

* Container for the real API app.

## Frontend

* Right now we are using redis as a cache layer for the web app: we would then need a separate redis container, or another cache layer in a container.

* One container for uwsgi. Also here: what is the best approach? More smaller containers or fewer bigger ones? Need to be tested as well.

## Webserver

* Container running nginx. Same approach as for the previous ones.

# Things to Test

* Need to test the celery container and how it works with multiple containers running celery-worker.
* Autoscale value in celery-worker is set to "3,1", must verified if it is better to have more smaller celery-worker containers or few bigger ones.

# Things to Fix

* Need to fix confguration file variable names, both for celery and the kernelci backend. Need to unify them and test.

* Move code that is used by the celery task into its own modules, so that we can break down the dependencies only needed by celery.
