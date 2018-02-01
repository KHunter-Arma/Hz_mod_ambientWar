//If trigger will stay switched on for an extended period of time, might need an external script to monitor if all civs are still alive and update Hz_ambw_currentNumberOfCiviliansSpawned.

#define SAFE_DISTANCE_FOR_SPAWN 300
#define CIV_KILLED_COUNT_BEFORE_RAGE 5000 //deprecated for now so keep it too high

//#define playableunits switchableunits

if (Hz_ambw_civ_debug) exitWith {_this spawn Hz_ambw_civ_fnc_spawnCivs;};

private ["_ForceSpawnAtHouses","_numinput","_mutex","_exit","_civarray","_num","_count","_newcivarray","_roadarr","_client","_civtype","_group","_civ","_road","_spawnpos","_buildings","_wait","_group1","_group2","_group3","_civgroups","_killcivs","_trigger","_pos","_radius","_ownerIDs"];

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
_buildings = nearestObjects [_pos, ["House"], 500];
_count = count _buildings;
_num = 0;
_wait = false;
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
  
  if (!(_veh in _thisList)) then {_thisList set [count _thisList, _veh];};
  
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
    
    for "_x" from 1 to _bposCount do {
      
      //add some filler spawn positions
      _house = _roadarr call bis_fnc_selectrandom;
      _fillerPos = [[(getpos _house) select 0,(getpos _house) select 1, 0],50,1,0] call mps_getFlatArea;
      
      _bposArr pushback _fillerPos;
      
    };
    
  };
  
};


