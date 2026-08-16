--============================================================================
--  ShiftFocus
--  为暴雪原生框架、UUF、DandersFrames、Enhance Qol、EllesmereUI 及姓名版
--  添加鼠标指向设置焦点与快速标记功能。
--  作者：誓小言
--============================================================================

local ADDON_NAME = "ShiftFocus"
local L = ShiftFocusL

-------------------------------------------------------------------------------
--  配置管理
-------------------------------------------------------------------------------
local function InitializeDB()
    if not ShiftFocusDB then ShiftFocusDB = {} end
    local defaults = {
        allowClearFocus   = false,
        modifier          = "shift",
        mouseButton       = "1",
        selectedMarker    = 0,
        enableMarking     = false,
        preventOverwrite  = false,
    }
    for k, v in pairs(defaults) do
        if ShiftFocusDB[k] == nil then
            ShiftFocusDB[k] = v
        end
    end
end
InitializeDB()

local function GetConfig()
    return ShiftFocusDB.modifier, ShiftFocusDB.mouseButton
end

-------------------------------------------------------------------------------
--  标记图标与映射
-------------------------------------------------------------------------------
local nameToIndex = {
    [L["MARKER_0"]] = 0, [L["MARKER_1"]] = 1, [L["MARKER_2"]] = 2, [L["MARKER_3"]] = 3,
    [L["MARKER_4"]] = 4, [L["MARKER_5"]] = 5, [L["MARKER_6"]] = 6, [L["MARKER_7"]] = 7,
    [L["MARKER_8"]] = 8,
}

local markerTextures = {
    [1] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16|t",
    [2] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:16|t",
    [3] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:16|t",
    [4] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:16|t",
    [5] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:16|t",
    [6] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:16|t",
    [7] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:16|t",
    [8] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:16|t",
    [0] = "|TInterface\\Buttons\\UI-GroupLoot-Pass-Up:16|t",
}

local optionsOrder = {
    L["MARKER_0"], L["MARKER_1"], L["MARKER_2"], L["MARKER_3"], L["MARKER_4"],
    L["MARKER_5"], L["MARKER_6"], L["MARKER_7"], L["MARKER_8"],
}

-------------------------------------------------------------------------------
--  宏命令生成
-------------------------------------------------------------------------------
local function GetFocusMacro()
    local markmacro = ""
    if ShiftFocusDB.enableMarking and ShiftFocusDB.selectedMarker and ShiftFocusDB.selectedMarker > 0 then
        local prevent = ShiftFocusDB.preventOverwrite and "~" or ""
        markmacro = "\n/tm [@mouseover]" .. prevent .. ShiftFocusDB.selectedMarker
    end

    local macro = ""
    if ShiftFocusDB.allowClearFocus then
        macro = "/clearfocus [@mouseover,noexists]\n"
    end
    macro = macro .. "/focus [@mouseover,exists]" .. markmacro

    return macro
end

-------------------------------------------------------------------------------
--  快捷键绑定
-------------------------------------------------------------------------------
local function SetFocusHotkey(frame, macroText)
    if not frame or not frame.SetAttribute or InCombatLockdown() then return end

    local mod, btn = GetConfig()
    local attrType = mod .. "-type" .. btn
    local attrMacro = mod .. "-macrotext" .. btn
    macroText = macroText or GetFocusMacro()

    pcall(function()
        frame:SetAttribute(attrType, "macro")
        frame:SetAttribute(attrMacro, macroText)
    end)
end

-------------------------------------------------------------------------------
--  鼠标指向
-------------------------------------------------------------------------------
local function InitMouseoverFocus(macroText)
    if not ShiftFocuserButton then
        ShiftFocuserButton = CreateFrame("CheckButton", "ShiftFocuserButton", UIParent, "SecureActionButtonTemplate")
        ShiftFocuserButton:RegisterForClicks("AnyDown", "AnyUp")
        ShiftFocuserButton:SetAttribute("type", "macro")
    end

    if ShiftFocuserButton then
        ClearOverrideBindings(ShiftFocuserButton)
        local mod, btn = GetConfig()
        ShiftFocuserButton:SetAttribute("macrotext1", macroText or GetFocusMacro())

        if not InCombatLockdown() then
            SetOverrideBindingClick(ShiftFocuserButton, true, mod .. "-BUTTON" .. btn, "ShiftFocuserButton")
        end
    end
end

