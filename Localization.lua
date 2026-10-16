local ADDON_NAME = "ShiftFocusRemake"
local L = setmetatable({}, { __index = function(t, k)
    local v = tostring(k)
    rawset(t, k, v)
    return v
end })

-- English (default)
    L["SETTING_TITLE"] = "ShiftFocusRemake Settings"
    L["PARTY_ANNOUNCE_DESC"] = "Announce focus marker to party when entering dungeons"
    L["PARTY_ANNOUNCE_MSG"] = "I'll focus %s and interrupt"
    L["ENABLE_MARKING_DESC"] = "Set Raid Marker while focusing:"
    L["PREVENT_OVERWRITE_DESC"] = "Prevent overwriting existing markers (/tm ~1-8)"
    L["CAST_ALERT_DESC"] = "Play voice alert when focus starts casting"
    L["MODIFIER_KEY"] = "Modifier Key"
    L["MOUSE_BUTTON"] = "Mouse Button"
    L["LEFT_BUTTON"] = "Left Button"
    L["RIGHT_BUTTON"] = "Right Button"
    L["MIDDLE_BUTTON"] = "Middle Button"
    L["BUTTON_4"] = "Button 4"
    L["BUTTON_5"] = "Button 5"

    L["MARKER_1"] = "Star"
    L["MARKER_2"] = "Circle"
    L["MARKER_3"] = "Diamond"
    L["MARKER_4"] = "Triangle"
    L["MARKER_5"] = "Moon"
    L["MARKER_6"] = "Square"
    L["MARKER_7"] = "Cross"
    L["MARKER_8"] = "Skull"

-- 中文
if GetLocale() == "zhCN" then
    L["SETTING_TITLE"] = "ShiftFocusRemake 设置"
    L["PARTY_ANNOUNCE_DESC"] = "进入5人副本后在小队通告焦点标记"
    L["PARTY_ANNOUNCE_MSG"] = "我焦点%s并打断"
    L["ENABLE_MARKING_DESC"] = "设置焦点时同时标记："
    L["PREVENT_OVERWRITE_DESC"] = "防止覆盖已有标记 (/tm ~1-8)"
    L["CAST_ALERT_DESC"] = "启用焦点读条语音通知"
    L["MODIFIER_KEY"] = "修饰键"
    L["MOUSE_BUTTON"] = "鼠标按键"
    L["LEFT_BUTTON"] = "左键"
    L["RIGHT_BUTTON"] = "右键"
    L["MIDDLE_BUTTON"] = "中键"
    L["BUTTON_4"] = "侧4"
    L["BUTTON_5"] = "侧5"

    L["MARKER_1"] = "星星"
    L["MARKER_2"] = "大饼"
    L["MARKER_3"] = "菱形"
    L["MARKER_4"] = "三角"
    L["MARKER_5"] = "月亮"
    L["MARKER_6"] = "方块"
    L["MARKER_7"] = "十字"
    L["MARKER_8"] = "骷髅"
end

-- 繁體中文(台服用語)
if GetLocale() == "zhTW" then
    L["SETTING_TITLE"] = "ShiftFocusRemake 設定"
    L["PARTY_ANNOUNCE_DESC"] = "進入5人地城後在隊伍通告焦點標記"
    L["PARTY_ANNOUNCE_MSG"] = "我焦點%s並中斷"
    L["ENABLE_MARKING_DESC"] = "設定焦點時同時標記："
    L["PREVENT_OVERWRITE_DESC"] = "防止覆蓋已有標記 (/tm ~1-8)"
    L["CAST_ALERT_DESC"] = "啟用焦點施法語音通知"
    L["MODIFIER_KEY"] = "修飾鍵"
    L["MOUSE_BUTTON"] = "滑鼠按鍵"
    L["LEFT_BUTTON"] = "左鍵"
    L["RIGHT_BUTTON"] = "右鍵"
    L["MIDDLE_BUTTON"] = "中鍵"
    L["BUTTON_4"] = "側4"
    L["BUTTON_5"] = "側5"

    L["MARKER_1"] = "星星"
    L["MARKER_2"] = "圓圈"
    L["MARKER_3"] = "菱形"
    L["MARKER_4"] = "三角"
    L["MARKER_5"] = "月亮"
    L["MARKER_6"] = "方形"
    L["MARKER_7"] = "十字"
    L["MARKER_8"] = "骷髏"
end

ShiftFocusRemakeL = L
