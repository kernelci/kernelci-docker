## Purpose

Definition of a TLS stack in front of the whole application.

This stack defines a simple service based on nginx which acts as a TLS termination

## Pre-requisite

Before deploying the stack, a CA and a server certificate need to be created.

### CA creation

The following command creates the Certification Authority.

```
$ ./create-CA.sh
```

This one will be used to sign the server certificate we will create below.

The result of this command is the creation of the *ca-key.pem* and *ca.pem*.

### Server certificate

The following command creates a Certificate Signin Request and have it signed by the CA.

```
$ ./create-server-cert.sh
```

The result of this command is the creation of the *server-cert.pem* and *server-cert.pem*.

## How to run it ?

The following command deploys the stack, it uses the certificates create above and also the *nginx.conf* configuration file present in the current folder.

```
$ docker stack deploy -c tls.yml yml
```

## Usage

The web interface is available on *https://kci.org*.

Note: as the CA is not recognized by the browsers, an securoty exception needs to be accepted.


