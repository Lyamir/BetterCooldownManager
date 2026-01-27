local _, BCDM = ...
local BetterCooldownManager = LibStub("AceAddon-3.0"):NewAddon("BetterCooldownManager")

function BetterCooldownManager:OnInitialize()
    BCDM.db = LibStub("AceDB-3.0"):New("BCDMDB", BCDM:GetDefaultDB(), true)
    BCDM.LDS:EnhanceDatabase(BCDM.db, "UnhaltedUnitFrames")
    for k, v in pairs(BCDM:GetDefaultDB()) do
        if BCDM.db.profile[k] == nil then
            BCDM.db.profile[k] = v
        end
    end
    -- Migration: populate IconWidth/IconHeight from legacy IconSize when missing
    do
        local cm = BCDM.db.profile.CooldownManager
        if cm then
            local viewers = { "Essential", "Utility", "Buffs", "Custom", "AdditionalCustom", "Item", "Trinket", "ItemSpell" }
            for _, name in ipairs(viewers) do
                local entry = cm[name]
                if entry and type(entry) == "table" then
                    if entry.IconSize and (entry.IconWidth == nil or entry.IconHeight == nil) then
                        entry.IconWidth = entry.IconWidth or entry.IconSize
                        entry.IconHeight = entry.IconHeight or entry.IconSize
                    end
                end
            end
        end
    end
    if BCDM.db.global.UseGlobalProfile then BCDM.db:SetProfile(BCDM.db.global.GlobalProfile or "Default") end
    BCDM.db.RegisterCallback(BCDM, "OnProfileChanged", function() BCDM:UpdateBCDM() end)
end

function BetterCooldownManager:OnEnable()
    BCDM:Init()
    BCDM:SetupEventManager()
    BCDM:SkinCooldownManager()
    BCDM:CreatePowerBar()
    BCDM:CreateSecondaryPowerBar()
    BCDM:CreateCastBar()
    BCDM:SetupCustomCooldownViewer()
    BCDM:SetupAdditionalCustomCooldownViewer()
    BCDM:SetupCustomItemBar()
    BCDM:SetupTrinketBar()
    BCDM:SetupCustomItemsSpellsBar()
    BCDM:CreateCooldownViewerOverlays()
    BCDM:SetupEditModeManager()
    BCDM.Keybinds:Initialize()
end