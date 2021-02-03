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

if (!isServer) exitWith {};

params ["_unit", "_respawnPosition", "_patrolMarker"];

private _side = side _unit; 
private _group = group _unit;
_group setvariable ["Hz_Patrolling",true];

private _infantryTypes = [];
{
	if((vehicle _x) == _x) then {
		_infantryTypes pushback (typeof _x);
	};
}foreach units _group;

private _unitType = typeof _unit;
private _isInfantryGroup = _unitType isKindOf "CAManBase";
private _crewAndPassengerTypes  = [];
if (!_isInfantryGroup) then {
	{	
		_crewAndPassengerTypes set [count _crewAndPassengerTypes, typeOf _x];	
	}forEach (crew _unit);
};

_group deleteGroupWhenEmpty true;

{
	private _veh = vehicle _x;
	if (_veh == _x) then {							
		deletevehicle _x;							
	} else {							
		_veh deleteVehicleCrew _x;							
	};
} foreach units _unit;
deleteVehicle _unit;
deleteGroup _group;

if (isnil "Hz_ambw_pat_patrolsArray") then {
	Hz_ambw_pat_patrolsArray = [];
};
Hz_ambw_pat_patrolsArray pushBack [_unitType, _respawnPosition, _patrolMarker, _side, _crewAndPassengerTypes,_infantryTypes];
