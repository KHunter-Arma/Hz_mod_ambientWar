/*******************************************************************************
* Copyright (C) 2020-2023 K.Hunter
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

	while {(time < _tEnd) && {({(alive _x) && {(lifeState _x) != "INCAPACITATED"}} count units _grp) > 0}} do {
		if (((time - (_grp getvariable ["Hz_AI_lastCriticalDangerTime",-120])) < 120) || {
					_nearEntities = _sectorPos nearEntities [["CAManBase","LandVehicle","Ship","StaticWeapon"], _radius];
					_strengthRatio = ({_sideX = side _x; (_sideX != civilian) && {[_side, _sideX] call Hz_ambw_fnc_areFriends}} count _nearEntities)/(0.1 max ({_sideX = side _x; (_sideX != civilian) && {[_side, _sideX] call Hz_ambw_fnc_areEnemies}} count _nearEntities));
					_strengthRatio <= 1.0
				}) then {
			_tEnd = _tEnd + 5;
		};	
		sleep 5;
	};
	
	if (({(alive _x) && {(lifeState _x) != "INCAPACITATED"}} count units _grp) < 1) then {
		_groupsCapturing set [_sideIndex,(_groupsCapturing select _sideIndex) - [_grp]];
		_sector set [7,_groupsCapturing];
		Hz_ambw_sc_sectors set [_sectorIndex, _sector];
		publicVariable "Hz_ambw_sc_sectors";
		
		true
	} else {
		false	
	}

};

private _moveToPositionOrGun = {

	params ["_dude", "_pos"];
	
	private _isGun = (typeName _pos) == "OBJECT";
	private _gun = objNull;
	if (_isGun) then {
		_gun = _pos;
		_pos = getpos _gun;
	};
	
	_dude doMove _pos;

	private _timeout = time + 120;
	private _dudeFooked = false;
	
	waitUntil {
		
		sleep 2;
		
		if ((!alive _dude) || {(lifeState _dude) == "INCAPACITATED"}) then {
			_dudeFooked = true;
		};
		
		_dudeFooked || {(_dude distance _pos) < 10} || {time > _timeout}
		
	};
	
	if (!_dudeFooked) then {		
		if (_isGun) then {
			dostop _dude;
			sleep 1;
			[_dude] allowGetIn true;
			[_dude] orderGetIn true;
			_dude assignAsGunner _gun;
			_dude moveInGunner _gun;
		} else {
			_dude setVariable ["Hz_noMove",true];
			dostop _dude;
			_dude forcespeed 0;
			_dude disableAI "PATH";
			_dude setPosATL _pos;
			sleep 2;
			_dude setPosATL _pos;
		};
	};

};

private _sector = Hz_ambw_sc_sectors select _sectorIndex; 
private _sectorPos = _sector select 0;
private _radius = _sector select 1;
private _flag = _sector select 5;
private _objects = _sector select 6;
private _groupsCapturing = _sector select 7;
private _lead = leader _grp;
private _side = side _lead;
private _sideX = sideEmpty;
private _friendlyPlayerFactionsHelpingNeutralise = [];

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

private _useRealisticSectorBuildUp = isClass (configFile >> "cfgPatches" >> "Hz_AI");
private _reinforcementVics = [];
private _numDefenders = Hz_ambw_sc_defenderCountMin max (round random Hz_ambw_sc_defenderCountMax);
private _numGuns = Hz_ambw_sc_staticCountMin max (round random Hz_ambw_sc_staticCountMax);
private _defGroup = grpNull;
private _reinforcementsFooked = false;

if (_useRealisticSectorBuildUp) then {

	private _repeat = true;

	// probably needs checking of enemies trying to capture the sector at the same time
	// or we might end up with an eternal great battle of supply trucks...
	while {_repeat} do {
	
		_repeat = false;

		// create reinforcements and wait for their arrival (or untimely demise...)
		
		private _spawnPos = [_sectorPos, 1800, 2200, _side] call Hz_ambw_fnc_findSpawnPos;
		
		_defGroup = createGroup _side;
		_defGroup deleteGroupWhenEmpty true;
		_defGroup setVariable ["Hz_defending",true];
		
		for "_i" from 1 to (_numDefenders + _numGuns) do {
			private _dude = _defGroup createUnit [(selectRandom (Hz_ambw_sc_defenderTypes select _sideIndex)), _spawnPos, [], 50, "NONE"];				
		};
		
		_reinforcementVics = [_defGroup, _sectorPos, Hz_ambw_sc_transportVehicleTypes select _sideIndex,Hz_ambw_sc_transportVehicleTypes select _sideIndex,100] call Hz_AI_moveAndCapture;
		
		{
			_x setVariable ["Hz_ambw_sc_isReinforcementVehicle", true];
		} foreach _reinforcementVics;

		_reinforcementsFooked = false;
		private _defUnits = [];
		
		waitUntil {

			sleep 15;
			
			_defUnits = (units _defGroup) select {(alive _x) && {(lifeState _x) != "INCAPACITATED"}};

			if ((({alive _x} count _reinforcementVics) == 0) || {(count _defUnits) == 0}) then {
				_reinforcementsFooked = true;
			};		
			
			_reinforcementsFooked || {({((vehicle _x) == _x) && {(_x distance _sectorPos) < 200}} count _defUnits) >= ((count _defUnits)/2)}
			
		};
		
		if (_reinforcementsFooked) then {
			// have a delay before sending new reinforcements and check if capturing group is still alive (don't send otherwise)
			_tEnd = time + 600;
			if (call _sleep) exitWith {};
			_repeat = true;
		} else {
			{
				_x removeEventHandler ["GetOutMan",_x getvariable ["Hz_getOutMan",9999]];
				_x removeEventHandler ["GetInMan",_x getvariable ["Hz_getInMan",9999]];
			} foreach units _defGroup;
		};
			
	};

} else {

	// create defenders and gunners here...
	_defGroup = createGroup _side;
	_defGroup deleteGroupWhenEmpty true;
	_defGroup setVariable ["Hz_defending",true];
	
	for "_i" from 1 to (_numDefenders + _numGuns) do {
		private _dude = _defGroup createUnit [(selectRandom (Hz_ambw_sc_defenderTypes select _sideIndex)), _sectorPos, [], 50, "NONE"];				
	};
	
};

if (_reinforcementsFooked) exitWith {};

// switch capturing group to new defender group and release patrol group	
_groupsCapturing set [_sideIndex,(_groupsCapturing select _sideIndex) - [_grp]];
_grp = _defGroup;
_groupsCapturing set [_sideIndex,(_groupsCapturing select _sideIndex) + [_grp]];
_sector set [7,_groupsCapturing];
Hz_ambw_sc_sectors set [_sectorIndex, _sector];
publicVariable "Hz_ambw_sc_sectors";

//wait until we are stronger than the enemy within the radius and are not being attacked
_tEnd = time + 10;
if (call _sleep) exitWith {};

private _exit = false;

//cleanup any remnants of enemy emplacements (t=0)
private _temp = [];
{
	if (alive _x) then {
		_temp pushBack _x;
	};
} foreach _objects;

// also cleanup any supply trucks from previous sector buildups, but leave ones that are damaged for ambience :)
{
	if ((canMove _x) && {!(_x in _reinforcementVics)} && {_x getVariable ["Hz_ambw_sc_isReinforcementVehicle", false]}) then {
		_temp pushBack _x;
	};
} foreach (_sectorPos nearEntities ["LandVehicle", 300]);

_objects = _temp;

if ((count _objects) > 0) then {
	{
		private _obj = _x;
		
		if (_exit) exitWith {};
		
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
			
			private _weaponHolders = nearestObjects [_obj,["WeaponHolder"],10];
			{								
				deletevehicle _x;							
			} foreach _weaponHolders;		
			
			_objects = _objects - [_obj];			
			deleteVehicle _obj;
			_tEnd = time + 9;
			_exit = call _sleep;
		};
	} foreach _objects;
};
_sector set [6,_objects];
Hz_ambw_sc_sectors set [_sectorIndex, _sector];
publicVariable "Hz_ambw_sc_sectors";

if (_exit) exitWith {};

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
	
	// check for any helping player factions
	private _nearFriendlyPlayers = (_sectorPos nearEntities [["CAManBase", "LandVehicle", "Ship", "StaticWeapon"], _radius*1.2]) select {
		private _unit = effectiveCommander _x;	
		(isPlayer _unit)
		&& {[side _unit, _side] call Hz_ambw_fnc_areFriends}
		&& {!(_unit getVariable ["ACE_isUnconscious",false])}
		&& {(lifeState _unit) != "INCAPACITATED"}
	};
	_nearFriendlyPlayers = _nearFriendlyPlayers apply {effectiveCommander _x};
	{
		private _sideFaction = _x call Hz_ambw_srel_fnc_getUnitSideFaction;
		private _playerFaction = _sideFaction select 1;
		if (_playerFaction != "") then {
			_friendlyPlayerFactionsHelpingNeutralise pushBackUnique _playerFaction;
		};
	} foreach _nearFriendlyPlayers;
	
	_tEnd = time + Hz_ambw_sc_captureTime/4;
	_exit = call _sleep;
	
} else {
	_flagPos = [_sectorPos,10] call Hz_ambw_fnc_findSafePos;
};

if (_exit) exitWith {};

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

// check if helping player factions are still there
private _nearFriendlyPlayers = (_sectorPos nearEntities [["CAManBase", "LandVehicle", "Ship", "StaticWeapon"], _radius]) select {
	private _unit = effectiveCommander _x;	
	(isPlayer _unit)
	&& {[side _unit, _side] call Hz_ambw_fnc_areFriends}
	&& {!(_unit getVariable ["ACE_isUnconscious",false])}
	&& {(lifeState _unit) != "INCAPACITATED"}
};
_nearFriendlyPlayers = _nearFriendlyPlayers apply {effectiveCommander _x};
{
	private _sideFaction = _x call Hz_ambw_srel_fnc_getUnitSideFaction;
	private _playerFaction = _sideFaction select 1;
	if (_playerFaction != "") then {
		if (_playerFaction in _friendlyPlayerFactionsHelpingNeutralise) then {
			(format ["%1 relations with friendly forces have been improved for assisting them in capturing a strategic sector", _playerFaction]) remoteExecCall ["hint",0,false];
			Hz_ambw_srel_relationsOwnSide = (Hz_ambw_srel_relationsOwnSide + Hz_ambw_srel_relationsImprovementForAssistingSectorCapture) min 150;
			publicVariable "Hz_ambw_srel_relationsOwnSide";
			_friendlyPlayerFactionsHelpingNeutralise = _friendlyPlayerFactionsHelpingNeutralise - [_playerFaction];
			sleep 10;
		};
	};
} foreach _nearFriendlyPlayers;


private _availableUnits = [];

//build guns
if (_numGuns > 0) then {

	private _t = (Hz_ambw_sc_captureTime/4)/_numGuns;

	for "_i" from 1 to _numGuns do {
	
		_availableUnits = (units _defGroup) select {(alive _x) && {(lifeState _x) != "INCAPACITATED"} && {!(_x getVariable ["Hz_busy", false])}};
		
		if ((count _availableUnits) < 1) exitWith {};
		
		_tEnd = time + _t;		
		_exit = call _sleep;
		
		private _gunPos = [_sectorPos, 20] call Hz_ambw_fnc_findSafePos;	
		private _gun = (selectRandom (Hz_ambw_sc_staticTypes select _sideIndex)) createVehicle _gunPos;
		_gun setPosATL _gunPos;
		_gun setDir ((_gunPos getDir _flag) + 180);
		_gun setVehicleLock "LOCKED";
		_gun enableWeaponDisassembly false;
		_gun setVariable ["ace_dragging_canDrag", false, true];
		_gun spawn {
			sleep 5;
			{deletevehicle _x} foreach (nearestObjects [_this, ["WeaponHolder"], 10]);
		};
		
		_objects pushBack _gun;
		
		_availableUnits = (units _defGroup) select {(alive _x) && {(lifeState _x) != "INCAPACITATED"} && {!(_x getVariable ["Hz_busy", false])}};
		
		if ((count _availableUnits) > 0) then {
			private _dude = selectRandom _availableUnits;
			_dude setVariable ["Hz_busy", true];
			[_dude, _gun] spawn _moveToPositionOrGun;
		};
				
	};

};

_sector set [6,_objects];
Hz_ambw_sc_sectors set [_sectorIndex, _sector];
publicVariable "Hz_ambw_sc_sectors";

if (_exit) exitWith {};

//build emplacements
private _numEmplacements = Hz_ambw_sc_emplacementCountMin max (round random Hz_ambw_sc_emplacementCountMax);

private _emplacementBuildingPos = [];
private _emplacements = [];

if (_numEmplacements > 0) then {

	private _t = (Hz_ambw_sc_captureTime/4)/_numEmplacements;

	for "_i" from 1 to _numEmplacements do {
		
		_tEnd = time + _t;		
		_exit = call _sleep;
		
		private _empPos = [_sectorPos, 20] call Hz_ambw_fnc_findSafePos;	
		private _emp = (selectRandom (Hz_ambw_sc_fortificationTypes select _sideIndex)) createVehicle _empPos;
		
		_objects pushBack _emp;
		_emplacements pushBack _emp;
		_emp setPosATL _empPos;
		//most emplacements have "reversed" direction...
		_emp setDir (_empPos getDir _flag);	
		
		sleep 1;
		_emplacementBuildingPos = _emplacementBuildingPos + ([_emp] call BIS_fnc_buildingPositions);
		
	};

};

_sector set [6,_objects];

//set up defending infantry

if (_numDefenders > 0) then {

	_emplacements = _emplacements select {(count (_x nearEntities ["CAManBase", 10])) == 0};
	
	while {true} do {
			
		_availableUnits = (units _defGroup) select {(alive _x) && {(lifeState _x) != "INCAPACITATED"} && {!(_x getVariable ["Hz_busy", false])}};
		
		if ((count _availableUnits) < 1) exitWith {};
				
		private _dude = selectRandom _availableUnits;
		_dude setVariable ["Hz_busy", true];
		
		if ((count _emplacementBuildingPos) > 0) then {
			private _pos = selectRandom _emplacementBuildingPos;
			_emplacementBuildingPos = _emplacementBuildingPos - [_pos];
			[_dude, _pos] spawn _moveToPositionOrGun;
		} else {
			if ((count _emplacements) > 0) then {
				private _emp = selectRandom _emplacements;
				_emplacements = _emplacements - [_emp];
				private _empPos = getpos _emp;
				private _bbox = boundingBoxReal _emp;
				private _delta = (((_bbox select 0) distance2D (_bbox select 1))/2) + 0.3;
				private _pos = [_empPos, _delta, [_empPos, _flag] call BIS_fnc_dirTo] call BIS_fnc_relPos;
				_pos set [2, 0];
				[_dude, _pos] spawn _moveToPositionOrGun;
			};
		};			
	};

};


// remove defender group from capture list
_groupsCapturing set [_sideIndex,(_groupsCapturing select _sideIndex) - [_grp]];
_sector set [7,_groupsCapturing];
Hz_ambw_sc_sectors set [_sectorIndex, _sector];
publicVariable "Hz_ambw_sc_sectors";
