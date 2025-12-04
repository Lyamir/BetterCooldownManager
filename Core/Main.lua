local _, BCDM = ...
local AddOn = LibStub("AceAddon-3.0"):NewAddon("BetterCooldownManager")

function AddOn:OnInitialize()
    BCDM.db = LibStub("AceDB-3.0"):New("BetterCDMDB", BCDM.Defaults, true)
    for key, value in pairs(BCDM.Defaults) do
        if BCDM.db.global[key] == nil then
            BCDM.db.global[key] = value
        end
    end
end

function AddOn:OnEnable()
    BCDM:SetupSlashCommands()
    BCDM:SetupCooldownManager()
end