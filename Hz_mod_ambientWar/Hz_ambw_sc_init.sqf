/*******************************************************************************
* Copyright (C) 2020 K.Hunter
*
* This file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

Hz_ambw_sc_buildSector = compile preprocessFileLineNumbers (Hz_ambw_scriptsPath+"Hz_ambw_sc_buildSector.sqf");
Hz_ambw_sc_fnc_loadSectorsFromSave = compile preprocessFileLineNumbers (Hz_ambw_functionsPath+"Hz_ambw_sc_fnc_loadSectorsFromSave.sqf");

//TODO: module parameters
Hz_ambw_sc_editorMarkers = ["sector_1","sector_2","sector_3","sector_4","sector_5","sector_6"];
Hz_ambw_sc_defenderCountMin = 6;
Hz_ambw_sc_defenderCountMax = 12;
Hz_ambw_sc_staticCountMin = 1;
Hz_ambw_sc_staticCountMax = 3;
Hz_ambw_sc_emplacementCountMin = 10;
Hz_ambw_sc_emplacementCountMax = 20;
//[[OPFOR],[BLUFOR],[GRNFOR]]
Hz_ambw_sc_defenderTypes = [
["CUP_O_TK_Soldier"],
["LOP_IA_Infantry_Rifleman_4"],
[]];
Hz_ambw_sc_staticTypes = [
["rhsgref_ins_DSHKM","rhsgref_ins_DSHKM","rhsgref_ins_DSHKM","rhsgref_ins_ZU23","rhsgref_ins_SPG9"],
["LOP_IA_Static_M2","LOP_IA_Static_M2","LOP_IA_Static_DSHKM","LOP_IA_Static_SPG9"],
[]];
Hz_ambw_sc_fortificationTypes = [
["Land_BagBunker_Small_F","Land_BagBunker_Small_F","Land_BagBunker_Small_F","Land_BagBunker_Large_F","Land_BagFence_Round_F","Land_BagFence_Round_F","Land_BagFence_Round_F","Land_BagFence_Round_F","Land_BagFence_Round_F","Land_BagFence_Round_F","Land_BagFence_Long_F","Land_BagFence_Long_F","Land_SandbagBarricade_01_half_F","Land_SandbagBarricade_01_half_F","Land_SandbagBarricade_01_half_F","Land_Razorwire_F","Land_Razorwire_F","Land_Razorwire_F","Land_Razorwire_F","Land_CzechHedgehog_01_new_F","Land_CzechHedgehog_01_new_F","Land_CzechHedgehog_01_new_F"],
["Land_BagBunker_Small_F","Land_BagBunker_Small_F","Land_BagBunker_Small_F","Land_BagBunker_Large_F","Land_BagFence_Round_F","Land_BagFence_Round_F","Land_BagFence_Round_F","Land_BagFence_Round_F","Land_BagFence_Round_F","Land_BagFence_Round_F","Land_BagFence_Long_F","Land_BagFence_Long_F","Land_SandbagBarricade_01_half_F","Land_SandbagBarricade_01_half_F","Land_SandbagBarricade_01_half_F","Land_Razorwire_F","Land_Razorwire_F","Land_Razorwire_F","Land_Razorwire_F","Land_CzechHedgehog_01_new_F","Land_CzechHedgehog_01_new_F","Land_CzechHedgehog_01_new_F"],
[]];
Hz_ambw_sc_staticGunnerTypes = [
["CUP_O_TK_Soldier"],
["LOP_IA_Infantry_Rifleman_4"],
[]];
Hz_ambw_sc_flagTypes = ["FlagCarrierTakistan_EP1","lop_Flag_Iraq_F","FlagCarrierTKMilitia_EP1"];
Hz_ambw_sc_captureTime = 120;

if (!isServer) exitWith {};

//init sectors

//position, radius, direction, controlling side, marker,flagObj,array of spawned objects for currently owning side,array of groups currently trying to capture sector in the form [E,W,I]  -- [[[0,0,0], 300, 0, sideEmpty, "",flag, [obj1,obj2,obj3],[[Egrp1,Egrp2],[Wgrp1],[Igrp1]]]]
Hz_ambw_sc_sectors = [];

_markerIndex = 0;
{
	_pos = markerpos _x;
	
	//make sure marker exists
	if ((str _pos) != "[0,0,0]") then {
		_marker = "Hz_ambw_sc_sector_" + (str _markerIndex);
		_pos set [2,0];
		createMarker [_marker, _pos];
		_marker setMarkerShape "ELLIPSE";		
		_size = (markerSize _x) select 0;
		if (_size < 100) then {
			_size = 100;
		};		
		_marker setMarkerSize [_size, _size];
		_dir = markerDir _x;
		_marker setMarkerDir _dir;		
		_colour = markerColor _x;
		_side = sideEmpty;
		switch (_colour) do {
			case "ColorEAST" : {_side = east};
			case "ColorWEST" : {_side = west};
			case "ColorGUER" : {_side = resistance};
			default {_colour = "ColorBlack"};
		};
		_marker setMarkerColor _colour;
		_marker setMarkerAlpha 0.5;	
		_marker setMarkerText (markerText _x);
		
		_markerIndex = _markerIndex + 1;
		Hz_ambw_sc_sectors pushBack [_pos, _size, _dir, _side, _marker,objNull,[],[[],[],[]]];
		deleteMarker _x;
	};
} foreach Hz_ambw_sc_editorMarkers;

publicVariable "Hz_ambw_sc_sectors";

if (Hz_ambw_enablePersistency) then {

	[] spawn {
		
		waitUntil {
			sleep 1;
			(!isnil "Hz_ambw_pat_enableHeadlessClient")	
		};
		sleep 3;
		
		if (Hz_ambw_pat_enableHeadlessClient) exitWith {};

		waitUntil {
			sleep 5;
			(!isnil "Hz_pers_serverInitialised") && {Hz_pers_serverInitialised}
		};
			
		call Hz_ambw_sc_fnc_loadSectorsFromSave;
	
	};

};

[] execVM (Hz_ambw_scriptsPath+"Hz_ambw_sc_trackSectors.sqf");