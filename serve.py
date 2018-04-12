#!/usr/bin/env python3

#
#                 CSGO Server Launcher
#
#   Filename:   server.py
#   Author:     Matthias Riegler <matthias@xvzf.tech>
#   License:    None
#
#

import os, sys, subprocess
from pprint import pprint


class CSGOBuilder(object):

    def __init__(self):
        self.arguments = []
        self.set_basic_settings()
        self.set_from_env()


    def set_basic_settings(self):
        """
        Sets basic settings such as ports and tickrate
        """
        for setting in [
            "-game csgo", "-usercon",
            "-strictportbind", "-port 27015", "+clientport 27005", "+tv_port 27020",
            "-tickrate 128", "+log on",
            "-authkey", "-unsecure", "-insecure"]:
            self.arguments.append(setting)
    

    def set_gamemode(self, name="deathmatch"):
        """
        Sets the gamemode, available options:
            - deathmatch
            - armsrace
            - demolition
            - casual
            - competitive
        """
        def set_mode(gametype, gamemode):
            self.arguments.append(f"+game_type {gametype}")
            self.arguments.append(f"+game_mode {gamemode}")
            
        if name == "deathmatch":
            set_mode(1, 2) # Mode for Deathmatch

        elif name == "armsrace":
            set_mode(1, 0) # Mode for Arms Race

        elif name == "demolition":
            set_mode(1, 1) # Mode for Demolition

        elif name == "casual":
            set_mode(0, 0) # Mode for Classic Casual

        elif name == "competitive":
            set_mode(0, 1) # Mode for Classic Competitive

        else:
            raise NotImplementedError(f"The gamemode {name} is not available")
    

    def set_rcon_password(self, password="lanaramagameserver"):
        """
        Sets RCON Password
        """
        self.arguments.append(f"+rcon_password {password}")
    
    
    def set_GSLT(self, gslt=None):
        """
        Sets if the server is operating at a LAN Party or is online
        """
        self.arguments.append(f"+sv_lan {1 if not gslt else 0}")

        # Set some options if the server is serving online
        if gslt:
            self.arguments.append(f"+sv_setsteamaccount {gslt}")
            self.arguments.append(f"-net_port_try 1")


    def set_servername(self, name="Lanarama 2018 Dedicated Server - lanarama.com"):
        """
        Sets a custom server name
        """
        self.arguments.append(f"+hostname \"{name}\"")


    def set_from_env(self):
        """
        Parses environment options 
        """
        pass
        # Get gamemode from ENV
        if os.environ.get("CSGO_GAMEMODE"):
            self.set_gamemode(os.environ.get("CSGO_GAMEMODE"))
        else:
            print("CSGO_GAMEMODE required")
            sys.exit(1)
        
        # Get RCON Password from ENV
        if os.environ.get("CSGO_RCON_PASSWORD"):
            self.set_rcon_password(os.environ.get("CSGO_RCON_PASSWORD"))
        else:
            print("CSGO_RCON_PASSWORD not set, setting default to \"lanaramagameserver\"")
            self.set_rcon_password()
        
        # Get Servername from ENV
        if os.environ.get("CSGO_SERVERNAME"):
            self.set_servername(name=os.environ.get("CSGO_SERVERNAME"))
        else:
            print("CSGO_SERVERNAME not set, setting default")
            self.set_servername()
        
        # Get GSLT from ENV
        if os.environ.get("CSGO_GSTL"):
            print(f"Server set to public, GSLT token: {os.environ.get('CSGO_GSLT')}")
            self.set_GSLT(os.environ.get("CSGO_GSTL"))
        else:
            print("CSGO_GSLT not set, server is running in LAN mode")
            self.set_GSLT() # gamemode, rcon, name, GSTL 


    def run(self):
        """
        Spins up the actual server
        """
        # Quick'n dirty, but nothing else needed
        sys.exit(subprocess.call(
            f"./csgo/srcds_run {' '.join(self.arguments)}",
            shell=True)
        )

if __name__ == "__main__":
    CSGOBuilder().run()