-------------------------------------------------------------------------------
--  框架名称列表
-------------------------------------------------------------------------------
local BLIZZARD_FRAMES = {
    "PlayerFrame", "PetFrame", "TargetFrame", "TargetFrameToT", "FocusFrame",
    "PartyMemberFrame1", "PartyMemberFrame2", "PartyMemberFrame3",
    "PartyMemberFrame4", "PartyMemberFrame5",
    "Boss1TargetFrame", "Boss2TargetFrame", "Boss3TargetFrame",
    "Boss4TargetFrame", "Boss5TargetFrame",
}

local UUF_FRAMES = {
    "UUF_Player", "UUF_Pet", "UUF_Target", "UUF_TargetTarget",
    "UUF_Focus", "UUF_FocusTarget",
    "UUF_Boss1", "UUF_Boss2", "UUF_Boss3", "UUF_Boss4", "UUF_Boss5",
    "UUF_Boss6", "UUF_Boss7", "UUF_Boss8", "UUF_Boss9", "UUF_Boss10",
}

local EQOL_FRAMES = {
    "EQOLUFPlayerFrame", "EQOLUFTargetFrame", "EQOLUFToTFrame",
    "EQOLUFFocusFrame",
    "EQOLUFBoss1Frame", "EQOLUFBoss2Frame", "EQOLUFBoss3Frame",
    "EQOLUFBoss4Frame", "EQOLUFBoss5Frame",
}

local EUI_UNIT_FRAMES = {
    "EllesmereUIUnitFrames_Player", "EllesmereUIUnitFrames_Target",
    "EllesmereUIUnitFrames_Focus", "EllesmereUIUnitFrames_Pet",
    "EllesmereUIUnitFrames_TargetTarget", "EllesmereUIUnitFrames_FocusTarget",
    "EllesmereUIUnitFrames_Boss1", "EllesmereUIUnitFrames_Boss2",
    "EllesmereUIUnitFrames_Boss3", "EllesmereUIUnitFrames_Boss4",
    "EllesmereUIUnitFrames_Boss5",
}

-------------------------------------------------------------------------------
--  主初始化：遍历所有支持的框架
-------------------------------------------------------------------------------
local function InitAll()
    if InCombatLockdown() then return end
    local macroText = GetFocusMacro()
    local function apply(frame)
        if frame then SetFocusHotkey(frame, macroText) end
    end

    -- 暴雪原生框架
    for _, name in ipairs(BLIZZARD_FRAMES) do apply(_G[name]) end

    -- UUF (UnhaltedUnitFrames)
    for _, name in ipairs(UUF_FRAMES) do apply(_G[name]) end

    -- Enhance Qol
    for _, name in ipairs(EQOL_FRAMES) do apply(_G[name]) end

    -- EllesmereUI UnitFrames
    for _, name in ipairs(EUI_UNIT_FRAMES) do apply(_G[name]) end

    -- DandersFrames
    local DF = _G["DandersFrames"]
    if DF then
        apply(DF.playerFrame)
        if DF.partyFrames then
            for i = 1, 4 do apply(DF.partyFrames[i]) end
        end
        if DF.raidFrames then
            for i = 1, 40 do apply(DF.raidFrames[i]) end
        end
    end

    -- 姓名版
    for _, plate in pairs(C_NamePlate.GetNamePlates()) do apply(plate) end

    -- EllesmereUI Raid Frames（分离模式）
    for group = 1, 8 do
        local hdr = _G["ERFGroupHeader" .. group]
        if hdr then
            for i = 1, 5 do apply(hdr[i]) end
        end
    end



    InitMouseoverFocus(macroText)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:SetScript("OnEvent", function(_, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate and not InCombatLockdown() then
            SetFocusHotkey(plate)
        end
    elseif not InCombatLockdown() then
        C_Timer.After(2, InitAll)
    end
end)

-------------------------------------------------------------------------------
--  设置面板
-------------------------------------------------------------------------------
local panel = CreateFrame("Frame", "ShiftFocusOptionsPanel", UIParent)
panel.name = "ShiftFocus"

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(L["SETTING_TITLE"])

local clearFocusCheck = CreateFrame("CheckButton", "ShiftFocusClearFocusCheckbox", panel, "InterfaceOptionsCheckButtonTemplate")
clearFocusCheck:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -15)
clearFocusCheck.Text:SetText(L["CLEAR_FOCUS_DESC"])
clearFocusCheck:SetScript("OnClick", function(self)
    ShiftFocusDB.allowClearFocus = self:GetChecked()
    InitAll()
end)

local markCheck = CreateFrame("CheckButton", "ShiftFocusEnableMarkingCheckbox", panel, "InterfaceOptionsCheckButtonTemplate")
markCheck:SetPoint("TOPLEFT", clearFocusCheck, "BOTTOMLEFT", 0, -10)
markCheck.Text:SetText(L["ENABLE_MARKING_DESC"])
markCheck:SetScript("OnClick", function(self)
    ShiftFocusDB.enableMarking = self:GetChecked()
    InitAll()
end)

