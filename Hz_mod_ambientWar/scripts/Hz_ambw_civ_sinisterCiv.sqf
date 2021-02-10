private ["_civ","_side","_targetSide","_grp"];

_civ = _this select 0;
_side = _this select 1;
_targetSide = _this select 2;

_grp = grpNull;
//_civ disableAI "FSM";
_civ disableAI "AUTOCOMBAT";

_nearTargets = [];

//apparently we need something like this in Arma 3 to force him to holster weapon...
_civ action ['SwitchWeapon', _civ, _civ, -1];
sleep 0.1;
// get rid of initial "weapon on back" animation at spawn...
[_civ, ""] remoteExecCall ["switchMove", 0, false];
sleep 1;

[_civ] joinSilent grpNull;
_civgrp = createGroup civilian;
[_civ] joinSilent _civgrp;
deleteGroup _grp;
_civ setunitpos "AUTO";
_civ setVariable ["Hz_ambw_sideFaction",[civilian,"Civilians"]];
//_civ disableAI "FSM";

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
	_civ setVariable ["Hz_ambw_sideFaction",[_side,"Civilians"]];
	
	//give enough time to "wake up"
	uisleep 3;
	
	if ((random 1) < 0.75) then {
	
		_civ setUnitPos "UP";
	
	};
	
	_grp setvariable ["Hz_AI_lastTrueDangerTime",time];
  _grp setvariable ["Hz_AI_lastCriticalDangerTime",time];
  _grp setvariable ["Hz_AI_lastDangerTime",time];
  _grp setBehaviour "COMBAT";
	_civ selectWeapon (handgunWeapon _civ);
	_civ action ['SwitchWeapon', _civ, _civ, 0];
  
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
		_civ setVariable ["Hz_ambw_sideFaction",[civilian,"Civilians"]];
		//_civ disableAI "FSM";

		_civ action ['SwitchWeapon', _civ, _civ, -1];
	
	};

};

deleteGroup _grp;