/*******************************************************************************
* Copyright (C) 2018-2024 K.Hunter
*
* This file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

_this spawn {

	Hz_ambw_path = "\x\Hz\Hz_mod_ambientWar\";

	Hz_ambw_initDone = false;

	Hz_ambw_functionsPath = Hz_ambw_path + "fnc\";
	Hz_ambw_scriptsPath = Hz_ambw_path + "scripts\";

	if (is3DEN) then {
		waitUntil {sleep 2; !is3DEN};
	};
	
	Hz_ambw_fnc_areEnemies = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_fnc_areEnemies.sqf");
	Hz_ambw_fnc_areFriends = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_fnc_areFriends.sqf");
	Hz_ambw_fnc_findSafePos = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_fnc_findSafePos.sqf");
	Hz_ambw_fnc_findSpawnPos = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_fnc_findSpawnPos.sqf");
	Hz_ambw_fnc_isHeadlessClient = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_fnc_isHeadlessClient.sqf");
	Hz_ambw_fnc_isUncon = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_fnc_isUncon.sqf");

	Hz_ambw_enablePersistency = false;
	if (isClass (configFile >> "cfgPatches" >> "Hz_mod_persistency")) then {
		sleep 5;
		if (!isnil "Hz_pers_initDone") then {
			Hz_ambw_enablePersistency = true;
		};
	};
	
	_this call compile preprocessFileLineNumbers (Hz_ambw_path + "Hz_ambw_srel_init.sqf");
	_this call compile preprocessFileLineNumbers (Hz_ambw_path + "Hz_ambw_civ_init.sqf");
	_this call compile preprocessFileLineNumbers (Hz_ambw_path + "Hz_ambw_sc_init.sqf");
	_this call compile preprocessFileLineNumbers (Hz_ambw_path + "Hz_ambw_pat_init.sqf");

	Hz_ambw_initDone = true;

};