local preventOverwriteCheck = CreateFrame("CheckButton", "ShiftFocusPreventOverwriteCheckbox", panel, "InterfaceOptionsCheckButtonTemplate")
preventOverwriteCheck:SetPoint("TOPLEFT", markCheck, "BOTTOMLEFT", 0, -10)
preventOverwriteCheck.Text:SetText(L["PREVENT_OVERWRITE_DESC"] or "防止覆盖已有标记 (/tm ~1-8)")
preventOverwriteCheck:SetScript("OnClick", function(self)
    ShiftFocusDB.preventOverwrite = self:GetChecked()
    InitAll()
end)

local markerDropdown = CreateFrame("Frame", "ShiftFocusMarkerDropdown", panel, "UIDropDownMenuTemplate")
markerDropdown:SetPoint("LEFT", markCheck.Text, "RIGHT", -5, -2)
UIDropDownMenu_SetWidth(markerDropdown, 100)
UIDropDownMenu_Initialize(markerDropdown, function()
    for _, name in ipairs(optionsOrder) do
        local info = UIDropDownMenu_CreateInfo()
        local idx = nameToIndex[name]
        info.text = (markerTextures[idx] or "") .. " " .. name
        info.func = function()
            ShiftFocusDB.selectedMarker = idx
            UIDropDownMenu_SetText(markerDropdown, info.text)
            InitAll()
        end
        UIDropDownMenu_AddButton(info)
    end
end)

local modLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
modLabel:SetPoint("TOPLEFT", preventOverwriteCheck, "BOTTOMLEFT", 5, -25)
modLabel:SetText(L["MODIFIER_KEY"])

local btnLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
btnLabel:SetPoint("LEFT", modLabel, "RIGHT", 105, 0)
btnLabel:SetText(L["MOUSE_BUTTON"])

local modDropdown = CreateFrame("Frame", "ShiftFocusModDropdown", panel, "UIDropDownMenuTemplate")
modDropdown:SetPoint("TOPLEFT", modLabel, "BOTTOMLEFT", -15, -5)
UIDropDownMenu_SetWidth(modDropdown, 100)
UIDropDownMenu_Initialize(modDropdown, function()
    for _, mod in ipairs({ "shift", "alt", "ctrl" }) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = mod
        info.func = function()
            ShiftFocusDB.modifier = mod
            UIDropDownMenu_SetText(modDropdown, mod)
            InitAll()
        end
        UIDropDownMenu_AddButton(info)
    end
end)

local btnDropdown = CreateFrame("Frame", "ShiftFocusBtnDropdown", panel, "UIDropDownMenuTemplate")
btnDropdown:SetPoint("LEFT", modDropdown, "RIGHT", -10, 0)
UIDropDownMenu_SetWidth(btnDropdown, 100)
local buttons = {
    { text = L["LEFT_BUTTON"],   v = "1" },
    { text = L["RIGHT_BUTTON"],  v = "2" },
    { text = L["MIDDLE_BUTTON"], v = "3" },
    { text = L["BUTTON_4"],      v = "4" },
    { text = L["BUTTON_5"],      v = "5" },
}
UIDropDownMenu_Initialize(btnDropdown, function()
    for _, btn in ipairs(buttons) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = btn.text
        info.func = function()
            ShiftFocusDB.mouseButton = btn.v
            UIDropDownMenu_SetText(btnDropdown, btn.text)
            InitAll()
        end
        UIDropDownMenu_AddButton(info)
    end
end)

panel:SetScript("OnShow", function()
    clearFocusCheck:SetChecked(ShiftFocusDB.allowClearFocus)
    markCheck:SetChecked(ShiftFocusDB.enableMarking)
    preventOverwriteCheck:SetChecked(ShiftFocusDB.preventOverwrite)
    UIDropDownMenu_SetText(modDropdown, ShiftFocusDB.modifier)

    local curIdx = ShiftFocusDB.selectedMarker or 0
    local curName = L["MARKER_0"]
    for n, i in pairs(nameToIndex) do
        if i == curIdx then curName = n end
    end
    UIDropDownMenu_SetText(markerDropdown, (markerTextures[curIdx] or "") .. " " .. curName)

    local btnT = L["LEFT_BUTTON"]
    for _, b in ipairs(buttons) do
        if b.v == ShiftFocusDB.mouseButton then btnT = b.text end
    end
    UIDropDownMenu_SetText(btnDropdown, btnT)
end)

local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
Settings.RegisterAddOnCategory(category)