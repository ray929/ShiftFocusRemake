--============================================================================
--  ShiftFocusRemake
--  为暴雪原生框架、UUF、DandersFrames、Enhance Qol、EllesmereUI 及姓名版
--  添加鼠标指向设置焦点与快速标记功能。
--  原作者：誓小言 | Remake：ray929
--============================================================================

local ADDON_NAME = "ShiftFocusRemake"
local L = ShiftFocusRemakeL

-------------------------------------------------------------------------------
--  配置管理
-------------------------------------------------------------------------------
local function InitializeDB()
    -- 从原版 ShiftFocus 迁移设置(仅当原插件同时安装时其变量才会被加载)
    if type(ShiftFocusDB) == "table" and next(ShiftFocusRemakeDB or {}) == nil then
        ShiftFocusRemakeDB = {}
        for k, v in pairs(ShiftFocusDB) do
            ShiftFocusRemakeDB[k] = v
        end
    end
    if not ShiftFocusRemakeDB then ShiftFocusRemakeDB = {} end
    ShiftFocusRemakeDB.allowClearFocus = nil      -- 旧选项已移除:清焦点恒定生效
    ShiftFocusRemakeDB.announcedInstanceID = nil  -- 旧去重字段已移除:改为内存级去重
    local defaults = {
        modifier          = "shift",
        mouseButton       = "1",
        selectedMarker    = 1,          -- 默认星星
        enableMarking     = false,
        preventOverwrite  = false,
        partyAnnounce     = true,
    }
    for k, v in pairs(defaults) do
        if ShiftFocusRemakeDB[k] == nil then
            ShiftFocusRemakeDB[k] = v
        end
    end
end
InitializeDB()

local function GetConfig()
    return ShiftFocusRemakeDB.modifier, ShiftFocusRemakeDB.mouseButton
end

-------------------------------------------------------------------------------
--  标记图标与映射
-------------------------------------------------------------------------------
local nameToIndex = {
    [L["MARKER_1"]] = 1, [L["MARKER_2"]] = 2, [L["MARKER_3"]] = 3,
    [L["MARKER_4"]] = 4, [L["MARKER_5"]] = 5, [L["MARKER_6"]] = 6,
    [L["MARKER_7"]] = 7, [L["MARKER_8"]] = 8,
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
}

local optionsOrder = {
    L["MARKER_1"], L["MARKER_2"], L["MARKER_3"], L["MARKER_4"],
    L["MARKER_5"], L["MARKER_6"], L["MARKER_7"], L["MARKER_8"],
}

-- 聊天标记符号:使用 {rt1}~{rt8},中英文客户端均会渲染为图标
local markerChatTokens = {
    [1] = "{rt1}", [2] = "{rt2}", [3] = "{rt3}", [4] = "{rt4}",
    [5] = "{rt5}", [6] = "{rt6}", [7] = "{rt7}", [8] = "{rt8}",
}

-------------------------------------------------------------------------------
--  宏命令生成
-------------------------------------------------------------------------------
local function IsInPartyDungeon()
    local _, instanceType = IsInInstance()
    return instanceType == "party"
end

local function GetFocusMacro()
    local markmacro = ""
    -- 团队标记仅在5人本(含追随者模式)生效,避免野外/团本误标
    if IsInPartyDungeon() and ShiftFocusRemakeDB.enableMarking and ShiftFocusRemakeDB.selectedMarker and ShiftFocusRemakeDB.selectedMarker > 0 then
        local prevent = ShiftFocusRemakeDB.preventOverwrite and "~" or ""
        markmacro = "\n/tm [@mouseover]" .. prevent .. ShiftFocusRemakeDB.selectedMarker
    end

    -- 清除焦点恒定生效:鼠标下无单位时先清焦
    return "/clearfocus [@mouseover,noexists]\n/focus [@mouseover,exists]" .. markmacro
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
-- 12.x 起 SetOverrideBindingClick 必须显式传入 mouseClick 参数,
-- 否则合成点击静默失效;同时属性查找需要与按键号匹配的 macrotext
local BUTTON_NAMES = {
    ["1"] = "LeftButton",
    ["2"] = "RightButton",
    ["3"] = "MiddleButton",
    ["4"] = "Button4",
    ["5"] = "Button5",
}

