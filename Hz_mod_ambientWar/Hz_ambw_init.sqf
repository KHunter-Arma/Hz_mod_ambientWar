Hz_ambw_path = "\x\Hz\Hz_mod_ambientWar\";

Hz_ambw_initDone = false;

Hz_ambw_functionsPath = Hz_ambw_path + "fnc\";

_this call compile preprocessFileLineNumbers (Hz_ambw_path + "Hz_ambw_srel_init.sqf");
_this call compile preprocessFileLineNumbers (Hz_ambw_path + "Hz_ambw_civ_init.sqf");

Hz_ambw_initDone = true;