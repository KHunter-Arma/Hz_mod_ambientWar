#define PATH ""

//compile functions and init global vars
Hz_ambw_civ_fnc_spawnCivs = compile preprocessFileLineNumbers (PATH+"fnc\Hz_ambw_civ_fnc_spawnCivs.sqf");
Hz_ambw_civ_fnc_despawnCivs = compile preprocessFileLineNumbers (PATH+"fnc\Hz_ambw_civ_fnc_despawnCivs.sqf");
Hz_ambw_civGlobalMutexUnlocked = true;
Hz_ambw_currentNumberOfCiviliansSpawned = 0;
civ_killed_count = 0;

// ==========================================================================
//                                PARAMETERS
// ==========================================================================

Hz_ambw_maxNumberOfCivs = 60;
Hz_ambw_hostileCivRatio = 0.1;

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

// ==========================================================================
// ==========================================================================


Hz_ambw_civ_initDone = true;
if (Hz_ambw_civ_debug) then {[-1, {hint"Hunter'z Civilian Module initialised!";}] call CBA_fnc_globalExecute;};