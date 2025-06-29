local VORPcore = exports.vorp_core:GetCore()
local T = Translation.Langs[Config.Lang]

RegisterServerEvent('rs_ballon:checkOwned')
AddEventHandler('rs_ballon:checkOwned', function()
    local src = source
    local User = VORPcore.getUser(src).getUsedCharacter
    local u_identifier = User.identifier
    local u_charid = User.charIdentifier

    exports.ghmattimysql:execute('SELECT * FROM globo WHERE identifier = @identifier AND charid = @charid LIMIT 1', {
        ['@identifier'] = u_identifier,
        ['@charid'] = u_charid
    }, function(result)
        if result and result[1] then
            TriggerClientEvent('rs_ballon:openMenu', src, true) -- ya tiene
        else
            TriggerClientEvent('rs_ballon:openMenu', src, false) -- no tiene
        end
    end)
end)

-- rental ballon

RegisterNetEvent('rs_ballon:BuyBalloon')
AddEventHandler('rs_ballon:BuyBalloon', function()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local money = Character.money
    local cost = Config.BallonPrice
    local useTime = Config.BallonUseTime * 60000 -- Convertir minutos a milisegundos
    local enableTimer = Config.EnableBalloonTimer -- Activar/desactivar tiempo de uso

    if Config.EnableTax then
        if money >= cost then
            Character.removeCurrency(0, cost)
            VORPcore.NotifyRightTip(src, T.TaxOfUse .. '' .. cost .. '$ ' .. T.ToUseBalloon, 4000)

            -- Crear el globo en el cliente
            TriggerClientEvent("rs_ballon:spawnBalloon1", src)

            -- Si el temporizador está activado, programar la advertencia y eliminación
            if enableTimer then
                SetTimeout(useTime - 30000, function()
                    TriggerClientEvent("rs_ballon:balloonWarning", src)
                end)

                SetTimeout(useTime, function()
                    TriggerClientEvent("rs_ballon:deleteTemporaryBalloon", src)
                end)
            end
        else
            VORPcore.NotifyRightTip(src, T.IfNecessary .. '' .. cost .. '$ ' .. T.ToUseBalloon, 4000)
        end
    end
end)


local VorpCore = {}

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

local function GetAmountBoats(Player_ID, Character_ID)
    local HasBoats = exports.ghmattimysql:execute( "SELECT * FROM globo WHERE identifier = @identifier AND charid = @charid ", {
        ['identifier'] = Player_ID,
        ['charid'] = Character_ID
    } )

    if #HasBoats > 0 then
        return true
    end

    return false
end

RegisterServerEvent('rs_ballon:buyboat')
AddEventHandler('rs_ballon:buyboat', function(args)
    local _price = args['Price']
    local _name = args['Name']
    local User = VorpCore.getUser(source).getUsedCharacter

    local u_identifier = User.identifier
    local u_charid = User.charIdentifier
    local u_money = User.money

    if u_money < _price then
        TriggerClientEvent("vorp:TipBottom", source, T.Noti, 5000)
        return
    end

    User.removeCurrency(0, _price)

    local Parameters = {
        ['identifier'] = u_identifier,
        ['charid'] = u_charid,
        ['name'] = _name
    }

    exports.ghmattimysql:execute("INSERT INTO globo (`identifier`, `charid`, `name`) VALUES (@identifier, @charid, @name)", Parameters)

    TriggerClientEvent("vorp:TipBottom", source, T.Noti1, 5000)
end)

RegisterServerEvent('rs_ballon:loadownedboats')
AddEventHandler('rs_ballon:loadownedboats', function()
    local _source = source
    local User = VorpCore.getUser(_source).getUsedCharacter
    local u_identifier = User.identifier
    local u_charid = User.charIdentifier

    local Parameters = {
        ['@identifier'] = u_identifier,
        ['@charid'] = u_charid
    }

    exports.ghmattimysql:execute('SELECT * FROM globo WHERE identifier = @identifier AND charid = @charid', Parameters, function(HasBoats)
        if HasBoats[1] then
            TriggerClientEvent("rs_ballon:loadBoatsMenu", _source, HasBoats)
        end
    end)
end)

RegisterServerEvent('rs_ballon:transferBalloon')
AddEventHandler('rs_ballon:transferBalloon', function(targetId)
    local src = source
    local sender = VorpCore.getUser(src).getUsedCharacter
    local target = VorpCore.getUser(tonumber(targetId))
    if not target then
        TriggerClientEvent("vorp:TipBottom", src, "Player not found", 5000)
        return
    end

    local sender_identifier = sender.identifier
    local sender_charid = sender.charIdentifier
    local target_identifier = target.getUsedCharacter.identifier
    local target_charid = target.getUsedCharacter.charIdentifier

    -- Verificar si el receptor ya tiene un globo
    exports.ghmattimysql:execute('SELECT * FROM globo WHERE identifier = @identifier AND charid = @charid LIMIT 1', {
        ['@identifier'] = target_identifier,
        ['@charid'] = target_charid
    }, function(existing)
        if existing and existing[1] then
            TriggerClientEvent("vorp:TipBottom", src, T.has, 5000)
        else
            -- Transferir el globo al nuevo jugador
            exports.ghmattimysql:execute('UPDATE globo SET identifier = @newIdentifier, charid = @newCharId WHERE identifier = @oldIdentifier AND charid = @oldCharId LIMIT 1', {
                ['@newIdentifier'] = target_identifier,
                ['@newCharId'] = target_charid,
                ['@oldIdentifier'] = sender_identifier,
                ['@oldCharId'] = sender_charid
            }, function()
                TriggerClientEvent("vorp:TipBottom", src, T.Tranfer, 5000)
                TriggerClientEvent("vorp:TipBottom", tonumber(targetId), T.Received, 5000)
            end)
        end
    end)
end)

RegisterServerEvent('rs_ballon:sellboat')
AddEventHandler('rs_ballon:sellboat', function(args)
    if not args then
        TriggerClientEvent("vorp:TipBottom", source, T.Error, 5000)
        return
    end

    local User = VorpCore.getUser(source).getUsedCharacter

    local u_identifier = User.identifier
    local u_charid = User.charIdentifier

    -- Obtener el precio del globo desde la configuración
    local original_price = nil

    for _, globo in pairs(Config.Globo) do
        original_price = globo.Param.Price
        break
    end

    if original_price then
        local sell_price = original_price * 0.6

        -- Agregar el dinero al usuario
        User.addCurrency(0, sell_price)

        -- Eliminar el globo de la base de datos
        exports.ghmattimysql:execute("DELETE FROM globo WHERE identifier = @identifier AND charid = @charid", {
            ['@identifier'] = u_identifier,
            ['@charid'] = u_charid,
        })

        TriggerClientEvent("vorp:TipBottom", source, T.Buy .. " " .. sell_price .. "$", 5000)
    else
        TriggerClientEvent("vorp:TipBottom", source, T.Dont, 5000)
    end
end)