//SPAWN LOOP
for "_x" from 1 to _num do {
  
  _spawnpos = [];
  
  if (!_ForceSpawnAtHouses) then {
    
    //Choose random road. Try and make them spawn on the side rather than in the middle
    _road = _roadarr call bis_fnc_selectrandom;
    
    _roadarr = _roadarr - [_road];
    
    _spawnpos = (boundingbox _road) select 0;
    _spawnpos = _road modeltoworld _spawnpos;
    _spawnpos = [(_spawnpos select 0),(_spawnpos select 1),0];
    
  } else {
    
    _spawnpos = _bposArr call bis_fnc_selectrandom;
    _bposArr = _bposArr - [_spawnpos];

  };

  //Choose civ behaviour (normal or hostile) based on probability.
  
  if ((random 1) < Hz_ambw_hostileCivRatio) then {
    
    _civtype = Hz_ambw_hostileCivTypes call bis_fnc_selectrandom;
    _group = _civgroups call bis_fnc_selectrandom;
    _civ = _group createUnit [ _civtype, _spawnpos, [], 2, "NONE" ];
    
    _civarray set [count _civarray,_civ];  
    
    _civ setskill 0.2;
    _civ setskill ["aimingSpeed",0.6];
    _civ setskill ["aimingShake",0];
    _civ setskill ["reloadSpeed",0.2];
    _civ setskill ["spotDistance",0.2];
    _civ setskill ["aimingAccuracy",0.1];
    _civ setskill ["spotTime",1];
    _civ allowFleeing 0.5;
    removeAllWeapons _civ;
    removeAllItems _civ;
    
    _civ setposatl _spawnpos;
    
    if(Hz_ambw_enableClientProcessing) then {_client = _ownerIDs call bis_fnc_selectrandom; _civ setowner _client;};
    
    if ((random 1) > 0.5) then {      
      _civ addMagazine "CUP_8Rnd_9x18_Makarov_M";
      _civ addMagazine "CUP_8Rnd_9x18_Makarov_M";
      _civ addMagazine "CUP_8Rnd_9x18_Makarov_M";
      _civ addMagazine "CUP_8Rnd_9x18_Makarov_M";
      _civ addMagazine "CUP_8Rnd_9x18_Makarov_M";
      _civ addMagazine "CUP_8Rnd_9x18_Makarov_M";
      _civ addMagazine "CUP_8Rnd_9x18_Makarov_M";
      _civ addMagazine "CUP_8Rnd_9x18_Makarov_M";
      _civ addWeapon "CUP_hgun_Makarov";
      [_civ,Hz_ambw_armedCivilianSide, Hz_ambw_armedCivilianTargetSide] spawn Hz_sinisterCiv;
      
    } else {
      
      if ((random 1) < 0.95) then  {
        _civ addMagazine "CUP_6Rnd_45ACP_M";
        _civ addMagazine "CUP_6Rnd_45ACP_M";
        _civ addMagazine "CUP_6Rnd_45ACP_M";
        _civ addMagazine "CUP_6Rnd_45ACP_M";
        _civ addMagazine "CUP_6Rnd_45ACP_M";
        _civ addMagazine "CUP_6Rnd_45ACP_M";
        _civ addMagazine "CUP_6Rnd_45ACP_M";
        _civ addMagazine "CUP_6Rnd_45ACP_M";
        _civ addWeapon "CUP_hgun_TaurusTracker455";
        [_civ,Hz_ambw_armedCivilianSide, Hz_ambw_armedCivilianTargetSide] spawn Hz_sinisterCiv;           
        
      } else {

        _civ setskill 1;
        _civ addMagazine "IEDUrbanBig_Remote_Mag";
        [_civ,[Hz_ambw_armedCivilianTargetSide],"IEDUrbanBig_Remote_Ammo",Hz_ambw_armedCivilianSide] execVM "suicideBomber.sqf";
        
        _civ setunitpos "UP";
        
        if (random 1 > 0.5) then {_civ addBackpack "B_OutdoorPack_tan";};

      }; };			  
  } else {
    
    _civtype = Hz_ambw_allCivTypes call bis_fnc_selectrandom;
    _group = _civgroups call bis_fnc_selectrandom;
    _civ = _group createUnit [ _civtype, _spawnpos, [], 2, "NONE" ];
    _civarray set [count _civarray,_civ];  
    
    _civ setSkill 0;
    _civ allowFleeing 1;
    removeAllWeapons _civ;
    removeAllItems _civ;       
    
    _civ setposatl _spawnpos;
    
    if ((random 1) > 0.96) then {_civ addBackpack "B_OutdoorPack_tan";};          
    group _civ setBehaviour "SAFE";      
    _civ addEventHandler ["killed", {
      
      _civ = _this select 0;
      _killer = _this select 1;
      
      _condition = false;
      
      if (isplayer _killer) then {_condition = true;} else {
        
        //hit and run detection
        if (_civ == _killer) then {
          
          //civ might be sent away so keep radius large
          _nearCars = nearestobjects [_civ,["LandVehicle"],30];
          
          {
            
            if (((speed _x) > 10) && (isplayer (driver _x))) exitwith {_condition = true;};
            
          } foreach _nearCars;
          
        };
        
      };
      
      if (_condition) then {
        
        if (_killer getvariable ["JointOps",false]) then {
          
          [-1, {
            
            if (player getvariable ["JointOps",false]) then {
              
              hint "Civilian casualties are unacceptable. Command is sure to cut our budget in this theatre if this continues.";
              
            };
            
          }] call CBA_fnc_globalExecute;
          
        } else {
          
          mps_mission_deathcount = mps_mission_deathcount - 1; 
          Hz_econ_funds = Hz_econ_funds - 100000;
          publicvariable "Hz_econ_funds";
          publicVariable "mps_mission_deathcount";
          [-1, {
            
            if (!(player getvariable ["JointOps",false])) then {
              
              hint "Civilian casualties are unacceptable. We lost $100000 in compensation, but the big loss will come from losing support from our clients.";
              
            };
            
          }] call CBA_fnc_globalExecute;
          civ_killed_count = civ_killed_count + 1;
          
          if (civ_killed_count > CIV_KILLED_COUNT_BEFORE_RAGE) then {
            
            [-1, {hint parsetext format ["<t size='1.5' shadow='1' color='#ff0000' shadowColor='#000000'>Civilian casualties have reached outrageous numbers. Civilians will now start rebelling against you!</t>"];}] call CBA_fnc_globalExecute;    
            
          };
          
        };  
        
      };
      
    }];
    
    if(Hz_ambw_enableClientProcessing) then {_client = _ownerIDs call bis_fnc_selectrandom; _civ setowner _client;};
    
  };

  Hz_ambw_currentNumberOfCiviliansSpawned = Hz_ambw_currentNumberOfCiviliansSpawned + 1;

  if (Hz_ambw_civ_debug) then {[-1, {hint format["%1",_civarray];}] call CBA_fnc_globalExecute;};

};

if (Hz_ambw_civ_debug) then {sleep 4; [-1, {hint format ["Script done. returned civarray: %1",_civarray];}] call CBA_fnc_globalExecute; sleep 5;};

_trigger setVariable ["civarray",_civarray];
_trigger setVariable ["mutex",true];

publicvariable "Hz_ambw_currentNumberOfCiviliansSpawned";

if(Hz_ambw_civ_forceGlobalMutex) then {Hz_ambw_civGlobalMutexUnlocked = true;};