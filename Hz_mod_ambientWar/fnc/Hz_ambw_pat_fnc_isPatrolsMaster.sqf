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

if (Hz_ambw_pat_enableHeadlessClient) then {

	(call Hz_ambw_fnc_isHeadlessClient) && {(name player) == Hz_ambw_pat_hcName}

} else {

	isServer

}
