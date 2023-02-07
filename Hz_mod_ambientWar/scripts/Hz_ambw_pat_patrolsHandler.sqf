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

scriptname "Hz_ambw_pat_patrolsHandler";

if (Hz_ambw_enablePersistency) then {

	waitUntil {
		sleep 5;
		(!isnil "Hz_pers_serverInitialised") && {Hz_pers_serverInitialised}
	};
	
	if (isServer) then {
	
		//make sure sectors finish loading
		waitUntil {
			sleep 5;
			(!isNil "Hz_ambw_sc_sectorsLoadingFromSaveDone") && {Hz_ambw_sc_sectorsLoadingFromSaveDone}
		};
	
		call Hz_ambw_pat_fnc_loadPatrolsFromSave;
	
	} else {
	
		waitUntil {
			sleep 0.1;
			Hz_pers_initDone
		};
		
		call Hz_pers_fnc_hzAmbwHcRequestInfoFromServer;
		
		call Hz_ambw_sc_fnc_loadSectorsFromSave;
		
		call Hz_ambw_pat_fnc_loadPatrolsFromSave;
		
		Hz_ambw_sc_hcSectorsLoaded = true;
		publicVariableServer "Hz_ambw_sc_hcSectorsLoaded";
	
	};
	
};

if ((count Hz_ambw_pat_patrolsArray) == 0) then {
	waitUntil {
		sleep 30;
		(count Hz_ambw_pat_patrolsArray) > 0
	};
};

private _timeScale = ceil(Hz_ambw_pat_cleanupLeftoverVehiclesTime/20);
private _timeScaler = 0;

