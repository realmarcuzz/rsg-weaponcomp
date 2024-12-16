local RSGCore = exports['rsg-core']:GetCoreObject()

lib.locale()
---------------------------------------------
-- send To Discord
-------------------------------------------
local sendToDiscord = function(color, name, message, footer, type)
    local embed = {
            {
                ['color'] = color,
                ['title'] = '**'.. name ..'**',
                ['description'] = message,
                ['footer'] = {
                ['text'] = footer
            }
        }
    }
    if type == 'weapons' then
    	PerformHttpRequest(Config['Webhooks']['weaponCustom'], function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
    end
end

--------------------------------------------
-- COMMAND 
--------------------------------------------

RSGCore.Commands.Add('w_inspect_old', locale('label_39'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-weaponcomp:client:InspectionWeapon', src)
end)

RSGCore.Commands.Add(Config.Command.inspect, locale('label_40'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-weaponcomp:client:InspectionWeaponNew', src)
end)

RSGCore.Commands.Add(Config.Command.loadweapon, locale('label_41'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-weaponcomp:client:LoadComponents', src)
end)

-------------------------------------------
-- Payment
-------------------------------------------
RegisterServerEvent('rsg-weaponcomp:server:price')
AddEventHandler('rsg-weaponcomp:server:price', function(price, objecthash)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if Config.Payment == 'item' then
        local cashItem = Player.Functions.GetItemByName(Config.PaymentType)
    	local cashAmount = cashItem.amount

        if not cashItem and tonumber(cashAmount) < tonumber(price) then
            TriggerClientEvent('ox_lib:notify', src, {title = locale('notify_42').. tonumber(price), description = locale('notify_43'), type = 'error', duration = 5000 })
            return
        else
            Player.Functions.RemoveItem(Config.PaymentType, tonumber(price), 'custom-weapon')
            TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[Config.PaymentType], 'remove')
            TriggerClientEvent('ox_lib:notify', src, {title = locale('notify_44') ..tonumber(price), description = locale('notify_45'), type = 'inform', duration = 5000 })
        end
    elseif Config.Payment == 'money' then
        local currentCash = Player.Functions.GetMoney(Config.PaymentType)
        if currentCash < tonumber(price) then
            TriggerClientEvent('ox_lib:notify', src, {title = locale('notify_46') .. tonumber(price), description = locale('notify_47'), type = 'error', duration = 5000 })
            TriggerClientEvent('rsg-weaponcomp:client:ExitCam', src)
            return
        else
            Player.Functions.RemoveMoney(Config.PaymentType, tonumber(price))
            TriggerClientEvent('ox_lib:notify', src, {title = locale('notify_48') ..tonumber(price), description = locale('notify_49'), type = 'inform', duration = 5000 })
        end
    end

    TriggerClientEvent('rsg-weaponcomp:client:animationSaved', src, objecthash)
end)

--------------------------------------------
-- ADD COMPONENTS SQL
--------------------------------------------
-- Server event for storing components in the database
RegisterNetEvent('rsg-weaponcomp:server:apply_weapon_components')
AddEventHandler('rsg-weaponcomp:server:apply_weapon_components', function(components, weaponName, serial)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    -- ADD CUSTOM EVER
    MySQL.Async.execute('UPDATE player_weapons SET components = @components WHERE serial = @serial', {
        ['@components'] = json.encode(components),
        ['@serial'] = serial
    }, function(rowsChanged)
        if rowsChanged > 0 then

            sendToDiscord(16753920,	'Craft | WEAPON CUSTOM', '**Citizenid:** '..Player.PlayerData.citizenid..'\n**Ingame ID:** '..Player.PlayerData.cid.. '\n**Name:** '..Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname.. '\n**Job:** '.. 'job' ..'\n**Weapon:** '..weaponName .. '\n**Serial:** '..serial .. '\n**Components Specific:** '.. json.encode(components),	'Weapon Craft  for RSG Framework', 'weapons')
            Wait(1000)
            TriggerClientEvent('ox_lib:notify', src, {title = locale('notify_50'), type = 'inform', duration = 5000 })

            if Config.Debug then print('Weapon components have been successfully updated for the serial:', serial, json.encode(components)) end
        end
    end)

    -- DELETE CUSTOM TABLE
    Wait(100)
    TriggerEvent('rsg-weaponcomp:server:removeComponents_selection', 'DEFAULT', serial) -- update SQL

end)

RegisterNetEvent('rsg-weaponcomp:server:update_selection')
AddEventHandler('rsg-weaponcomp:server:update_selection', function(components, serial)
    local src = source
    -- ADD CUSTOM SELECTION
    MySQL.Async.execute('UPDATE player_weapons SET components_before = @components_before WHERE serial = @serial', {
        ['@components_before'] = json.encode(components),
        ['@serial'] = serial
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('rsg-weaponcomp:client:LoadComponents_selection', src)
        end
    end)
end)

-------------------------------------------
-- update/REMOVE components SQL
-------------------------------------------
RegisterServerEvent('rsg-weaponcomp:server:removeComponents', function(components, weaponName, serial)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if components == 'DEFAULT' then
        MySQL.Async.execute('UPDATE player_weapons SET components = DEFAULT WHERE serial = @serial', {
            ['@serial'] = serial
        }, function(rowsChanged)
            if rowsChanged > 0 then
                sendToDiscord(16753920,	'Craft | WEAPON CUSTEM', '**Citizenid:** '..Player.PlayerData.citizenid..'\n**Ingame ID:** '..Player.PlayerData.cid.. '\n**Name:** '..Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname.. '\n**Job:** '.. 'job' ..'\n**Weapon:** '.. weaponName .. '\n**Serial:** '..serial .. '\n**Components Specific:** '.. '{}',	'Weapon Craft  for RSG Framework', 'weapons')
                Wait(2000)
                TriggerClientEvent('ox_lib:notify', src, {title = locale('notify_51'), type = 'inform', duration = 5000 })

                Wait(100)
                TriggerClientEvent('rsg-weaponcomp:client:LoadComponents', src)

            end
        end)
    end
end)

RegisterServerEvent('rsg-weaponcomp:server:removeComponents_selection', function(components, serial)
    local src = source
    if components == 'DEFAULT' then
        MySQL.Async.execute('UPDATE player_weapons SET components_before = DEFAULT WHERE serial = @serial', {
            ['@serial'] = serial
        }, function()
            TriggerClientEvent('rsg-weaponcomp:client:LoadComponents_selection', src)
        end)
    end
end)

--------------------------------------------
-- CHECK COMPONENTS SQL
--------------------------------------------
RegisterNetEvent('rsg-weaponcomp:server:check_comps') -- EQUIPED
AddEventHandler('rsg-weaponcomp:server:check_comps', function()
    local src = source
    TriggerClientEvent('rsg-weaponcomp:client:LoadComponents', src)
end)

RegisterNetEvent('rsg-weaponcomp:server:check_comps_selection') -- EQUIPED
AddEventHandler('rsg-weaponcomp:server:check_comps_selection', function()
    local src = source
    TriggerClientEvent('rsg-weaponcomp:client:LoadComponents_selection', src)
end)

--------------------------------------------
-- VISION COMPONENTS / IN TEST
--------------------------------------------
RegisterNetEvent('rsg-weaponcomp:server:inspectWeapon')
AddEventHandler('rsg-weaponcomp:server:inspectWeapon', function(weaponHash)
    local src = source
    local stats = getWeaponStats(weaponHash)
    TriggerClientEvent('rsg-weaponcomp:client:viewweapon', src, weaponHash, stats)
end)


RegisterNetEvent('rsg-weaponcomp:server:inspectkitConsume')
AddEventHandler('rsg-weaponcomp:server:inspectkitConsume', function()
    local src = source
    local cashItem = Player.Functions.GetItemByName(Config.RepairItem)

    if not cashItem then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('notify_52'), description = locale('notify_53'), type = 'error', duration = 5000 })
        return
    else
        Player.Functions.RemoveItem(Config.RepairItem, 1, 'custom-weapon')
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[Config.RepairItem], 'remove')
    end
end)
