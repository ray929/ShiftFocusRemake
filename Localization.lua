local ADDON_NAME = "ShiftFocus"
local L = setmetatable({}, { __index = function(t, k)
    local v = tostring(k)
    rawset(t, k, v)
    return v
end })

-- English
    L["SETTING_TITLE"] = "ShiftFocus Settings"
    L["CLEAR_FOCUS_DESC"] = "Allow clearing focus by clicking empty space"
    L["ENABLE_MARKING_DESC"] = "Set Raid Marker while focusing:"
    L["PREVENT_OVERWRITE_DESC"] = "Prevent overwriting existing markers (/tm ~1-8)"
    L["MODIFIER_KEY"] = "Modifier Key"
    L["MOUSE_BUTTON"] = "Mouse Button"
    L["LEFT_BUTTON"] = "Left Button"
    L["RIGHT_BUTTON"] = "Right Button"
    L["MIDDLE_BUTTON"] = "Middle Button"
    L["BUTTON_4"] = "Button 4"
    L["BUTTON_5"] = "Button 5"

    L["MARKER_0"] = "None"
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
    L["SETTING_TITLE"] = "ShiftFocus 设置"
    L["CLEAR_FOCUS_DESC"] = "允许点击空白清除焦点"
    L["ENABLE_MARKING_DESC"] = "设置焦点时同时标记："
    L["PREVENT_OVERWRITE_DESC"] = "防止覆盖已有标记 (/tm ~1-8)"
    L["MODIFIER_KEY"] = "修饰键"
    L["MOUSE_BUTTON"] = "鼠标按键"
    L["LEFT_BUTTON"] = "左键"
    L["RIGHT_BUTTON"] = "右键"
    L["MIDDLE_BUTTON"] = "中键"
    L["BUTTON_4"] = "侧4"
    L["BUTTON_5"] = "侧5"
    
    L["MARKER_0"] = "无"
    L["MARKER_1"] = "星星"
    L["MARKER_2"] = "大饼"
    L["MARKER_3"] = "菱形"
    L["MARKER_4"] = "三角"
    L["MARKER_5"] = "月亮"
    L["MARKER_6"] = "方块"
    L["MARKER_7"] = "十字"
    L["MARKER_8"] = "骷髅"
end

ShiftFocusL = L