# Run mongodb

To run mongodb pass the `-f /etc/mongod.conf` option on the docker run command.
Data is stored in `/data/db`: add a volume to persist it.

# Run redis

It needs a volume mounted as `/data/redis`.
