# Setup Keycloak Locally

## Prerequisites

* [Docker](https://docs.docker.com/engine/installation/ubuntulinux/)
* [Docker-Compose](https://docs.docker.com/compose/install/)

## Start Keycloak

* Add `127.0.0.1  keycloak` to /etc/hosts
* `$ cd <CRYPTOPUS_ROOT>/config/docker/keycloak`
* `$ docker-compose up -d`

## Create Users

* Visit <http://keycloak:8180>
* "Administration Console"
* Login Username: admin, Password: password
* "Users"
* "Add user"
* Fill out form and click "Save"
* Go to Credentials and set a new Password(disable "Temporary")

## Service Account

* Open Cryptopus client
* Go to the "Service Account Roles" Tab
* Select "realm-management" in the Client Roles
* Add "manage-users" to the Assigned Roles

## Start Cryptopus with Keycloak

* Change provider in [auth.yml](../../auth.yml) to keycloak
* start application `$ rails s`
