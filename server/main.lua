local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("panicbutton", function(source)
	TriggerClientEvent('panic:client:UseButton', source)
end)

RegisterServerEvent("panic:server:NewPanic")
AddEventHandler("panic:server:NewPanic", function(Officer) 
	TriggerClientEvent("panic:client:NewPanic", -1, source, Officer) 
end)

QBCore.Functions.CreateCallback('panic:server:GetJob', function(_, cb, playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    cb(Player.PlayerData.job.name)
end)