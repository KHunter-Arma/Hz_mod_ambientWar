private ["_civ","_side","_targetSide","_grp"];

_civ = _this select 0;
_side = _this select 1;
_targetSide = _this select 2;

_grp = grpNull;

_nearTargets = [];

[_civ] joinSilent grpNull;
_civgrp = createGroup civilian;
[_civ] joinSilent _civgrp;
_civ setVariable ["Hz_ambw_sideFaction",[civilian,"Civilians",1]];

_civ disableAI "AUTOCOMBAT";
//_civ disableAI "FSM";

_civ setunitpos "AUTO";

//apparently we need something like this in Arma 3 to force him to holster weapon...
sleep 0.1;
_civ action ['SwitchWeapon', _civ, _civ, 99];

// get rid of initial "weapon on back" animation at spawn...
sleep 0.1;
[_civ, ""] remoteExecCall ["switchMove", 0, false];

while {alive _civ} do {

  waitUntil {
    
    sleep 5;
		
		_nearTargets = _civ nearEntities ["CAManBase", 50];
    
    ((lifeState _civ) != "INCAPACITATED") && {({(side _x) == _targetSide} count _nearTargets) > 0}
    || {!alive _civ}

  };
			
	if (!alive _civ) exitWith {deleteGroup _civgrp};

	//add some random intensity
  sleep (random 10);
		
	_grp = createGroup [_side,true];
	[_civ] joinSilent grpNull;
	[_civ] joinSilent _grp;
	deleteGroup _civgrp;
	
	{_civ reveal [_x,2]} foreach _nearTargets;
	
	//_civ enableAI "FSM";
	_civ setCombatMode "RED";
	_civ setVariable ["Hz_ambw_sideFaction",[_side,"Civilians",0]];
	
	//give enough time to "wake up"
	uisleep 3;
	
	if ((random 1) < 0.75) then {
	
		_civ setUnitPos "UP";
	
	};
	
	_grp setvariable ["Hz_AI_lastTrueDangerTime",time];
  _grp setvariable ["Hz_AI_lastCriticalDangerTime",time];
  _grp setvariable ["Hz_AI_lastDangerTime",time];
  _grp setBehaviour "COMBAT";
	
	for [{_idx_muzzle = 0}, {currentWeapon _civ != handgunWeapon _civ}, {_idx_muzzle = _idx_muzzle+1}] do {
		_civ action ["SWITCHWEAPON", _civ, _civ, _idx_muzzle];
	};
	_civ selectWeapon (handgunWeapon _civ);
  
  waitUntil {
  
  sleep 10;
  
  (!alive _civ) || {((lifeState _civ) != "INCAPACITATED") && {(behaviour _civ) != "COMBAT"}}
  
  };
	
	if (alive _civ) then {
	
		[_civ] joinSilent grpNull;
		_civgrp = createGroup civilian;
		[_civ] joinSilent _civgrp;
		deleteGroup _grp;
		_civ setunitpos "AUTO";
		_civ setVariable ["Hz_ambw_sideFaction",[civilian,"Civilians",1]];
		//_civ disableAI "FSM";

		_civ action ['SwitchWeapon', _civ, _civ, 99];
	
	};

};

deleteGroup _grp;