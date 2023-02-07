/*******************************************************************************
* Copyright (C) 2018-2023 K.Hunter
*
* This file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

	//#define playableunits switchableunits

	if (Hz_ambw_civ_debug) exitWith {_this spawn Hz_ambw_civ_fnc_despawnCivs;};

	private ["_ForceSpawnAtHouses","_numinput","_mutex","_exit","_civarray","_num","_count","_newcivarray","_roadarr","_client","_civtype","_group","_civ","_road","_spawnpos","_buildings","_wait","_group1","_group2","_group3","_civgroups","_killcivs","_trigger","_pos","_radius","_ownerIDs"];

	if (Hz_ambw_civ_debug) then {hint "inside main script";};

	_trigger = _this select 0;
	_pos = getpos _trigger;
	_radius = (triggerArea _trigger) select 0;
	_civarray = _trigger getVariable ["civarray",[]];
	_mutex = _trigger getVariable ["mutex",true];
	_ForceSpawnAtHouses = false;
	_numinput = 0;

	//optional, if true then use house positions to spawn civs instead of roads
	if((count _this) > 1) then {_ForceSpawnAtHouses = _this select 1;};

	//optional, for manual control of number of civs to spawn in area, rather than auto calculation.
	if((count _this) > 2) then {_numinput = _this select 2;};


	//if (Hz_ambw_civ_debug) then {sleep 4; [-1, {hint format ["%1",_this];}] call CBA_fnc_globalExecute; sleep 10;};

	if (!isServer) exitwith {};
	if(!Hz_ambw_civ_initDone) exitwith {};
	if(!_mutex) exitwith {};

	_exit = false;
	if(Hz_ambw_civ_forceGlobalMutex) then {
		if(!Hz_ambw_civGlobalMutexUnlocked) exitwith {_exit = true;};
		Hz_ambw_civGlobalMutexUnlocked = false;
	};
	if(_exit) exitwith{};

	_trigger setVariable ["mutex",false];

	if (Hz_ambw_civ_debug) then {hint format ["%1",_pos];sleep 10;};

	_ownerIDs = [];
	if(Hz_ambw_enableClientProcessing) then {{_ownerIDs set [count _ownerIDs, owner _x];}foreach playableunits;};

	
	if (Hz_ambw_civ_debug) then {[-1, {hint "inside despawn script";}] call CBA_fnc_globalExecute; sleep 10;};
	//Subtract civarray from total
	_count = count _civarray;
	Hz_ambw_currentNumberOfCiviliansSpawned = Hz_ambw_currentNumberOfCiviliansSpawned - _count;

	//Clean civarray; delete all civilians that are alive. Leave the already dead for added ambiance. 
	{
		_veh = vehicle _x;
		if (_veh == _x) then {							
			deletevehicle _x;							
		} else {							
			_veh deleteVehicleCrew _x;							
		};
	} foreach (_civarray select {(alive _x) && {!(_x getVariable ["Hz_ambw_civ_doNotDelete", false])}});

	_civarray = [];	
	
	if (Hz_ambw_civ_debug) then {sleep 4; [-1, {hint format ["Script done. returned civarray: %1",_civarray];}] call CBA_fnc_globalExecute; sleep 5;};

	_trigger setVariable ["civarray",_civarray];
	_trigger setVariable ["mutex",true];

	publicvariable "Hz_ambw_currentNumberOfCiviliansSpawned";

	if(Hz_ambw_civ_forceGlobalMutex) then {Hz_ambw_civGlobalMutexUnlocked = true;};