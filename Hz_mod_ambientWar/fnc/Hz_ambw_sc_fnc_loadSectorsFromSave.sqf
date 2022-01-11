/*******************************************************************************
* Copyright (C) 2020 K.Hunter
*
* The source code contained within this file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

//no prior save data found
if ((count Hz_pers_network_ambw_sc_sPos) == 0) exitWith {
	if (isServer) then {
		Hz_ambw_sc_sectorsLoadingFromSaveDone = true;
	};
};

{
	// make sure sector still exists (in case mission is edited)
	private _sectorIndex = -1;
	private _sectorPos = _x;
	{
		if ((_sectorPos distance2D (_x select 0)) < 50) exitWith {
			_sectorIndex = _foreachIndex;
		};
	} foreach Hz_ambw_sc_sectors;
	
	private _sector = Hz_ambw_sc_sectors select _sectorIndex;
	
	private _side = Hz_pers_network_ambw_sc_sSides select _foreachIndex;
	
	private _sideIndex = switch (_side) do {
		case west : {1};
		case east : {0};
		case independent : {2};
		default {-1};
	};
	
	private _flag = objNull;
	if (_sideIndex != -1) then {	
		private _flagPos = [_sectorPos,10] call Hz_ambw_fnc_findSafePos;
		_flag = (Hz_ambw_sc_flagTypes select _sideIndex) createVehicle [-5000,-5000,50000];
		_flag setPosATL _flagPos;
		_sector set [5,_flag];
		_sector set [3, _side];
		private _colour = switch (_side) do {
			case east : {"ColorEAST"};
			case west : {"ColorWEST"};
			case resistance : {"ColorGUER"};
		};
		(_sector select 4) setMarkerColor _colour;
	};
	
	private _objectTypes = Hz_pers_network_ambw_sc_sObjectTypes select _foreachIndex;
	private _objectPosATL = Hz_pers_network_ambw_sc_sObjectPosATL select _foreachIndex;
	
	private _defGroup = grpNull;
	private _objects = _sector select 6;
	private _emplacementBuildingPos = [];
	private _emplacements = [];
	{
		if (_x isKindOf "StaticWeapon") then {
			private _gunPos = _objectPosATL select _foreachIndex;
			private _gun = _x createVehicle _gunPos;
			_gun setPosATL _gunPos;
			_gun setDir ((_gunPos getDir _flag) + 180);
			_gun setVehicleLock "LOCKED";
			_gun enableWeaponDisassembly false;
			
			_objects pushBack _gun;
			
			if (_sideIndex != -1) then {
				if (isNull _defGroup) then {
					_defGroup = createGroup _side;
					_defGroup deleteGroupWhenEmpty true;
					_defGroup setVariable ["Hz_defending",true];
				};	
				private _dude = _defGroup createUnit [(selectRandom (Hz_ambw_sc_defenderTypes select _sideIndex)), _gunPos, [], 100, "NONE"];
				_dude assignAsGunner _gun;
				_dude moveInGunner _gun;
			} else {
				_gun setDamage 0.8;
			};
		} else {
			private _empPos = _objectPosATL select _foreachIndex;
			private _emp = _x createVehicle _empPos;
			
			_objects pushBack _emp;
			_emplacements pushBack _emp;	
			_emp setPosATL _empPos;
			//most emplacements have "reversed" direction...
			_emp setDir (_empPos getDir _flag);	
			
			sleep 1;
			_emplacementBuildingPos = _emplacementBuildingPos + ([_emp] call BIS_fnc_buildingPositions);
		};
		
	} foreach _objectTypes;
	
	_sector set [6,_objects];
	
	//create defenders
	if (_sideIndex != -1) then {
		private _numDefenders = Hz_ambw_sc_defenderCountMin max (round random Hz_ambw_sc_defenderCountMax);

		if (_numDefenders > 0) then {
		
			_emplacements = _emplacements select {(count (_x nearEntities ["CAManBase", 10])) == 0};

			for "_i" from 1 to _numDefenders do {
				
				if (isNull _defGroup) then {
					_defGroup = createGroup _side;
					_defGroup deleteGroupWhenEmpty true;
					_defGroup setVariable ["Hz_defending",true];
				};	
				private _dude = _defGroup createUnit [(selectRandom (Hz_ambw_sc_defenderTypes select _sideIndex)), _sectorPos, [], 50, "NONE"];
				
				if ((count _emplacementBuildingPos) > 0) then {
					_pos = selectRandom _emplacementBuildingPos;
					_dude setPosATL _pos;
					_emplacementBuildingPos = _emplacementBuildingPos - [_pos];
					_dude setVariable ["Hz_noMove",true];
					_dude disableAI "PATH";
					_dude forcespeed 0;
					dostop _dude;
				} else {
					if ((count _emplacements) > 0) then {
						private _emp = selectRandom _emplacements;
						_emplacements = _emplacements - [_emp];
						private _empPos = getpos _emp;
						private _bbox = boundingBoxReal _emp;
						private _delta = (((_bbox select 0) distance2D (_bbox select 1))/2) + 1.3;
						private _pos = [_empPos, _delta, [_empPos, _flag] call BIS_fnc_dirTo] call BIS_fnc_relPos;
						_pos set [2, 0];
						_dude setPosATL _pos;
						_dude setVariable ["Hz_noMove",true];
						_dude disableAI "PATH";
						_dude forcespeed 0;
						dostop _dude;
					};
				};
				
			};

		};
	};
	
	Hz_ambw_sc_sectors set [_sectorIndex, _sector];
	publicVariable "Hz_ambw_sc_sectors";
	
} foreach Hz_pers_network_ambw_sc_sPos;

if (isServer) then {
	Hz_ambw_sc_sectorsLoadingFromSaveDone = true;
};
		