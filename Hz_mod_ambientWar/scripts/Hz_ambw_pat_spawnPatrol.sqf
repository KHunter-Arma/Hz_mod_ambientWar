/*******************************************************************************
* Copyright (C) 2020 K.Hunter
*
* This file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

params ["_unitType", "_respawnPosition", "_patrolMarker", "_side", "_crewAndPassengerTypes", "_infantryTypes"];

private _signx = if ((random 1) < 0.5) then {-1} else {1};
private _signy = if ((random 1) < 0.5) then {-1} else {1};

//TODO: Find safe pos
private _respawnArea = [(((markerPos _respawnPosition) select 0) + (random 715)*_signx),(((markerPos _respawnPosition) select 1) + (random 715)*_signy),0];

private _noPassengers = false;
private _isInfantryGroup = _unitType isKindOf "CAManBase";
if (!_isInfantryGroup && {(count _infantryTypes) > 0}) then {
	_noPassengers = true;
};

private _vehicle = objNull;
private _group = createGroup _side;
_group setvariable ["Hz_Patrolling",true]; 
scriptName format ["Hz_ambw_pat_ID: %1",_group];

if (_isInfantryGroup) then {

	{
		private _dude = _group createUnit [_x,_respawnArea, [], 100, "NONE"];			
	} foreach _infantryTypes;
	
	_infantryTypes allowGetIn false;
	_infantryTypes orderGetIn false;

} else {

	if (_noPassengers) then {
	
		_vehicle = ([_respawnArea,90,_unitType,_group] call BIS_fnc_spawnVehicle) select 0;
		if (Hz_ambw_pat_lockVehicles) then {
			_vehicle setvehiclelock "LOCKED";
		};
		
		(units _group) allowGetIn true;
		(units _group) orderGetIn true;
		
		{
			_dude = _group createUnit [_x,_respawnArea, [], 100, "NONE"];			
		} foreach _infantryTypes;

		_infantryTypes allowGetIn false;
		_infantryTypes orderGetIn false;

	} else {
		
		private _vehArray = [_respawnArea,90,_unitType,_group] call BIS_fnc_spawnVehicle;
		_vehArray params ["_vehicle", "_crew"];		
		if (Hz_ambw_pat_lockVehicles) then {
			_vehicle setvehiclelock "LOCKED";
		};
		
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
			private _dude = _group createUnit [_x,_respawnArea, [], 100, "NONE"];
			
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
		
	};

};

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

[_group,_patrolMarker] call Hz_AI_doPatrol;

_group deleteGroupWhenEmpty true;

if (alive _vehicle) then {
	Hz_pops_deleteVehicleArray pushBack _vehicle;
};

Hz_ambw_pat_patrolsArray pushBack [_unitType, _respawnPosition, _patrolMarker, _side, _crewAndPassengerTypes,_infantryTypes];
