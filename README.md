# LANARAMA-CSGO

Dockerized CSGO Server. Optimized for 128 Ticks.
As the Image is quite large (~16GB) it will not be pushed to Dockerhub as frequent. To build a recent version, just call `docker build . -t lanarama/csog-128tick`

## Launch options
Launch options are parsed by the ENV. Following options are available:
  - CSGO_GAMEMODE
  - CSGO_RCON_PASSWORD
  - CSGO_GSLT
  - CSGO_SERVERNAME

You can spin up a server using e.g. <br>
`docker run -e CSGO_SERVERNAME="Lanarama Gameserver 01" -e CSGO_GAMEMODE="competitive" -e CSGO_RCON_PASSWORD="dontusethispassword" -d lanarama/csgo-128tick`

Macvlan docker is a good idea; run via: `docker run  -e CSGO_SERVERNAME="Lanarama Gameserver 0" -e CSGO_GAMEMODE="competitive" -e CSGO_RCON_PASSWORD="dontusethispassword" -e CSGO_GSTL="<redacted>" --network=servernet --name=csgo-0 lanarama/csgo`

### Gamemode options
In order to set the gamemode, set `CSGO_GAMEMODE` to one of the following options:
  - deathmatch
  - casual
  - competitive
  - armsrace
  - demolition

### Changing the RCON password
The default RCON password is `lanaramagameserver`. In order to change it, set `CSGO_RCON_PASSWORD` to the desired passphrase.

### Changing the server name
A custom server name can be set by assigning `CSGO_SERVERNAME`.

### Going online
In order to create public server, `CSGO_GSLT` has to be populated by the correct GSLT.
