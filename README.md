# WolkConnect-PLCNext-Store-deployment
This repo contains artifacts require to deploy WolkConnect-PLCNext images on the PLCNext Store in the form of the applications.
Following files are presented:
 - Three WolkConnect-PLCNext docker images
 - PLCNext Store application template files - default files are provided by PhoenixContact via email in form of .tar.gz file.

## How to create a Container App for PLCnext

This template implements everything needed for creating a Container App for PLCnext Technology.

### Get started (ARM)

Simply [build the app](https://store.plcnext.help/st/PLCnext_App_Integration_Guide/PLCnext_Apps/Building_a_PLCnext_App.htm) and [install](https://www.plcnext.help/te/WBM/Administration_PLCnext_Apps.htm) it via the controller's Web Based Management.

#### app_info.json

Following parameters have to be changed:

- `name` of your App (without spaces!)
- `identifier` - can be obtained after creating a new app in the PLCnext Store
- `target` - needs to be compatible to your container architecture
- `minfirmware_version` - needs to be at least 22.6.0 for this type of app
- `manufacturer`

Follow this [link](https://store.plcnext.help/st/PLCnext_App_Integration_Guide/Apps_parts/Metadata.htm#bookmark) for more information to the metadata.


#### initscript.sh

Find the `APP configuration` section and edit the two available paramters.

Specify your **image(s)** and their accociated names by adding appropriate lines.

```bash
IMAGES[image_name]=image_archive
```

- `image_name` = the image name in the container system like hello-world.
- `image_archive` = the name of your saved image archive e.g. hello-world_x86.tar.gz

The archive(s) need to be located in the `images` folder.

> **Best Practice:** Instead of the image name, using the image ID provides more security. This also applies to the sha265 for downloads, instead of fixed image tags. To get the ID and sha265, call the `podman image inspect <image name>` command and get the ID and SHA256 from the first two values `"Id"` and `"Digest"`.

#### app-compose.yml

Write your own app-compose.yml.

For information about User Configuration, Volumes and environment variables, please look at the **Advanced configuration** chapter.

After your basic configuration is done, you can [build the app](https://store.plcnext.help/st/PLCnext_App_Integration_Guide/PLCnext_Apps/Building_a_PLCnext_App.htm) and [install](https://www.plcnext.help/te/WBM/Administration_PLCnext_Apps.htm) your app.


### Advanced configuration

#### User Configuration

Compose offers the option to load variables from a file. In PLCnext we will use this to allow user configuration without the right to edit the whole app-compose.yml. This can be used for example to pass port mappings, a user, persistent storage paths or environment variables into the container.

As an example the external port mapping in this template is available as a user editable variable.

First of all you have to use the variable in your compose.yml. Our recommendation is to set a default for each variable with the following pattern `${VARIABLE:-default}`. The default is used if "VARIABLE" is unset or empty in the environment. For more information follow the [link](https://docs.docker.com/compose/environment-variables/) into the official docker documentation.

If now a key value pair with the VARIABLE name as key is set in the `user.env`. It will be used upon restart. The environment file which will be used, is editable for the admin user under `/opt/plcnext/appshome/data/<APPID>/user.env`.

#### Usefull environment Variables while running the compose

While running the initscript there are some PLCnext specific environment variables available which should be used for specific tasks. They are the following and offering the path to:

- the mountpoint for ro app file: `APP_PATH`
- the app temporary data storage: `APP_TMP_PATH`
- the app persistent data storage: `APP_DATA_PATH`
- the app specific logfile: `APP_LOG`

#### Volumes and storage

First of all you have to use the app specific space for temporary and persistant data of your app. The available environment variables can be used for this task, e.g.:

```yml
    volumes:
      - $APP_DATA_PATH/data:/data
```

To make them accessible as admin, you have to add the same host paths to the init script as well. Use and extend the space separated `VOLUMES` list like this:

```bash
VOLUMES=("$APP_DATA_PATH/data" "$APP_TMP_PATH/temp")
```

### Creation of the PLCnext app container
All data that were prepared in the above steps is now ready to be composed to a PLCnext app.
Typically the app container is created on the PLCnext device by the command "plcnextapp" See more information in the PLCnext Store info center: [Creation of an App Container](https://store.plcnext.help/st/PLCnext_App_Integration_Guide/PLCnext_Apps/Creation_of_an_App-Container.htm "PLCnext Store").  
If this solution is not suitable for you by some reason e.g. the creation of the container should be integrated as an automatic build step then the app can be
created on a Linux desktop, too, see
[Alternative creation of an App Container](https://store.plcnext.help/st/PLCnext_App_Integration_Guide/PLCnext_Apps/Alternative_creation_of_an_app_container.htm "PLCnext Store")