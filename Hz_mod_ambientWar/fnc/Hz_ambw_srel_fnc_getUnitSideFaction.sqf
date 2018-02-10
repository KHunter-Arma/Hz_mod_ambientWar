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

private ["_unit", "_sideFaction", "_unitFaction", "_unitSide", "_unitImportance", "_configFaction", "_element", "_factionClasses"];

_unit = _this;

_sideFaction = _unit getvariable "Hz_ambw_sideFaction";

_unitFaction = "";
_unitSide = sideEmpty;
_unitImportance = 0;

if (!isnil "_sideFaction") then {

	_unitSide = _sideFaction select 0;
	_unitFaction = _sideFaction select 1;

} else {

	_configFaction = toupper (faction _unit);
	_element = [];

	{
		_element = _x;
		
		_factionClasses = _x select 3;

		if (_configFaction in _factionClasses) then {

			_unitFaction = _x select 0;
			
		} else {
			
			{
				
				if (_unit iskindof _x) exitWith {
					
					_unitFaction = _element select 0;
					
				};
				
			} foreach _factionClasses;		
			
		};
		
		if (_unitFaction != "") exitWith {
			
			_unitSide = _x select 1;		
			_unitImportance = _x select 2;			
			
		};

	} foreach Hz_ambw_srel_factions;

};

if (_unitFaction == "") then {
	
	DEBUGFNC(_unit);
	
};

[_unitSide,_unitFaction,_unitImportance]