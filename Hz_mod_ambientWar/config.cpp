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

class cfgPatches {

  class Hz_mod_ambientWar {
    
    name = "Hunter'z Ambient War Module";
    author = "K.Hunter";
    url = "https://github.com/KHunter-Arma";
    
    requiredVersion = 1.58; 
    requiredAddons[] = {"A3_Modules_F","Extended_Eventhandlers"};
    units[] = {"Hz_mod_ambientWar_module"};
    weapons[] = {};
    
  };

};

class CfgMods
{
	class Mod_Base;
	class Hz_mod_ambientWar: Mod_Base
	{
		name = "Hunter'z Ambient War Module";
		picture = "\x\Hz\Hz_mod_ambientWar\media\Hunterz_logo.paa";
		logo = "\x\Hz\Hz_mod_ambientWar\media\Hunterz_icon.paa";
		logoSmall = "\x\Hz\Hz_mod_ambientWar\media\Hunterz_iconSmall.paa";
		logoOver = "\x\Hz\Hz_mod_ambientWar\media\Hunterz_icon.paa";
		tooltipOwned = "";
		action = "https://github.com/KHunter-Arma";
		dlcColor[] = {1,00,00,0.8};
		overview = "";
		hideName = 0;
		hidePicture = 0;
		dir = "@Hz_mod_ambientWar";
	};
};

class cfgFunctions
{
  class Hz {
      
      class Hz_moduleFunctions {
				
				class ambw_init {
					
					file = "\x\Hz\Hz_mod_ambientWar\Hz_ambw_init.sqf";					
					
				};     

      };
    
  };
  
};

class CfgFactionClasses
{
	class NO_CATEGORY;
	class Hz_editorModules: NO_CATEGORY
	{
		displayName = "Hz";
	};
};

class CfgVehicles
{
  class Logic;
  class Module_F: Logic
  {
    class AttributesBase
    {
      class Default;
      class Edit; // Default edit box (i.e., text input field)
      class Combo; // Default combo box (i.e., drop-down menu)
      class Checkbox; // Default checkbox (returned value is Bool)
      class CheckboxNumber; // Default checkbox (returned value is Number)
      class ModuleDescription; // Module description
    };
    // Description base classes, for more information see below
    class ModuleDescription
    {
      
    };
  };
  class Hz_mod_ambientWar_module: Module_F
  {
    // Standard object definitions
    scope = 2; // Editor visibility; 2 will show it in the menu, 1 will hide it.
    displayName = "Hunter'z Ambient War"; // Name displayed in the menu
    icon = "\x\Hz\Hz_mod_ambientWar\media\Hunterz_icon.paa"; // Map icon. Delete this entry to use the default icon
    category = "Hz_editorModules";

    // Name of function triggered once conditions are met
    function = "Hz_fnc_ambw_init";
    // Execution priority, modules with lower number are executed first. 0 is used when the attribute is undefined
    functionPriority = 0;
    // 0 for server only execution, 1 for global execution, 2 for persistent global execution
    isGlobal = 2;
    // 1 for module waiting until all synced triggers are activated
    isTriggerActivated = 0;
    // 1 if modules is to be disabled once it's activated (i.e., repeated trigger activation won't work)
    isDisposable = 0;
    // 1 to run init function in Eden Editor as well
    is3DEN = 0;

    // Menu displayed when the module is placed or double-clicked on by Zeus
    curatorInfoType = "";

    // Module attributes, uses https://community.bistudio.com/wiki/Eden_Editor:_Configuring_Attributes#Entity_Specific
    class Attributes: AttributesBase
    {      
			
			
			
      class ModuleDescription: ModuleDescription {}; // Module description should be shown last
    };

    // Module description. Must inherit from base class, otherwise pre-defined entities won't be available
    class ModuleDescription: ModuleDescription
    {
      description = "Hunter'z Ambient War Module"; // Short description, will be formatted as structured text
      sync[] = {}; // Array of synced entities (can contain base classes)      

    };
  };
};

class Extended_Killed_EventHandlers {
		
	class CAManBase {		

		class Hz_ambw_EH_unitDead {
			
			serverKilled = "_this call Hz_ambw_fnc_unitHandleKilled;";
			
		};
	};
};