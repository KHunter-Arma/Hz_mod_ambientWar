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

class cfgSounds {
	
	class Hz_ambw_shout  {
            
		name     = "AllahAkbar";
		sound[]  = {"\x\Hz\Hz_mod_ambientWar\media\shout.ogg",1,1,200};
		titles[] = {};
				
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
			
			class Factions: Edit
			{
				property="Hz_ambw_module_pFactions";
				displayName="Factions Array";
				tooltip="";
				defaultValue="""[['B.A.D. PMC',west,5,['C_MAN_POLO_1_F','CUP_I_PMC_ION','C_MAN_HUNTER_1_F']],['Iraqi Army',west,1,['LOP_IA']],['US Forces',west,10,['USAF','USAF_AFSOC','USAF_SFS_PILOTS','RHS_FACTION_SOCOM','RHS_FACTION_USAF','RHS_FACTION_USARMY','RHS_FACTION_USARMY_D','RHS_FACTION_USARMY_WD','RHS_FACTION_USMC','RHS_FACTION_USMC_D','RHS_FACTION_USMC_WD','RHS_FACTION_USN']],['Friendly Insurgents',west,0.3,[]],['Enemy Insurgents',east,0,['CUP_O_TK_MILITIA','CUP_I_TK_GUE']],['Takistani Army',east,0,['LOP_TKA','CUP_O_TK']],['Civilians',civilian,1,['LOP_TAK_CIV','CUP_C_TK','CIV_F','CIV_IDAP_F']]]""";
			};
			
			class PenaltyPerKill: Edit
			{
				property="Hz_ambw_module_pPenaltyPerKill";
				displayName="Penalty Per Kill";
				tooltip="";
				defaultValue="""5""";
			};
			
			class PenaltyPerStolenItem: Edit
			{
				property="Hz_ambw_module_pPenaltyPerStolenItem";
				displayName="Penalty Per Stolen Item";
				tooltip="";
				defaultValue="""1""";
			};
			
			class PenaltyPerStolenWeapon: Edit
			{
				property="Hz_ambw_module_pPenaltyPerStolenWeapon";
				displayName="Penalty Per Stolen Weapon";
				tooltip="";
				defaultValue="""2""";
			};
			
			class RelationsOwnSide: Edit
			{
				property="Hz_ambw_module_pRelationsOwnSide";
				displayName="Relations Own Side";
				tooltip="";
				defaultValue="""100""";
			};
			
			class RelationsCivilian: Edit
			{
				property="Hz_ambw_module_pRelationsCivilian";
				displayName="Relations Civilian";
				tooltip="";
				defaultValue="""100""";
			};
			
			class EnableHzEcon: Checkbox
			{
				property="Hz_ambw_module_pEnableHzEcon";
				displayName="Enable Hz Economy";
				tooltip="";
			};
			
			class FundsPenaltyPerKill: Edit
			{
				property="Hz_ambw_module_pFundsPenaltyPerKill";
				displayName="Funds Penalty Per Kill";
				tooltip="";
				defaultValue="""100000""";
			};
			
			class MaxCivCount: Edit
			{
				property="Hz_ambw_module_pMaxCivCount";
				displayName="Max Number of Civilians";
				tooltip="";
				defaultValue="""60""";
			};
			
			class HostileCivRatio: Edit
			{
				property="Hz_ambw_module_pHostileCivRatio";
				displayName="Ratio of Hostile Civilians";
				tooltip="";
				defaultValue="""0.1""";
			};
			
			class ArmedCivilianSide: Edit
			{
				property="Hz_ambw_module_pArmedCivilianSide";
				displayName="Armed Civilian Side";
				tooltip="";
				defaultValue="""east""";
			};
			
			class ArmedCivilianTargetSide: Edit
			{
				property="Hz_ambw_module_pArmedCivilianTargetSide";
				displayName="Armed Civilian Target Side";
				tooltip="";
				defaultValue="""west""";
			};
			
			class CivTypes: Edit
			{
				property="Hz_ambw_module_pCivTypes";
				displayName="Civilian Types";
				tooltip="";
				defaultValue="""['C_journalist_F','C_Journalist_01_War_F','C_man_p_beggar_F','LOP_Tak_Civ_Random','LOP_Tak_Civ_Random','LOP_Tak_Civ_Random','LOP_Tak_Civ_Random','C_man_p_beggar_F','LOP_Tak_Civ_Random','LOP_Tak_Civ_Random','LOP_Tak_Civ_Random','LOP_Tak_Civ_Random']""";
			};
			
			class HostileCivTypes: Edit
			{
				property="Hz_ambw_module_pHostileCivTypes";
				displayName="Hostile Civilian Types";
				tooltip="";
				defaultValue="""['C_man_p_beggar_F','LOP_Tak_Civ_Random','LOP_Tak_Civ_Random','LOP_Tak_Civ_Random','LOP_Tak_Civ_Random']""";
			};
			
			class CivilianMultiplier: Edit
			{
				property="Hz_ambw_module_pCivilianMultiplier";
				displayName="Civilian Count Multiplier";
				tooltip="";
				defaultValue="""0.75""";
			};
			
			class SuicideBomberProbability: Edit
			{
				property="Hz_ambw_module_pSuicideBomberProbability";
				displayName="Suicide Bomber Probability";
				tooltip="";
				defaultValue="""0.05""";
			};
			
			class CivilianLoadouts: Edit
			{
				property="Hz_ambw_module_pCivilianLoadouts";
				displayName="Civilian Loadouts";
				tooltip="";
				defaultValue="""[[0.45, 'CUP_hgun_Makarov', 'CUP_8Rnd_9x18_Makarov_M', 8],[1, 'CUP_hgun_TaurusTracker455', 'CUP_6Rnd_45ACP_M', 8]]""";
			};
			
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

class Extended_InitPost_EventHandlers
{
		
			class Civilian {		

        class RemoveItems {
          
          init = "(_this select 0) unassignItem 'ItemMap'; (_this select 0) removeItem 'ItemMap'; (_this select 0) unassignItem 'ItemCompass'; (_this select 0) removeItem 'ItemCompass';";
          
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