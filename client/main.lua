
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

	local hasButton = QBCore.Functions.HasItem('panicbutton')

	if not hasButton then
		QBCore.Functions.Notify("You do not have a panic button!", "error")
		return
	end

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

		cooldown = Config.Cooldown

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

	local PlayerData = QBCore.Functions.GetPlayerData()

	if PlayerData.job.name == "police" then

		if Officer.Ped ~= PlayerPedId() then

			local message = "Officer " .. tostring(Officer.Name) .. " Is In Distress"

			SetNuiFocus(false, false)
			SendNUIMessage({
				action = "showAlert",
				text = message,
				location = tostring(Officer.Location)
			})
		
			TriggerServerEvent("InteractSound_SV:PlayWithinDistance", Config.VicinityDistance, Config.Sound1, 0.2)
	
			Citizen.CreateThread(function()

				-- Blip Circle
				local blipCircle = AddBlipForRadius(Officer.Coords.x, Officer.Coords.y, Officer.Coords.z, 100.0)
				SetBlipRoute(blipCircle, true)
				SetBlipAlpha(blipCircle, 60)
				SetBlipColour(blipCircle, 1)
				SetBlipFlashes(blipCircle, true)
				SetBlipFlashInterval(blipCircle, 200)

				-- Blip Icon
				local blipIcon = AddBlipForCoord(Officer.Coords.x, Officer.Coords.y, Officer.Coords.z)
				SetBlipSprite(blipIcon, 526)
				SetBlipHighDetail(blipIcon, true)
				SetBlipScale(blipIcon, 1.5)
				SetBlipColour(blipIcon, 1)
				SetBlipAlpha(blipIcon, 255)
				SetBlipAsShortRange(blipIcon, false)
				SetBlipCategory(blipIcon, 2)
				BeginTextCommandSetBlipName('STRING')
				AddTextComponentString(message)
				EndTextCommandSetBlipName(blipIcon)
		
				Citizen.CreateThread(function()
					while blipCircle do
						SetBlipRouteColour(blipCircle, 1)
						Citizen.Wait(150)
						SetBlipRouteColour(blipCircle, 6)
						Citizen.Wait(150)
						SetBlipRouteColour(blipCircle, 35)
						Citizen.Wait(150)
						SetBlipRouteColour(blipCircle, 6)
					end
				end)

				Citizen.Wait(Config.BlipTime * 1000)
		
				RemoveBlip(blipCircle)
				RemoveBlip(blipIcon)
				blipCircle = nil
				blipIcon = nil
			end)
	
		else
			-- If close to an officer, do not play button sound
			local playSound = true
			local players = QBCore.Functions.GetPlayersFromCoords(GetEntityCoords(PlayerPedId()), Config.VicinityDistance)
			for i = 1, #players, 1 do
				player = players[i]
				if player ~= PlayerId() then
					local playerId = GetPlayerServerId(player)
					QBCore.Functions.TriggerCallback('panic:server:GetJob', function(result)
						if result and result == "police" then
							playSound = false
						end
					end, playerId)
					if not playSound then break end
				end
			end

			if playSound then
				TriggerServerEvent("InteractSound_SV:PlayOnSource", Config.Sound2, 0.1)
			end
		end

	end

end)


