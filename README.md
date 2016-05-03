Updated repository for Payara Dockerfiles. This repository is for the **web profile** of Payara Server.

* Payara is located in the `/opt/payara41` directory. This is deliberately free of any versioning so that any scripts written to work with one version can be seamlessly migrated to the latest docker image.
* Full and Web editions are derived from the OpenJDK 8 images with a Debian Jessie base
* Micro editions are built on OpenJDK 8 images with an Alpine linux base to keep image size as small as possible.
