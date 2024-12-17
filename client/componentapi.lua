ComponentApi = {}

-- LIST POSSIBLES CATEGORIES
readComponent = {Components.LanguageWeapons[1], Components.LanguageWeapons[7], Components.LanguageWeapons[5], Components.LanguageWeapons[10], Components.LanguageWeapons[41], Components.LanguageWeapons[11], Components.LanguageWeapons[36],  Components.LanguageWeapons[2], Components.LanguageWeapons[37], Components.LanguageWeapons[27], Components.LanguageWeapons[31], Components.LanguageWeapons[39], Components.LanguageWeapons[38]}
readMaterial = {Components.LanguageWeapons[13], Components.LanguageWeapons[19], Components.LanguageWeapons[3], Components.LanguageWeapons[4], Components.LanguageWeapons[6], Components.LanguageWeapons[9], Components.LanguageWeapons[16], Components.LanguageWeapons[21], Components.LanguageWeapons[24], Components.LanguageWeapons[26], Components.LanguageWeapons[22],  Components.LanguageWeapons[23], Components.LanguageWeapons[32]}
readEngraving = {Components.LanguageWeapons[14], Components.LanguageWeapons[20], Components.LanguageWeapons[40], Components.LanguageWeapons[17], Components.LanguageWeapons[15], Components.LanguageWeapons[12], Components.LanguageWeapons[42], Components.LanguageWeapons[33], Components.LanguageWeapons[8], Components.LanguageWeapons[34] }
-- local readTints = {Components.LanguageWeapons[18], Components.LanguageWeapons[23], Components.LanguageWeapons[25], Components.LanguageWeapons[28], Components.LanguageWeapons[29], Components.LanguageWeapons[30], Components.LanguageWeapons[35],}

ComponentApi.AttachComponentToEntity = function(weaponOrPed, componentModel)
    local componentModelHash = GetWeaponComponentTypeModel(GetHashKey(componentModel))
    if componentModelHash ~= 0 then lib.requestModel(componentModelHash) end
    GiveWeaponComponentToEntity(weaponOrPed, GetHashKey(componentModel), -1, true)
    ApplyShopItemToPed(weaponOrPed, GetHashKey(componentModel), true, true, true)
    if componentModelHash ~= 0 then SetModelAsNoLongerNeeded(componentModelHash) end
end

ComponentApi.AttachComponentsToEntity = function(weaponOrPed, components)
    for _, _componentModel in pairs(components) do
        ComponentApi.AttachComponentToEntity(weaponOrPed, _componentModel)
    end
end

ComponentApi.AttachDefaultComponentsToEntity = function(weaponOrPed, weaponHash)
    local specific = Config.SpecificComponents
    local grouphash = tonumber(GetWeapontypeGroup(weaponHash))

    for _weaponName, _components in pairs(specific) do
        if tonumber(GetHashKey(_weaponName)) ~= tonumber(weaponHash) then goto continue end

        for _componentType, _componentData in pairs(_components) do
            local componentFilter = {
                BARREL = true,
                GRIP = true,
                SIGHT = true,
                CLIP = true,
                MAG = true,
                STOCK = true,
                FRAME_VERTDATA = true,
                TUBE = true,
                TORCH_MATCHSTICK = true,
                GRIPSTOCK = true,
            }

            if componentFilter[_componentType] then 
                ComponentApi.AttachComponentToEntity(weaponOrPed, _componentData[1]) --we are assuming weaponlist have default component at first position
            end
        end
        ::continue::
    end

    -- Todo  Ajust Specific Weapon Parts ---
    -- what does it mean?
end


return ComponentApi