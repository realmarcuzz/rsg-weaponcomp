RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

RegisterNetEvent("rsg-weaponcomp:client:animationSaved", function(objecthash)
    if weaponObject ~= nil and DoesEntityExist(weaponObject) then
        DeleteObject(weaponObject)
        weaponObject = nil
    else
        if Config.Debug then print("No hay objeto para eliminar o ya ha sido eliminado -- Animacion save") end
    end

    local weapon_type = GetWeaponType(objecthash)
    local boneIndex2 = GetEntityBoneIndexByName(cache.ped, "SKEL_L_Finger00")
    local Cloth = CreateObject(GetHashKey('s_balledragcloth01x'), GetEntityCoords(cache.ped), false, true, false, false, true)
    local animDict = nil
    local animName = nil

    if weapon_type == 'SHORTARM' then
        animDict = "mech_inspection@weapons@shortarms@volcanic@base"
        animName = "clean_loop"
        c_zoom = 0.85
        c_offset = 0.10
    elseif weapon_type == 'LONGARM' then
        animDict = "mech_inspection@weapons@longarms@sniper_carcano@base"
        animName = "clean_loop"
        c_zoom = 1.5
        c_offset = 0.20
    elseif weapon_type == 'SHOTGUN' then
        animDict = "mech_inspection@weapons@longarms@shotgun_double_barrel@base"
        animName = "clean_loop"
        c_zoom = 1.2
        c_offset = 0.15
    elseif weapon_type == 'GROUP_BOW' then
        c_zoom = 1.5
        c_offset = 0.15
    elseif weapon_type == 'MELEE_BLADE' then
        c_zoom = 1.2
        c_offset = 0.15
    end

    StartCamClean(c_zoom, c_offset)
    Wait(100)
    if animDict ~= nil and animName ~= nil then
      AttachEntityToEntity(Cloth, cache.ped, boneIndex2, 0.02, -0.035, 0.00, 20.0, -24.0, 165.0, true, false, true, false, 0, true)
      lib.progressBar({
        duration = tonumber(Config.animationSave),
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat= true, mouse= false, sprint = true, },
        anim = { dict = animDict, clip = animName, flag = 15, },
        label = locale('label_36'),
      })
      SetEntityAsNoLongerNeeded(Cloth)
      DeleteEntity(Cloth)
    end
    TriggerEvent('rsg-weaponcomp:client:loadComponents')
    TriggerEvent('rsg-weaponcomp:client:exitCustomsCamera')
end)

RegisterNetEvent("rsg-weaponcomp:client:loadComponents", function()
    local weaponHash = GetPedCurrentHeldWeapon(cache.ped)
    local weaponInHands = exports['rsg-weapons']:weaponInHands()
    local wepSerial = weaponInHands[weaponHash]
    local wep = GetCurrentPedWeaponEntityIndex(cache.ped, 0)
   
    RSGCore.Functions.TriggerCallback('rsg-weapons:server:getweaponinfo', function(result)
        local components = {}
        if result and #result > 0 then
            components = json.decode(result[1].components)
        end
        if next(components) ~= nil and wep ~= nil then
            if Config.Debug then print( 'rsg-weaponcomp:client:loadComponents"')  print('weaponHash: ', weaponHash, 'component: ', json.encode(components)) end
            for category, hashname in pairs(components) do
    
                if tableContains(readComponent, category)  then
                    RemoveWeaponComponentFromPed(wep, GetHashKey(hashname), -1)
                end
                if tableContains(readMaterial, category) then
                    RemoveWeaponComponentFromPed(wep, GetHashKey(hashname), -1)
                end
                if tableContains(readEngraving, category) then
                    RemoveWeaponComponentFromPed(wep, GetHashKey(hashname), -1)
                end
            end
            ComponentApi.AttachComponentsToEntity(cache.ped, components)
        end
    end, wepSerial)
end)
