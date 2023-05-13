local QRCore = exports['qr-core']:GetCoreObject()
local ResetStress = false

-- Money Commands --
for TYPE, _ in pairs(QRCore.Config.Money.MoneyTypes) do
    QRCore.Commands.Add(TYPE, 'Check '..TYPE..' balance', {}, false, function(source, args)
        local Player = QRCore.Functions.GetPlayer(source)
        local amount = Player.PlayerData.money[TYPE]
        TriggerClientEvent('hud:client:ShowAccounts', source, TYPE, amount)
    end)
end

-- Gain Stress --
RegisterNetEvent('hud:server:GainStress', function(amount)
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil and Player.PlayerData.job.name ~= 'police' then
        if not ResetStress then
            if Player.PlayerData.metadata['stress'] == nil then
                Player.PlayerData.metadata['stress'] = 0
            end
            newStress = Player.PlayerData.metadata['stress'] + amount
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData('stress', newStress)
        TriggerClientEvent('hud:client:UpdateStress', src, newStress)
        TriggerClientEvent('QRCore:Notify', src, Lang:t("info.getstress"), 'primary')
	end
end)

-- Gain Thirst --
RegisterNetEvent('hud:server:GainThirst', function(amount)
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    local newThirst
    if Player ~= nil then
            if Player.PlayerData.metadata['thirst'] == nil then
                Player.PlayerData.metadata['thirst'] = 0
            end
            local thirst = Player.PlayerData.metadata['thirst']
            if newThirst <= 0 then
                newThirst = 0
            end
            if newThirst > 100 then
                newThirst = 100
            end
        Player.Functions.SetMetaData('thirst', newThirst)
        TriggerClientEvent('hud:client:UpdateThirst', src, newThirst)
        TriggerClientEvent('QRCore:Notify', src, Lang:t("info.thirsty"), 'primary')
	end
end)

-- Relieve Stress --
RegisterNetEvent('hud:server:RelieveStress', function(amount)
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata['stress'] == nil then
                Player.PlayerData.metadata['stress'] = 0
            end
            newStress = Player.PlayerData.metadata['stress'] - amount
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData('stress', newStress)
        TriggerClientEvent('hud:client:UpdateStress', src, newStress)
        TriggerClientEvent('QRCore:Notify', src, Lang:t("info.relaxing"), 'primary')
	end
end)
