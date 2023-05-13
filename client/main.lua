local QRCore = exports['qr-core']:GetCoreObject()
local PlayerData = QRCore.Functions.GetPlayerData()
local speed = 0.0
local stress = 0
local hunger = 100
local thirst = 100
local cashAmount = 0
local bankAmount = 0
local bloodmoneyAmount = 0

-- Functions --
local function GetShakeIntensity(stresslevel)
    local retval = 0.05
    for _, v in pairs(Config.Intensity['shake']) do
        if stresslevel >= v.min and stresslevel <= v.max then
            retval = v.intensity
            break
        end
    end
    return retval
end

local function GetEffectInterval(stresslevel)
    local retval = 60000
    for _, v in pairs(Config.EffectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            retval = v.timeout
            break
        end
    end
    return retval
end

-- Events --
RegisterNetEvent('QRCore:Client:OnPlayerLoaded', function()
    PlayerData = QRCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QRCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
    hunger = newHunger
    thirst = newThirst
end)

RegisterNetEvent('hud:client:UpdateThirst', function(newThirst)
    thirst = newThirst
end)

RegisterNetEvent('hud:client:UpdateStress', function(newStress)
    stress = newStress
end)

-- Money HUD --
RegisterNetEvent('hud:client:ShowAccounts', function(type, amount)
    if type == 'cash' then
        SendNUIMessage({
            action = 'show',
            type = 'cash',
            cash = QRCore.Shared.Round(amount, 2),
        })
    elseif type == 'bloodmoney' then
        SendNUIMessage({
            action = 'show',
            type = 'bloodmoney',
            bloodmoney = QRCore.Shared.Round(amount, 2),
        })
    elseif type == 'bank' then
        SendNUIMessage({
            action = 'show',
            type = 'bank',
            bank = QRCore.Shared.Round(amount, 2),
        })
    end
end)

RegisterNetEvent('hud:client:OnMoneyChange', function(type, amount, isMinus)
    QRCore.Functions.GetPlayerData(function(PlayerData)
        cashAmount = PlayerData.money['cash']
        bloodmoneyAmount = PlayerData.money['bloodmoney']
        bankAmount = PlayerData.money['bank']
    end)
    SendNUIMessage({
        action = 'update',
        cash = QRCore.Shared.Round(cashAmount, 2),
        bloodmoney = QRCore.Shared.Round(bloodmoneyAmount, 2),
        bank = QRCore.Shared.Round(bankAmount, 2),
        amount = QRCore.Shared.Round(amount, 2),
        minus = isMinus,
        type = type,
    })
end)

-- Player HUD --
CreateThread(function()
    while true do
        Wait(500)
        if LocalPlayer.state.isLoggedIn then
            local show = true
            if IsPauseMenuActive() then show = false end
            local voice = 0
            local talking = Citizen.InvokeNative(0x33EEF97F, cache.playerId) -- MumbleIsPlayerTalking
            if LocalPlayer.state['proximity'] then
                voice = LocalPlayer.state['proximity'].distance
            end
            SendNUIMessage({
                action = 'hudtick',
                show = show,
                health = GetEntityHealth(player) / 3, -- RDR2 Health = 300 (Divide by 100 Here)
                armor = Citizen.InvokeNative(0x2CE311A7, cache.ped),
                thirst = thirst,
                hunger = hunger,
                stress = stress,
				talking = talking,
				voice = voice,
            })
        else
            SendNUIMessage({
                action = 'hudtick',
                show = false,
            })
        end
    end
end)

-- Radar & Map --
CreateThread(function()
    while true do
        Wait(1000)
        if LocalPlayer.state.isLoggedIn then
            if cache.mount or cache.vehicle then
                if Config.MounttMinimap then
                    SetMinimapType(1)
                else
                    if Config.MountCompass then
                        SetMinimapType(3)
                    else
                        SetMinimapType(0)
                    end
                end
            else
                if Config.OnFootMinimap then
                    SetMinimapType(1)
                else
                    if Config.OnFootCompass then
                        SetMinimapType(3)
                    else
                        SetMinimapType(0)
                    end
                end
            end
        end
    end
end)

-- Speeding Stress --
CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            if cache.mount or cache.vehicle then
                local veh = cache.vehicle or cache.mount
                speed = GetEntitySpeed(veh) * 2.237 -- MPH
                if speed >= Config.MinimumSpeed then
                    TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                end
            end
        end
        Wait(Config.SpeedCheck * 1000)
    end
end)

-- Shooting Stress --
local Shooting = 500
CreateThread(function() -- Shooting
    while true do
        local isArmed = Citizen.InvokeNative(0xCB690F680A3EA971, cache.ped, 7) -- IsPedArmed
        if LocalPlayer.state.isLoggedIn and isArmed then
            local weapon = Citizen.InvokeNative(0x8425C5F057012DAB, cache.ped) -- GetPedCurrentHeldWeapon
            if weapon ~= -1569615261 then
                if IsPedShooting(cache.ped) then
                    if math.random() < Config.StressChance then
                        TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                    end
                end
                Shooting = 0
            else
                Shooting = 1000
            end
        end
        Wait(Shooting)
    end
end)

-- Stress Screen Effects --
CreateThread(function()
    while true do
        local sleep = GetEffectInterval(stress)
        if stress >= 100 then
            local ShakeIntensity = GetShakeIntensity(stress)
            local FallRepeat = math.random(2, 4)
            local RagdollTimeout = (FallRepeat * 1750)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
            SetFlash(0, 0, 500, 3000, 500)

            if not IsPedRagdoll(cache.ped) and IsPedOnFoot(cache.ped) and not IsPedSwimming(cache.ped) then
                SetPedToRagdollWithFall(player, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(cache.ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end

            Wait(500)
            for i = 1, FallRepeat, 1 do
                Wait(750)
                DoScreenFadeOut(200)
                Wait(1000)
                DoScreenFadeIn(200)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
                SetFlash(0, 0, 200, 750, 200)
            end
        elseif stress >= Config.MinimumStress then
            local ShakeIntensity = GetShakeIntensity(stress)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
            SetFlash(0, 0, 500, 2500, 500)
        end
        Wait(sleep)
    end
end)