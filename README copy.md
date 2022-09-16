# WPDS - WordPress Development Server

WordPress development server with Docker and Docker Compose.

With this project you can quickly run the following:

- [WordPress and WP CLI](https://hub.docker.com/_/wordpress/)
- [phpMyAdmin](https://hub.docker.com/r/phpmyadmin/phpmyadmin/)
- [MySQL](https://hub.docker.com/_/mysql/)

Contents:

- [Requirements](#requirements)
- [Configuration](#configuration)
- [Installation](#installation)
- [Usage](#usage)

## Requirements

Make sure you have the latest versions of **Docker** and **Docker Compose** installed on your machine.

Clone this repository or copy the files from this repository into a new folder. In the **docker-compose.yml** file you may change the IP address (in case you run multiple containers) or the database from MySQL to MariaDB.

Make sure to [add your user to the `docker` group](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user) when using Linux.

## Publishing (publish)

This script publish your Wordpress to the environment you specify.

It accepts only one parameter, with following values:

- `all`: push your Wordpress to both staging and production
- `stating`: push your Wordpress to staging
- `production`: push your Wordpress to production

## Configuration

Copy the example environment into `.env`

```
cp env.example .env
```

Edit the `.env` file to change the default IP address, MySQL root password and WordPress database name.

## Docker Provisioning

Open a terminal and `cd` to the folder in which `docker-compose.yml` is saved and run:

```
docker-compose up
```

This creates two new folders next to your `docker-compose.yml` file.

* `wp-data` – used to store and restore database dumps
* `wp-app` – the location of your WordPress application

The containers are now built and running. You should be able to access the WordPress installation with the configured IP in the browser address. By default it is `http://127.0.0.1`.

For convenience you may add a new entry into your hosts file.

## Usage

### Starting containers

You can start the containers with the `up` command in daemon mode (by adding `-d` as an argument) or by using the `start` command:

```
docker-compose start
```

### Stopping containers

```
docker-compose stop
```

### Removing containers

To stop and remove all the containers use the`down` command:

```
docker-compose down
```

Use `-v` if you need to remove the database volume which is used to persist the database:

```
docker-compose down -v
```

### Project from existing source

Copy the `docker-compose.yml` file into a new directory. In the directory you create two folders:

* `wp-data` – here you add the database dump
* `wp-app` – here you copy your existing WordPress code

You can now use the `up` command:

```
docker-compose up
```

This will create the containers and populate the database with the given dump. You may set your host entry and change it in the database, or you simply overwrite it in `wp-config.php` by adding:

```
define('WP_HOME','http://wp-app.local');
define('WP_SITEURL','http://wp-app.local');
```

### Creating database dumps

```
./export.sh
```

### Developing a Theme

Configure the volume to load the theme in the container in the `docker-compose.yml`:

```
volumes:
  - ./theme-name/trunk/:/var/www/html/wp-content/themes/theme-name
```

### Developing a Plugin

Configure the volume to load the plugin in the container in the `docker-compose.yml`:

```
volumes:
  - ./plugin-name/trunk/:/var/www/html/wp-content/plugins/plugin-name
```

### WP CLI

The docker compose configuration also provides a service for using the [WordPress CLI](https://developer.wordpress.org/cli/commands/).

Sample command to install WordPress:

```
docker-compose run --rm wpcli core install --url=http://localhost --title=test --admin_user=admin --admin_email=test@example.com
```

Or to list installed plugins:

```
docker-compose run --rm wpcli plugin list
```

For an easier usage you may consider adding an alias for the CLI:

```
alias wp="docker-compose run --rm wpcli"
```

This way you can use the CLI command above as follows:

```
wp plugin list
```

### phpMyAdmin

You can also visit `http://127.0.0.1:8080` to access phpMyAdmin after starting the containers.

The default username is `root`, and the password is the same as supplied in the `.env` file.



## Workflow

Basically, this workflow performs the basic operations to manage your Wordpress application using Git as SCM. You just have to copy these files in the root folder of your Wordpress project, and the workflow will be available.

The actions you can do with this workflow are:

- Execute `run-docker.sh` to start a container on `port 80`.
- Execute `publish.sh [all|staging|production]` to publish to your live environments.

How do we publish to the live environments? Using [git-ftp](https://github.com/git-ftp/git-ftp), which is super cool for dealing with traditional, old-school operations on hosting servers using FTP. With this tool we can use Git to send only the required files by FTP, not all-or-nothing.

The workflow has to configure two remote sites with `git-ftp`, with names `staging` and `production`. Please read about how to configure them at project's repository.

To set up your workflow, **it's mandatory** to write down your custom values in a `.workflow.properties` file at the root directory of your Wordpress project.

    There is a sample file for this configuration, named `.workflow-sample.properties`.

## Git Branches

It's **mandatory** to have these three local branches to use this workflow:

- `dev`: where you create new features.
- `staging`: this branch will be pushed to your Staging environment.
- `master`: this branch will be pushed to your Production environment.

The workflow will move commits from `dev` to `staging` and to `master`, respectively when publishing to the proper environment.

    A git tag will be created when publishing to production, using as tag name the value defined in the file blog-version.txt. So keep that file up-to-date!

## Environments

It's **mandatory** to have three environments:

 - `Local`: a dockerised environment for testing locally. It will package the Wordpress application into a Docker container, following the LAMP stack. You can find the Docker image representing this environment [here](https://hub.docker.com/r/mdelapenya/lamp). You can find the code [here](https://github.com/mdelapenya/lamp).
 - `Staging`: a live environment for testing the Wordpress application before publishing to production. You can push your code here and review your changes. This workflow uses `dev` as subdomain.
 - `Production`: the live environment for the Wordpress application.

I.e.:

- local: http://localhost
- staging: http://dev.my-wordpress.com
- production: http://www.my-wordpress.com

## Files

### Versioning your project

Set the version of your Wordpress application in the `blog-version.txt` file. It will be used to create `git tags` for your project.

### Configuring Database (mysql-setup)

    This script is executed on build time of the Docker image.

This script initialises the database in the MySQL server that is bundled into the LAMP image.

You have to configure it with your database name, your database user, and its password.

### Updating Wordpress URLs (change-wp-url)

    This script is executed on build time of the Docker image.

As Wordpress hardcodes its URL in the database (WTF!), this script replaces all those ocurrences and applies the DNS name of the Wordpress environment.

It accepts one parameter, representing the environment where to apply the DNS name.

- `local`: it will apply `localhost` as URL for the environment, so it can be executed inside the Docker container.
- `staging`: it will prepend the `dev.` subdomain to the DNS, so it's important to understand that it's mandatory to have th
- `Any other value`: it will use the real DNS name, so all URL will be replaced with the real ones.

You have to configure it with your database name, and the DNS name of your Wordpress, without `www`, i.e. `mdelapenya.org`.

NOTE: please make sure that the real paths for the environments match with your hosting provider, including subdomains. In my case, I use [Interdominios](www.interdominios.com), which uses `/var/www/vhosts/mdelapenya.org\` for environments, and `` for subdomains.

### Running Docker container (run-docker)

    This script is executed every time we want to recreate the container.

It builds the image based on the current Dockerfile, copying your Wordpress installation to the Docker image. Then it `removes` the already existing container (`Cattle, not Pets`), and runs a new instance of the image, applying one volume for the `wp-content` folder.

    You have to configure it with your DockerHub user, the name of the Docker image, the name of the Docker container you want to use, and the name of the Wordpress theme you are using, just in case you need it. Please see the .workflow-sample.properties file.