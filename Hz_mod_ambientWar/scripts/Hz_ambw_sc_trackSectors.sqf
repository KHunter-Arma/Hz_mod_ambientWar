/*******************************************************************************
* Copyright (C) 2021 K.Hunter
*
* The source code contained within this file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

if (Hz_ambw_pat_enableHeadlessClient) then {
	waitUntil {
		sleep 5;
		(!isnil "Hz_ambw_sc_hcSectorsLoaded") && {Hz_ambw_sc_hcSectorsLoaded}
	};
} else {
		waitUntil {
		sleep 5;
		(!isnil "Hz_pers_serverInitialised") && {Hz_pers_serverInitialised}
	};	
	sleep 60;
};

private _trackedSectors_ID = [];
private _trackedSectors_IsEmpty = [];
{
	// create a sector ID from coordinates
	_trackedSectors_ID = ((_x select 0) select 0) + ((_x select 0) select 1);
	_trackedSectors_IsEmpty pushBack false;
} foreach Hz_ambw_sc_sectors; 

private _sectorsChanged = false;
private _nearVics = [];
private _nearMen = [];
private _side = sideEmpty;
private _trackTime = (Hz_ambw_sc_captureTime*4) min 1800;

while {true} do {

	sleep _trackTime;
	
	{
	
		if ((_trackedSectors_ID select _foreachIndex) != (((_x select 0) select 0) + ((_x select 0) select 1))) exitWith {
			_sectorsChanged = true;
		};
		
		_sector = _x;
		
		_side = _sector select 3;
		if (_side != sideEmpty) then {
		
			_nearMen = ((_sector select 0) nearEntities ["CAManBase", (_sector select 1)*4]) select {
				((side _x) == _side)
				&& {!(_x getVariable ["ACE_isUnconscious",false])}
				&& {(lifeState _x) != "INCAPACITATED"}
			};
			
			if ((count _nearMen) == 0) then {
				_nearVics = ((_sector select 0) nearEntities [["LandVehicle", "Ship", "StaticWeapon"], (_sector select 1)*4]) select {
					((side _x) == _side)
					&& {
						(count ((crew _x) select {
							(!(_x getVariable ["ACE_isUnconscious",false]))
							&& {(lifeState _x) != "INCAPACITATED"}
						})) > 0
					}
				};
				if ((count _nearVics) == 0) then {
					if (_trackedSectors_IsEmpty select _foreachIndex) then {
						//neutralize flag
						private _flag = _sector select 5;
						if (!isnull _flag) then {
							deleteVehicle _flag;
							(_sector select 4) setMarkerColor "ColorBlack";
							_sector set [3, sideEmpty];
							Hz_ambw_sc_sectors set [_foreachIndex, _sector];
							publicVariable "Hz_ambw_sc_sectors";
						};
					} else {
						_trackedSectors_IsEmpty set [_foreachIndex, true];
					};
				} else {
					_trackedSectors_IsEmpty set [_foreachIndex, false];
				};
			} else {
				_trackedSectors_IsEmpty set [_foreachIndex, false];
			};
		
		};
		
	} foreach Hz_ambw_sc_sectors;
	
	
	if (_sectorsChanged) then {
		// reset tracking info
		_trackedSectors_ID = [];
		_trackedSectors_IsEmpty = [];	
		{
			_trackedSectors_ID = ((_x select 0) select 0) + ((_x select 0) select 1);
			_trackedSectors_IsEmpty pushBack false;
		} foreach Hz_ambw_sc_sectors; 
	};

};
