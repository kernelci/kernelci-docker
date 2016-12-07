# Run mongodb

To run mongodb pass the `-f /etc/mongod.conf` option on the docker run command.
Data is stored in `/data/db`: add a volume to persist it.

# Run redis

It needs a volume mounted as `/data/redis`.

Warning: the redis server is configured without user and password and listens
on all available network interfaces: it is not bound to 127.0.0.1.
