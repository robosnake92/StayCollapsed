sc_collapsedCategories = {};

local frame = CreateFrame("FRAME", "");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("VARIABLES_LOADED");
frame:RegisterEvent("TRADE_SKILL_SHOW");
frame:RegisterEvent("TRADE_SKILL_CLOSE");
frame:RegisterEvent("TRADE_SKILL_DATA_SOURCE_CHANGED");
frame:RegisterEvent("TRADE_SKILL_DATA_SOURCE_CHANGING");

local button = CreateFrame("Button", "StayCollapsedButton", UIParent, "SecureActionButtonTemplate");
local normal = button:CreateTexture()
local pushed = button:CreateTexture()
local highlight = button:CreateTexture()

isCollapsed = true;
isTradeWindowOpen = false;

local function setButtonTexture()
	local normalTexture = "Interface/Buttons/UI-PlusButton-Up";
	local pushedTexture = "Interface/Buttons/UI-PlusButton-Down";
	local highlightTexture = "Interface/Buttons/UI-PlusButton-Hilight";

	if (isCollapsed) then
		normalTexture = "Interface/Buttons/UI-MinusButton-Up";
		pushedTexture = "Interface/Buttons/UI-MinusButton-Down";
	end

	normal:SetTexture(normalTexture)
	normal:SetAllPoints()	
	button:SetNormalTexture(normal)

	highlight:SetTexture(highlightTexture)
	highlight:SetAllPoints()
	button:SetHighlightTexture(highlight)

	pushed:SetTexture(pushedTexture)
	pushed:SetAllPoints()
	button:SetPushedTexture(pushed)
end

local function expandCollapse()
	for _, category in pairs({C_TradeSkillUI.GetCategories()}) do
		TradeSkillFrame.RecipeList:SetCategoryCollapsed(category, isCollapsed);
	end
	isCollapsed = not isCollapsed;
	setButtonTexture();
end

local function restore()
	if (sc_collapsedCategories ~= nil) then
		for cat,wasPreviouslyCollapsed in pairs(sc_collapsedCategories) do
			if (cat ~= nil) then
				TradeSkillFrame.RecipeList:SetCategoryCollapsed(cat, wasPreviouslyCollapsed);
			end
		end
	end
	isTradeWindowOpen = true;
end

local function eventHandler(self, event, ...)
	if (event == "VARIABLES_LOADED") then
		sc_collapsedCategories = sc_collapsedCategories;
	end

	if (event == "TRADE_SKILL_DATA_SOURCE_CHANGED" and isTradeWindowOpen) then
		--this sucks, might not work everytime
		C_Timer.After(.1, restore);
	end

	if (event == "TRADE_SKILL_DATA_SOURCE_CHANGING") then
		if (TradeSkillFrame ~= nil) then
			for _, category in pairs({C_TradeSkillUI.GetCategories()}) do
				sc_collapsedCategories[tonumber(category)] = TradeSkillFrame.RecipeList:IsCategoryCollapsed(category)
			end
		end		
	end

	if (event == "TRADE_SKILL_SHOW") then	
		if (TradeSkillFrame ~= nil) then
			button:SetParent(TradeSkillFrame.DetailsFrame.ExitButton)
			button:SetSize(20, 20) --Width, Height
			button:SetPoint("TOPLEFT", TradeSkillFrame.RecipeList.UnlearnedTab, "TOPLEFT", 86, -13)
			button:SetText(buttonText);
			button:SetNormalFontObject("GameFontNormal")

			setButtonTexture();

			--this sucks, might not work everytime
			C_Timer.After(.1, restore);
		end
	end

	if (event == "TRADE_SKILL_CLOSE") then
		if (TradeSkillFrame ~= nil) then
			for _, category in pairs({C_TradeSkillUI.GetCategories()}) do
				sc_collapsedCategories[tonumber(category)] = TradeSkillFrame.RecipeList:IsCategoryCollapsed(category)
			end
		end		
		isTradeWindowOpen = false;
	end
end

SLASH_STAYCOLLAPSED1 = "/sc";
function SlashCmdList.STAYCOLLAPSED(msg)
	if (isTradeWindowOpen) then
		restore();
	end
end

frame:SetScript("OnEvent", eventHandler);
button:SetScript("OnClick", expandCollapse);