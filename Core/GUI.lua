local _, BCDM = ...
local AG = LibStub("AceGUI-3.0")
local OpenedGUI = false
local GUIFrame = nil

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

local function DrawCooldownSettings(parentContainer, cooldownViewer)
    local CooldownManagerDB = BCDM.db.global
    local CooldownViewerDB = CooldownManagerDB[BCDM.CooldownViewerToDB[cooldownViewer]]

    local ScrollFrame = AG:Create("ScrollFrame")
    ScrollFrame:SetLayout("Flow")
    ScrollFrame:SetFullWidth(true)
    ScrollFrame:SetFullHeight(true)
    parentContainer:AddChild(ScrollFrame)

    local IconSize = AG:Create("Slider")
    IconSize:SetLabel("Icon Size")
    IconSize:SetValue(CooldownViewerDB.IconSize)
    IconSize:SetSliderValues(16, 128, 1)
    IconSize:SetFullWidth(true)
    IconSize:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.IconSize = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    ScrollFrame:AddChild(IconSize)

    local ChargesContainer = AG:Create("InlineGroup")
    ChargesContainer:SetTitle("Charges Settings")
    ChargesContainer:SetFullWidth(true)
    ChargesContainer:SetLayout("Flow")
    ScrollFrame:AddChild(ChargesContainer)

    local AnchorFrom = AG:Create("Dropdown")
    AnchorFrom:SetLabel("Anchor From")
    AnchorFrom:SetList(Anchors[1], Anchors[2])
    AnchorFrom:SetValue(CooldownViewerDB.Count.Anchors[1])
    AnchorFrom:SetRelativeWidth(0.5)
    AnchorFrom:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Count.Anchors[1] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    ChargesContainer:AddChild(AnchorFrom)

    local AnchorTo = AG:Create("Dropdown")
    AnchorTo:SetLabel("Anchor To")
    AnchorTo:SetList(Anchors[1], Anchors[2])
    AnchorTo:SetValue(CooldownViewerDB.Count.Anchors[2])
    AnchorTo:SetRelativeWidth(0.5)
    AnchorTo:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Count.Anchors[2] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    ChargesContainer:AddChild(AnchorTo)

    local OffsetX = AG:Create("Slider")
    OffsetX:SetLabel("Offset X")
    OffsetX:SetValue(CooldownViewerDB.Count.Anchors[3])
    OffsetX:SetSliderValues(-200, 200, 1)
    OffsetX:SetRelativeWidth(0.33)
    OffsetX:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Count.Anchors[3] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    ChargesContainer:AddChild(OffsetX)

    local OffsetY = AG:Create("Slider")
    OffsetY:SetLabel("Offset Y")
    OffsetY:SetValue(CooldownViewerDB.Count.Anchors[4])
    OffsetY:SetSliderValues(-200, 200, 1)
    OffsetY:SetRelativeWidth(0.33)
    OffsetY:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Count.Anchors[4] = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    ChargesContainer:AddChild(OffsetY)

    local FontSize = AG:Create("Slider")
    FontSize:SetLabel("Font Size")
    FontSize:SetValue(CooldownViewerDB.Count.FontSize)
    FontSize:SetSliderValues(8, 40, 1)
    FontSize:SetRelativeWidth(0.33)
    FontSize:SetCallback("OnValueChanged", function(_, _, value) CooldownViewerDB.Count.FontSize = value BCDM:UpdateCooldownViewer(cooldownViewer) end)
    ChargesContainer:AddChild(FontSize)

end

function BCDM:CreateGUI()
    if OpenedGUI then return end
    if InCombatLockdown() then return end

    OpenedGUI = true
    GUIFrame = AG:Create("Frame")
    GUIFrame:SetTitle(BCDM.AddOnName)
    GUIFrame:SetLayout("Fill")
    GUIFrame:SetWidth(900)
    GUIFrame:SetHeight(600)
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