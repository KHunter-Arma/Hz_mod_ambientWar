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

params ["_pos", "_objDistance"];
	
private _maxDist = 1;
private _ret = [0,0,0];

//this function doesn't seem to account for some stuff so we need to handle those manually and add their positions into the blacklist...
private _objDistanceSqrt = _objDistance/1.41;
private _blackList = [];
private _objPos = [];
{
	_objPos = getPos _x;
	_blackList pushBack [[(_objPos select 0) - _objDistanceSqrt, (_objPos select 1) + _objDistanceSqrt, _objPos select 2],[(_objPos select 0) + _objDistanceSqrt, (_objPos select 1) - _objDistanceSqrt, _objPos select 2]];
} foreach (nearestObjects [_pos,["Static","StaticWeapon"],1000]);

//do the same for "Thing" class but filter by volume first so it ignores tiny things
{
	_bb = boundingBoxReal _x;
	_p1 = _bb select 0;
	_p2 = _bb select 1;
	_maxWidth = abs ((_p2 select 0) - (_p1 select 0));
	_maxLength = abs ((_p2 select 1) - (_p1 select 1));
	_maxHeight = abs ((_p2 select 2) - (_p1 select 2));	
	if ((_maxHeight*_maxWidth*_maxLength) > 0.25) then {	
		_objPos = getPos _x;
		_blackList pushBack [[(_objPos select 0) - _objDistanceSqrt, (_objPos select 1) + _objDistanceSqrt, _objPos select 2],[(_objPos select 0) + _objDistanceSqrt, (_objPos select 1) - _objDistanceSqrt, _objPos select 2]];
	};
} foreach (nearestObjects [_pos,["Thing"],1000]);

//also blacklist road segments so we don't obstruct patrols
_objDistanceSqrt = 15;
{
	_objPos = getPos _x;
	_blackList pushBack [[(_objPos select 0) - _objDistanceSqrt, (_objPos select 1) + _objDistanceSqrt, _objPos select 2],[(_objPos select 0) + _objDistanceSqrt, (_objPos select 1) - _objDistanceSqrt, _objPos select 2]];
} foreach (_pos nearRoads 1000);

//not good to leave this without a safeguard... but eventually should(TM) return something right? :D
while {(count _ret) == 3} do {
	
	_ret = [_pos, 0, _maxDist, _objDistance, 0, 1, 0,_blackList,[[0,0,0]]] call BIS_fnc_findSafePos;
	_maxDist = _maxDist + 5;
	
};

_ret pushBack 0;			
_ret
