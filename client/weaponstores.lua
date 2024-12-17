weaponObject = nil
currentSerial = nil
currentName = nil
currentWep = nil

local weaponHash = nil
local usedPromptCache = nil

CreateThread(function() 
    for _identifier, _locationData in pairs(Config.CustomsLocations) do
        exports['rsg-core']:createPrompt(
            _identifier, 
            _locationData.promptCoords, 
            RSGCore.Shared.Keybinds[Config.CustomsPromptKey],
            _locationData.label, 
            {
                type = 'client',
                event = 'rsg-weaponcomp:client:weaponStoreCustom',
                args = {
                    _identifier,
                }
            }
        )
    end
end)

local function _createWeaponObject(x, y, z, hash)

    if weaponObject ~= nil and DoesEntityExist(weaponObject) then
        DeleteObject(wepobject)
        weaponObject = nil
    end

    weapon = Citizen.InvokeNative(0x9888652B8BA77F73, hash, 0, x, y, z, false, 1.0) --investigate 6th param - show world model

    if weapon and DoesEntityExist(weapon) then
        SetEntityCoords(weapon, x, y, z) --check if necessary
        SetEntityRotation(weapon, 90.0, 0, 270, 1, true)
    else
        print("Error: Invalid weapon hash:", hash)
        --add cancel customization
    end

    return weapon
end

RegisterNetEvent('rsg-weaponcomp:client:weaponStoreCustom', function(_storeIdentifier)
    if weaponObject ~= nil then return end --failsafe when prompt is pressed again
    local storeConfig = Config.CustomsLocations[_storeIdentifier]
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local playerJobName = PlayerData.job.name
    weaponHash = GetPedCurrentHeldWeapon(cache.ped)

    local weaponInHands = exports['rsg-weapons']:weaponInHands()
    local weaponName = Citizen.InvokeNative(0x89CF5FF3D363311E, weaponHash, Citizen.ResultAsString())
    local serial = weaponInHands[weaponHash]
    local wep = GetCurrentPedWeaponEntityIndex(cache.ped, 0)

    currentSerial = serial
    currentName = weaponName
    currentWep = wep

    usedPromptCache = exports['rsg-core']:getPrompt(_storeIdentifier) --try to disable and reenable (investigate possible bug in rsg-core prompt)
    
    if currentSerial == nil or weaponHash == -1569615261 then --hash for unarmed
        lib.notify({ title = locale('notify_1'), description = locale('notify_2'), type = 'error', icon = 'fa-solid fa-gun', iconAnimation = 'shake', duration = 7000})
        return 
    end

    if storeConfig.requireJob and playerJobName ~= storeConfig.job then
        lib.notify({ title = locale('notify_3'), description = locale('notify_4'), type = 'error', icon = 'fa-solid fa-gun', iconAnimation = 'shake', duration = 7000})
        return
    end

    StartCam(storeConfig.tableCoords.x+0.2, storeConfig.tableCoords.y+0.15 , storeConfig.tableCoords.z+1.0, storeConfig.tableCoords.w)
    Wait(500)
    mainComponentMenu(weaponHash)
    weaponObject = _createWeaponObject(storeConfig.tableCoords.x, storeConfig.tableCoords.y, storeConfig.tableCoords.z, weaponHash)
    ComponentApi.AttachDefaultComponentsToEntity(weaponObject, weaponHash)

    RSGCore.Functions.TriggerCallback('rsg-weapons:server:getweaponinfo', function(result)
        if result and #result > 0 then
            local components = json.decode(result[1].components)
            if next(components) ~= nil then
                ComponentApi.AttachComponentsToEntity(weaponObject, components)
            end
        else
            lib.print.error('Weapon does not exists in DB')
            lib.notify({ title = locale('notify_1'), description = locale('notify_2'), type = 'error', icon = 'fa-solid fa-gun', iconAnimation = 'shake', duration = 7000})
            TriggerEvent('rsg-weaponcomp:client:exitCustomsCamera')
        end
    end, currentSerial)
end)

RegisterNetEvent('rsg-weaponcomp:client:exitCustomsCamera', function()
    ExitCam()

    if weaponObject ~= nil and DoesEntityExist(weaponObject) then
        DeleteObject(weaponObject)
        weaponObject = nil
    end

    MenuData.CloseAll()

    DoScreenFadeOut(1000)
    Wait(0)
    DoScreenFadeIn(1000)

    FreezeEntityPosition(cache.ped, false)
    ClearPedTasks(cache.ped)
    ClearPedSecondaryTask(cache.ped)
    LocalPlayer.state:set("inv_busy", false, true)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    if weaponObject ~= nil then
        DeleteObject(weaponObject)
    end

    ExitCam()
    MenuData.CloseAll()
   
    FreezeEntityPosition(cache.ped , false)
    LocalPlayer.state:set("inv_busy", false, true)
    usedPromptCache = nil
end)