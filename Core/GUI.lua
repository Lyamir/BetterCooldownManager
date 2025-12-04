local _, BCDM = ...
local AG = LibStub("AceGUI-3.0")
local OpenedGUI = false
local GUIFrame = nil
local LSM = BCDM.LSM

local Anchors = {
    {
        ["TOPLEFT"] = "Top Left",
        ["TOP"] = "Top",
        ["TOPRIGHT"] = "Top Right",
        ["LEFT"] = "Left",
        ["CENTER"] = "Center",
        ["RIGHT"] = "Right",
        ["BOTTOMLEFT"] = "Bottom Left",
        ["BOTTOM"] = "Bottom",
        ["BOTTOMRIGHT"] = "Bottom Right",
    },
    { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT" }
}

local function CreateInfoTag(Description)
    local InfoDesc = AG:Create("Label")
    InfoDesc:SetText(BCDM.InfoButton .. Description)
    InfoDesc:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    InfoDesc:SetFullWidth(true)
    InfoDesc:SetJustifyH("CENTER")
    InfoDesc:SetHeight(24)
    InfoDesc:SetJustifyV("MIDDLE")
    return InfoDesc
end

local function DrawGeneralSettings(parentContainer)
    local CooldownManagerDB = BCDM.db.global
    local GeneralDB = CooldownManagerDB.General

    local ScrollFrame = AG:Create("ScrollFrame")
    ScrollFrame:SetLayout("Flow")
    ScrollFrame:SetFullWidth(true)
    ScrollFrame:SetFullHeight(true)
    parentContainer:AddChild(ScrollFrame)

    local OpenEditModeButton = AG:Create("Button")
    OpenEditModeButton:SetText("Toggle Edit Mode")
    OpenEditModeButton:SetRelativeWidth(0.5)
    OpenEditModeButton:SetCallback("OnClick", function() if EditModeManagerFrame:IsShown() then EditModeManagerFrame:Hide() else EditModeManagerFrame:Show() end end)
    ScrollFrame:AddChild(OpenEditModeButton)

    local OpenCDMSettingsButton = AG:Create("Button")
    OpenCDMSettingsButton:SetText("Advanced Settings")
    OpenCDMSettingsButton:SetRelativeWidth(0.5)
    OpenCDMSettingsButton:SetCallback("OnClick", function() if CooldownViewerSettings:IsShown() then CooldownViewerSettings:Hide() else CooldownViewerSettings:Show() end end)
    ScrollFrame:AddChild(OpenCDMSettingsButton)

    local CooldownManagerFontDropdown = AG:Create("LSM30_Font")
    CooldownManagerFontDropdown:SetLabel("Font")
    CooldownManagerFontDropdown:SetList(LSM:HashTable("font"))
    CooldownManagerFontDropdown:SetValue(GeneralDB.Font)
    CooldownManagerFontDropdown:SetCallback("OnValueChanged", function(widget, _, value) widget:SetValue(value) GeneralDB.Font = value BCDM:RefreshAllViewers() end)
    CooldownManagerFontDropdown:SetRelativeWidth(0.33)
    ScrollFrame:AddChild(CooldownManagerFontDropdown)

    local CooldownManagerFontFlagDropdown = AG:Create("Dropdown")
    CooldownManagerFontFlagDropdown:SetLabel("Font Flag")
    CooldownManagerFontFlagDropdown:SetList({
        ["NONE"] = "None",
        ["OUTLINE"] = "Outline",
        ["THICKOUTLINE"] = "Thick Outline",
        ["MONOCHROME"] = "Monochrome",
    })
    CooldownManagerFontFlagDropdown:SetValue(GeneralDB.FontFlag)
    CooldownManagerFontFlagDropdown:SetCallback("OnValueChanged", function(_, _, value) GeneralDB.FontFlag = value BCDM:RefreshAllViewers() end)
    CooldownManagerFontFlagDropdown:SetRelativeWidth(0.33)
    ScrollFrame:AddChild(CooldownManagerFontFlagDropdown)

    local CooldownManagerIconZoomSlider = AG:Create("Slider")
    CooldownManagerIconZoomSlider:SetLabel("Icon Zoom")
    CooldownManagerIconZoomSlider:SetValue(GeneralDB.IconZoom)
    CooldownManagerIconZoomSlider:SetSliderValues(0, 1, 0.01)
    CooldownManagerIconZoomSlider:SetIsPercent(true)
    CooldownManagerIconZoomSlider:SetCallback("OnMouseUp", function(_, _, value) GeneralDB.IconZoom = value BCDM:RefreshAllViewers() end)
    CooldownManagerIconZoomSlider:SetRelativeWidth(0.33)
    ScrollFrame:AddChild(CooldownManagerIconZoomSlider)

    local CooldownTextContainer = AG:Create("InlineGroup")
    CooldownTextContainer:SetTitle("Cooldown Text Settings")
    CooldownTextContainer:SetFullWidth(true)
    CooldownTextContainer:SetLayout("Flow")
    ScrollFrame:AddChild(CooldownTextContainer)

    local CooldownText_AnchorFrom = AG:Create("Dropdown")
    CooldownText_AnchorFrom:SetLabel("Anchor From")
    CooldownText_AnchorFrom:SetList(Anchors[1], Anchors[2])
    CooldownText_AnchorFrom:SetValue(GeneralDB.CooldownText.Anchors[1])
    CooldownText_AnchorFrom:SetRelativeWidth(0.33)
    CooldownText_AnchorFrom:SetCallback("OnValueChanged", function(_, _, value) GeneralDB.CooldownText.Anchors[1] = value BCDM:RefreshAllViewers() end)
    CooldownTextContainer:AddChild(CooldownText_AnchorFrom)

    local CooldownText_AnchorTo = AG:Create("Dropdown")
    CooldownText_AnchorTo:SetLabel("Anchor To")
    CooldownText_AnchorTo:SetList(Anchors[1], Anchors[2])
    CooldownText_AnchorTo:SetValue(GeneralDB.CooldownText.Anchors[2])
    CooldownText_AnchorTo:SetRelativeWidth(0.33)
    CooldownText_AnchorTo:SetCallback("OnValueChanged", function(_, _, value) GeneralDB.CooldownText.Anchors[2] = value BCDM:RefreshAllViewers() end)
    CooldownTextContainer:AddChild(CooldownText_AnchorTo)

    local CooldownText_Colour = AG:Create("ColorPicker")
    CooldownText_Colour:SetLabel("Font Colour")
    CooldownText_Colour:SetColor(unpack(GeneralDB.CooldownText.Colour))
    CooldownText_Colour:SetRelativeWidth(0.33)
    CooldownText_Colour:SetCallback("OnValueChanged", function(_, _, r, g, b) GeneralDB.CooldownText.Colour = {r, g, b} BCDM:RefreshAllViewers() end)
    CooldownTextContainer:AddChild(CooldownText_Colour)

    local CooldownText_OffsetX = AG:Create("Slider")
    CooldownText_OffsetX:SetLabel("Offset X")
    CooldownText_OffsetX:SetValue(GeneralDB.CooldownText.Anchors[3])
    CooldownText_OffsetX:SetSliderValues(-200, 200, 1)
    CooldownText_OffsetX:SetRelativeWidth(0.33)
    CooldownText_OffsetX:SetCallback("OnValueChanged", function(_, _, value) GeneralDB.CooldownText.Anchors[3] = value BCDM:RefreshAllViewers() end)
    CooldownTextContainer:AddChild(CooldownText_OffsetX)

    local CooldownText_OffsetY = AG:Create("Slider")
    CooldownText_OffsetY:SetLabel("Offset Y")
    CooldownText_OffsetY:SetValue(GeneralDB.CooldownText.Anchors[4])
    CooldownText_OffsetY:SetSliderValues(-200, 200, 1)
    CooldownText_OffsetY:SetRelativeWidth(0.33)
    CooldownText_OffsetY:SetCallback("OnValueChanged", function(_, _, value) GeneralDB.CooldownText.Anchors[4] = value BCDM:RefreshAllViewers() end)
    CooldownTextContainer:AddChild(CooldownText_OffsetY)

    local CooldownText_FontSize = AG:Create("Slider")
    CooldownText_FontSize:SetLabel("Font Size")
    CooldownText_FontSize:SetValue(GeneralDB.CooldownText.FontSize)
    CooldownText_FontSize:SetSliderValues(8, 40, 1)
    CooldownText_FontSize:SetRelativeWidth(0.33)
    CooldownText_FontSize:SetCallback("OnValueChanged", function(_, _, value) GeneralDB.CooldownText.FontSize = value BCDM:RefreshAllViewers() end)
    CooldownTextContainer:AddChild(CooldownText_FontSize)

    return ScrollFrame
end

local function DrawCooldownSettings(parentContainer, cooldownViewer)
    local CooldownManagerDB = BCDM.db.global
    local CooldownViewerDB = CooldownManagerDB[BCDM.CooldownViewerToDB[cooldownViewer]]
    local isEssential = (cooldownViewer == "EssentialCooldownViewer")

    local ScrollFrame = AG:Create("ScrollFrame")
    ScrollFrame:SetLayout("Flow")
    ScrollFrame:SetFullWidth(true)
    ScrollFrame:SetFullHeight(true)
    parentContainer:AddChild(ScrollFrame)

    local LayoutContainer = AG:Create("InlineGroup")
    LayoutContainer:SetTitle("Layout Settings")
    LayoutContainer:SetFullWidth(true)
    LayoutContainer:SetLayout("Flow")
    ScrollFrame:AddChild(LayoutContainer)

    local Viewer_AnchorFrom = AG:Create("Dropdown")
    Viewer_AnchorFrom:SetLabel("Anchor From")
    Viewer_AnchorFrom:SetList(Anchors[1], Anchors[2])
    Viewer_AnchorFrom:SetValue(CooldownViewerDB.Anchors[1])
    Viewer_AnchorFrom:SetRelativeWidth(isEssential and 0.5 or 0.33)
    Viewer_AnchorFrom:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Anchors[1] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    LayoutContainer:AddChild(Viewer_AnchorFrom)

    if not isEssential then
        local Viewer_AnchorParent = AG:Create("EditBox")
        Viewer_AnchorParent:SetLabel("Anchor Parent Frame")
        Viewer_AnchorParent:SetText(CooldownViewerDB.Anchors[2])
        Viewer_AnchorParent:SetRelativeWidth(0.33)
        Viewer_AnchorParent:SetCallback("OnEnterPressed", function(_, _, value) CooldownViewerDB.Anchors[2] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
        LayoutContainer:AddChild(Viewer_AnchorParent)
    end

    local Viewer_AnchorTo = AG:Create("Dropdown")
    Viewer_AnchorTo:SetLabel("Anchor To")
    Viewer_AnchorTo:SetList(Anchors[1], Anchors[2])
    Viewer_AnchorTo:SetValue(CooldownViewerDB.Anchors[3])
    Viewer_AnchorTo:SetRelativeWidth(isEssential and 0.5 or 0.33)
    Viewer_AnchorTo:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Anchors[3] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    LayoutContainer:AddChild(Viewer_AnchorTo)

    local Viewer_OffsetX = AG:Create("Slider")
    Viewer_OffsetX:SetLabel("Offset X")
    Viewer_OffsetX:SetValue(CooldownViewerDB.Anchors[4])
    Viewer_OffsetX:SetSliderValues(-2000, 2000, 1)
    Viewer_OffsetX:SetRelativeWidth(0.33)
    Viewer_OffsetX:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Anchors[4] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    LayoutContainer:AddChild(Viewer_OffsetX)

    local Viewer_OffsetY = AG:Create("Slider")
    Viewer_OffsetY:SetLabel("Offset Y")
    Viewer_OffsetY:SetValue(CooldownViewerDB.Anchors[5])
    Viewer_OffsetY:SetSliderValues(-2000, 2000, 1)
    Viewer_OffsetY:SetRelativeWidth(0.33)
    Viewer_OffsetY:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Anchors[5] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    LayoutContainer:AddChild(Viewer_OffsetY)

    local Viewer_IconSize = AG:Create("Slider")
    Viewer_IconSize:SetLabel("Icon Size")
    Viewer_IconSize:SetValue(CooldownViewerDB.IconSize)
    Viewer_IconSize:SetSliderValues(16, 128, 1)
    Viewer_IconSize:SetRelativeWidth(0.33)
    Viewer_IconSize:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.IconSize = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    LayoutContainer:AddChild(Viewer_IconSize)

    local ChargesContainer = AG:Create("InlineGroup")
    ChargesContainer:SetTitle("Charges Settings")
    ChargesContainer:SetFullWidth(true)
    ChargesContainer:SetLayout("Flow")
    ScrollFrame:AddChild(ChargesContainer)

    local Charges_AnchorFrom = AG:Create("Dropdown")
    Charges_AnchorFrom:SetLabel("Anchor From")
    Charges_AnchorFrom:SetList(Anchors[1], Anchors[2])
    Charges_AnchorFrom:SetValue(CooldownViewerDB.Count.Anchors[1])
    Charges_AnchorFrom:SetRelativeWidth(0.33)
    Charges_AnchorFrom:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Count.Anchors[1] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    ChargesContainer:AddChild(Charges_AnchorFrom)

    local Charges_AnchorTo = AG:Create("Dropdown")
    Charges_AnchorTo:SetLabel("Anchor To")
    Charges_AnchorTo:SetList(Anchors[1], Anchors[2])
    Charges_AnchorTo:SetValue(CooldownViewerDB.Count.Anchors[2])
    Charges_AnchorTo:SetRelativeWidth(0.33)
    Charges_AnchorTo:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Count.Anchors[2] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    ChargesContainer:AddChild(Charges_AnchorTo)

    local Charges_Colour = AG:Create("ColorPicker")
    Charges_Colour:SetLabel("Font Colour")
    Charges_Colour:SetColor(unpack(CooldownViewerDB.Count.Colour))
    Charges_Colour:SetRelativeWidth(0.33)
    Charges_Colour:SetCallback("OnValueChanged", function(_, _, r, g, b) CooldownViewerDB.Count.Colour = {r, g, b} BCDM:UpdateCooldownViewer(cooldownViewer) end)
    ChargesContainer:AddChild(Charges_Colour)

    local Charges_OffsetX = AG:Create("Slider")
    Charges_OffsetX:SetLabel("Offset X")
    Charges_OffsetX:SetValue(CooldownViewerDB.Count.Anchors[3])
    Charges_OffsetX:SetSliderValues(-200, 200, 1)
    Charges_OffsetX:SetRelativeWidth(0.33)
    Charges_OffsetX:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Count.Anchors[3] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    ChargesContainer:AddChild(Charges_OffsetX)

    local Charges_OffsetY = AG:Create("Slider")
    Charges_OffsetY:SetLabel("Offset Y")
    Charges_OffsetY:SetValue(CooldownViewerDB.Count.Anchors[4])
    Charges_OffsetY:SetSliderValues(-200, 200, 1)
    Charges_OffsetY:SetRelativeWidth(0.33)
    Charges_OffsetY:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Count.Anchors[4] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    ChargesContainer:AddChild(Charges_OffsetY)

    local Charges_FontSize = AG:Create("Slider")
    Charges_FontSize:SetLabel("Font Size")
    Charges_FontSize:SetValue(CooldownViewerDB.Count.FontSize)
    Charges_FontSize:SetSliderValues(8, 40, 1)
    Charges_FontSize:SetRelativeWidth(0.33)
    Charges_FontSize:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Count.FontSize = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    ChargesContainer:AddChild(Charges_FontSize)

    return ScrollFrame
end

function BCDM:CreateGUI()
    if OpenedGUI then return end
    if InCombatLockdown() then return end

    OpenedGUI = true
    GUIFrame = AG:Create("Frame")
    GUIFrame:SetTitle("|T" .. BCDM.Icon .. ":16:16|t " .. BCDM.AddOnName)
    GUIFrame:SetLayout("Fill")
    GUIFrame:SetWidth(700)
    GUIFrame:SetHeight(400)
    GUIFrame:EnableResize(true)
    GUIFrame:SetCallback("OnClose", function(widget) AG:Release(widget) OpenedGUI = false BCDM:RefreshAllViewers() end)

    local function SelectedGroup(GUIContainer, _, MainGroup)
        GUIContainer:ReleaseChildren()

        local Wrapper = AG:Create("SimpleGroup")
        Wrapper:SetFullWidth(true)
        Wrapper:SetFullHeight(true)
        Wrapper:SetLayout("Fill")
        GUIContainer:AddChild(Wrapper)

        if MainGroup == "General" then
            DrawGeneralSettings(Wrapper)
        elseif MainGroup == "Essential" then
            DrawCooldownSettings(Wrapper, "EssentialCooldownViewer")
        elseif MainGroup == "Utility" then
            DrawCooldownSettings(Wrapper, "UtilityCooldownViewer")
        elseif MainGroup == "Buffs" then
            DrawCooldownSettings(Wrapper, "BuffIconCooldownViewer")
        end
    end

    local GUIContainerTabGroup = AG:Create("TabGroup")
    GUIContainerTabGroup:SetLayout("Flow")
    GUIContainerTabGroup:SetTabs({
        { text = "General", value = "General"},
        { text = "Essential", value = "Essential"},
        { text = "Utility", value = "Utility"},
        { text = "Buffs", value = "Buffs"},
    })
    GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
    GUIContainerTabGroup:SelectTab("General")
    GUIFrame:AddChild(GUIContainerTabGroup)
end