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

//If trigger will stay switched on for an extended period of time, might need an external script to monitor if all civs are still alive and update Hz_ambw_currentNumberOfCiviliansSpawned.

#define SAFE_DISTANCE_FOR_SPAWN 300

//#define playableunits switchableunits

if (Hz_ambw_civ_debug) exitWith {_this spawn Hz_ambw_civ_fnc_spawnCivs;};

private ["_ForceSpawnAtHouses","_numinput","_mutex","_exit","_civarray","_num","_count","_newcivarray","_roadarr","_client","_civtype","_group","_civ","_road","_spawnpos","_buildings","_group1","_group2","_group3","_civgroups","_killcivs","_trigger","_pos","_radius","_ownerIDs"];

if (Hz_ambw_civ_debug) then {hint "inside main script";};

_trigger = _this select 0;
_pos = getpos _trigger;
_radius = (triggerArea _trigger) select 0;
_civarray = _trigger getVariable ["civarray",[]];
_mutex = _trigger getVariable ["mutex",true];
_ForceSpawnAtHouses = false;
_numinput = 0;

//optional, if true then use house positions to spawn civs instead of roads
if((count _this) > 1) then {_ForceSpawnAtHouses = _this select 1;};

//optional, for manual control of number of civs to spawn in area, rather than auto calculation.
if((count _this) > 2) then {_numinput = _this select 2;};

//if (Hz_ambw_civ_debug) then {sleep 4; [-1, {hint format ["%1",_this];}] call CBA_fnc_globalExecute; sleep 10;};

if (!isServer) exitwith {};
if(!Hz_ambw_civ_initDone) exitwith {};
if(!_mutex) exitwith {};

_exit = false;
if(Hz_ambw_civ_forceGlobalMutex) then {
  if(!Hz_ambw_civGlobalMutexUnlocked) exitwith {_exit = true;};
  Hz_ambw_civGlobalMutexUnlocked = false;
};
if(_exit) exitwith{};

_trigger setVariable ["mutex",false];

if (Hz_ambw_civ_debug) then {hint format ["%1",_pos];sleep 10;};

_ownerIDs = [];
if(Hz_ambw_enableClientProcessing) then {

  {

    _ownerIDs pushBack (owner _x);

  }foreach playableunits;

};

//Determine number of civs to spawn for this location
_buildings = nearestObjects [_pos, ["House"], _radius];
_count = count _buildings;
_num = 0;
if (_numinput > 0) then {
  _num = _numinput;
} else {    
  _num = floor (Hz_ambw_spawnCivilianCountMultiplier * (sqrt _count));
};

//Check if civs have already been spawned in the area

if((count _civarray) > 0) then {

  _count = {alive _x} count _civarray;
  _num = _num - _count;
  if(_num < 0) exitwith {};

  _newcivarray = [];

  {
    
    if (alive _x) then {
      
      _newcivarray pushBack _x;
      
    };
    
  }foreach _civarray;

  _civarray = +_newcivarray;

};

if (_num == 0) exitwith {};

if ((Hz_ambw_currentNumberOfCiviliansSpawned + _num) > Hz_ambw_maxNumberOfCivs) then {

  _num = Hz_ambw_maxNumberOfCivs - Hz_ambw_currentNumberOfCiviliansSpawned;

};

//create single group for entire area?
_group1 = creategroup civilian;
_group2 = creategroup civilian;
_group3 = creategroup civilian;

_civgroups = [_group1,_group2,_group3];

{
	_x deleteGroupWhenEmpty true;
} foreach _civgroups;

_civ = objNull;

//Find near roads
_roadarr = [];
if(_ForceSpawnAtHouses)then {

  _roadarr = nearestobjects [_pos,["House"],_radius];  
  
} else {

  _roadarr = _pos nearroads _radius;   

  if ((count _roadarr) < 100) then {
    
    _ForceSpawnAtHouses = true;
    _roadarr = nearestobjects [_pos,["House"],_radius];  
    
  };
  
};

//filter
_thisList = [];
_temp = +(list _trigger);
{
  _veh = vehicle _x;    
  
  if (!(_veh in _thisList)) then {_thisList pushBack _veh;};
  
} foreach _temp;


_temp = +_roadarr;
{
  
  _remove = false;
  
  {
    
    if (_x in _thisList) exitWith {_remove = true;};
    
  } foreach (nearestobjects [_x,["CAManBase","LandVehicle"],SAFE_DISTANCE_FOR_SPAWN]);
  
  if (_remove) then {_roadarr = _roadarr - [_x];};
  
} foreach _temp;  

_bPosArr = [];

if (_ForceSpawnAtHouses) then {
  
  //get a list of spawn positions from "houses" with at least 3 bpos		
  {
    
    _bPos = _x buildingPos -1;

    if ((count _bPos) > 2) then {
      
      _bPosArr = _bPosArr + _bPos;
      
    };
    
  } foreach _roadarr;
  
  //check if we have enough bPoses
  _bposCount = count _bposArr;
  if (_bposCount < _num) then {
    
    _bposCount = _num - _bposCount;
    
    for "_i" from 1 to _bposCount do {
      
      //add some filler spawn positions
      _house = selectRandom _roadarr;
      _fillerPos = [[(getpos _house) select 0,(getpos _house) select 1, 0],50,1,0] call mps_getFlatArea;
      
      _bposArr pushback _fillerPos;
      
    };
    
  };
  
};


