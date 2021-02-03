/*******************************************************************************
* Copyright (C) 2018-2020 K.Hunter
*
* This file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

params ["_side1","_side2"];

if ((_side1 == sideLogic) || {_side2 == sideLogic}) exitWith {false};

(_side1 getFriend _side2) >= 0.6
