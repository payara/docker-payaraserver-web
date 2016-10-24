Updated repository for Payara Dockerfiles. This repository is for the **Web Profile** of [Payara Server](http://www.payara.fish).

# Supported tags and respective `Dockerfile` links

-	[`latest`](https://github.com/payara/docker-payaraserver-web/blob/master/Dockerfile)
  - contains latest released version of Payara Server Web Profile
-	[`prerelease`](https://github.com/payara/docker-payaraserver-web/blob/prerelease/Dockerfile)
  - contains nightly build of Payara Server Web Profile from the master branch (updated daily)
-	[other tags](https://hub.docker.com/r/payara/server-web/tags/) correspond to past releases of Payara Server Web Profile matched by short version number

# Usage

## Quick start

To boot the default domain with HTTP listener exported on port 8080:

```
docker run -p 8080:8080 payara/server-web bin/asadmin start-domain -v
```

## Open ports

Most common default open ports that can be exposed outside of the container:

 - 8080 - HTTP listener
 - 8181 - HTTPS listener
 - 4848 - HTTPS admin listener

## Administration

To boot and export admin interface on port 4848:

```
docker run -p 4848:4848 payara/server-web bin/asadmin start-domain -v
```

The admin interface is secured by default, accessible using HTTPS on the host machine: [https://localhost:4848](https://localhost:4848) The default user and password is `admin`.

## Application deployment

### Remote deployment

Once admin port is exposed, it is possible to deploy applications remotely, outside of the docker container, by means of admin console and asadmin tool as usual.

### Deployment on startup

Payara Server automatically deploys all deployable files in the `autodeploy` directory of the current domain. For example `/opt/payara41/glassfish/domains/domain1/autodeploy` in the default domain `domain1`.

You can mount this folder as a docker volume to a directory, which contains your applications. The following will run Payara Server in the docker and will start applications that exist in the directory `~/payara/apps` on the local file-system:

```
docker run -p 8080:8080 \
 -v ~/payara/apps:/opt/payara41/glassfish/domains/domain1/autodeploy \
 payara/server-full bin/asadmin start-domain -v
```

Another approach is to extend the docker image to add your deployables into the `autodeploy` directory and run the resulting docker image instead of the original one.

The following example Dockerfile will build an image that deploys `myapplication.war` when Payara Server domain `domain1` is started:

```
FROM payara/server-web:162

COPY myapplication.war /opt/payara41/glassfish/domains/domain1/autodeploy
```

# Details

Payara Server installation is located in the `/opt/payara41` directory. This directory is the default working directory of the docker image. The directory name is deliberately free of any versioning so that any scripts written to work with one version can be seamlessly migrated to the latest docker image.

- Full and Web editions are derived from the OpenJDK 8 images with a Debian Jessie base
- Micro editions are built on OpenJDK 8 images with an Alpine Linux base to keep image size as small as possible.

Payara Server is a patched, enhanced and supported application server derived from GlassFish Server Open Source Edition 4.x. Visit [www.payara.fish](http://www.payara.fish) for full 24/7 support and lots of free resources.

Full Payara Server and Payara Micro documentation: [https://payara.gitbooks.io/payara-server/content/](https://payara.gitbooks.io/payara-server/content/)
