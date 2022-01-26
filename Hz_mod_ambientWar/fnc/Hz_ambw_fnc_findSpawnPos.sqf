/*******************************************************************************
* Copyright (C) 2022 K.Hunter
*
* This file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/
#define MIN_1D_DISTANCE_FROM_PLAYER 1400
#define MIN_DISTANCE_FROM_OBJECTS 10

private ["_targetpos", "_minDistance", "_maxDistance", "_side", "_sidesToAvoid", "_maxDistanceStart", "_blacklistpos", "_unitarray", "_playerPositions", "_player", "_marker1", "_marker2", "_results", "_spawnpos", "_tries", "_safetyFactors", "_nearEntities", "_minEnemies", "_minTotal", "_returnIndex"];

_targetpos = _this select 0;
_minDistance = _this select 1;

_maxDistance = _minDistance + 500;

_maxDistance = _this select 2;
_side = _this select 3;

private _addBlacklistPos = {
		
	_marker1 = [(_this select 0)-MIN_1D_DISTANCE_FROM_PLAYER,(_this select 1)+MIN_1D_DISTANCE_FROM_PLAYER];
	_marker2 = [(_this select 0)+MIN_1D_DISTANCE_FROM_PLAYER,(_this select 1)-MIN_1D_DISTANCE_FROM_PLAYER];
	_blacklistpos pushBack [_marker1,_marker2];

};

//figure out sides to avoid (assuming everyone's friendly with civilian side...)
_sidesToAvoid = [];
{
	if ([_side, _x] call Hz_ambw_fnc_areEnemies) then {
		_sidesToAvoid pushBack _x;
	};
} foreach [east, west, resistance];

_blacklistpos = [];


// avoid spawning them near respawn areas of enemy or neutral factions
if (east in _sidesToAvoid) then {
	if (!((markerpos "respawn_east") isEqualTo [0,0,0])) then {
		(markerpos "respawn_east") call _addBlacklistPos;
	};
	if (!((markerpos "respawn_vehicle_east") isEqualTo [0,0,0])) then {
		(markerpos "respawn_vehicle_east") call _addBlacklistPos;
	};
};

if (west in _sidesToAvoid) then {
	if (!((markerpos "respawn_west") isEqualTo [0,0,0])) then {
		(markerpos "respawn_west") call _addBlacklistPos;
	};
	if (!((markerpos "respawn_vehicle_west") isEqualTo [0,0,0])) then {
		(markerpos "respawn_vehicle_west") call _addBlacklistPos;
	};
};

if (resistance in _sidesToAvoid) then {
	if (!((markerpos "respawn_guerrila") isEqualTo [0,0,0])) then {
		(markerpos "respawn_guerrila") call _addBlacklistPos;
	};
	if (!((markerpos "respawn_vehicle_guerrila") isEqualTo [0,0,0])) then {
		(markerpos "respawn_vehicle_guerrila") call _addBlacklistPos;
	};
};

if (!((markerpos "respawn") isEqualTo [0,0,0])) then {
	(markerpos "respawn") call _addBlacklistPos;
};

if (!((markerpos "respawn_civilian") isEqualTo [0,0,0])) then {
	(markerpos "respawn_civilian") call _addBlacklistPos;
};
if (!((markerpos "respawn_vehicle_civilian") isEqualTo [0,0,0])) then {
	(markerpos "respawn_vehicle_civilian") call _addBlacklistPos;
};

_maxDistanceStart = _maxDistance;

_unitarray = [];
_playerPositions = [];

//needs refactoring and optimisation on condition check order
{  	
	_player = _x;

		//add player object to blacklist only if he's more than 2km away from respawn position and make sure players close to each other are considered only as one position
	 if (({(_player distance _x) < 1000} count _playerPositions) == 0) then {
		 _unitarray set [count _unitarray, _x];     
	 }; 
							 
	 _playerPositions pushBack (getpos _x);  
						
}foreach playableunits;

{
	if(((_x distance _targetpos) > 1000) && {(speed (vehicle _x)) < 20}) then {			
		(getpos _x) call _addBlacklistPos;		
	};
}foreach _unitarray;


//try collecting different options
_results = [];

for "_i" from 1 to 50 do {

	_spawnpos = [0,0,0];
	_tries = 0;
	_maxDistance = _maxDistanceStart;

	while {(format ["%1",_spawnpos]) == "[0,0,0]"} do {
						
		_spawnpos = [_targetpos, _minDistance, _maxDistance, MIN_DISTANCE_FROM_OBJECTS, 0, 1, 0,_blacklistpos,[[0,0,0]]] call BIS_fnc_findSafePos;

		_tries = _tries + 1;
		_maxDistance = _maxDistance + 500;
		if(_tries > 100) exitwith {};

	};

	_results pushBack [_spawnpos select 0, _spawnpos select 1, 0];

};

//choose safest position that is also the most empty
_safetyFactors = [];
{
	_nearEntities = _x nearEntities [["CAManBase","Ship","LandVehicle","Helicopter","StaticWeapon"], _maxDistanceStart];
	_safetyFactors pushBack [{(side _x) in _sidesToAvoid} count _nearEntities, {(side _x) != civilian} count _nearEntities]; 
} foreach _results;

_minEnemies = 999;
_minTotal = 999;
_returnIndex = 0;
{
	if (((_x select 0) < _minEnemies) && {(_x select 1) < _minTotal}) then {
		_minEnemies = _x select 0;
		_minTotal = _x select 1;
		_returnIndex = _foreachIndex;
	};
} foreach _safetyFactors;

//output
_results select _returnIndex