local function InitMouseoverFocus(macroText)
    if not ShiftFocusRemakeButton then
        ShiftFocusRemakeButton = CreateFrame("CheckButton", "ShiftFocusRemakeButton", UIParent, "SecureActionButtonTemplate")
        ShiftFocusRemakeButton:RegisterForClicks("AnyDown", "AnyUp")
        ShiftFocusRemakeButton:SetAttribute("type", "macro")
    end

    if ShiftFocusRemakeButton and not InCombatLockdown() then
        macroText = macroText or GetFocusMacro()
        local mod, btn = GetConfig()
        local btnName = BUTTON_NAMES[btn] or "LeftButton"

        -- 无后缀兜底 + 数字/按键名两种后缀变体,任意鼠标按键均能命中
        ShiftFocusRemakeButton:SetAttribute("macrotext", macroText)
        ShiftFocusRemakeButton:SetAttribute("macrotext" .. btn, macroText)
        ShiftFocusRemakeButton:SetAttribute("macrotext" .. btnName, macroText)

        ClearOverrideBindings(ShiftFocusRemakeButton)
        SetOverrideBindingClick(ShiftFocusRemakeButton, true, mod .. "-BUTTON" .. btn,
            "ShiftFocusRemakeButton", btnName)
    end
end

-------------------------------------------------------------------------------
--  框架名称列表
-------------------------------------------------------------------------------
local BLIZZARD_FRAMES = {
    "PlayerFrame", "PetFrame", "TargetFrame", "TargetFrameToT", "FocusFrame",
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

    -- 暴雪原生框架（不含小队/团队框架，避免与暴雪点击施法冲突）
    for _, name in ipairs(BLIZZARD_FRAMES) do apply(_G[name]) end

    -- UUF (UnhaltedUnitFrames)（不含小队/团队框架）
    for _, name in ipairs(UUF_FRAMES) do apply(_G[name]) end

    -- Enhance Qol（不含小队/团队框架）
    for _, name in ipairs(EQOL_FRAMES) do apply(_G[name]) end

    -- EllesmereUI UnitFrames（不含小队/团队框架）
    for _, name in ipairs(EUI_UNIT_FRAMES) do apply(_G[name]) end

    -- DandersFrames: 仅玩家/Boss 框体，不含小队/团队
    local DF = _G["DandersFrames"]
    if DF then
        apply(DF.playerFrame)
        if DF.bossFrames then
            for _, f in ipairs(DF.bossFrames) do apply(f) end
        end
    end

    -- 姓名版
    for _, plate in pairs(C_NamePlate.GetNamePlates()) do apply(plate) end

    InitMouseoverFocus(macroText)
end

-------------------------------------------------------------------------------
--  小队通告:进入5人本后提示焦点标记
-------------------------------------------------------------------------------
-- 内存级去重:重载界面且仍在同一地图时不重复喊
local lastAnnouncedMapID

local function DoAnnounce()
    local token = markerChatTokens[ShiftFocusRemakeDB.selectedMarker]
    if token then
        local msg = string.format(L["PARTY_ANNOUNCE_MSG"], token)
        SendChatMessage(msg, "PARTY")
    end
end

local function AnnounceMarker(isReload)
    local marker = ShiftFocusRemakeDB.selectedMarker or 0
    if not ShiftFocusRemakeDB.partyAnnounce then return end
    if not (ShiftFocusRemakeDB.enableMarking and marker and marker > 0) then return end
    if not IsInPartyDungeon() then return end

    -- 重载界面仍在同一地图时不重复喊
    local mapID = C_Map.GetBestMapForUnit("player")
    if isReload and lastAnnouncedMapID == mapID then return end
    lastAnnouncedMapID = mapID

    C_Timer.After(2, DoAnnounce)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local plate = C_NamePlate.GetNamePlateForUnit(arg1)
        if plate and not InCombatLockdown() then
            SetFocusHotkey(plate)
        end
    else
        -- PLAYER_ENTERING_WORLD: arg1=isInitialLogin, arg2=isReloadUI
        if event == "PLAYER_ENTERING_WORLD" then
            AnnounceMarker(arg2)
        end
        if not InCombatLockdown() then
            C_Timer.After(2, InitAll)
        end
    end
end)

-------------------------------------------------------------------------------
--  设置面板
-------------------------------------------------------------------------------
local panel = CreateFrame("Frame", "ShiftFocusRemakeOptionsPanel", UIParent)
panel.name = "ShiftFocusRemake"

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(L["SETTING_TITLE"])

