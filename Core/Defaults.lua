local _, BCDM = ...

BCDM.Defaults = {
    global = {
        General = {
            Font = "Friz Quadrata TT",
            FontFlag = "OUTLINE",
            IconZoom = 0.1,
            CooldownText = {
                FontSize = 15,
                Colour = {1, 1, 1},
                Anchors = {"CENTER", "CENTER", 0, 0}
            },
        },
        Essential = {
            IconSize = 42,
            Count = {
                FontSize = 15,
                Colour = {1, 1, 1},
                Anchors = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 3}
            },
        },
        Utility = {
            IconSize = 36,
            Count = {
                FontSize = 12,
                Colour = {1, 1, 1},
                Anchors = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 3}
            },
        },
        Buffs = {
            IconSize = 36,
            Count = {
                FontSize = 12,
                Colour = {1, 1, 1},
                Anchors = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 3}
            },
        },
    }
}