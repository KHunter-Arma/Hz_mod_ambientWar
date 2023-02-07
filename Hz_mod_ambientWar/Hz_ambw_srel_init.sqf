/*******************************************************************************
* Copyright (C) 2018-2023 K.Hunter
*
* This file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

_moduleLogic = _this select 0;

Hz_ambw_srel_fnc_broadcastUnitKilled = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_srel_fnc_broadcastUnitKilled.sqf");
Hz_ambw_srel_fnc_getUnitSideFaction = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_srel_fnc_getUnitSideFaction.sqf");
Hz_ambw_srel_factions = call compile (_moduleLogic getVariable "Factions");
Hz_ambw_fnc_unitHandleKilled = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_fnc_unitHandleKilled.sqf");
Hz_ambw_srel_relationsPenaltyPerKill = call compile (_moduleLogic getVariable "PenaltyPerKill");
Hz_ambw_srel_relationsImprovementForAssistingSectorCapture = Hz_ambw_srel_relationsPenaltyPerKill/2;

if (isServer) then {
		
	Hz_ambw_srel_relationsPenaltyPerStolenItem = call compile (_moduleLogic getVariable "PenaltyPerStolenItem");
	Hz_ambw_srel_relationsPenaltyPerStolenWeapon = call compile (_moduleLogic getVariable "PenaltyPerStolenWeapon");
	publicVariable "Hz_ambw_srel_relationsPenaltyPerStolenItem";
	publicVariable "Hz_ambw_srel_relationsPenaltyPerStolenWeapon";

	//this is the default (mid-point)
	Hz_ambw_srel_relationsOwnSideStarting = call compile (_moduleLogic getVariable "RelationsOwnSide");
	Hz_ambw_srel_relationsCivilianStarting = call compile (_moduleLogic getVariable "RelationsCivilian");
	publicVariable "Hz_ambw_srel_relationsOwnSideStarting";
	publicVariable "Hz_ambw_srel_relationsCivilianStarting";

	//currently designed to be capped between 1 and 150 (representing 1-150%, 0 not allowed)
	Hz_ambw_srel_relationsOwnSide = Hz_ambw_srel_relationsOwnSideStarting;
	Hz_ambw_srel_relationsCivilian = Hz_ambw_srel_relationsCivilianStarting;
	publicVariable "Hz_ambw_srel_relationsOwnSide";
	publicVariable "Hz_ambw_srel_relationsCivilian";

	Hz_ambw_srel_enableHzEcon = _moduleLogic getVariable "EnableHzEcon";
	publicVariable "Hz_ambw_srel_enableHzEcon";

	Hz_ambw_srel_fundsPenaltyPerKill = call compile (_moduleLogic getVariable "FundsPenaltyPerKill");
	publicVariable "Hz_ambw_srel_fundsPenaltyPerKill";

};

if (!isDedicated && hasInterface) then {

	Hz_ambw_srel_fnc_playerHandleTake = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_srel_fnc_playerHandleTake.sqf");

	waitUntil {sleep 2; !isNull player};
	
	player addEventHandler ["Take",Hz_ambw_srel_fnc_playerHandleTake];

};
