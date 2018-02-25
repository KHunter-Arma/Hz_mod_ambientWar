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

_moduleLogic = _this select 0;

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

Hz_ambw_maxNumberOfCivs = call compile (_moduleLogic getVariable "MaxCivCount");

Hz_ambw_hostileCivRatioStarting = call compile (_moduleLogic getVariable "HostileCivRatio");
Hz_ambw_hostileCivRatio = Hz_ambw_hostileCivRatioStarting;

Hz_ambw_armedCivilianSide = call compile (_moduleLogic getVariable "ArmedCivilianSide");
Hz_ambw_armedCivilianTargetSide = call compile (_moduleLogic getVariable "ArmedCivilianTargetSide");

Hz_ambw_allCivTypes = call compile (_moduleLogic getVariable "CivTypes");

Hz_ambw_hostileCivTypes = call compile (_moduleLogic getVariable "HostileCivTypes");

// If enabled, multiple triggers won't be able to spawn civilians at exactly the same time. Could be useful if your triggers are all meshed up into each other and you drive fast...
Hz_ambw_civ_forceGlobalMutex = false;

//Offload processing of civilian AI to clients. This doesn't include hosile civs, since they refuse to attack enemies when they switch owner to client for some reason (Arma 2).
Hz_ambw_enableClientProcessing = false;

//increase multiplier to increase number of civs per area
Hz_ambw_spawnCivilianCountMultiplier = call compile (_moduleLogic getVariable "CivilianMultiplier");

Hz_ambw_civ_suicideBomberProbability = call compile (_moduleLogic getVariable "SuicideBomberProbability");

Hz_ambw_civ_loadouts = call compile (_moduleLogic getVariable "CivilianLoadouts");

// ==========================================================================
// ==========================================================================

Hz_ambw_civ_initDone = true;
if (Hz_ambw_civ_debug) then {[-1, {hint"Hunter'z Civilian Module initialised!";}] call CBA_fnc_globalExecute;};