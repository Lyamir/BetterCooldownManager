local _, BCDM = ...

local function SetBarValue(bar, value)
    local GeneralDB = BCDM.db.profile.General
    local smoothBars = GeneralDB.Animation and GeneralDB.Animation.SmoothBars
    if smoothBars and Enum and Enum.StatusBarInterpolation then
        bar:SetValue(value, Enum.StatusBarInterpolation.ExponentialEaseOut)
    else
        bar:SetValue(value)
    end
end

local function FetchCastBarColour()
    local CastBarDB = BCDM.db.profile.CastBar
    if CastBarDB.ColourByClass then
        local _, class = UnitClass("player")
        local colour = RAID_CLASS_COLORS[class]
        return colour.r, colour.g, colour.b, 1
    else
        return CastBarDB.ForegroundColour[1], CastBarDB.ForegroundColour[2], CastBarDB.ForegroundColour[3], CastBarDB.ForegroundColour[4]
    end
end

local function CreatePips(empoweredStages)
    if not BCDM.CastBar then return end

    for _, pip in ipairs(BCDM.CastBar.Pips) do pip:Hide() pip:SetParent(nil) end
    BCDM.CastBar.Pips = {}

    local totalWidth = BCDM.CastBar.Status:GetWidth()
    local cumulativePercentage = 0

    for i, stageProportion in ipairs(empoweredStages) do
        if i < #empoweredStages then
            cumulativePercentage = cumulativePercentage + stageProportion
            local empoweredPip = BCDM.CastBar.Status:CreateTexture(nil, "OVERLAY")
            empoweredPip:SetColorTexture(1, 1, 1, 1)
            local xPos = totalWidth * cumulativePercentage
            empoweredPip:SetSize(1, BCDM.CastBar.Status:GetHeight() - 2)
            empoweredPip:SetPoint("LEFT", BCDM.CastBar.Status, "LEFT", xPos, 0)
            table.insert(BCDM.CastBar.Pips, empoweredPip)
            empoweredPip:Show()
        end
    end
end

local function UpdateCastBarValues(self, event, unit)
    if not BCDM.CastBar then return end

    local EMPOWERED_CAST_START = {
        UNIT_SPELLCAST_EMPOWER_START = true,
    }

    local CAST_START = {
        UNIT_SPELLCAST_START = true,
        UNIT_SPELLCAST_INTERRUPTIBLE = true,
        UNIT_SPELLCAST_NOT_INTERRUPTIBLE = true,
        UNIT_SPELLCAST_SENT = true,
    }

    local CAST_STOP = {
        UNIT_SPELLCAST_STOP = true,
        UNIT_SPELLCAST_CHANNEL_STOP = true,
        UNIT_SPELLCAST_INTERRUPTED = true,
        UNIT_SPELLCAST_EMPOWER_STOP = true,
    }

    local CHANNEL_START = {
        UNIT_SPELLCAST_CHANNEL_START = true,
    }

    if CAST_START[event] then
        local castDuration = UnitCastingDuration("player")
        if not castDuration then return end
        BCDM.CastBar.Status:SetTimerDuration(castDuration, 0)
        BCDM.CastBar.SpellNameText:SetText(string.sub(UnitCastingInfo("player") or "", 1, BCDM.db.profile.CastBar.Text.SpellName.MaxCharacters))
        BCDM.CastBar.Icon:SetTexture(select(3, UnitCastingInfo("player")) or nil)
        BCDM.CastBar:SetScript("OnUpdate", function()
            local remainingDuration = castDuration:GetRemainingDuration()
            if remainingDuration < 5 then
                BCDM.CastBar.CastTimeText:SetText(string.format("%.1f", remainingDuration))
            else
                BCDM.CastBar.CastTimeText:SetText(string.format("%.0f", remainingDuration))
            end
            SetBarValue(BCDM.CastBar.Status, remainingDuration)
        end)
        BCDM.CastBar:Show()
    elseif EMPOWERED_CAST_START[event] then
		local isEmpowered = select(9, UnitChannelInfo("player"))
        local empoweredStages = UnitEmpoweredStagePercentages("player")
        if isEmpowered then
            local empowerCastDuration = UnitEmpoweredChannelDuration("player")
            CreatePips(empoweredStages)
            BCDM.CastBar.Status:SetTimerDuration(empowerCastDuration, 0)
            BCDM.CastBar.SpellNameText:SetText(string.sub(UnitChannelInfo("player"), 1, BCDM.db.profile.CastBar.Text.SpellName.MaxCharacters))
            BCDM.CastBar.Icon:SetTexture(select(3, UnitChannelInfo("player")) or nil)
            BCDM.CastBar:SetScript("OnUpdate", function()
                local remainingDuration = empowerCastDuration:GetRemainingDuration()
                if remainingDuration < 5 then
                    BCDM.CastBar.CastTimeText:SetText(string.format("%.1f", remainingDuration))
                else
                    BCDM.CastBar.CastTimeText:SetText(string.format("%.0f", remainingDuration))
                end
                SetBarValue(BCDM.CastBar.Status, remainingDuration)
            end)
            BCDM.CastBar:Show()
        end
    elseif CHANNEL_START[event] then
        local channelDuration = UnitChannelDuration("player")
        if not channelDuration then return end
        BCDM.CastBar.Status:SetTimerDuration(channelDuration, 0)
        BCDM.CastBar.Status:SetMinMaxValues(0, channelDuration:GetTotalDuration())
        BCDM.CastBar.SpellNameText:SetText(string.sub(UnitChannelInfo("player"), 1, BCDM.db.profile.CastBar.Text.SpellName.MaxCharacters))
        BCDM.CastBar.Icon:SetTexture(select(3, UnitChannelInfo("player")) or nil)
        BCDM.CastBar:SetScript("OnUpdate", function()
            local remainingDuration = channelDuration:GetRemainingDuration()
            SetBarValue(BCDM.CastBar.Status, remainingDuration)
            if remainingDuration < 5 then
                BCDM.CastBar.CastTimeText:SetText(string.format("%.1f", remainingDuration))
            else
                BCDM.CastBar.CastTimeText:SetText(string.format("%.0f", remainingDuration))
            end
        end)
        BCDM.CastBar:Show()
    elseif CAST_STOP[event] then
        BCDM.CastBar:Hide()
        BCDM.CastBar:SetScript("OnUpdate", nil)
        for _, pip in ipairs(BCDM.CastBar.Pips) do pip:Hide() pip:SetParent(nil) end
    end
