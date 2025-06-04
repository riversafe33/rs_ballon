local Core = exports.vorp_core:GetCore()
local T = Translation.Langs[Config.Lang]

local balloon
local lockZ = false
local useCameraRelativeControls = true -- Set to false to revert to original NSEW controls

local balloonPrompts = UipromptGroup:new("Balloon")

local nsPrompt = Uiprompt:new({`INPUT_VEH_MOVE_UP_ONLY`, `INPUT_VEH_MOVE_DOWN_ONLY` }, T.Prompts.NorthSouth, balloonPrompts)
local wePrompt = Uiprompt:new({`INPUT_VEH_MOVE_LEFT_ONLY`, `INPUT_VEH_MOVE_RIGHT_ONLY`}, T.Prompts.WestEast, balloonPrompts)
local brakePrompt = Uiprompt:new(`INPUT_CONTEXT_X`, T.Prompts.DownBalloon, balloonPrompts)
local lockZPrompt = Uiprompt:new(`INPUT_CONTEXT_A`, T.Prompts.LockInAltitude, balloonPrompts)
local throttlePrompt = Uiprompt:new(`INPUT_VEH_FLY_THROTTLE_UP`, T.Prompts.UpBalloon, balloonPrompts)
local deleteBalloonPrompt = Uiprompt:new(`INPUT_VEH_HORN`, T.Prompts.RemoveBalloon, balloonPrompts)

-- Function to calculate direction vectors based on camera heading
local function GetCameraRelativeVectors()
    local camRot = GetGameplayCamRot(2)
    local camHeading = math.rad(camRot.z)
    local forwardVector = vector3(-math.sin(camHeading), math.cos(camHeading), 0.0)
    local rightVector = vector3(math.cos(camHeading), math.sin(camHeading), 0.0)
    return forwardVector, rightVector
end


Citizen.CreateThread(function()
	while true do
		local playerPed = PlayerPedId()
		local vehiclePedIsIn = GetVehiclePedIsIn(playerPed, false)

		if vehiclePedIsIn ~= 0 and GetEntityModel(vehiclePedIsIn) == `hotairballoon01` then
			if not balloon then
				balloon = vehiclePedIsIn
			end
		else
			if balloon then
				balloon = nil
			end
		end

		Citizen.Wait(500)
	end
end)

Citizen.CreateThread(function()
	local bv
	while true do
		if balloon then
			balloonPrompts:handleEvents()

			local speed = IsControlPressed(0, `INPUT_VEH_TRAVERSAL`) and 0.15 or 0.05
			local v1 = GetEntityVelocity(balloon)
			local v2 = v1

			if useCameraRelativeControls then
				local forwardVec, rightVec = GetCameraRelativeVectors()
				if IsControlPressed(0, `INPUT_VEH_MOVE_UP_ONLY`) then
					v2 = v2 + forwardVec * speed
				end
				if IsControlPressed(0, `INPUT_VEH_MOVE_DOWN_ONLY`) then
					v2 = v2 - forwardVec * speed
				end
				if IsControlPressed(0, `INPUT_VEH_MOVE_LEFT_ONLY`) then
					v2 = v2 - rightVec * speed
				end
				if IsControlPressed(0, `INPUT_VEH_MOVE_RIGHT_ONLY`) then
					v2 = v2 + rightVec * speed
				end
			else
				if IsControlPressed(0, `INPUT_VEH_MOVE_UP_ONLY`) then
					v2 = v2 + vector3(0, speed, 0)
				end
				if IsControlPressed(0, `INPUT_VEH_MOVE_DOWN_ONLY`) then
					v2 = v2 - vector3(0, speed, 0)
				end
				if IsControlPressed(0, `INPUT_VEH_MOVE_LEFT_ONLY`) then
					v2 = v2 - vector3(speed, 0, 0)
				end
				if IsControlPressed(0, `INPUT_VEH_MOVE_RIGHT_ONLY`) then
					v2 = v2 + vector3(speed, 0, 0)
				end
			end

			if IsControlPressed(0, `INPUT_CONTEXT_X`) then
				if bv then
					local x = bv.x > 0 and bv.x - speed or bv.x + speed
					local y = bv.y > 0 and bv.y - speed or bv.y + speed
					v2 = vector3(x, y, v2.z)
				end
				bv = v2.xy
			else
				bv = nil
			end

			if IsControlJustPressed(0, `INPUT_CONTEXT_A`) then
				lockZ = not lockZ
				if lockZ then
					lockZPrompt:setText(T.Prompts.UnlockInAltitude)
				else
					lockZPrompt:setText(T.Prompts.LockInAltitude)
				end
			end

			if lockZ and not IsControlPressed(0, `INPUT_VEH_FLY_THROTTLE_UP`) then
				SetEntityVelocity(balloon, vector3(v2.x, v2.y, 0.0))
			elseif v2 ~= v1 then
				SetEntityVelocity(balloon, v2)
			end

			if IsControlJustPressed(0, `INPUT_VEH_HORN`) then
				if DoesEntityExist(balloon) then
					DeleteEntity(balloon)
					balloon = nil
				end
			end

			Citizen.Wait(0)
		else
			Citizen.Wait(500)
		end
	end
end)

