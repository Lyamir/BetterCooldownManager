local _, BCDM = ...

BCDM.LSM = LibStub("LibSharedMedia-3.0")
BCDM.InfoButton = "|A:glueannouncementpopup-icon-info:16:16|a "

BCDM.AddOnName = C_AddOns.GetAddOnMetadata("BetterCooldownManager", "Title")

BCDM.Icon = "Interface\\AddOns\\BetterCooldownManager\\Media\\Logo.png"

BCDM.CooldownViewerToDB = {
    ["EssentialCooldownViewer"] = "Essential",
    ["UtilityCooldownViewer"] = "Utility",
    ["BuffIconCooldownViewer"] = "Buffs",
}

function BCDM:Print(MSG)
    print(BCDM.AddOnName..": "..MSG)
end

local function PixelPerfect(value)
    if not value then return 0 end
    local _, screenHeight = GetPhysicalScreenSize()
    local uiScale = UIParent:GetEffectiveScale()
    local pixelSize = 768 / screenHeight / uiScale
    return pixelSize * math.floor(value / pixelSize + 0.5333)
end

function BCDM:AddPixelBorder(frame)
    if not frame then return end

    local borderSize = 1
    local borderColour = { r = 0, g = 0, b = 0 }

    frame._borderSegments = frame._borderSegments or {}

    local borderAnchor = frame.Icon or frame
    local borderInset = PixelPerfect(-1)

    if #frame._borderSegments == 0 then
        local function CreateLine() return frame:CreateTexture(nil, "OVERLAY") end
        local topBorder = CreateLine()
        topBorder:SetPoint("TOPLEFT", borderAnchor, "TOPLEFT", PixelPerfect(borderInset), PixelPerfect(-borderInset))
        topBorder:SetPoint("TOPRIGHT", borderAnchor, "TOPRIGHT", PixelPerfect(-borderInset), PixelPerfect(-borderInset))

        local bottomBorder = CreateLine()
        bottomBorder:SetPoint("BOTTOMLEFT", borderAnchor, "BOTTOMLEFT", PixelPerfect(borderInset), PixelPerfect(borderInset))
        bottomBorder:SetPoint("BOTTOMRIGHT", borderAnchor, "BOTTOMRIGHT", PixelPerfect(-borderInset), PixelPerfect(borderInset))

        local leftBorder = CreateLine()
        leftBorder:SetPoint("TOPLEFT", borderAnchor, "TOPLEFT", PixelPerfect(borderInset), PixelPerfect(-borderInset))
        leftBorder:SetPoint("BOTTOMLEFT", borderAnchor, "BOTTOMLEFT", PixelPerfect(borderInset), PixelPerfect(borderInset))

        local rightBorder = CreateLine()
        rightBorder:SetPoint("TOPRIGHT", borderAnchor, "TOPRIGHT", PixelPerfect(-borderInset), PixelPerfect(-borderInset))
        rightBorder:SetPoint("BOTTOMRIGHT", borderAnchor, "BOTTOMRIGHT", PixelPerfect(-borderInset), PixelPerfect(borderInset))

        frame._borderSegments = { topBorder, bottomBorder, leftBorder, rightBorder }
    end

    local top, bottom, left, right = unpack(frame._borderSegments)

    if top and bottom and left and right then
        top:SetHeight(PixelPerfect(borderSize))
        bottom:SetHeight(PixelPerfect(borderSize))
        left:SetWidth(PixelPerfect(borderSize))
        right:SetWidth(PixelPerfect(borderSize))
        for _, line in ipairs(frame._borderSegments) do
            line:SetColorTexture(borderColour.r, borderColour.g, borderColour.b, 1)
            line:SetShown(borderSize > 0)
        end
    end
end

function BCDM:SetupSlashCommands()
    SLASH_BCDM1 = "/bcdm"
    SlashCmdList["BCDM"] = function(msg)
        if msg == "" or msg == "gui" or msg == "options" then BCDM:CreateGUI() end
    end
    BCDM:Print("'|cFF8080FF/bcdm|r' for in-game configuration.")
end

function BCDM:ResolveMedia()
    local LSM = BCDM.LSM
    local GeneralDB = BCDM.db.global.General
    BCDM.Media = BCDM.Media or {}
    BCDM.Media.Font = LSM:Fetch("font", GeneralDB.Font) or STANDARD_TEXT_FONT
end