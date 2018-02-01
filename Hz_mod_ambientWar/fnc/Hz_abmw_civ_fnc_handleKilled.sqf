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

_civ = _this select 0;
_killer = _this select 1;

_condition = false;

if (isplayer _killer) then {

_condition = true;

} else {
  
  //hit and run detection
  if (_civ == _killer) then {
    
    //civ might be sent away so keep radius large
    _nearCars = nearestobjects [_civ,["LandVehicle"],30];
    
    {
    
      _driver = driver _x;
      
      if (((speed _x) > 10) && (isplayer _driver)) exitwith {
      
      _condition = true;
      _killer = _driver;
      
      };
      
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

