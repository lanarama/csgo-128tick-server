FROM ubuntu:17.10
MAINTAINER Matthias Riegler <matthias@xvzf.tech>

ENV USER steam
ENV HOME /home/${USER}
ENV SERVER ${HOME}/cs_server

RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install lib32gcc1 curl net-tools lib32stdc++6 python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && useradd $USER \
    && mkdir $HOME \
    && chown $USER:$USER $HOME \
    && mkdir $SERVER \
    && chown $USER:$USER $SERVER


# Copy scripts needed for installation
COPY ./scripts/ $SERVER/scripts
RUN cd $SERVER \
    && mv scripts/* . \
    && rmdir scripts \
    && chown $USER:$USER -Rf * 

USER $USER

# Install steamcmd
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"  | tar xz -C $SERVER

# Install CSGO
RUN cd ${SERVER} && ./steamcmd.sh +login anonymous +force_install_dir ${SERVER}/csgo +app_update 740 validate +quit

# Copy startup script
COPY --chown=steam:steam ./config/* ${SERVER}/csgo/csgo/cfg/
COPY --chown=steam:steam ./serve.py ${SERVER}/serve.py

# Workdir and server startup
WORKDIR ${SERVER}

# Entrypoint; Startup server based on enviromental variables, available:
#  - CSGO_GAMEMODE      -> One out of "deathmatch", "casual", "competitive", "armsrace", "demolition"
#  - CSGO_RCON_PASSWORD -> Sets the RCON password
#  - CSGO_GSTL          -> Set to your GSTL, don't pass it and the server runs in LAN mode
#  - CSGO_SERVERNAME    -> Server Name
ENTRYPOINT [ "/usr/bin/python3", "serve.py" ]


# Main gamestream
EXPOSE 27015/udp
# Clientport, no need to forward
EXPOSE 27005/udp
# SourceTV, forward so GOTV can be used
EXPOSE 27020/udp