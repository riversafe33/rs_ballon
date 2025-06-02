-- Spawn Balloon --------------------------------------------------------------------
local balloon = nil
local Blips = {}

local T = Translation.Langs[Config.Lang]

local showingPrompt = false

Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearLocation = false

        for _, location in pairs(Config.BalloonLocations) do
            local distance = Vdist(playerCoords, location.coords.x, location.coords.y, location.coords.z)
            if distance < 2.0 then
                if not showingPrompt then
                    SendNUIMessage({ action = "showAlqui" }) -- mostrar UI
                    showingPrompt = true
                end

                if IsControlJustReleased(0, Config.KeyToBuyBalloon) then
                    TriggerServerEvent('rs_ballon:BuyBalloon', Config.BalloonModel or "hotairballoon01x")
                end

                nearLocation = true
                break
            end
        end

        if not nearLocation and showingPrompt then
            SendNUIMessage({ action = "hideAlqui" }) -- ocultar UI
            showingPrompt = false
        end

        Citizen.Wait(nearLocation and 0 or 500)
    end
end)



-- Crear blips en el mapa para cada punto de alquiler de globo
Citizen.CreateThread(function()
    for _, location in pairs(Config.BalloonLocations) do
        local blip = N_0x554d9d53f696d002(1664425300, location.coords.x, location.coords.y, location.coords.z)
        SetBlipSprite(blip, location.sprite, 1) -- Usa un sprite por defecto si no se especifica
        SetBlipScale(blip, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, location.name)
    end  
end)


-- Clean up blips when the resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, blip in pairs(Blips) do
        RemoveBlip(blip)
    end
end)