local BoatGroup = GetRandomIntInRange(0, 0xffffff)
local OwnedBoats = {}
local near = 1000
local boating = false
local stand = { x = 0, y = 0, z = 0 }
local T = Translation.Langs[Config.Lang]

local _BoatPrompt
function BoatPrompt()
    Citizen.CreateThread(function()
        local str = T.Shop
        _BoatPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(_BoatPrompt, 0x760A9C6F)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(_BoatPrompt, str)
        PromptSetEnabled(_BoatPrompt, true)
        PromptSetVisible(_BoatPrompt, true)
        PromptSetStandardMode(_BoatPrompt, true)
        PromptSetGroup(_BoatPrompt, BoatGroup)
        PromptRegisterEnd(_BoatPrompt)
        PromptSetPriority(_BoatPrompt , true)
    end)
end

TriggerEvent("vorp_menu:getData",function(call)
    MenuData = call
end)


local boates = Config.Globo

Citizen.CreateThread(function()
	BoatPrompt()

	while true do
		local playerCoords = GetEntityCoords(PlayerPedId())
		local inZone = false

		for i, zone in pairs(Config.Marker) do
			local dist = GetDistanceBetweenCoords(zone.x, zone.y, zone.z, playerCoords, false)
			if dist < 2 then
				inZone = true
				stand = zone
				near = 5

				local BoatGroupName  = CreateVarString(10, 'LITERAL_STRING', T.Shop7)
				PromptSetActiveGroupThisFrame(BoatGroup, BoatGroupName)
				PromptSetEnabled(_BoatPrompt, true)
				PromptSetVisible(_BoatPrompt, true)

				if PromptHasStandardModeCompleted(_BoatPrompt) then
					PromptSetEnabled(_BoatPrompt, false)
					PromptSetVisible(_BoatPrompt, false)
					TriggerServerEvent('rs_ballon:checkOwned')
					Citizen.Wait(500) -- previene múltiples aperturas
				end
			end
		end

		if not inZone and stand then
			MenuData.Close('default', GetCurrentResourceName(), 'vorp_menu')
			PromptSetEnabled(_BoatPrompt, false)
			PromptSetVisible(_BoatPrompt, false)
			stand = nil
			near = 1000
		end

		Citizen.Wait(near)
	end
end)

local datosVenta = {
    Model = "hotairballoon01"
}