end

local function SetHooks()
    hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function() if InCombatLockdown() then return end  BCDM:UpdateCastBarWidth() end)
    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function() if InCombatLockdown() then return end  BCDM:UpdateCastBarWidth() end)
end

local function DetectSecondaryPower()
    local class = select(2, UnitClass("player"))
    local spec  = GetSpecialization()
    local specID = GetSpecializationInfo(spec)
    if class == "MONK" then
        if specID == 268 then return true end
        if specID == 269 then return true end
    elseif class == "ROGUE" then
        return true
    elseif class == "DRUID" then
        local form = GetShapeshiftFormID()
        if form == 1 then return true end
    elseif class == "PALADIN" then
        return true
    elseif class == "WARLOCK" then
        return true
    elseif class == "MAGE" then
        if specID == 62 then return true end
    elseif class == "EVOKER" then
        return true
    elseif class == "DEATHKNIGHT" then
        return true
    elseif class == "DEMONHUNTER" then
        if specID == 1480 then return true end
    elseif class == "SHAMAN" then
        if specID == 263 then return true end
    end
    return false
end

function BCDM:CreateCastBar()
    local GeneralDB = BCDM.db.profile.General
    local CastBarDB = BCDM.db.profile.CastBar

    SetHooks()

    local CastBar = CreateFrame("Frame", "BCDM_CastBar", UIParent, "BackdropTemplate")
    local borderSize = BCDM.db.profile.CooldownManager.General.BorderSize

    CastBar.Pips = {}


    CastBar:SetBackdrop(BCDM.BACKDROP)
    if borderSize > 0 then
        CastBar:SetBackdropBorderColor(0, 0, 0, 1)
    else
        CastBar:SetBackdropBorderColor(0, 0, 0, 0)
    end
    CastBar:SetBackdropColor(CastBarDB.BackgroundColour[1], CastBarDB.BackgroundColour[2], CastBarDB.BackgroundColour[3], CastBarDB.BackgroundColour[4])
    CastBar:SetSize(CastBarDB.Width, CastBarDB.Height)
    local anchorKey = CastBarDB.Layout[2]
    -- If user selected the Secondary Power Bar but the class/spec doesn't provide it, fall back to the primary Power Bar
    if anchorKey == "BCDM_SecondaryPowerBar" and not DetectSecondaryPower() then anchorKey = "BCDM_PowerBar" end
    CastBar:SetPoint(CastBarDB.Layout[1], _G[anchorKey], CastBarDB.Layout[3], CastBarDB.Layout[4], CastBarDB.Layout[5])
    CastBar:SetFrameStrata(CastBarDB.FrameStrata or "LOW")

    if CastBarDB.MatchWidthOfAnchor then
        local anchorKey = CastBarDB.Layout[2]
        if anchorKey == "BCDM_SecondaryPowerBar" and not DetectSecondaryPower() then anchorKey = "BCDM_PowerBar" end
        local anchorFrame = _G[anchorKey]
        if anchorFrame then
            C_Timer.After(0.1, function() local anchorWidth = anchorFrame:GetWidth() CastBar:SetWidth(anchorWidth) end)
        end
    end

    CastBar.Icon = CastBar:CreateTexture(nil, "OVERLAY")
    CastBar.Icon:SetSize(CastBarDB.Height, CastBarDB.Height)
    local iconZoom = BCDM.db.profile.CooldownManager.General.IconZoom * 0.5
    CastBar.Icon:SetTexCoord(iconZoom, 1 - iconZoom, iconZoom, 1 - iconZoom)

    CastBar.Status = CreateFrame("StatusBar", nil, CastBar)
    CastBar.Status:SetStatusBarTexture(BCDM.Media.Foreground)
    CastBar.Status:SetStatusBarColor(FetchCastBarColour())
    CastBar.Status:SetMinMaxValues(0, UnitPowerMax("player"))
    CastBar.Status:SetValue(UnitPower("player"))

    if CastBarDB.Icon.Enabled == false then
        CastBar.Status:SetPoint("TOPLEFT", CastBar, "TOPLEFT", borderSize, -borderSize)
        CastBar.Status:SetPoint("BOTTOMRIGHT", CastBar, "BOTTOMRIGHT", -borderSize, borderSize)
    elseif CastBarDB.Icon.Layout == "LEFT" then
        CastBar.Icon:SetPoint("TOPLEFT", CastBar, "TOPLEFT", borderSize, -borderSize)
        CastBar.Icon:SetPoint("BOTTOMLEFT", CastBar, "BOTTOMLEFT", borderSize, borderSize)
        CastBar.Status:SetPoint("TOPLEFT", CastBar.Icon, "TOPRIGHT", 0, 0)
        CastBar.Status:SetPoint("BOTTOMRIGHT", CastBar, "BOTTOMRIGHT", -borderSize, borderSize)
    elseif CastBarDB.Icon.Layout == "RIGHT" then
        CastBar.Icon:SetPoint("TOPRIGHT", CastBar, "TOPRIGHT", -borderSize, -borderSize)
        CastBar.Icon:SetPoint("BOTTOMRIGHT", CastBar, "BOTTOMRIGHT", -borderSize, borderSize)
        CastBar.Status:SetPoint("TOPLEFT", CastBar, "TOPLEFT", borderSize, -borderSize)
        CastBar.Status:SetPoint("BOTTOMRIGHT", CastBar.Icon, "BOTTOMLEFT", 0, 0)
    end

    CastBar.SpellNameText = CastBar.Status:CreateFontString(nil, "OVERLAY")
    CastBar.SpellNameText:SetFont(BCDM.Media.Font, CastBarDB.Text.SpellName.FontSize, GeneralDB.Fonts.FontFlag)
    CastBar.SpellNameText:SetTextColor(CastBarDB.Text.SpellName.Colour[1], CastBarDB.Text.SpellName.Colour[2], CastBarDB.Text.SpellName.Colour[3], 1)
    CastBar.SpellNameText:SetPoint(CastBarDB.Text.SpellName.Layout[1], CastBar.Status, CastBarDB.Text.SpellName.Layout[2], CastBarDB.Text.SpellName.Layout[3], CastBarDB.Text.SpellName.Layout[4])
    if GeneralDB.Fonts.Shadow.Enabled then
        CastBar.SpellNameText:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
        CastBar.SpellNameText:SetShadowOffset(GeneralDB.Fonts.Shadow.OffsetX, GeneralDB.Fonts.Shadow.OffsetY)
    else
        CastBar.SpellNameText:SetShadowColor(0, 0, 0, 0)
        CastBar.SpellNameText:SetShadowOffset(0, 0)
    end
    CastBar.SpellNameText:SetText("")

    CastBar.CastTimeText = CastBar.Status:CreateFontString(nil, "OVERLAY")
    CastBar.CastTimeText:SetFont(BCDM.Media.Font, CastBarDB.Text.CastTime.FontSize, GeneralDB.Fonts.FontFlag)
    CastBar.CastTimeText:SetTextColor(CastBarDB.Text.CastTime.Colour[1], CastBarDB.Text.CastTime.Colour[2], CastBarDB.Text.CastTime.Colour[3], 1)
    CastBar.CastTimeText:SetPoint(CastBarDB.Text.CastTime.Layout[1], CastBar.Status, CastBarDB.Text.CastTime.Layout[2], CastBarDB.Text.CastTime.Layout[3], CastBarDB.Text.CastTime.Layout[4])
    if GeneralDB.Fonts.Shadow.Enabled then
        CastBar.CastTimeText:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
        CastBar.CastTimeText:SetShadowOffset(GeneralDB.Fonts.Shadow.OffsetX, GeneralDB.Fonts.Shadow.OffsetY)
    else
        CastBar.CastTimeText:SetShadowColor(0, 0, 0, 0)
        CastBar.CastTimeText:SetShadowOffset(0, 0)
    end
    CastBar.CastTimeText:SetText("")

    BCDM.CastBar = CastBar

    if CastBarDB.Enabled then
        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")

        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")

        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "player")
        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "player")

        CastBar:SetScript("OnEvent", UpdateCastBarValues)

        if CastBarDB.Icon.Enabled then CastBar.Icon:Show() else CastBar.Icon:Hide() end

        CastBar:Hide()
        PlayerCastingBarFrame:SetUnit(nil)
    else
        CastBar:Hide()
        CastBar:SetScript("OnEvent", nil)
        CastBar:UnregisterAllEvents()
    end
