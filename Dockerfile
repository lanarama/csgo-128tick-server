FROM xvzf/lanarama-steamcmd
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