RegisterNetEvent('rs_ballon:openMenu')
AddEventHandler('rs_ballon:openMenu', function(hasBalloon)
    MenuData.CloseAll()

    local elements = {}

    if not hasBalloon then
        table.insert(elements, { label = T.Buyballon, value = 'buy', desc = T.Desc1 })
    else
        table.insert(elements, { label = T.Property, value = 'own', desc = T.Property1 })
        table.insert(elements, { label = T.SellBalloon, value = 'sell', desc = T.Sell })
        table.insert(elements, { label = T.TransferBalloon, value = 'transfer', desc = T.TransferDesc })
    end

    MenuData.Open('default', GetCurrentResourceName(), 'vorp_menu',
    {
        title    = T.Shop1,
        subtext  = T.Shop2,
        align    = 'top-right',
        elements = elements,
    },
    function(data, menu)
        if data.current.value == "buy" then
            OpenBuyBoatsMenu()

        elseif data.current.value == "own" then
            TriggerServerEvent('rs_ballon:loadownedboats')
            menu.close() -- Cierra el menú después de la acción

        elseif data.current.value == "sell" then
            TriggerServerEvent('rs_ballon:sellboat', datosVenta)
            menu.close() -- Cierra el menú después de la acción

        elseif data.current.value == "transfer" then
            -- ya está bien validado abajo
            if not hasBalloon then
                TriggerEvent("vorp:TipBottom", "You don't have a balloon to transfer.", 4000)
                return
            end

            local myInput = {
                type = "enableinput",
                inputType = "input",
                button = "Confirm",
                placeholder = "PLAYER ID",
                style = "block",
                attributes = {
                    inputHeader = "TRANSFER BALLOON",
                    type = "text",
                    pattern = "[0-9]+",
                    title = "Only numbers allowed",
                    style = "border-radius: 10px; background-color: ; border:none;"
                }
            }

            local result = exports.vorp_inputs:advancedInput(myInput)
            if result and result ~= "" then
                local playerId = tonumber(result)
                if playerId then
                    TriggerServerEvent('rs_ballon:transferBalloon', playerId)
                    menu.close() -- Cierra el menú después de la acción
                else
                    TriggerEvent("vorp:TipBottom", "Invalid ID format.", 4000)
                end
            end
        end
    end,
    function(data, menu)
        menu.close()
    end)
end)

function OpenOwnBoatsMenu()
    MenuData.CloseAll()
	local elements = {}
	
	for k, boot in pairs(OwnedBoats) do
		 elements[#elements + 1] = {
            label = boot['name'],
            value = k,
            desc = boot['name'], 
			info = boot['globo']
        }
	end
    MenuData.Open('default', GetCurrentResourceName(), 'vorp_menu',
	{
		title    = T.Shop3,
		subtext  = T.Shop4,
		align    = 'top-right',
		elements = elements,
	},
	function(data, menu)
		if data.current.value then
			local boatget = data.current.info
			TriggerEvent('rs_ballon:spawnBalloon', boatget)
			menu.close()
		end
	end,
	function(data, menu)
		menu.close()
	end)
end

