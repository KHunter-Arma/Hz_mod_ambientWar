Hz_ambw_path = "\x\Hz\Hz_mod_ambientWar\";

Hz_ambw_initDone = false;

if (isServer) then {

	_this call compile preprocessFileLineNumbers (Hz_ambw_path + "Hz_ambw_init_server.sqf");
	
};


if (!isDedicated) then {

	
	
};

Hz_ambw_initDone = true;