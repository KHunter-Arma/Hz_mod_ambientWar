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

if (!isServer) exitWith {};

//compile functions and init global vars
Hz_ambw_civ_fnc_spawnCivs = compile preprocessFileLineNumbers (Hz_ambw_functionsPath+"Hz_ambw_civ_fnc_spawnCivs.sqf");
Hz_ambw_civ_fnc_despawnCivs = compile preprocessFileLineNumbers (Hz_ambw_functionsPath+"Hz_ambw_civ_fnc_despawnCivs.sqf");
Hz_ambw_civ_suicideBomber = compile preprocessFileLineNumbers (Hz_ambw_path+"scripts\Hz_ambw_civ_suicideBomber.sqf");
Hz_ambw_civ_sinisterCiv = compile preprocessFileLineNumbers (Hz_ambw_path+"scripts\Hz_ambw_civ_sinisterCiv.sqf");
Hz_ambw_civGlobalMutexUnlocked = true;
Hz_ambw_currentNumberOfCiviliansSpawned = 0;
Hz_ambw_civ_debug = false;

// ==========================================================================
//                                PARAMETERS
// ==========================================================================

Hz_ambw_maxNumberOfCivs = 60;

Hz_ambw_hostileCivRatioStarting = 0.1;
Hz_ambw_hostileCivRatio = Hz_ambw_hostileCivRatioStarting;

Hz_ambw_armedCivilianSide = east;
Hz_ambw_armedCivilianTargetSide = west;

Hz_ambw_allCivTypes = ["C_journalist_F","C_Journalist_01_War_F","C_man_p_beggar_F","LOP_Tak_Civ_Random","LOP_Tak_Civ_Random","LOP_Tak_Civ_Random","LOP_Tak_Civ_Random","C_man_p_beggar_F","LOP_Tak_Civ_Random","LOP_Tak_Civ_Random","LOP_Tak_Civ_Random","LOP_Tak_Civ_Random"];

Hz_ambw_hostileCivTypes = ["C_man_p_beggar_F","LOP_Tak_Civ_Random","LOP_Tak_Civ_Random","LOP_Tak_Civ_Random","LOP_Tak_Civ_Random"];

// If enabled, multiple triggers won't be able to spawn civilians at exactly the same time. Could be useful if your triggers are all meshed up into each other and you drive fast...
Hz_ambw_civ_forceGlobalMutex = false;

//Offload processing of civilian AI to clients. This doesn't include hosile civs, since they refuse to attack enemies when they switch owner to client for some reason (Arma 2).
Hz_ambw_enableClientProcessing = false;

//increase multiplier to increase number of civs per area
Hz_ambw_spawnCivilianCountMultiplier = 0.75;

Hz_ambw_civ_suicideBomberProbability = 0.05;

Hz_ambw_civ_loadouts = [

[0.45, "CUP_hgun_Makarov", "CUP_8Rnd_9x18_Makarov_M", 8],
[1, "CUP_hgun_TaurusTracker455", "CUP_6Rnd_45ACP_M", 8]

];

// ==========================================================================
// ==========================================================================

Hz_ambw_civ_initDone = true;
if (Hz_ambw_civ_debug) then {[-1, {hint"Hunter'z Civilian Module initialised!";}] call CBA_fnc_globalExecute;};