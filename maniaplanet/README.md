# ManiaPlanet 3 Beta Server

## How to run

```
docker run [docker options] minigod/maniaplanet [arguments to maniplanet server]
```
Required docker options to be able to run:
* `-e PORT=x` - where `x` is any free port on the host (only required if you need to expose on any other port than `2350`)
* `-p x:2350 -p x:2350/udp` - where `x` is any free port on the host (must match `-e PORT=x`). eg: `-p 9999:2350 -p 9999:2350/udp`

Required arguments to maniaplanet
* `/title=x` - where `x` is the title to use. Titles available: `TMCanyon`, `TMStadium`, `TMValley`, `SMStorm`.
* \* `/login=x` - where `x` is the [login of the dedicated server][playerpage:dedicated-servers].
* \* `/password=x` - where `x` is the [password of the dedicated server][playerpage:dedicated-servers].
* \* `/dedicated_cfg=x` - where `x` is the filename of the config file - relative to `/maniaplanet/UserData/Config/`. It loads `config.xml` by default. See the section below about custom config for more details.
* `/game_settings=x` - where `x` is the filename of the match settings file - relative to `/maniaplanet/UserData/Maps`.

\* Either a `dedicated_cfg` with valid masterserver login information or `/login=x /password=y` is required

### Most basic example to get it running

This will start a server for TMCanyon with the white maps matchsettings (TMCanyonA). The login will also be the name of the server.

Since this does not have the login information in the `dedicated_cfg` file, we need to provide it in the arguments to the server.

```
docker run \
  -p 2350:2350 -p 2350:2350/udp \              # expose the ports from the container on the host
  --name mycanyonserver \                      # name the container (not the name of server in game)
  minigod/maniaplanet \                        # the image to run (this image)
  /login=canyonserver /password=foobar \       # masterserver login and password
  /title=TMCanyon \                            # The titlepack to use
  /game_settings=MatchSettings/TMCanyonA.txt   # Which matchsettings to use
```

### Multiple servers per host

To run multiple servers per host, you have to add `-e PORT=someport` to tell the image which port the server is exposed on the host machine, example:  
`-e PORT=2355 -p 2355:2350 -p 2355:2350`  
This is needed because the server tells the masterserver which IP:PORT combination its running on. Without `-e PORT` you have to expose the container on port 2350 on the host.

```
docker run \
  -e PORT=2355 -p 2355:2350 -p 2355:2350/udp \    # expose the ports from the container on the host
  --name smserver \                               # name the container
  minigod/maniaplanet \                           # the image to run (this image)
  /login=smserver /password=foobar \              # masterserver login and password
  /title=SMStorm \                                # The titlepack to use
  /game_settings=MatchSettings/SMStormBattle1.txt # Which matchsettings to use
```

### Custom maps, config and matchsettings

To run your own dedicated_cfg: `docker run -v /where/my/config/is/dedicated_cfg.txt:/maniaplanet/UserData/Config/config.xml`. It loads `config.xml` by default, so there is no need to add `/dedicated_cfg`. If you set the masterserver login and password in this file, you can omit the `/login` and `/password` arguments to the server.  
_note: when using a custom config file, make sure you set `xmlrpc_allowremote` to `True` so that xaseco or the likes can connect_

The maps are in `/maniaplanet/UserData/Maps/`. To replace this directory with your own maps directory from the host, use the [volume docker option][docker:runvolume]: `docker run -v /where/my/maps/are:/maniaplanet/UserData/Maps -e POR....`  
This will also include your match settings files, so now you can, for instance, add `/game_settings=playlist.txt` to use your own match settings.

### Example: Run your existing server in docker
```
docker run \
  -e PORT=2355 -p 2355:2350 -p 2355:2350/udp \    # expose the ports from the container on the host
  -v /home/tm2/smserver/UserData/Config/dedicated_cfg.txt:/maniaplanet/UserData/Config/config.xml \
  -v /home/tm2/smserver/UserData/Maps/:/maniaplanet/UserData/Maps \
  --name smserver \                               # name the container
  minigod/maniaplanet \                           # the image to run (this image)
  /title=SMStorm \                                # The titlepack to use
  /game_settings=playlist.txt                     # Which matchsettings to use
```


# discalimer

This is my first Dockerfile ever.

[playerpage:dedicated-servers]: https://player.maniaplanet.com/dedicated-servers
[docker:runvolume]: https://docs.docker.com/engine/reference/commandline/run/#/mount-volume-v-read-only