local partyAnnounceCheck = CreateFrame("CheckButton", "ShiftFocusRemakePartyAnnounceCheckbox", panel, "InterfaceOptionsCheckButtonTemplate")
partyAnnounceCheck:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -15)
partyAnnounceCheck.Text:SetText(L["PARTY_ANNOUNCE_DESC"])
partyAnnounceCheck:SetScript("OnClick", function(self)
    ShiftFocusRemakeDB.partyAnnounce = self:GetChecked()
end)

local markCheck = CreateFrame("CheckButton", "ShiftFocusRemakeEnableMarkingCheckbox", panel, "InterfaceOptionsCheckButtonTemplate")
markCheck:SetPoint("TOPLEFT", partyAnnounceCheck, "BOTTOMLEFT", 0, -10)
markCheck.Text:SetText(L["ENABLE_MARKING_DESC"])
markCheck:SetScript("OnClick", function(self)
    ShiftFocusRemakeDB.enableMarking = self:GetChecked()
    InitAll()
end)

local preventOverwriteCheck = CreateFrame("CheckButton", "ShiftFocusRemakePreventOverwriteCheckbox", panel, "InterfaceOptionsCheckButtonTemplate")
preventOverwriteCheck:SetPoint("TOPLEFT", markCheck, "BOTTOMLEFT", 0, -10)
preventOverwriteCheck.Text:SetText(L["PREVENT_OVERWRITE_DESC"] or "防止覆盖已有标记 (/tm ~1-8)")
preventOverwriteCheck:SetScript("OnClick", function(self)
    ShiftFocusRemakeDB.preventOverwrite = self:GetChecked()
    InitAll()
end)

local markerDropdown = CreateFrame("Frame", "ShiftFocusRemakeMarkerDropdown", panel, "UIDropDownMenuTemplate")
markerDropdown:SetPoint("LEFT", markCheck.Text, "RIGHT", -5, -2)
UIDropDownMenu_SetWidth(markerDropdown, 100)
UIDropDownMenu_Initialize(markerDropdown, function()
    for _, name in ipairs(optionsOrder) do
        local info = UIDropDownMenu_CreateInfo()
        local idx = nameToIndex[name]
        info.text = (markerTextures[idx] or "") .. " " .. name
        info.func = function()
            ShiftFocusRemakeDB.selectedMarker = idx
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

local modDropdown = CreateFrame("Frame", "ShiftFocusRemakeModDropdown", panel, "UIDropDownMenuTemplate")
modDropdown:SetPoint("TOPLEFT", modLabel, "BOTTOMLEFT", -15, -5)
UIDropDownMenu_SetWidth(modDropdown, 100)
UIDropDownMenu_Initialize(modDropdown, function()
    for _, mod in ipairs({ "shift", "alt", "ctrl" }) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = mod
        info.func = function()
            ShiftFocusRemakeDB.modifier = mod
            UIDropDownMenu_SetText(modDropdown, mod)
            InitAll()
        end
        UIDropDownMenu_AddButton(info)
    end
end)

local btnDropdown = CreateFrame("Frame", "ShiftFocusRemakeBtnDropdown", panel, "UIDropDownMenuTemplate")
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
            ShiftFocusRemakeDB.mouseButton = btn.v
            UIDropDownMenu_SetText(btnDropdown, btn.text)
            InitAll()
        end
        UIDropDownMenu_AddButton(info)
    end
end)

panel:SetScript("OnShow", function()
    partyAnnounceCheck:SetChecked(ShiftFocusRemakeDB.partyAnnounce)
    markCheck:SetChecked(ShiftFocusRemakeDB.enableMarking)
    preventOverwriteCheck:SetChecked(ShiftFocusRemakeDB.preventOverwrite)
    UIDropDownMenu_SetText(modDropdown, ShiftFocusRemakeDB.modifier)

    local curIdx = ShiftFocusRemakeDB.selectedMarker or 1
    local curName = L["MARKER_1"]
    for n, i in pairs(nameToIndex) do
        if i == curIdx then curName = n end
    end
    UIDropDownMenu_SetText(markerDropdown, (markerTextures[curIdx] or "") .. " " .. curName)

    local btnT = L["LEFT_BUTTON"]
    for _, b in ipairs(buttons) do
        if b.v == ShiftFocusRemakeDB.mouseButton then btnT = b.text end
    end
    UIDropDownMenu_SetText(btnDropdown, btnT)
end)

local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
Settings.RegisterAddOnCategory(category)