end

function BCDM:UpdateCastBar()
    local GeneralDB = BCDM.db.profile.General
    local CastBarDB = BCDM.db.profile.CastBar
    local CastBar = BCDM.CastBar
    local borderSize = BCDM.db.profile.CooldownManager.General.BorderSize
    if not CastBar then return end

    BCDM.CastBar:SetBackdropColor(CastBarDB.BackgroundColour[1], CastBarDB.BackgroundColour[2], CastBarDB.BackgroundColour[3], CastBarDB.BackgroundColour[4])
    BCDM.CastBar:SetSize(CastBarDB.Width, CastBarDB.Height)
    BCDM.CastBar:ClearAllPoints()
    local anchorKey = CastBarDB.Layout[2]
    if anchorKey == "BCDM_SecondaryPowerBar" and not DetectSecondaryPower() then anchorKey = "BCDM_PowerBar" end
    BCDM.CastBar:SetPoint(CastBarDB.Layout[1], _G[anchorKey], CastBarDB.Layout[3], CastBarDB.Layout[4], CastBarDB.Layout[5])
    BCDM.CastBar:SetFrameStrata(CastBarDB.FrameStrata or "LOW")
    CastBar:SetBackdrop(BCDM.BACKDROP)
    if borderSize > 0 then
        CastBar:SetBackdropBorderColor(0, 0, 0, 1)
    else
        CastBar:SetBackdropBorderColor(0, 0, 0, 0)
    end
    BCDM.CastBar:SetBackdropColor(CastBarDB.BackgroundColour[1], CastBarDB.BackgroundColour[2], CastBarDB.BackgroundColour[3], CastBarDB.BackgroundColour[4])

    BCDM.CastBar.Status:SetStatusBarColor(FetchCastBarColour())
    BCDM.CastBar.Status:SetStatusBarTexture(BCDM.Media.Foreground)

    if CastBarDB.MatchWidthOfAnchor then
        local anchorKey = CastBarDB.Layout[2]
        if anchorKey == "BCDM_SecondaryPowerBar" and not DetectSecondaryPower() then anchorKey = "BCDM_PowerBar" end
        local anchorFrame = _G[anchorKey]
        if anchorFrame then
            C_Timer.After(0.1, function() local anchorWidth = anchorFrame:GetWidth() CastBar:SetWidth(anchorWidth) end)
        end
    end

    CastBar.Icon:SetSize(CastBarDB.Height, CastBarDB.Height)
    local iconZoom = BCDM.db.profile.CooldownManager.General.IconZoom * 0.5
    CastBar.Icon:SetTexCoord(iconZoom, 1 - iconZoom, iconZoom, 1 - iconZoom)

    CastBar.Icon:ClearAllPoints()
    if CastBarDB.Icon.Enabled == false then
        CastBar.Status:SetPoint("TOPLEFT", CastBar, "TOPLEFT", borderSize, -borderSize)
        CastBar.Status:SetPoint("BOTTOMRIGHT", CastBar, "BOTTOMRIGHT", -borderSize, borderSize)
    elseif CastBarDB.Icon.Layout == "LEFT" then
        CastBar.Icon:SetPoint("TOPLEFT", CastBar, "TOPLEFT", borderSize, -borderSize)
        CastBar.Icon:SetPoint("BOTTOMLEFT", CastBar, "BOTTOMLEFT", borderSize, borderSize)
        CastBar.Status:SetPoint("TOPLEFT", CastBar.Icon, "TOPRIGHT", 0, 0)
        CastBar.Status:SetPoint("BOTTOMRIGHT", CastBar, "BOTTOMRIGHT", -borderSize, borderSize)
    elseif CastBarDB.Icon.Layout == "RIGHT" then
        CastBar.Icon:SetPoint("TOPRIGHT", CastBar, "TOPRIGHT", -borderSize, -borderSize)
        CastBar.Icon:SetPoint("BOTTOMRIGHT", CastBar, "BOTTOMRIGHT", -borderSize, borderSize)
        CastBar.Status:SetPoint("TOPLEFT", CastBar, "TOPLEFT", borderSize, -borderSize)
        CastBar.Status:SetPoint("BOTTOMRIGHT", CastBar.Icon, "BOTTOMLEFT", 0, 0)
    end

    CastBar.SpellNameText:SetFont(BCDM.Media.Font, CastBarDB.Text.SpellName.FontSize, BCDM.db.profile.General.Fonts.FontFlag)
    CastBar.SpellNameText:SetTextColor(CastBarDB.Text.SpellName.Colour[1], CastBarDB.Text.SpellName.Colour[2], CastBarDB.Text.SpellName.Colour[3], 1)
    CastBar.SpellNameText:ClearAllPoints()
    CastBar.SpellNameText:SetPoint(CastBarDB.Text.SpellName.Layout[1], CastBar.Status, CastBarDB.Text.SpellName.Layout[2], CastBarDB.Text.SpellName.Layout[3], CastBarDB.Text.SpellName.Layout[4])
    if GeneralDB.Fonts.Shadow.Enabled then
        CastBar.SpellNameText:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
        CastBar.SpellNameText:SetShadowOffset(GeneralDB.Fonts.Shadow.OffsetX, GeneralDB.Fonts.Shadow.OffsetY)
    else
        CastBar.SpellNameText:SetShadowColor(0, 0, 0, 0)
        CastBar.SpellNameText:SetShadowOffset(0, 0)
    end

    CastBar.CastTimeText:SetFont(BCDM.Media.Font, CastBarDB.Text.CastTime.FontSize, BCDM.db.profile.General.Fonts.FontFlag)
    CastBar.CastTimeText:SetTextColor(CastBarDB.Text.CastTime.Colour[1], CastBarDB.Text.CastTime.Colour[2], CastBarDB.Text.CastTime.Colour[3], 1)
    CastBar.CastTimeText:ClearAllPoints()
    CastBar.CastTimeText:SetPoint(CastBarDB.Text.CastTime.Layout[1], CastBar.Status, CastBarDB.Text.CastTime.Layout[2], CastBarDB.Text.CastTime.Layout[3], CastBarDB.Text.CastTime.Layout[4])
    if GeneralDB.Fonts.Shadow.Enabled then
        CastBar.CastTimeText:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
        CastBar.CastTimeText:SetShadowOffset(GeneralDB.Fonts.Shadow.OffsetX, GeneralDB.Fonts.Shadow.OffsetY)
    else
        CastBar.CastTimeText:SetShadowColor(0, 0, 0, 0)
        CastBar.CastTimeText:SetShadowOffset(0, 0)
    end

    if CastBarDB.Enabled then
        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")

        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")

        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "player")
        CastBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "player")

        CastBar:SetScript("OnEvent", UpdateCastBarValues)

        if CastBarDB.Icon.Enabled then CastBar.Icon:Show() else CastBar.Icon:Hide() end

        CastBar:Hide()

        PlayerCastingBarFrame:SetUnit(nil)
    else
        CastBar:Hide()
        CastBar:SetScript("OnEvent", nil)
        CastBar:UnregisterAllEvents()
    end
    if BCDM.CAST_BAR_TEST_MODE then BCDM:CreateTestCastBar() end
