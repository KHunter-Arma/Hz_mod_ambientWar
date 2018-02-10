/*******************************************************************************
* Copyright (C) 2018 K.Hunter
*
* This file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

Hz_ambw_path = "\x\Hz\Hz_mod_ambientWar\";

Hz_ambw_initDone = false;

Hz_ambw_functionsPath = Hz_ambw_path + "fnc\";

if (is3DEN) then {

	waitUntil {sleep 2; !is3DEN};

};

_this call compile preprocessFileLineNumbers (Hz_ambw_path + "Hz_ambw_srel_init.sqf");
_this call compile preprocessFileLineNumbers (Hz_ambw_path + "Hz_ambw_civ_init.sqf");

Hz_ambw_initDone = true;