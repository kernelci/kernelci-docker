In order to simplify the search in log files, an ELK stack could be used.
Log files are indexed in Elasticsearch, as soon as they are created on the filesystem, and filtered through Kibana great interface. 

*** WIP ***

## The search application

The search application is defined in the `docker-compose-es.yml` file. It basically defines the 3 services of the ELK stack:

- logstash: specifies the log files to take into account (different paths for boot and build logs). It also filters and add additional attributes to each line of a log file.

- elasticsearch: index each line of the logs it receives 

- kibana: provides a fancy interface to search within the logs

## How it works

In this first version logstash is configured to check the new files written to disk and parses them accordingly.

Build files are expected at the following locations

```
BASE_FOLDER/tree/branch/kernel/arch/defconfig/build.log
```

Boot files are expected at the following locations
```
BASE_FOLDER/tree/branch/kernel/arch/defconfig/lab/boot-*.log
```

Note: those locations might not be the correct one, some others might also be used, but we will limit to those ones in this POC.

Each time a new file is detected, each line of this file will be used to generate a new record in ealsticsearch. Each record is enhanced with the following elements:
- tree
- branch
- kernel
- arch
- defconfig
- lab (if boot)
- filename (if boot)

Kibana can then be used to search the logs in a very clean way. It's a very configurable tool which provides a lot of filters and visualisation tools.

## Example

Let's consider the boot file located at:
https://storage.kernelci.org/next/master/next-20170824/arm64/defconfig/lab-baylibre/boot-meson-gxl-s905x-khadas-vim.txt

Once it's ingested by logstash and indexed in elasticsearch, each record will look like the following.

```
{
    "kernel" => "next-20170824",
    "tree" => "next",
    "defconfig" => "defconfig",
    "message" => "/bin/sh: can't access tty; job control turned off",
    "type" => "boot",
    "lab" => "lab-baylibre",
    "branch" => "master",
    "path" => "/BASE_FOLDER/next/master/next-20170824/arm64/defconfig/lab-baylibre/boot-meson-gxl-s905x-khadas-vim.txt",
    "@timestamp" => 2017-09-22T07:48:46.208Z,
    "@version" => "1",
    "host" => "3d5db4968c0c",
    "arch" => "arm64",
    "boot" => "meson-gxl-s905x-khadas-vim"
}
```

It's then very easy to search and filter logs through Kibana.


## Prerequisite

In this POC, the folder in which the log files are stored is provided to logstash so it can watch for new files. The path to this folder needs to be set in the *logstash* service within the `docker-compose-es.yml` file.

```
logstash:
  image: logstash:5.5.2
  depends_on:
    - elasticsearch
  volumes:
    - ./search/logstash/logstash.conf:/config/logstash.conf
    - STORAGE_FOLDER:/tmp/:ro
  command: ["logstash", "-f", "/config/logstash.conf"]
```

## Running the search stack

As a Compose application, the search stack can be run with the following command:

```
docker-compose -f docker-compose-es.yml up
```

If the STORAGE_FOLDER is provided correctly, the existing build and boot files will start to be indexed. Kibana visualisation dashboard is then available at http://localhost:5601

## Status

This is a WIP dedicated to enhance the search within the log files.
Any feedback is welcome.

## Additional note

This stack does not need to have the whole application deployed as a Docker Compose application. It could be tested on a existing dev/test instance of kernelci.
