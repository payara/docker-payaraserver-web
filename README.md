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
docker run -p 8080:8080 payara/server-web
```

The Docker container specifies the default entry point, which starts the default domain `domain1` in foreground so that Payara Server becomes the main process.

## Open ports

Most common default open ports that can be exposed outside of the container:

 - 8080 - HTTP listener
 - 8181 - HTTPS listener
 - 4848 - HTTPS admin listener

## Administration

To boot and export admin interface on port 4848 (and also the default HTTP listener on port 8080):

```
docker run -p 4848:4848 -p 8080:8080 payara/server-web
```

Because Payara Server doesn't allow insecure remote admin connections (outside of a Docker container), the admin interface is secured by default (in both the default `domain1` as well as `payaradomain`), accessible using HTTPS on the host machine: [https://localhost:4848](https://localhost:4848) The default user and password is `admin`.

## Application deployment

### Remote deployment

Once admin port is exposed, it is possible to deploy applications remotely, outside of the docker container, by means of admin console and asadmin tool as usual.

### Deployment on startup

The docker image supports 2 ways of deploying applications on server startup.

#### Deployment on startup using a startup script

Since version 172, Payara Server supports running asadmin commands automatically after the domain is started, including the deploy command to deploy applications. This is the preferred way to deploy applications on Docker container startup.

The default Docker entry point will scan the folder `$DEPLOY_DIR` for files and folders and deploy them automatically after the domain is started.

In order to deploy applications, you can mount the `$DEPLOY_DIR` (`/opt/payara41/deployments`) folder as a docker volume to a directory, which contains your applications. The following will run Payara Server in the docker and will start applications that exist in the directory `~/payara/apps` on the local file-system:

```
docker run -p 8080:8080 -v ~/payara/apps:/opt/payara41/deployments payara/server-web
```

In order to build a Docker image that contains your applications and starts them automatically, you can copy the applications into the `$DEPLOY_DIR` directory. and run the resulting docker image instead of the original one.

The following example Dockerfile will build an image that starts Payara Server and deploys `myapplication.war` when the Docker container is started:

```
FROM payara/server-web

COPY myapplication.war $DEPLOY_DIR
```

You can now build the Docker image and run the application `myapplication.war` with the following commands:

```
docker build -t mycompany/myapplication .
```

```
docker run -p 8080:8080 mycompany/myapplication
```

#### Deployment on startup using the autodeployment directory

When running the `domain1` domain, Payara server automatically deploys all deployable files in the directory specified by the `$AUTODEPLOY_DIR` environment variable (it refers to the `autodeploy` directory in the domain directory of `domain1`). 

You can deploy applications in the same way as with the `$DEPLOY_DIR` directory as described above.

However, deploying applications using the autodeployment directory is discouraged because of many drawbacks:

 - this approach uses only default deployment options, it's not possible to define any deploy parameters, e.g. the context root and more
 - it requires a writable filesystem, what might be cumbersome when deploying from a mounted directory
 - this functionality is disabled in the `payaradomain` domain for security reasons and has to be enabled before using it with that domain

## Selection of domain

The default entry point starts the server in the `domain1` domain. If you want to start it with a different domain, e.g. `payaradomain`, you may provide the domain name in the `PAYARA_DOMAIN` environment variable. The following would start Payara Server in `payaradomain`, without changing the entry point:

```
docker run -p 8080:8080 --env PAYARA_DOMAIN=payaradomain payara/server-web
```

If you also want to use the `AUTODEPLOY_DIR` variable (although this is discouraged), you need to overwrite the value of this variable accordingly. It points to the autodeploy directory of the `domain1` domain by default.

## The default Docker entry point

The default entry point does the following:

- generates an asadmin script which deploys all applications found in the directory `/opt/payara41/deployments`, as described in _"Deployment on startup using a startup script"_
- starts the server using the `startInForeground.sh` startup script, which avoids running 2 JVM instances as opposed to the command `asadmin start-domain --verbose`
- uses the generated asadmin as a post boot command file to deploy all found applications at server start

It's possible to run a custom set of asadmin commands by specifying the `POSTBOOT_COMMANDS` environment variable to point to the abslute path of the custom post boot command file. In that case, the default entry point won't deploy applications in `/opt/payara41/deployments`, you will have to specify the deploy command(s) in your custom post boot command file.

You may also want to completely redefine the default entry point with the `--entrypoint` argument of `docker run`.

# Details

Payara Server installation is located in the `/opt/payara41` directory. This directory is the default working directory of the docker image. The directory name is deliberately free of any versioning so that any scripts written to work with one version can be seamlessly migrated to the latest docker image.

- Full and Web editions are derived from the OpenJDK 8 images with a Debian Jessie base
- Micro editions are built on OpenJDK 8 images with an Alpine Linux base to keep image size as small as possible.

Payara Server is a patched, enhanced and supported application server derived from GlassFish Server Open Source Edition 4.x. Visit [www.payara.fish](http://www.payara.fish) for full 24/7 support and lots of free resources.

Full Payara Server and Payara Micro documentation: [https://payara.gitbooks.io/payara-server/content/](https://payara.gitbooks.io/payara-server/content/)
