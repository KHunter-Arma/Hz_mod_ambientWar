/*******************************************************************************
* Copyright (C) 2018-2020 K.Hunter
*
* This file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

//TODO: module params
Hz_ambw_pat_lockVehicles = true;
Hz_ambw_pat_maxNumOfUnits = 160;
Hz_ambw_pat_factionsBalanceRatio = 0.65;
Hz_ambw_pat_cleanupLeftoverVehiclesTime = 10800;
Hz_ambw_pat_cleanupPlayerDist = 2000;
Hz_ambw_pat_hcName = "HC";


Hz_ambw_pat_enableHeadlessClient = false;
if (isMultiplayer && {Hz_ambw_pat_hcName != ""}) then {
	Hz_ambw_pat_enableHeadlessClient = true;
};
Hz_ambw_pat_fnc_isPatrolsMaster = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_pat_fnc_isPatrolsMaster.sqf");

if (isServer) then {
	if (isnil "Hz_ambw_pat_patrolsArray") then {
		Hz_ambw_pat_patrolsArray = [];
	};
	publicVariable "Hz_ambw_pat_patrolsArray";
	Hz_ambw_pat_serverInitDone = true;
	publicVariable "Hz_ambw_pat_serverInitDone";
};

if (!isDedicated) then {
	waitUntil {!isNull player};
	waitUntil {(name player) != "Error: No vehicle"};	
};
sleep 1;

if (call Hz_ambw_pat_fnc_isPatrolsMaster) then {
	
	// For persistency
	Hz_ambw_pat_patrolGroups = [];
	Hz_ambw_pat_patrolMarkers = [];
	publicVariableServer "Hz_ambw_pat_patrolGroups";
	publicVariableServer "Hz_ambw_pat_patrolMarkers";

	_hzAiCheckFailed = false;
	if (!isClass (configFile >> "cfgPatches" >> "Hz_AI")) then {
		_hzAiCheckFailed = true;
		waitUntil {
			time > 30
		};
	};
	if (_hzAiCheckFailed) exitWith {
		hint "Hz_AMBW Error: Ambient patrols require Hunter'z AI mod to be running where patrols are local! Exiting...";
		diag_log "#### Hunter'z Ambient Warfare ERROR";
		diag_log "#### Ambient patrols require Hunter'z AI mod to be running where patrols are local! Exiting...";
		diag_log "####";
	};

	Hz_ambw_pat_patrolsHandler = compile preprocessFileLineNumbers (Hz_ambw_scriptsPath + "Hz_ambw_pat_patrolsHandler.sqf");
	Hz_ambw_pat_spawnPatrol = compile preprocessFileLineNumbers (Hz_ambw_scriptsPath + "Hz_ambw_pat_spawnPatrol.sqf");
	Hz_ambw_pat_fnc_loadPatrolsFromSave = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_pat_fnc_loadPatrolsFromSave.sqf");

	if (isnil "Hz_ambw_pat_disablePatrols") then {
		Hz_ambw_pat_disablePatrols = false;
	};
	Hz_ambw_pat_deleteVehicles = [];
	Hz_ambw_pat_opforUnits = [];
	Hz_ambw_pat_bluforUnits = [];
	Hz_ambw_pat_grnforUnits = [];
	
	waitUntil {
		sleep 1;
		(!isNil "Hz_ambw_pat_serverInitDone") && {Hz_ambw_pat_serverInitDone}
	};
	
	sleep 10;
	
	if (isnil "Hz_ambw_pat_patrolsArray") then {
		Hz_ambw_pat_patrolsArray = [];
	};
	
	[] spawn Hz_ambw_pat_patrolsHandler;
	
};