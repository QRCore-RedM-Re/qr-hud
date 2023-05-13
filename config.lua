Config = {}
Config.StressChance = 0.1 -- Default: 10% -- Percentage Stress Chance When Shooting (0-1)
Config.MinimumStress = 50 -- Minimum Stress Level For Screen Shaking
Config.MinimumSpeed = 20 -- Going Over This Speed Will Cause Stress
Config.SpeedCheck = 10 -- Check Player Speed Every 10 Seconds

-- On Foot Minimap & Comapss --
Config.OnFootMinimap = true -- Enable/Disable Minimap on Foot (If Disabled, Compass can be Enabled)
Config.OnFootCompass = false -- Only used if Config.OnFootMinimap = false

-- On Mount / Vehicle Minimap & Comapss --
Config.MounttMinimap = true -- Enable/Disable Minimap on Mount / Vehicles (If Disabled, Compass can be Enabled)
Config.MountCompass = false -- Only used if Config.MounttMinimap = false

-- Stress
Config.Intensity = {
    ["shake"] = {
        [1] = {
            min = 50,
            max = 60,
            intensity = 0.12,
        },
        [2] = {
            min = 60,
            max = 70,
            intensity = 0.17,
        },
        [3] = {
            min = 70,
            max = 80,
            intensity = 0.22,
        },
        [4] = {
            min = 80,
            max = 90,
            intensity = 0.28,
        },
        [5] = {
            min = 90,
            max = 100,
            intensity = 0.32,
        },
    }
}

Config.EffectInterval = {
    [1] = {
        min = 50,
        max = 60,
        timeout = math.random(50000, 60000)
    },
    [2] = {
        min = 60,
        max = 70,
        timeout = math.random(40000, 50000)
    },
    [3] = {
        min = 70,
        max = 80,
        timeout = math.random(30000, 40000)
    },
    [4] = {
        min = 80,
        max = 90,
        timeout = math.random(20000, 30000)
    },
    [5] = {
        min = 90,
        max = 100,
        timeout = math.random(15000, 20000)
    }
}
