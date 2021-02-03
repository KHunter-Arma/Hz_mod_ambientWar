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

params ["_grp", "_sectorIndex"];

private _sleep = {

	while {(time < _tEnd) && {({(alive _x) && {(lifeState _x) != "INCAPACITATED"}} count units _grp) > 0} && {((leader _grp) distance2D _sectorPos) < _radius}} do {
		if (((time - (_grp getvariable ["Hz_AI_lastCriticalDangerTime",-120])) < 120) || {
					_nearEntities = _sectorPos nearEntities [["CAManBase","LandVehicle","Ship","StaticWeapon"], _radius];
					_strengthRatio = ({_sideX = side _x; (_sideX != civilian) && {[_side, _sideX] call Hz_ambw_fnc_areFriends}} count _nearEntities)/(0.1 max ({_sideX = side _x; (_sideX != civilian) && {[_side, _sideX] call Hz_ambw_fnc_areEnemies}} count _nearEntities));
					_strengthRatio <= 1.0
				}) then {
			_tEnd = _tEnd + 5;
		};	
		sleep 5;
	};
	
	if ((({(alive _x) && {(lifeState _x) != "INCAPACITATED"}} count units _grp) < 1) || {((leader _grp) distance2D _sectorPos) > _radius}) then {
		_groupsCapturing set [_sideIndex,(_groupsCapturing select _sideIndex) - [_grp]];
		_sector set [7,_groupsCapturing];
		Hz_ambw_sc_sectors set [_sectorIndex, _sector];
		publicVariable "Hz_ambw_sc_sectors";
		
		true
	} else {
		false	
	}

};

//wait until we are not being attacked
waitUntil {
	sleep 5;
	((time - (_grp getvariable ["Hz_AI_lastCriticalDangerTime",-120])) > 120)	|| {({(alive _x) && {(lifeState _x) != "INCAPACITATED"}} count units _grp) < 1}
};

//check if still alive -- exit if not
if (({(alive _x) && {(lifeState _x) != "INCAPACITATED"}} count units _grp) < 1) exitWith {};

private _sector = Hz_ambw_sc_sectors select _sectorIndex; 
private _sectorPos = _sector select 0;
private _radius = _sector select 1;
private _flag = _sector select 5;
private _objects = _sector select 6;
private _groupsCapturing = _sector select 7;
private _lead = leader _grp;
private _side = side _lead;
private _sideX = sideEmpty;

//are we still within the radius if we were under attack until now? -- a good way to handle this is to return to patrol and let it re-issue move order
if ((_lead distance2D _sectorPos) > _radius) exitWith {}; 

private _sideIndex = switch (_side) do {
	case west : {1};
	case east : {0};
	case independent : {2};
	default {-1};
};

if (_sideIndex == -1) exitWith {
	hint "Hz_Ambw ERROR: Unknown side trying to capture sector";
	diag_log "Hz_Ambw ERROR: Unknown side trying to capture sector";
};

if ((count (_groupsCapturing select _sideIndex)) > 0) exitWith {};

_groupsCapturing set [_sideIndex,(_groupsCapturing select _sideIndex) + [_grp]];
_sector set [7,_groupsCapturing];
Hz_ambw_sc_sectors set [_sectorIndex, _sector];
publicVariable "Hz_ambw_sc_sectors";

//wait until we are stronger than the enemy within the radius
private _nearEntities = [];
private _strengthRatio = 0;
private _tEnd = time + 10;
if (call _sleep) exitWith {};

//cleanup any remnants of enemy emplacements (t=0)
private _temp = [];
{
	if (alive _x) then {
		_temp pushBack _x;
	};
} foreach _objects;
_objects = _temp;
if ((count _objects) > 0) then {
	{
		if (({(alive _x) && {(lifeState _x) != "INCAPACITATED"}} count units _grp) < 1) exitWith {};
		private _obj = _x;
		if (alive _obj) then {
			if ((count crew _obj) > 0) then {
				{
					if (local _x) then {
						unassignVehicle _x;
						(group _x) leaveVehicle _obj;
						moveout _x;
						sleep 1;
						_x doMove _sectorPos;
					} else {
						_x remoteExecCall ["unassignVehicle", _x, false];
						[group _x, _obj] remoteExecCall ["leaveVehicle", _x, false];
						_x remoteExecCall ["moveout", _x, false];
						waitUntil {sleep 1; ((count crew _obj) < 1)};
						[_x, _sectorPos] remoteExecCall ["doMove", _x, false];
					};
				} foreach crew _obj;
			};				
			
			private _weaponHolders = nearestObjects [_obj,["WeaponHolder"],5];
			{								
				deletevehicle _x;							
			} foreach _weaponHolders;		
			
			_objects = _objects - [_obj];			
			deleteVehicle _obj;
			_tEnd = time + 9;
			call _sleep;
		};
	} foreach _objects;
};
_sector set [6,_objects];
Hz_ambw_sc_sectors set [_sectorIndex, _sector];
publicVariable "Hz_ambw_sc_sectors";
if ((({(alive _x) && {(lifeState _x) != "INCAPACITATED"}} count units _grp) < 1) || {((leader _grp) distance2D _sectorPos) > _radius}) exitWith {};

