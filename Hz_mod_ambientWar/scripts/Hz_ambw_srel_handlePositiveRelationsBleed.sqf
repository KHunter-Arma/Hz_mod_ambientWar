/*******************************************************************************
* Copyright (C) 2024 K.Hunter
*
* This file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

scriptName "Hz_ambw_srel_handlePositiveRelationsBleed";

if ((Hz_ambw_srel_positiveRelationsCivilianBleedAmount <= 0)
		&& {Hz_ambw_srel_positiveRelationsOwnSideBleedAmount <= 0}) exitWith {};

if (Hz_ambw_enablePersistency) then {

	waitUntil {
		sleep 5;
		(!isnil "Hz_pers_serverInitialised") && {Hz_pers_serverInitialised}
	};

};

if (Hz_ambw_srel_positiveRelationsBleedOnlyWhenServerPopulated) then {
	
	// check whether joining player is "genuine"
	private _checkPassed = false;
	private _checkedPlayerUID = "";
	
	while {!_checkPassed} do {
		sleep 60;
		if (_checkedPlayerUID in (playableUnits apply {getPlayerUID _x})) then {
			_checkPassed = true;
		} else {
			waitUntil {
				sleep 10;
				(count playableUnits) > 0
			};
			_checkedPlayerUID = getPlayerUID (playableUnits select 0);
		};
	};
	
};

if ((Hz_ambw_srel_positiveRelationsCivilianBleedAmount > 0) && {Hz_ambw_srel_relationsCivilian > 100}) then {
	Hz_ambw_srel_relationsCivilian = (Hz_ambw_srel_relationsCivilian - Hz_ambw_srel_positiveRelationsCivilianBleedAmount) max 100;
	publicVariable "Hz_ambw_srel_relationsCivilian";
};
if ((Hz_ambw_srel_positiveRelationsOwnSideBleedAmount > 0) && {Hz_ambw_srel_relationsOwnSide > 100}) then {
	Hz_ambw_srel_relationsOwnSide = (Hz_ambw_srel_relationsOwnSide - Hz_ambw_srel_positiveRelationsOwnSideBleedAmount) max 100;
	publicVariable "Hz_ambw_srel_relationsOwnSide";
};
