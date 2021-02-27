/*******************************************************************************
* Copyright (C) 2020 K.Hunter
*
* The source code contained within this file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

//no prior save data found
if ((count Hz_pers_network_ambw_pat_gSides) == 0) exitWith {};

{
	private _side = _x;
	private _group = createGroup _side;
	private _patrolMarker = Hz_pers_network_ambw_pat_gPatMarkers select _foreachIndex;
	_group setvariable ["Hz_Patrolling",true]; 
	private _vehicleTypes = Hz_pers_network_ambw_pat_gVehicleTypes select _foreachIndex;
	private _vehicleCrewTypes = Hz_pers_network_ambw_pat_gVehicleCrewTypes select _foreachIndex;
	private _vehiclePosATL = Hz_pers_network_ambw_pat_gVehiclePosATL select _foreachIndex;
	private _vehicleDir = Hz_pers_network_ambw_pat_gVehicleDir select _foreachIndex;
	{
		private _pos = _vehiclePosATL select _foreachIndex;
		private _vehArray = [_pos,_vehicleDir select _foreachIndex,_x,_group] call BIS_fnc_spawnVehicle;
		_vehArray params ["_vehicle", "_crew"];
		_vehicle setPosATL _pos;
		if (Hz_ambw_pat_lockVehicles) then {
			_vehicle setvehiclelock "LOCKED";
		};
		
		// Init passengers (if any)
		private _crewAndPassengerTypes = _vehicleCrewTypes select _foreachIndex;
		
		// filter out actual crew & passengers (not a bullet-proof method to always have the exact units placed in editor)
		private _crewTypes = _crew apply {typeOf _x};
		private _passengerUnits = +_crewAndPassengerTypes;		
		_passengerUnits = _passengerUnits - _crewTypes;		
		private _diff = (count _crewAndPassengerTypes) - ((count _passengerUnits) + (count _crew));
		if (_diff > 0) then {		
			for "_i" from 1 to _diff do {			
				_passengerUnits pushBack (selectRandom _crewTypes);			
			};		
		};
		
		// Fire-from-vehicle positions are not always "Cargo" positions so we need to handle them like this
		private _cargoCount = _vehicle emptyPositions "Cargo";
		private _fcFreeTurrets = [];
		{		
			_fcFreeTurrets pushback (_x select 3);		
		} foreach (fullCrew [_vehicle, "Turret",true] - fullCrew [_vehicle, "Turret",false]);
		
		{
			private _dude = _group createUnit [_x,_pos, [], 100, "NONE"];
			
			if (_cargoCount > 0) then {
						
				_dude assignascargo _vehicle;
				_dude moveinCargo _vehicle;
				_cargoCount = _cargoCount - 1;
			
			} else {
			
				if ((count _fcFreeTurrets) > 0) then {
				
					private _turret = selectRandom _fcFreeTurrets;
					_dude assignasTurret [_vehicle, _turret];
					_dude moveinTurret [_vehicle, _turret];
					_fcFreeTurrets = _fcFreeTurrets - [_turret];
				
				};
			
			};	
			
			_dude assignasCargo _vehicle;
			_dude moveInCargo _vehicle;		
		} forEach _passengerUnits;
		
		(units _group) allowGetIn true;
		(units _group) orderGetIn true;
	} foreach _vehicleTypes;
	
	private _infTypes = Hz_pers_network_ambw_pat_gInfantryTypes select _foreachIndex;
	private _infPosATL = Hz_pers_network_ambw_pat_gInfantryPosATL select _foreachIndex;
	{	
		private _pos = _infPosATL select _foreachIndex;
		private _dude = _group createUnit [_x,_pos, [], 100, "NONE"];		
		_dude setPosATL _pos;
		[_dude] allowGetIn false;
		[_dude] orderGetIn false;
	} foreach _infTypes;
	
	_group setFormation "STAG COLUMN";
	_group setSpeedMode "NORMAL";
	_group setCombatMode "SAFE";

	switch (_side) do {
		case blufor : {
			{Hz_ambw_pat_bluforUnits pushBack _x} foreach (units _group);	
		};
		case opfor : {
			{Hz_ambw_pat_opforUnits pushBack _x} foreach (units _group);	
		};
		case resistance : {
			{Hz_ambw_pat_grnforUnits pushBack _x} foreach (units _group);		
		};
	};		

	Hz_ambw_pat_patrolGroups pushBack [_group, _patrolMarker];
	publicVariableServer "Hz_ambw_pat_patrolGroups";
	
	[_group,_patrolMarker] spawn {
		
		params ["_group","_patrolMarker"];
		
		scriptName format ["Hz_ambw_pat_ID: %1",_group];
		
		_vehicle = objNull;
		{
			if ((vehicle _x) != _x) exitWith {
				_vehicle = vehicle _x;
			};
		} foreach units _group;		
	
		[_group,_patrolMarker] call Hz_AI_doPatrol;
		
		_group deleteGroupWhenEmpty true;
		
		if (alive _vehicle) then {
			Hz_ambw_pat_deleteVehicles pushBack _vehicle;
		};
		
	};
	
} foreach Hz_pers_network_ambw_pat_gSides;
