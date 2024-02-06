local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("panicbutton", function(source)
	TriggerClientEvent('panic:client:UseButton', source)
end)

RegisterServerEvent("panic:server:NewPanic")
AddEventHandler("panic:server:NewPanic", function(Officer) 
	TriggerClientEvent("panic:client:NewPanic", -1, source, Officer) 
end)