end

function BCDM:CreateTestCastBar()
    local CastBarDB = BCDM.db.profile.CastBar
    local borderSize = BCDM.db.profile.CooldownManager.General.BorderSize
    if not BCDM.CastBar then return end
    if BCDM.CAST_BAR_TEST_MODE then
        BCDM.CastBar:SetFrameStrata(CastBarDB.FrameStrata or "LOW")
        BCDM.CastBar.SpellNameText:SetText(string.sub("Ethereal Portal", 1, BCDM.db.profile.CastBar.Text.SpellName.MaxCharacters))
        BCDM.CastBar.Icon:SetTexture("Interface\\Icons\\ability_mage_netherwindpresence")
        BCDM.CastBar.Status:SetMinMaxValues(0, 10)
        BCDM.CastBar.Status:SetValue(5)
        BCDM.CastBar.CastTimeText:SetText("5.0")
        BCDM.CastBar.Icon:ClearAllPoints()
        if CastBarDB.Icon.Enabled == false then
            BCDM.CastBar.Status:SetPoint("TOPLEFT", BCDM.CastBar, "TOPLEFT", borderSize, -borderSize)
            BCDM.CastBar.Status:SetPoint("BOTTOMRIGHT", BCDM.CastBar, "BOTTOMRIGHT", -borderSize, borderSize)
        elseif CastBarDB.Icon.Layout == "LEFT" then
            BCDM.CastBar.Icon:SetPoint("TOPLEFT", BCDM.CastBar, "TOPLEFT", borderSize, -borderSize)
            BCDM.CastBar.Icon:SetPoint("BOTTOMLEFT", BCDM.CastBar, "BOTTOMLEFT", borderSize, borderSize)
            BCDM.CastBar.Status:SetPoint("TOPLEFT", BCDM.CastBar.Icon, "TOPRIGHT", 0, 0)
            BCDM.CastBar.Status:SetPoint("BOTTOMRIGHT", BCDM.CastBar, "BOTTOMRIGHT", -borderSize, borderSize)
        elseif CastBarDB.Icon.Layout == "RIGHT" then
            BCDM.CastBar.Icon:SetPoint("TOPRIGHT", BCDM.CastBar, "TOPRIGHT", -borderSize, -borderSize)
            BCDM.CastBar.Icon:SetPoint("BOTTOMRIGHT", BCDM.CastBar, "BOTTOMRIGHT", -borderSize, borderSize)
            BCDM.CastBar.Status:SetPoint("TOPLEFT", BCDM.CastBar, "TOPLEFT", borderSize, -borderSize)
            BCDM.CastBar.Status:SetPoint("BOTTOMRIGHT", BCDM.CastBar.Icon, "BOTTOMLEFT", 0, 0)
        end
        if CastBarDB.Enabled then BCDM.CastBar:Show() else BCDM.CastBar:Hide() end
    else
        BCDM.CastBar:Hide()
    end