while {true} do {
	
	sleep 20;

	{		
		if (!alive _x) then {					
			Hz_ambw_pat_deleteVehicles = Hz_ambw_pat_deleteVehicles - [_x];			
		};
	} foreach Hz_ambw_pat_deleteVehicles;

	if ((!Hz_ambw_pat_disablePatrols) && {(count allunits) < Hz_ambw_pat_maxNumOfUnits}) then {
		
		{
			if (!alive _x) then {
				Hz_ambw_pat_grnforUnits = Hz_ambw_pat_grnforUnits - [_x];
			};
		} foreach Hz_ambw_pat_grnforUnits;
		{
			if (!alive _x) then {
				Hz_ambw_pat_opforUnits = Hz_ambw_pat_opforUnits - [_x];
			};
		} foreach Hz_ambw_pat_opforUnits;
		{
			if (!alive _x) then {
				Hz_ambw_pat_bluforUnits = Hz_ambw_pat_bluforUnits - [_x];
			};
		} foreach Hz_ambw_pat_bluforUnits;
		
		_countGrnfor = count Hz_ambw_pat_grnforUnits;
		_countBlufor = count Hz_ambw_pat_bluforUnits;
		_countOpfor = count Hz_ambw_pat_opforUnits;
		
		_GrnforArray = [];
		_BluforArray = [];
		_OpforArray = [];			
		{
			switch (_x select 3) do {
				case blufor : {
					_BluforArray pushBack _x;		
				};
				case opfor : {
					_OpforArray pushBack _x;	
				};
				case resistance : {
					_GrnforArray pushBack _x;	
				};
			};		
		} foreach Hz_ambw_pat_patrolsArray;
		
		_patrolArray = [];
		switch (true) do {
			case (((count _GrnforArray) > 0) && {(_countGrnfor < (Hz_ambw_pat_factionsBalanceRatio*_countOpfor)) || {_countGrnfor < (Hz_ambw_pat_factionsBalanceRatio*_countBlufor)}}) : {
				_patrolArray = _GrnforArray;
			};
			case (((count _BluforArray) > 0) && {(_countBlufor < (Hz_ambw_pat_factionsBalanceRatio*_countOpfor)) || {_countBlufor < (Hz_ambw_pat_factionsBalanceRatio*_countGrnfor)}}) : {
				_patrolArray = _BluforArray;
			};
			case (((count _OpforArray) > 0) && {(_countOpfor < (Hz_ambw_pat_factionsBalanceRatio*_countBlufor)) || {_countOpfor < (Hz_ambw_pat_factionsBalanceRatio*_countGrnfor)}}) : {
				_patrolArray = _OpforArray;
			};
			default {
				_patrolArray = Hz_ambw_pat_patrolsArray;
			};
		};
					
		{						
			_randomIndex = floor random (count _patrolArray);
			
			_randomPatrol = _patrolArray select _randomIndex; 
			
			_mpos = [];
			
			if ((typeName (_randomPatrol select 2)) == "STRING") then {
				_mpos = markerpos (_randomPatrol select 2);
			} else {
				_mpos = markerpos (selectRandom (_randomPatrol select 2));
			};
			
			if (({(_mpos distance _x) < 3500} count playableunits) < 1) exitWith {
				
				_randomPatrol spawn Hz_ambw_pat_spawnPatrol;
				_randomIndex = Hz_ambw_pat_patrolsArray find _randomPatrol;
				Hz_ambw_pat_patrolsArray set [_randomIndex,"nil"];
				Hz_ambw_pat_patrolsArray = Hz_ambw_pat_patrolsArray - ["nil"];		
			};		
		} foreach _patrolArray;
		
	};
	
	{
		
		if (local _x) then {
			
			if ((_x getVariable ["Hz_disabledPatrol",false])
					&& {(time - (_x getvariable ["Hz_AI_lastCriticalDangerTime",-600])) > 600}
					&& {_leadPos = getpos leader _x; ({(_x distance _leadPos) < 2000} count playableunits) < 1}
					) then {
				
				_veh = objnull;									
				{
					
					_veh = vehicle _x;					
					unassignvehicle _x;
					_x action ["Eject", _veh];	
					
				} foreach units _x;	
				(units _x) ordergetin false;
				(units _x) allowgetin false;
				_x leaveVehicle _veh;	
				
				//_x setVariable ["Hz_defending",false];
				_x setVariable ["Hz_disabledPatrol",false];
				_x setVariable ["Hz_disabledEjectedPatrol",true];
				
			};
			
		};
		
	} foreach allGroups;
	
	private _temp = [];
	private _count = count Hz_ambw_pat_patrolGroups;
	{
		if ((count units (_x select 0)) > 0) then {
			_temp pushBack _x;
		};
	} foreach Hz_ambw_pat_patrolGroups;
	if ((count _temp) != _count) then {
		Hz_ambw_pat_patrolGroups = +_temp;
		publicVariableServer "Hz_ambw_pat_patrolGroups";
	};

	{
		
		if (local _x) then {
			
			if ((_x getVariable ["Hz_disabledEjectedPatrol",false])
					&& {(time - (_x getvariable ["Hz_AI_lastCriticalDangerTime",-600])) > 900}
					&& {_leadPos = getpos leader _x; ({(_x distance _leadPos) < 2000} count playableunits) < 1}
					) then {
				
				{
					_veh = vehicle _x;
					if (_veh == _x) then {							
						deletevehicle _x;							
					} else {							
						_veh deleteVehicleCrew _x;							
					};
				} foreach units _x;
				
			};
			
		};		
		
	} foreach allGroups;
	
	_timeScaler = _timeScaler + 1;
	if (_timeScaler > _timeScale) then {
		_timeScaler = 0;
		{
			if (alive _x) then {
		
				if ((count crew _x) == 0) then {
				
					_veh = _x;
				
					if (({(_x distance _veh) < Hz_ambw_pat_cleanupPlayerDist} count playableUnits) < 1) then {
					
						Hz_ambw_pat_deleteVehicles = Hz_ambw_pat_deleteVehicles - [_x];
						deletevehicle _x;				
					
					};
				
				};
			
			};
		} foreach Hz_ambw_pat_deleteVehicles;
	};

};
