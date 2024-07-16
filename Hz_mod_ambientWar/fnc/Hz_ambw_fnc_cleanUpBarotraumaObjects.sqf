params ["_pos", "_radius"];

if (isServer) then {
	
	{
		deleteVehicle _x;
	} foreach (nearestObjects [_pos, ["BloodSplatter_Plane","BloodSplatter_SmallPlane","BloodSplatter_MediumPlane","BloodSplatter_LargePlane","BloodSplatter_SprayPlane","BloodSplatter_SmallSprayPlane","BloodSplatter_LeftHand","BloodSplatter_LeftLowerArm","BloodSplatter_LeftLowerLegAndFoot","BloodSplatter_LeftUpperArm","BloodSplatter_LeftUpperLeg","BloodSplatter_Pelvis","BloodSplatter_RightFoot","BloodSplatter_RightHand","BloodSplatter_RightIndexFinger","BloodSplatter_RightMiddleFinger","BloodSplatter_RightPinkyFinger","BloodSplatter_RightRingFinger","BloodSplatter_RightThumb","BloodSplatter_RightUpperArm","BloodSplatter_RightLowerArm","BloodSplatter_RightUpperLeg","BloodSplatter_RightLowerLeg","BloodSplatter_Torso"], _radius]);

} else {

	_this remoteExecCall ["Hz_ambw_fnc_cleanUpBarotraumaObjects", 2, false];

};
