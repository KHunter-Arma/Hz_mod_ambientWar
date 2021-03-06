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

private _unit = _this select 0;
private _unitImportance = _this select 1;
private _unitSide = _this select 2;
private _unitFaction = _this select 3;
private _playerSide = _this select 4;
private _playerFaction = _this select 5;

if (isServer) then {

	//subtract points
	if (_unitSide == civilian) then {
	
		Hz_ambw_srel_relationsCivilian = Hz_ambw_srel_relationsCivilian - (Hz_ambw_srel_relationsPenaltyPerKill*_unitImportance);
		
		if (Hz_ambw_srel_relationsCivilian < 1) then {
		
			Hz_ambw_srel_relationsCivilian = 1;
		
		};
		
		publicVariable "Hz_ambw_srel_relationsCivilian";
		
		Hz_ambw_hostileCivRatio = Hz_ambw_hostileCivRatioStarting*(Hz_ambw_srel_relationsCivilianStarting/Hz_ambw_srel_relationsCivilian);
	
	} else {
	
		Hz_ambw_srel_relationsOwnSide = Hz_ambw_srel_relationsOwnSide - (Hz_ambw_srel_relationsPenaltyPerKill*_unitImportance);
		
		if (Hz_ambw_srel_relationsOwnSide < 1) then {
		
			Hz_ambw_srel_relationsOwnSide = 1;
		
		};
		
		publicVariable "Hz_ambw_srel_relationsOwnSide";
		
	};
	
	if (Hz_ambw_srel_enableHzEcon) then {
	
		Hz_econ_funds = Hz_econ_funds - (Hz_ambw_srel_fundsPenaltyPerKill*_unitImportance);
		publicVariable "Hz_econ_funds";
	
	};
	
};

if (hasInterface) then {

	private _text = "";
	
	//show message
	if (_unitSide == civilian) then {
	
		_text = format ["%1 have killed a civilian. This will affect relations.", _playerFaction];
	
	} else {
	
		_text = format ["%1 have killed %2 personnel. This will affect relations.", _playerFaction, _unitFaction];
		
	};

	if (Hz_ambw_srel_enableHzEcon) then {
	
		_text = _text + format [" Compensation worth $%1 was given to victim's family.", Hz_ambw_srel_fundsPenaltyPerKill*_unitImportance];
	
	};
	
	hint _text;
	
};