//neutralize flag (t=0)
_tEnd = time + Hz_ambw_sc_captureTime/4;
if (call _sleep) exitWith {};
private _flagPos = [0,0,0];
if (!isnull _flag) then {
	_flagPos = getPosATL _flag;
	deleteVehicle _flag;
	(_sector select 4) setMarkerColor "ColorBlack";
	_sector set [3, sideEmpty];
	Hz_ambw_sc_sectors set [_sectorIndex, _sector];
	publicVariable "Hz_ambw_sc_sectors";
	_tEnd = time + Hz_ambw_sc_captureTime/4;
	if (call _sleep) exitWith {};
} else {
	_flagPos = [_sectorPos,10] call Hz_ambw_fnc_findSafePos;
};

if ((({(alive _x) && {(lifeState _x) != "INCAPACITATED"}} count units _grp) < 1) || {((leader _grp) distance2D _sectorPos) > _radius}) exitWith {};

_flag = (Hz_ambw_sc_flagTypes select _sideIndex) createVehicle [-5000,-5000,50000];
_flag setPosATL _flagPos;
_sector set [5,_flag];
_sector set [3, _side];
private _colour = switch (_side) do {
	case east : {"ColorEAST"};
	case west : {"ColorWEST"};
	case resistance : {"ColorGUER"};
};
(_sector select 4) setMarkerColor _colour;
Hz_ambw_sc_sectors set [_sectorIndex, _sector];
publicVariable "Hz_ambw_sc_sectors";

private _defGroup = grpNull;

//build guns
private _numGuns = Hz_ambw_sc_staticCountMin max (round random Hz_ambw_sc_staticCountMax);

if (_numGuns > 0) then {

	private _t = (Hz_ambw_sc_captureTime/4)/_numGuns;

	for "_i" from 1 to _numGuns do {
		
		_tEnd = time + _t;		
		if (call _sleep) exitWith {};
		
		private _gunPos = [_sectorPos, 20] call Hz_ambw_fnc_findSafePos;	
		private _gun = (selectRandom (Hz_ambw_sc_staticTypes select _sideIndex)) createVehicle _gunPos;
		_gun setPosATL _gunPos;
		_gun setDir ((_gunPos getDir _flag) + 180);
		_gun setVehicleLock "LOCKED";
		
		_objects pushBack _gun;
		
		if (isNull _defGroup) then {
			_defGroup = createGroup _side;
			_defGroup deleteGroupWhenEmpty true;
			_defGroup setVariable ["Hz_defending",true];
		};	
		private _dude = _defGroup createUnit [(selectRandom (Hz_ambw_sc_defenderTypes select _sideIndex)), _gunPos, [], 100, "NONE"];
		_dude assignAsGunner _gun;
		_dude moveInGunner _gun;
		
	};

};

_sector set [6,_objects];
Hz_ambw_sc_sectors set [_sectorIndex, _sector];
publicVariable "Hz_ambw_sc_sectors";

if ((({(alive _x) && {(lifeState _x) != "INCAPACITATED"}} count units _grp) < 1) || {((leader _grp) distance2D _sectorPos) > _radius}) exitWith {};

//build emplacements
private _numEmplacements = Hz_ambw_sc_emplacementCountMin max (round random Hz_ambw_sc_emplacementCountMax);

_attacked = false;
_emplacementBuildingPos = [];

if (_numEmplacements > 0) then {

	private _t = (Hz_ambw_sc_captureTime/4)/_numEmplacements;

	for "_i" from 1 to _numEmplacements do {
		
		_tEnd = time + _t;		
		if (call _sleep) exitWith {
			_attacked = true;
		};
		
		private _empPos = [_sectorPos, 20] call Hz_ambw_fnc_findSafePos;	
		private _emp = (selectRandom (Hz_ambw_sc_fortificationTypes select _sideIndex)) createVehicle _empPos;
		
		_objects pushBack _emp;		
		_emp setPosATL _empPos;
		//most emplacements have "reversed" direction...
		_emp setDir (_empPos getDir _flag);	
		
		sleep 1;
		_emplacementBuildingPos = _emplacementBuildingPos + ([_emp] call BIS_fnc_buildingPositions);
		
	};

};

_sector set [6,_objects];

if (!_attacked) then {

	//create defenders
	private _numDefenders = Hz_ambw_sc_defenderCountMin max (round random Hz_ambw_sc_defenderCountMax);

	if (_numDefenders > 0) then {

		for "_i" from 1 to _numDefenders do {
			
			if (isNull _defGroup) then {
				_defGroup = createGroup _side;
				_defGroup deleteGroupWhenEmpty true;
				_defGroup setVariable ["Hz_defending",true];
			};	
			private _dude = _defGroup createUnit [(selectRandom (Hz_ambw_sc_defenderTypes select _sideIndex)), _sectorPos, [], 50, "NONE"];
			
			if ((count _emplacementBuildingPos) > 0) then {
				_pos = selectRandom _emplacementBuildingPos;
				_dude setPosATL _pos;
				_emplacementBuildingPos = _emplacementBuildingPos - [_pos];
				_dude setVariable ["Hz_noMove",true];
				_dude disableAI "PATH";
				_dude forcespeed 0;
				dostop _dude;
			};
			
		};

	};

};

//return to patrol

_groupsCapturing set [_sideIndex,(_groupsCapturing select _sideIndex) - [_grp]];
_sector set [7,_groupsCapturing];
Hz_ambw_sc_sectors set [_sectorIndex, _sector];
publicVariable "Hz_ambw_sc_sectors";
