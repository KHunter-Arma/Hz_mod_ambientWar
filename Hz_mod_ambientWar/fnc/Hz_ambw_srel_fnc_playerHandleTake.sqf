/*******************************************************************************
* Copyright (C) 2018 K.Hunter
*
* This file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/
private ["_containerType", "_player", "_container", "_item", "_playerSideFaction","_playerSide", "_playerFaction", "_unit", "_isWeapon", "_temp", "_nearBodies", "_weapons", "_attachments", "_unitSideFaction", "_unitSide", "_unitFaction", "_unitImportance"];

_player = _this select 0;
_container = _this select 1;
_item = toLower (_this select 2);

if (_item in ["ace_tourniquet","ace_fielddressing","ace_packingbandage","ace_quikclot","ace_elasticbandage","ace_morphine","ace_epinephrine","ace_salineiv_250","ace_salineiv_500","ace_salineiv"]) exitWith {};

_playerSideFaction = _player call Hz_ambw_srel_fnc_getUnitSideFaction;
_playerSide = _playerSideFaction select 0;
_playerFaction = _playerSideFaction select 1;

if (_playerFaction == "") exitWith {};

_unit = objNull;
_isWeapon = false;

if (_container isKindOf "CAManBase") then {

	_unit = _container;

} else {

	if (_container isKindOf "WeaponHolderSimulated") then {
	
		_isWeapon = true;
			
		_temp = nearestObjects [_container, ["CAManBase"],3];
		_nearBodies = [];
		
		{
		
			if (!alive _x) then {
			
				_nearBodies pushBack _x;
			
			};
		
		} foreach _temp;
		
		{
		
			_temp = getArray (configFile >> "cfgVehicles" >> (typeof _x) >> "weapons");
			_weapons = [];
			_attachments = [];
			
			{
			
				_weapons pushBack (toLower _x);
				_attachments = _attachments + (_x call BIS_fnc_weaponComponents);
			
			} foreach _temp;
			
			if (_item in _weapons) then {
			
				_unit = _x;
			
			} else {
			
				if (_item in _attachments) then {
				
					_unit = _x;
				
				};
			
			};
			
			if (!isNull _unit) exitWith {};
		
		} foreach _nearBodies;
	
	} else {
	
		_containerType = toLower (typeof _container);
		
		//strange notation but uniform and vest on dead soldier apparently has Supply40 and Supply120 as type...
		
		if ((_containerType == "supply40") || (_containerType == "supply120")) then {
		
			_temp = nearestObjects [_container, ["CAManBase"],0.5];
			_nearBodies = [];
		
			{
			
				if (!alive _x) then {
				
					_nearBodies pushBack _x;
				
				};
			
			} foreach _temp;
			
			if ((count _nearBodies) > 0) then {
			
				_unit = _nearBodies select 0;
			
			};
			
		} else {
		
			if (_container isKindOf "Bag_base") then {
			
				_temp = nearestObjects [_container, ["CAManBase"],0.5];
				_nearBodies = [];
			
				{
				
					if (!alive _x) then {
					
						_nearBodies pushBack _x;
					
					};
				
				} foreach _temp;
				
				if ((count _nearBodies) > 0) then {
				
					_unit = _nearBodies select 0;
				
				};
			
			};
		
		};
	
	};

};

if (isNull _unit) exitWith {};

if (_unit getVariable ["Hz_ambw_disableSideRelations",false]) exitWith {};

_unitSideFaction = _unit call Hz_ambw_srel_fnc_getUnitSideFaction;
_unitSide = _unitSideFaction select 0;
_unitFaction = _unitSideFaction select 1;
_unitImportance = _unitSideFaction select 2;

if (_unitFaction == "") exitWith {};

//nothing of value here...
if (_unitSide == civilian) exitWith {};

if (_unitFaction == _playerFaction) exitWith {};

if ([_unitSide,_playerSide] call Hz_ambw_fnc_areEnemies) exitWith {};

if (_isWeapon) then {

	hint "Stealing weapons from friendlies will affect relations.";
	
	Hz_ambw_srel_relationsOwnSide = Hz_ambw_srel_relationsOwnSide - (Hz_ambw_srel_relationsPenaltyPerStolenWeapon*_unitImportance);

} else {

	hint "Stealing gear from friendlies will affect relations.";
	
	Hz_ambw_srel_relationsOwnSide = Hz_ambw_srel_relationsOwnSide - (Hz_ambw_srel_relationsPenaltyPerStolenItem*_unitImportance);

};

if (Hz_ambw_srel_relationsOwnSide < 1) then {

	Hz_ambw_srel_relationsOwnSide = 1;

};

publicVariable "Hz_ambw_srel_relationsOwnSide";