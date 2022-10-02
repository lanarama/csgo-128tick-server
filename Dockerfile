FROM ubuntu:20.04 as steamcmd
MAINTAINER Matthias Riegler <matthias@xvzf.tech>

ENV USER steam
ENV HOME /home/${USER}
ENV STEAMCMD ${HOME}/steamcmd

RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install lib32gcc1 curl unzip net-tools lib32stdc++6 python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && useradd $USER \
    && mkdir $HOME \
    && chown $USER:$USER $HOME \
    && mkdir $STEAMCMD \
    && chown $USER:$USER $STEAMCMD

USER $USER

# Install steamcmd
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"  | tar xz -C $STEAMCMD \
    && ./${STEAMCMD}/steamcmd.sh +quit \
    && mkdir -p ${HOMEDIR}/.steam/sdk32 \
    && ln -s ${STEAMCMD}/linux32/steamclient.so ${HOME}/.steam/sdk32/steamclient.so \
    && ln -s ${STEAMCMD}/linux32/steamcmd ${STEAMCMD}/linux32/steam \
    && ln -s ${STEAMCMD}/steamcmd.sh ${STEAMCMD}/steam.sh \


WORKDIR $STEAMCMD


FROM steamcmd as csgo-base
MAINTAINER Matthias Riegler <matthias@xvzf.tech>

# Install CSGO
RUN ./steamcmd.sh +login anonymous +force_install_dir ./csgo +app_update 740 validate +quit

# Copy startup script
COPY --chown=steam:steam ./config/* ./csgo/csgo/cfg/
COPY --chown=steam:steam ./serve.py ./serve.py

# Entrypoint; Startup server based on enviromental variables, available:
#  - CSGO_GAMEMODE      -> One out of "deathmatch", "casual", "competitive", "armsrace", "demolition"
#  - CSGO_RCON_PASSWORD -> Sets the RCON password
#  - CSGO_GSTL          -> Set to your GSTL, don't pass it and the server runs in LAN mode
#  - CSGO_SERVERNAME    -> Server Name
ENTRYPOINT [ "/usr/bin/python3", "./serve.py" ]


# Main gamestream
EXPOSE 27015/udp
# Clientport, no need to forward
EXPOSE 27005/udp
# SourceTV, forward so GOTV can be used
EXPOSE 27020/udp

FROM csgo-base

COPY --chown=steam:steam ./scripts/install-get5.sh install-get5.sh
# chmod for the full folder, otherwise we run into issues. Needs to be fixed properly :)
RUN  bash install-get5.sh $(pwd)/csgo/csgo/ && chmod 755 -R $(pwd)/csgo/csgo/
