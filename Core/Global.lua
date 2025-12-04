local _, BCDM = ...

BCDM.AddOnName = C_AddOns.GetAddOnMetadata("BetterCooldownManager", "Title")

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