end

function BCDM:UpdateCastBarWidth()
    local CastBarDB = BCDM.db.profile.CastBar
    local CastBar = BCDM.CastBar
    if CastBarDB.Enabled and CastBarDB.MatchWidthOfAnchor then
        local anchorKey = CastBarDB.Layout[2]
        if anchorKey == "BCDM_SecondaryPowerBar" and not DetectSecondaryPower() then anchorKey = "BCDM_PowerBar" end
        local anchorFrame = _G[anchorKey]
        if anchorFrame then
            C_Timer.After(0.5, function() local anchorWidth = anchorFrame:GetWidth() CastBar:SetWidth(anchorWidth) end)
        end
    end
end

-- Watch for class/spec/form changes and re-anchor the cast bar when secondary power availability changes.
do
    local anchorWatcher = CreateFrame("Frame")
    local pendingReanchor = false
    anchorWatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    anchorWatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    anchorWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    anchorWatcher:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
    anchorWatcher:SetScript("OnEvent", function(self, event, ...)
        -- If we're in combat, delay any re-anchoring until we're out of combat
        if InCombatLockdown() then
            if not pendingReanchor then
                pendingReanchor = true
                self:RegisterEvent("PLAYER_REGEN_ENABLED")
            end
            return
        end

        if event == "PLAYER_REGEN_ENABLED" then
            pendingReanchor = false
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end

        if BCDM and BCDM.UpdateCastBar then
            BCDM:UpdateCastBar()
        end
    end)
end