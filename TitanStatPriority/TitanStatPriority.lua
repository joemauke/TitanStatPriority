-- **************************************************************************
-- * TitanStatPriority.lua
-- * This is a Stat Priority Titan Addon.
-- * My brother asked for this....so here it is
-- * By: Joseph A Mauke
-- **************************************************************************

-- ******************************** Constants *******************************
-- Setup the name we want in the global namespace
TitanStatPriority = {}
-- Reduce the chance of functions and variables colliding with another addon.
local TSP = TitanStatPriority

TSP.id = "StatPriority";
TSP.addon = "TitanStatPriority";

-- These strings will be used for display. Localized strings are outside the scope of this example.
TSP.button_label = TSP.id..": "
TSP.menu_text = TSP.id
TSP.tooltip_header = TSP.id.." Info"
TSP.tooltip_hint_1 = "Hint: Left-click to open all bags."
TSP.menu_option = "Options"
TSP.menu_hide = "Hide"
TSP.menu_show_used = "Show used slots"
TSP.menu_show_avail = "Show available slots"

--  Get data from the TOC file.
TSP.version = tostring(GetAddOnMetadata(TSP.addon, "Version")) or "Unknown" 
TSP.author = GetAddOnMetadata("TitanQuests", "Author") or "Unknown"
-- ******************************** Variables *******************************
-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelBagButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TSP.Button_OnLoad(self)
-- SDK : "registry" is the data structure Titan uses to addon info it is displaying.
--       This is the critical structure!
-- SDK : This works because the button inherits from a Titan template. In this case
--       TitanPanelComboTemplate in the XML.
-- NOTE: LDB (LibDataBroker) type addons are NOT in the scope of this example.
	self.registry = {
		id = TSP.id,
		-- SDK : "id" MUST be unique to all the Titan specific addons
		-- Last addon loaded with same name wins...
		version = TSP.version,
		-- SDK : "version" the version of your addon that Titan displays
		category = "Information",
		-- SDK : "category" is where the user will find your addon when right clicking
		--       on the Titan bar.
		--       Currently: General, Combat, Information, Interfacem, Profession - These may change!
		menuText = TSP.menu_text,
		-- SDK : "menuText" is the text Titan displays when the user finds your addon by right clicking
		--       on the Titan bar.
		buttonTextFunction = "TitanStatPriority_GetButtonText", 
		-- SDK : "buttonTextFunction" is in the global name space due to the way Titan uses the routine.
		--       This routine is called to set (or update) the button text on the Titan bar.
		tooltipTitle = TSP.tooltip_header,
		-- SDK : "tooltipTitle" will be used as the first line in the tooltip.
		tooltipTextFunction = "TitanStatPriority_GetTooltipText", 
		-- SDK : "tooltipTextFunction" is in the global name space due to the way Titan uses the routine.
		--       This routine is called to fill in the tooltip of the button on the Titan bar.
		--       It is a typical tooltip and is drawn when the cursor is over the button.
		icon = "Interface\\AddOns\\TitanStatPriority\\Starter",
		-- SDK : "icon" needs the path to the icon to display. Blizzard uses the default extension of .tga
		--       If not needed make nil.
		iconWidth = 16,
		-- SDK : "iconWidth" leave at 16 unless you need a smaller/larger icon
		savedVariables = {
		-- SDK : "savedVariables" are variables saved by character across logins.
		--      Get - TitanGetVar (id, name)
		--      Set - TitanSetVar (id, name, value)
			-- SDK : The 2 variables below are for our example
			ShowStarterNum = 1,
			ShowUsedSlots = false,
			-- SDK : Titan will handle the 3 variables below but the addon code must put it on the menu
			ShowIcon = 1,
			ShowLabelText = 1,
			ShowColoredText = 1,               
		}
	};     

	-- Tell Blizzard the events we need
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	-- Any other addon specific "on load" code here
	
	-- shamelessly print a load message to chat window
	DEFAULT_CHAT_FRAME:AddMessage(
		GREEN_FONT_COLOR_CODE
		..TSP.addon..TSP.id.." "..TSP.version
		.." by "
		..FONT_COLOR_CODE_CLOSE
		.."|cFFFFFF00"..TSP.author..FONT_COLOR_CODE_CLOSE);
end

-- **************************************************************************
-- NAME : TSP.Button_OnEvent()
-- DESC : Parse events registered to plugin and act on them
-- USE  : _OnEvent handler from the XML file
-- **************************************************************************
function TSP.Button_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		-- do any set up needed          
		self:RegisterEvent("BAG_UPDATE");          
	end
end


-- **************************************************************************
-- NAME : TSP.Button_OnClick(button)
-- DESC : Opens all bags on a LeftClick
-- VARS : button = value of action
-- USE  : _OnClick handler from the XML file
-- **************************************************************************
function TSP.Button_OnClick(self, button)
	if (button == "LeftButton") then
		OpenAllBags();
	end
end

-- **************************************************************************
-- NAME : TitanStatPriority_GetButtonText(id)
-- DESC : Calculate bag space logic then display data on button
-- VARS : id = button ID
-- **************************************************************************
function TitanStatPriority_GetButtonText(id)
-- SDK : As specified in "registry"
--       Any button text to set or update goes here
	local button, id = TitanUtils_GetButton(id, true);
	-- SDK : "TitanUtils_GetButton" is used to get a reference to the button Titan created.
	--       The reference is not needed by this example.

	return TSP.button_label, TSP.GetBagSlotInfo();
end

