/* 

Adapted to and enhanced for Hunter'z Ambient War Module
from the Suicide Bomber script by Zooloo75/Stealthstick
Link to original:
http://www.armaholic.com/page.php?id=20562

*/

private ["_nearUnits","_exit","_pos","_timeout","_bomber","_targetSides","_explosives"];

_bomber = _this select 0;
_targetSides = _this select 1;
_explosives = _this select 2; // ["MagClass", "AmmoClass"]
_bomberSide = _this select 3;
_exit = false;

while {(alive _bomber) && {!_exit}} do {

  _nearUnits = nearestObjects [_bomber,["CAManBase"],100];
  _nearUnits = _nearUnits - [_bomber];
	
  {
    if(!(side _x in _targetSides)) then {_nearUnits = _nearUnits - [_x];};
  } forEach _nearUnits;
	
  if(count _nearUnits != 0) then {
	
    _pos = getpos (_nearUnits select 0);
    _bomber forceSpeed -1;
    _bomber setunitpos "UP";
    _bomber doMove _pos;
    
    _timeout = time + 10;
		
    waitUntil {
			
			sleep 0.1;
			
			(!alive _bomber) || (_bomber distance _pos < 15) || (time > _timeout)
			
		};
		
    if((alive _bomber) && {!(_bomber call Hz_ambw_fnc_isUncon)} && {!captive _bomber} && {({(side _x) in _targetSides} count nearestobjects [_bomber,["LandVehicle","CAManBase"],15] ) > 0}) exitWith {
      
			_exit = true;
      
      [_bomber,_explosives,_bomberSide] spawn {
        
        private ["_pos","_bomber"];
        
        _bomber = _this select 0; 
        _explosives = _this select 1;
        _bomberSide = _this select 2;
				
				_bomber setvariable ["Hz_ambw_sideFaction",[_bomberSide,"Civilians"]];	

				dostop _bomber;
				
				if ((unitPos _bomber) != "UP") then {
					_bomber setUnitPos "UP";
					uisleep 0.5;
				};				
				
				[_bomber,"Hz_ambw_shout"] remoteExecCall ["say3D",0,false];
				
				[_bomber] joinsilent grpNull;
				_bgroup = creategroup _bomberSide;
        [_bomber] joinsilent _bgroup;
				
				_bomber playMoveNow "AmovPercMstpSsurWnonDnon";
				
        _bomber disableAI "MOVE";				
        uisleep 0.5;
				
				if ((alive _bomber) && {!(_bomber call Hz_ambw_fnc_isUncon)} && {!captive _bomber}) then {
					[_bomber,"AmovPercMstpSsurWnonDnon"] remoteExecCall ["switchMove",0,false];
					_bomber disableAI "anim";
				};
				
        uisleep 1.4;
				
				_bgroup deleteGroupWhenEmpty true;
        
        if ((alive _bomber) && {!(_bomber call Hz_ambw_fnc_isUncon)} && {!captive _bomber}) then {
				
					// check is done in real time to make sure he hasn't been disarmed!
					private _explosiveMagType = _explosives select 0;
					_explosiveCount = {_x == _explosiveMagType} count (magazines _bomber);
					
					if (_explosiveCount > 0) then {
						
						_pos = getPos _bomber;
						
						// I don't know if grenades can be forced to explode early...
						private _fuseTime = (getNumber (configFile >> "cfgAmmo" >> (_explosives select 1) >> "timeToLive")) max 0.1;
						
						for "_i" from 1 to _explosiveCount do {
						
							[_pos, _explosives select 1] spawn {
							
								params ["_pos", "_explosiveType"];
							
								_bomb = _explosiveType createVehicle _pos;
								_bomb setpos _pos;
								_bomb setDamage 1;
							
							};
							
							uisleep 0.1;
						
						};
						
						uisleep _fuseTime;
						deletevehicle _bomber;
					
					};
					
        };
      };      
      
    };
  };
  
  sleep 10;
};