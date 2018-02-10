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

Hz_ambw_srel_fnc_broadcastUnitKilled = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_srel_fnc_broadcastUnitKilled.sqf");

if (isServer) then {

	Hz_ambw_fnc_unitHandleKilled = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_fnc_unitHandleKilled.sqf");
	Hz_ambw_fnc_areEnemies = compile preprocessFileLineNumbers (Hz_ambw_functionsPath + "Hz_ambw_fnc_areEnemies.sqf");

	Hz_ambw_srel_playerfactions = [

		["B.A.D. PMC",west,["C_MAN_POLO_1_F"]],
		["US Forces",west,["RHS_FACTION_SOCOM","RHS_FACTION_USAF","RHS_FACTION_USARMY","RHS_FACTION_USARMY_D","RHS_FACTION_USARMY_WD","RHS_FACTION_USMC","RHS_FACTION_USMC_D","RHS_FACTION_USMC_WD","RHS_FACTION_USN"]]

	];

	Hz_ambw_srel_AIfactions = [

		["Iraqi Army",west,1,["LOP_IA"]],
		["US Forces",west,10,["USAF","USAF_AFSOC","USAF_SFS_PILOTS","RHS_FACTION_SOCOM","RHS_FACTION_USAF","RHS_FACTION_USARMY","RHS_FACTION_USARMY_D","RHS_FACTION_USARMY_WD","RHS_FACTION_USMC","RHS_FACTION_USMC_D","RHS_FACTION_USMC_WD","RHS_FACTION_USN"]],
		["Friendly Insurgents",west,0.3,[]],
		["Enemy Insurgents",east,0,["CUP_O_TK_MILITIA","CUP_I_TK_GUE"]],
		["Takistani Army",east,0,["LOP_TKA","CUP_O_TK"]],
		["B.A.D. PMC",west,5,["CUP_I_PMC_ION","C_MAN_HUNTER_1_F"]],
		["Civilians",civilian,1,["LOP_TAK_CIV","CUP_C_TK","CIV_F","CIV_IDAP_F"]]

	];

	Hz_ambw_srel_relationsPenaltyPerKill = 5;

	//this is the default (mid-point)
	Hz_ambw_srel_relationsOwnSideStarting = 100;
	Hz_ambw_srel_relationsCivilianStarting = 100;

	Hz_ambw_srel_relationsOwnSide = Hz_ambw_srel_relationsOwnSideStarting;
	Hz_ambw_srel_relationsCivilian = Hz_ambw_srel_relationsCivilianStarting;
	publicVariable "Hz_ambw_srel_relationsOwnSide";
	publicVariable "Hz_ambw_srel_relationsCivilian";

	Hz_ambw_srel_enableHzEcon = true;
	publicVariable "Hz_ambw_srel_enableHzEcon";

	Hz_ambw_srel_fundsPenaltyPerKill = 10000;
	publicVariable "Hz_ambw_srel_fundsPenaltyPerKill";

};
