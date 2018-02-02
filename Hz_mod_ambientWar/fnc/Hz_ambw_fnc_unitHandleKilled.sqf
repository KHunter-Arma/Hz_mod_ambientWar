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
#define DEBUGFNC(X) diag_log "Hunter'z Ambient War Error: Faction not found";\
diag_log format ["[%1,%2]",if (isplayer X) then {name X} else {"AI"}, typeof X];

private _unit = _this select 0;
private _killer = _this select 1;

if (isPlayer _unit) exitWith {};

// for now this isn't handled -- maybe in future handling death from bleeding from ACE medical after being hit can be implemented...
if (isnull _killer) exitWith {};

private _killedByPlayer = false;
      
if (isplayer _killer) then {

	_killedByPlayer = true;

} else {
	
	//hit and run detection
	if (_unit == _killer) then {
		
		//unit might be sent away so keep radius large
		private _nearCars = nearestobjects [_unit,["LandVehicle"],30];
		
		{
			
			if (((speed _x) > 10) && (isplayer (driver _x))) exitWith {_killedByPlayer = true;};
			
		} foreach _nearCars;
		
	};
	
};

if (!_killedByPlayer) exitWith {};

// determine factions

private _playerSideFaction = _killer getvariable "Hz_ambw_sideFaction";

private _playerFaction = "";
private _playerSide = sideEmpty;

if (!isnil "_playerSideFaction") then {

 _playerSide = _playerSideFaction select 0;
 _playerFaction = _playerSideFaction select 1;

} else {

	private _configFaction = toupper (faction _killer);

	{
		
		private _factionClasses = _x select 3;

		if (_configFaction in _factionClasses) then {

			_playerFaction = _x select 0;
		
		} else {
		
			{
			
				if (_killer iskindof _x) exitWith {
				
					_playerFaction = _x select 0;
				
				};
			
			} foreach _factionClasses;		
		
		};
		
		if (_playerFaction != "") exitWith {
		
			_playerSide = _x select 1;			
		
		};

	} foreach Hz_ambw_srel_playerfactions;

};

if (_playerFaction == "") exitWith {
		
		DEBUGFNC(_killer);
		
};

private _unitSideFaction = _unit getvariable "Hz_ambw_sideFaction";

private _unitFaction = "";
private _unitSide = sideEmpty;
private _unitImportance = 0;

if (!isnil "_unitSideFaction") then {

 _unitSide = _unitSideFaction select 0;
 _unitFaction = _unitSideFaction select 1;

} else {

	private _configFaction = toupper (faction _unit);

	{
		
		private _factionClasses = _x select 3;

		if (_configFaction in _factionClasses) then {

			_unitFaction = _x select 0;
		
		} else {
		
			{
			
				if (_unit iskindof _x) exitWith {
				
					_unitFaction = _x select 0;
				
				};
			
			} foreach _factionClasses;		
		
		};
		
		if (_unitFaction != "") exitWith {
		
			_unitSide = _x select 1;
			_unitImportance = _x select 2;
		
		};

	} foreach Hz_ambw_srel_playerfactions;

};

if (_unitFaction == "") exitWith {
		
		DEBUGFNC(_unit);
		
};

if ([_unitSide,_playerSide] call Hz_ambw_fnc_areEnemies) exitWith {};

// global event