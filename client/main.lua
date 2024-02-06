
local QBCore = exports['qb-core']:GetCoreObject()

local cooldown = 0

-- ################################ THREADS ################################

-- Cooldown loop
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if cooldown ~= 0 then
			Citizen.Wait(1000)
			cooldown = cooldown - 1
		end
	end
end)

-- ################################ FUNCTIONS ################################

function UseButton()

	print("Button Used")

	if cooldown > 0 then

		QBCore.Functions.Notify("You need to wait before using your panic button again!", "error")

	else

		local Officer = {}
		local player = QBCore.Functions.GetPlayerData()
		Officer.Ped = PlayerPedId()
		Officer.Name = player.charinfo.firstname .. " " .. player.charinfo.lastname
		Officer.Coords = GetEntityCoords(Officer.Ped)
		Officer.Location = {}
		Officer.Location.Street, Officer.Location.CrossStreet = GetStreetNameAtCoord(Officer.Coords.x, Officer.Coords.y, Officer.Coords.z)
		Officer.Location.Street = GetStreetNameFromHashKey(Officer.Location.Street)
		if Officer.Location.CrossStreet ~= 0 then
			Officer.Location.CrossStreet = GetStreetNameFromHashKey(Officer.Location.CrossStreet)
			Officer.Location = Officer.Location.Street .. " // " .. Officer.Location.CrossStreet
		else
			Officer.Location = Officer.Location.Street
		end

		TriggerServerEvent("panic:server:NewPanic", Officer)

		cooldown = 5

	end

end

-- ################################ COMMANDS ################################

RegisterCommand("panicb", function()
	local PlayerData = QBCore.Functions.GetPlayerData()
	if PlayerData.job.name == "police" then
		UseButton()
	else
		QBCore.Functions.Notify("You cannot use this!", "error")
	end
end)

-- ################################ NET EVENTS ################################

RegisterNetEvent('panic:client:UseButton', function()
	local PlayerData = QBCore.Functions.GetPlayerData()

	if PlayerData.job.name == "police" then
		UseButton()
	else
		QBCore.Functions.Notify("You cannot use this!", "error")
	end
end)

RegisterNetEvent("panic:client:NewPanic")
AddEventHandler("panic:client:NewPanic", function(source, Officer)

	if Officer.Ped ~= PlayerPedId() then

		SetNuiFocus(false, false)
		SendNUIMessage({
			action = "showAlert",
			text = "Officer " .. tostring(Officer.Name) .. " In Need of Assistance",
			location = tostring(Officer.Location)
		})

		print("Other players...")

		-- Player localised sound
		--TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5.0, "panic", 0.2)

		Citizen.CreateThread(function()
			local Blip = AddBlipForRadius(Officer.Coords.x, Officer.Coords.y, Officer.Coords.z, 100.0)
	
			SetBlipRoute(Blip, true)
	
			Citizen.CreateThread(function()
				while Blip do
					SetBlipRouteColour(Blip, 1)
					Citizen.Wait(150)
					SetBlipRouteColour(Blip, 6)
					Citizen.Wait(150)
					SetBlipRouteColour(Blip, 35)
					Citizen.Wait(150)
					SetBlipRouteColour(Blip, 6)
				end
			end)
	
			SetBlipAlpha(Blip, 60)
			SetBlipColour(Blip, 1)
			SetBlipFlashes(Blip, true)
			SetBlipFlashInterval(Blip, 200)
	
			Citizen.Wait(Config.BlipTime * 1000)
	
			RemoveBlip(Blip)
			Blip = nil
		end)

	else
		print("ME !")
		TriggerServerEvent("InteractSound_SV:PlayOnSource", "pager", 0.1)
	end
	

end)