function OpenBuyBoatsMenu()
    MenuData.CloseAll()
	local elements = {}
	for k, boot in pairs(boates) do
		elements[#elements + 1] = {
			label = boates[k]['Text'],
            value = k,
			desc = '<span style=color:MediumSeaGreen;>'..boates[k]['Param']['Price']..'$</span>',
			info = boates[k]['Param']
		}
	end
    MenuData.Open('default', GetCurrentResourceName(), 'vorp_menu',
	{
		title    = T.Shop5,
		subtext  = T.Shop6,
		align    = 'top-right',
		elements = elements,
	},
	function(data, menu)
		if data.current.value then
			local boatbuy = data.current.info
			TriggerServerEvent('rs_ballon:buyboat', boatbuy)
			menu.close()
		end
	end,
	function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent("rs_ballon:loadBoatsMenu")
AddEventHandler("rs_ballon:loadBoatsMenu", function(result)
	OwnedBoats = result
	OpenOwnBoatsMenu()
end)

-- | Blips and NPC | --
Citizen.CreateThread(function()
    for _,marker in pairs(Config.Marker) do
        local blip = N_0x554d9d53f696d002(1664425300, marker.x, marker.y, marker.z)
        SetBlipSprite(blip, marker.sprite, 1)
        SetBlipScale(blip, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, marker.name)
    end  
end)

Citizen.CreateThread(function()
    for _, coords in pairs(Config.NPC.coords) do
        TriggerEvent("rs_ballon:CreateNPC", coords)
    end
end)


RegisterNetEvent("rs_ballon:CreateNPC")
AddEventHandler("rs_ballon:CreateNPC", function(zone)
    if not zone then return end

    local model = GetHashKey(Config.NPC.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(500) end

    local npc = CreatePed(model, zone.x, zone.y, zone.z, zone.w, false, true)
    Citizen.InvokeNative(0x283978A15512B2FE , npc, true)
    SetEntityNoCollisionEntity(PlayerPedId(), npc, false)
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetModelAsNoLongerNeeded(model)
end)



local spawn_boat = nil

RegisterNetEvent('rs_ballon:spawnBalloon')
AddEventHandler('rs_ballon:spawnBalloon', function()
    if DoesEntityExist(spawn_boat) then
        DeleteVehicle(spawn_boat)
        spawn_boat = nil
    end

    local balloonModel = 'hotairballoon01'  -- Ajusta al modelo correcto si es necesario
    local objectModel = 'p_ambfloorscrub01x'

    RequestModel(balloonModel)
    RequestModel(objectModel)

    while not HasModelLoaded(balloonModel) or not HasModelLoaded(objectModel) do
        Citizen.Wait(1000)
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local spawnCoords = coords + forward * 5.0

    local balloon = CreateVehicle(GetHashKey(balloonModel), spawnCoords.x, spawnCoords.y, spawnCoords.z, GetEntityHeading(playerPed), true, false)
    SetEntityAsMissionEntity(balloon, true, true)

    -- Asegurar que el globo sea visible para todos los jugadores en el servidor
    local netId = NetworkGetNetworkIdFromEntity(balloon)
    SetNetworkIdExistsOnAllMachines(netId, true)

    local object = CreateObject(GetHashKey(objectModel), spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)
    AttachEntityToEntity(object, balloon, 0, 0.0, 0.0, 0.09, 0.0, 0.0, 0.0, true, true, true, false, false, true, true, true)

    -- Hacer que el objeto adjunto sea invisible
    SetEntityVisible(object, false)

    -- Liberar los modelos de memoria
    SetModelAsNoLongerNeeded(balloonModel)
    SetModelAsNoLongerNeeded(objectModel)

    spawn_boat = balloon
    boating = true
end)

local spawn_ballon = nil

RegisterNetEvent('rs_ballon:spawnBalloon1')
AddEventHandler('rs_ballon:spawnBalloon1', function()
    if DoesEntityExist(spawn_ballon) then
        DeleteVehicle(spawn_ballon)
        spawn_ballon = nil
    end

    local balloonModel = 'hotairballoon01'  -- Ajusta al modelo correcto si es necesario
    local objectModel = 'p_ambfloorscrub01x'

    RequestModel(balloonModel)
    RequestModel(objectModel)

    while not HasModelLoaded(balloonModel) or not HasModelLoaded(objectModel) do
        Citizen.Wait(1000)
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local spawnCoords = coords + forward * 5.0

    local balloon = CreateVehicle(GetHashKey(balloonModel), spawnCoords.x, spawnCoords.y, spawnCoords.z, GetEntityHeading(playerPed), true, false)
    SetEntityAsMissionEntity(balloon, true, true)

    -- Asegurar que el globo sea visible para todos los jugadores en el servidor
    local netId = NetworkGetNetworkIdFromEntity(balloon)
    SetNetworkIdExistsOnAllMachines(netId, true)

    local object = CreateObject(GetHashKey(objectModel), spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)
    AttachEntityToEntity(object, balloon, 0, 0.0, 0.0, 0.09, 0.0, 0.0, 0.0, true, true, true, false, false, true, true, true)

    -- Hacer que el objeto adjunto sea invisible
    SetEntityVisible(object, false)

    -- Liberar los modelos de memoria
    SetModelAsNoLongerNeeded(balloonModel)
    SetModelAsNoLongerNeeded(objectModel)

    spawn_ballon = balloon
    boating = true
end)

RegisterNetEvent("rs_ballon:deleteTemporaryBalloon")
AddEventHandler("rs_ballon:deleteTemporaryBalloon", function()
    if spawn_ballon ~= nil and DoesEntityExist(spawn_ballon) then
        DeleteVehicle(spawn_ballon)
        spawn_ballon = nil
        Core.NotifyRightTip(T.BalloonExpired, 4000)
    end
end)

RegisterNetEvent("rs_ballon:balloonWarning")
AddEventHandler("rs_ballon:balloonWarning", function()
    Core.NotifyLeft(T.Tittle,T.BalloonWarning, "generic_textures", "tick", 4000, "COLOR_GREEN")
end)