//SPAWN LOOP
for "_i" from 1 to _num do {
  
  _spawnpos = [];
  
  if (!_ForceSpawnAtHouses) then {
    
    //Choose random road. Try and make them spawn on the side rather than in the middle
    _road = selectRandom _roadarr;
    
    _roadarr = _roadarr - [_road];
    
    _spawnpos = (boundingbox _road) select 0;
    _spawnpos = _road modeltoworld _spawnpos;
    _spawnpos = [(_spawnpos select 0),(_spawnpos select 1),0];
    
  } else {
    
    _spawnpos = selectRandom _bposArr;
    _bposArr = _bposArr - [_spawnpos];

  };

  //Choose civ behaviour (normal or hostile) based on probability.
	if ((random 1) < Hz_ambw_hostileCivRatio) then {
	
    _civtype = selectRandom Hz_ambw_hostileCivTypes;
    _group = selectRandom _civgroups;
    _civ = _group createUnit [ _civtype, _spawnpos, [], 2, "NONE" ];
    
    _civarray pushBack _civ;  
    
    _civ setskill 0.2;
		_civ allowFleeing 0.5;
    _civ setskill ["aimingSpeed",0.6];
    _civ setskill ["aimingShake",0.02];
    _civ setskill ["reloadSpeed",0.2];
    _civ setskill ["spotDistance",0.2];
    _civ setskill ["aimingAccuracy",0.02];
    _civ setskill ["spotTime",1];    
		
    removeAllWeapons _civ;
    removeAllItems _civ;		
		_civ unassignItem "ItemMap";
		_civ removeItem "ItemMap";
		_civ unassignItem "ItemCompass";
		_civ removeItem "ItemCompass";
    
    _civ setposatl _spawnpos;
    
    if(Hz_ambw_enableClientProcessing) then {_client = selectRandom _ownerIDs; _civ setowner _client;};
    
		_prob = random 1;
		
		if (_prob < Hz_ambw_civ_suicideBomberProbability) then {
		
			_civ setskill 1;			
			_civ setunitpos "UP";
			
			if ((random 1) < 0.5) then {
				_civ addBackpack "B_OutdoorPack_tan";	
				_civ addMagazine "IEDUrbanBig_Remote_Mag";			
				[_civ,[Hz_ambw_armedCivilianTargetSide],"IEDUrbanBig_Remote_Ammo",Hz_ambw_armedCivilianSide] spawn Hz_ambw_civ_suicideBomber;
			} else {
				[_civ,[Hz_ambw_armedCivilianTargetSide],"IEDUrbanSmall_Remote_Mag",Hz_ambw_armedCivilianSide] spawn Hz_ambw_civ_suicideBomber;
			};	
		
		} else {
		
			{
			
				if (_prob < (_x select 0)) exitWith {
				
					_civ addMagazine (_x select 2);
					_civ addWeapon (_x select 1);
					_civ addMagazines [_x select 2, _x select 3];
					
				};
			
			} foreach Hz_ambw_civ_loadouts;
			
			[_civ,Hz_ambw_armedCivilianSide, Hz_ambw_armedCivilianTargetSide] spawn Hz_ambw_civ_sinisterCiv; 
		
		};
			
	} else {
    
    _civtype = selectRandom Hz_ambw_allCivTypes;
    _group = selectRandom _civgroups;
    _civ = _group createUnit [ _civtype, _spawnpos, [], 2, "NONE" ];
    _civarray pushBack _civ;  
    
    _civ setSkill 0;
    _civ allowFleeing 1;
		
    removeAllWeapons _civ;
    removeAllItems _civ;     
		_civ unassignItem "ItemMap";
		_civ removeItem "ItemMap";
		_civ unassignItem "ItemCompass";
		_civ removeItem "ItemCompass";		
    
    _civ setposatl _spawnpos;
    
    if ((random 1) > 0.96) then {_civ addBackpack "B_OutdoorPack_tan";};          
    (group _civ) setBehaviour "SAFE";      
    
    if(Hz_ambw_enableClientProcessing) then {_client = selectRandom _ownerIDs; _civ setowner _client;};
    
  };

  Hz_ambw_currentNumberOfCiviliansSpawned = Hz_ambw_currentNumberOfCiviliansSpawned + 1;

  if (Hz_ambw_civ_debug) then {[-1, {hint format["%1",_civarray];}] call CBA_fnc_globalExecute;};

};

if (Hz_ambw_civ_debug) then {sleep 4; [-1, {hint format ["Script done. returned civarray: %1",_civarray];}] call CBA_fnc_globalExecute; sleep 5;};

_trigger setVariable ["civarray",_civarray];
_trigger setVariable ["mutex",true];

{_x deleteGroupWhenEmpty true} foreach _civgroups;

publicvariable "Hz_ambw_currentNumberOfCiviliansSpawned";

if(Hz_ambw_civ_forceGlobalMutex) then {Hz_ambw_civGlobalMutexUnlocked = true;};