-- **************************************************************************
-- NAME : TitanStatPriority_GetTooltipText()
-- DESC : Display tooltip text
-- **************************************************************************
function TitanStatPriority_GetTooltipText()
-- SDK : As specified in "registry"
--       Create the tooltip text here
	local str = "slots"
	if (TitanGetVar(TSP.id, "ShowUsedSlots")) then
		str = " used "..str
	else
		str = " available "..str
	end
	return TSP.GetBagSlotInfo()
		..str.."\n"
		..TitanUtils_GetGreenText(TSP.tooltip_hint_1);
	-- This is just a simple example.
end

-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PrepareBagMenu()
-- DESC : Display rightclick menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareStarterMenu()
-- SDK : This is a routine that Titan 'assumes' will exist. The name is a specific format
--       "TitanPanelRightClickMenu_Prepare"..ID.."Menu"
--       where ID is the "id" from "registry"
	local info

-- menu creation is beyond the scope of this example
-- but note the Titan get / set routines and other Titan routines being used.
-- SDK : "TitanPanelRightClickMenu_AddTitle" is used to place the title in the (sub)menu

	-- level 2 menu
	if UIDROPDOWNMENU_MENU_LEVEL == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == "Options" then
			TitanPanelRightClickMenu_AddTitle(TSP.menu_option, UIDROPDOWNMENU_MENU_LEVEL)
			info = {};
			info.text = TSP.menu_show_used;
			info.func = TitanPanelBagButton_ShowUsedSlots;
			info.checked = TitanGetVar(TSP.id, "ShowUsedSlots");
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

			info = {};
			info.text = TSP.menu_show_avail;
			info.func = TitanPanelBagButton_ShowAvailableSlots;
			info.checked = TitanUtils_Toggle(TitanGetVar(TSP.id, "ShowUsedSlots"));
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		end
		return -- so the menu does not create extra repeat buttons
	end
	
	-- level 1 menu
--	if "UIDROPDOWNMENU_MENU_LEVEL" == 1 then
		TitanPanelRightClickMenu_AddTitle(TitanPlugins[TSP.id].menuText);
		 
		info = {};
		info.text = TSP.menu_option
		info.value = "Options"
		info.hasArrow = 1;
		UIDropDownMenu_AddButton(info);

		TitanPanelRightClickMenu_AddSpacer();     
		-- SDK : "TitanPanelRightClickMenu_AddSpacer" is used to put a blank line in the menu
		TitanPanelRightClickMenu_AddToggleIcon(TSP.id);
		-- SDK : "TitanPanelRightClickMenu_AddToggleIcon" is used to put a "Show icon" (localized) in the menu.
		--        registry.savedVariables.ShowIcon
		TitanPanelRightClickMenu_AddToggleLabelText(TSP.id);
		-- SDK : "TitanPanelRightClickMenu_AddToggleLabelText" is used to put a "Show label text" (localized) in the menu.
		--        registry.savedVariables.ShowLabelText
		TitanPanelRightClickMenu_AddToggleColoredText(TSP.id);
		-- SDK : "TitanPanelRightClickMenu_AddToggleLabelText" is used to put a "Show colored text" (localized) in the menu.
		--        registry.savedVariables.ShowColoredText
		TitanPanelRightClickMenu_AddSpacer();     
		TitanPanelRightClickMenu_AddCommand(TSP.menu_hide, TSP.id, TITAN_PANEL_MENU_FUNC_HIDE);
		-- SDK : The routine above is used to put a "Hide" (localized) in the menu.
--	end

end

-- **************************************************************************
-- NAME : TitanPanelBagButton_ShowUsedSlots()
-- DESC : Set option to show used slots
-- **************************************************************************
function TitanPanelBagButton_ShowUsedSlots()
	TitanSetVar(TSP.id, "ShowUsedSlots", 1);
	TitanPanelButton_UpdateButton(TSP.id);
end

-- **************************************************************************
-- NAME : TitanPanelBagButton_ShowAvailableSlots()
-- DESC : Set option to show available slots
-- **************************************************************************
function TitanPanelBagButton_ShowAvailableSlots()
	TitanSetVar(TSP.id, "ShowUsedSlots", nil);
	TitanPanelButton_UpdateButton(TSP.id);
end

-- **************************************************************************
-- NAME : TitanStatPriority_GetButtonText(id)
-- DESC : Calculate bag space using what the user wants to see
-- VARS : 
-- **************************************************************************
function TSP.GetBagSlotInfo()
-- SDK : As specified in "registry"
--       Any button text to set or update goes here
	local totalSlots, usedSlots, availableSlots;

	totalSlots = 0;
	usedSlots = 0;
	for bag = 0, 4 do
		local size = GetContainerNumSlots(bag);
		if (size and size > 0) then
			totalSlots = totalSlots + size;
			for slot = 1, size do
				if (GetContainerItemInfo(bag, slot)) then
					usedSlots = usedSlots + 1;
				end
			end
		end
	end
	availableSlots = totalSlots - usedSlots;

	local bagText, bagRichText
	if (TitanGetVar(TSP.id, "ShowUsedSlots")) then
		bagText = format("%d/%d", usedSlots, totalSlots);
	else
		bagText = format("%d/%d", availableSlots, totalSlots);
	end
     
	if ( TitanGetVar(TSP.id, "ShowColoredText") ) then     
		bagRichText = TitanUtils_GetColoredText(bagText, NORMAL_FONT_COLOR);
	else
		bagRichText = TitanUtils_GetHighlightText(bagText);
	end

	return bagRichText
end
