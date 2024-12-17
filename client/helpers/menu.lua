local creatorCache = {}

local function resetCache()
    creatorCache = {}
end

MenuData = {}
if Config.CustomsMenuResource == 'rsg-menubase' then
    TriggerEvent("rsg-menubase:getData", function(call)
        MenuData = call
    end)
elseif Config.CustomsMenuResource == 'menu_base' then
    TriggerEvent("menu_base:getData", function(call)
        MenuData = call
    end)
end

local CalculatePrice = function(originalComponents, creatorComponents)
    local priceComp = 0.0
    local priceMat = 0.0
    local priceEng = 0.0
    -- local priceTint = 0.0
    local totalprice = 0.0

    Table = {}
    for _componentType, _componentName in pairs(creatorComponents) do
        if originalComponents[_componentType] and originalComponents[_componentType] ~= _componentName then
            priceComp = priceComp + Config.RemovePrice -- add removal price for swapping components
        end
        Table[_componentType] = _componentName
    end

    if Table ~= nil then
        for category, hashname in pairs(Table) do


            local processedComponents = {}
            for weaponType, weapons in pairs(Components.weapons_comp_list) do
                for weaponName, categories in pairs(weapons) do
                    if categories[category] then
                        for _, component in ipairs(categories[category]) do
                            if component.hashname == hashname and component.price ~= nil then
                                if not processedComponents[component.hashname] then
                                    priceComp = priceComp + component.price
                                    processedComponents[component.hashname] = true
                                end
                            end
                        end
                    end
                end
            end

            local processedMaterials = {}
            for weaponType, categories in pairs(Components.SharedComponents) do
                if categories[category] then
                    for _, material in ipairs(categories[category]) do
                        if material.hashname == hashname and material.price ~= nil then
                            if not processedMaterials[material.hashname] then
                                priceMat = priceMat + material.price
                                processedMaterials[material.hashname] = true
                            end
                        end
                    end
                end
            end

            local processedEngravings = {}
            for weaponType, categories in pairs(Components.SharedEngravingsComponents) do
                if categories[category] then
                    for _, engraving in ipairs(categories[category]) do
                        if engraving.hashname == hashname and engraving.price ~= nil then
                            if not processedEngravings[engraving.hashname] then
                                priceEng = priceEng + engraving.price
                                processedEngravings[engraving.hashname] = true
                            end
                        end
                    end
                end
            end

            --[[ for weaponType, categories in pairs(Components.SharedTintsComponents) do
                if categories[category] then
                    for _, tint in ipairs(categories[category]) do
                        if tint.hashname == hashname and tint.price ~= nil then
                            priceTint = priceTint + tint.price
                        end
                    end
                end
            end ]]--

        end
        Wait(0)
    end

    if Config.Debug then print('totalprice', priceComp, priceMat, priceEng) end -- , priceTint) end
    totalprice = priceComp + priceMat + priceEng -- + priceTint

    Wait(0)
    return totalprice
end

OpenComponentMenu = function(objecthash)
    local elements = {}
    local weapon_type = GetWeaponType(objecthash)
    local weaponData = Components.weapons_comp_list[weapon_type] or {}
    local weaponComponents = weaponData[currentName] or {}
    local coords = GetEntityCoords(weaponObject)

    for category, componentList in pairs(weaponComponents) do
        local newElement = {
            label = category,
            value = 1,
            type = "slider",
            min = 1,
            max = #componentList,
            category = category,
            components = {}
        }

        for i, component in ipairs(componentList) do
            if HasWeaponGotWeaponComponent(weaponObject, component.hashname) then
                newElement.value = i
            end
            table.insert(newElement.components, {label = component.title, value = component.hashname, price = component.price})
        end

        table.insert(elements, newElement)
    end

    MenuData.Open('default', GetCurrentResourceName(), 'component_weapon_menu', { title = locale('title_18'), subtext = locale('subtext_19') .. currentName, align = "bottom-left", elements = elements, itemHeight = "2vh",
    }, function(data, menu)

        if data.current then
            local selectedCategory = data.current.category
            local selectedIndex = data.current.value
            local selectedHash = nil

            if selectedIndex > 0 and selectedIndex <= #data.current.components then
                selectedHash = data.current.components[selectedIndex].value
             --   Citizen.InvokeNative(0xD3A7B003ED343FD9, weaponObject, GetHashKey(selectedHash), true, true, true)
            end

            if Config.Debug then print('selected', selectedHash) end
            if selectedHash ~= creatorCache[selectedCategory] then
                creatorCache[selectedCategory] = selectedHash
                ComponentApi.AttachComponentToEntity(weaponObject, selectedHash)
                if Config.StartCamObj == true then
                    TriggerEvent('rsg-weaponcomp:client:StartCamObj', selectedHash, coords, objecthash)
                end
            end
        end
        menu.refresh()
    end, function(data, menu)
        menu.close()
        mainComponentMenu(objecthash)
    end)
end

OpenMaterialMenu = function(objecthash)
    local weapon_type = GetWeaponType(objecthash)
    local elements = {}
    local weaponData = Components.SharedComponents[weapon_type] or {}
    local coords = GetEntityCoords(weaponObject)

    for category, materialList in pairs(weaponData) do
        local newElement = {
            label = category,
            value = 1,
            type = "slider",
            min = 1,
            max = #materialList,
            category = category,
            materials = {}
        }

        for i, material in ipairs(materialList) do
            if HasWeaponGotWeaponComponent(weaponObject, material.hashname) then
                newElement.value = i
            end
            table.insert(newElement.materials, {label = material.title, value = material.hashname, price = material.price})
        end

        table.insert(elements, newElement)

    end

    MenuData.Open('default', GetCurrentResourceName(), 'material_weapon_menu', { title = locale('title_20'), subtext = locale('subtext_21') .. currentName, align = "bottom-left", elements = elements, itemHeight = "2vh",
    }, function(data, menu)
        if data.current then
            local selectedCategory = data.current.category
            local selectedIndex = data.current.value
            local selectedHash = nil

            if selectedIndex > 0 and selectedIndex <= #data.current.materials then
                selectedHash = data.current.materials[selectedIndex].value
            end
            if Config.Debug then print( 'selected', selectedHash) end
            if selectedHash ~= creatorCache[selectedCategory] then
                creatorCache[selectedCategory] = selectedHash
                ComponentApi.AttachComponentToEntity(weaponObject, selectedHash)
                if Config.StartCamObj == true then
                    TriggerEvent('rsg-weaponcomp:client:StartCamObj', selectedHash, coords, objecthash)
                end
            end
        end
        menu.refresh()

    end, function(data, menu)
        menu.close()
        mainComponentMenu(objecthash)
    end)
end

OpenEngravingMenu = function(objecthash)
    local weapon_type = GetWeaponType(objecthash)
    local elements = {}
    local weaponData = Components.SharedEngravingsComponents[weapon_type] or {}
    local coords = GetEntityCoords(weaponObject)

    for category, engravingList in pairs(weaponData) do
        local newElement = {
            label = category,
            value = 1,
            type = "slider",
            min = 1,
            max = #engravingList,
            category = category,
            engravings = {}
        }

        for i, engraving in ipairs(engravingList) do
            if HasWeaponGotWeaponComponent(weaponObject, engraving.hashname) then
                newElement.value = i
            end
            table.insert(newElement.engravings, {label = engraving.title, value = engraving.hashname, price = engraving.price})
        end

        table.insert(elements, newElement)
    end

    MenuData.Open('default', GetCurrentResourceName(), 'engraving_weapon_menu', { title = locale('title_22'), subtext = locale('subtext_23') .. currentName, align = "bottom-left", elements = elements, itemHeight = "2vh",
    }, function(data, menu)
        if data.current then
            local selectedCategory = data.current.category
            local selectedIndex = data.current.value
            local selectedHash = nil

            if selectedIndex > 0 and selectedIndex <= #data.current.engravings then
                selectedHash = data.current.engravings[selectedIndex].value
            end

            if Config.Debug then print( 'selected', selectedHash) end
            if selectedHash ~= creatorCache[selectedCategory] then
                creatorCache[selectedCategory] = selectedHash
                ComponentApi.AttachComponentToEntity(weaponObject, selectedHash)
                if Config.StartCamObj == true then
                    TriggerEvent('rsg-weaponcomp:client:StartCamObj', selectedHash, coords, objecthash)
                end
            end
        end
        menu.refresh()

    end, function(data, menu)
        menu.close()
        mainComponentMenu(objecthash)
    end)
end

--[[ OpenTintsMenu = function(objecthash)
    TriggerServerEvent("rsg-weaponcomp:server:check_comps_selection")
    Wait(0)

    local weapon_type = GetWeaponType(objecthash)
    local elements = {}
    local weaponData = Components.SharedTintsComponents[weapon_type] or {}
    local coords = GetEntityCoords(weaponObject)

    for category, tintsList in pairs(weaponData) do
        local newElement = {
            label = category,
            value = 1,
            type = "slider",
            min = 1,
            max = #tintsList,
            category = category,
            tints = {}
        }

        for index, tint in ipairs(tintsList) do
            table.insert(newElement.tints, {label = tint.title, value = tint.hashname, price = tint.price})
        end
        table.insert(elements, newElement)
    end
    local resource = GetCurrentResourceName()
    MenuData.Open('default', resource, 'tints_weapon_menu', { title = locale('title_24'), subtext = locale('subtext_25') .. currentName, align = "bottom-left", elements = elements, itemHeight = "2vh",
    }, function(data, menu)

        if data.current then
            local selectedCategory = data.current.category
            local selectedIndex = data.current.value
            local selectedHash = nil

            if selectedIndex > 0 and selectedIndex <= #data.current.tints then
                selectedHash = data.current.tints[selectedIndex].value
            end

            if Config.Debug then print( 'selected', selectedHash) end
            if selectedHash ~= creatorCache[selectedCategory] then
                creatorCache[selectedCategory] = selectedHash
                TriggerEvent("rsg-weaponcomp:client:update_selection", creatorCache)
                if Config.StartCamObj == true then
                    TriggerEvent('rsg-weaponcomp:client:StartCamObj', selectedHash, coords, objecthash)
                end
            end
        end
        menu.refresh()
    end,
    function(data, menu)
        menu.close()
        mainCompMenu(objecthash)
    end)
end ]]--

local mainWeaponCompMenus = {
    ["component"] = function(objecthash) OpenComponentMenu(objecthash) end,
    ["material"] = function(objecthash) OpenMaterialMenu(objecthash) end,
    ["engraving"] = function(objecthash) OpenEngravingMenu(objecthash) end,
    -- ["tints"] = function(objecthash) OpenTintsMenu(objecthash) end,
    ["applycommponent"] = function(objecthash) ButtomApplyAllComponents(objecthash) end,
    ["removecommponent"] = function(objecthash) ButtomRemoveAllComponents(objecthash) end,
    ["exitcommponent"] = function() TriggerEvent('rsg-weaponcomp:client:ExitCam') end
}

mainComponentMenu = function(weaponObjectHash)
    MenuData.CloseAll()
    FreezeEntityPosition(cache.ped, true)
    LocalPlayer.state:set("inv_busy", true, true)

    local elements = {
        {label = locale('label_10'), value = 'component', desc = ""},
        {label = locale('label_11'), value = 'material', desc = ""},
        {label = locale('label_12'), value = 'engraving',  desc = ""},
        -- {label = locale('label_13'), value = 'tints', desc = ""},
        {label = locale('label_14'), value = 'applycommponent', desc = ""},
        {label = locale('label_15'), value = 'removecommponent', desc = ""},
        {label = locale('label_16'), value = 'exitcommponent', desc = ""},
    }

    local resource = GetCurrentResourceName()
    MenuData.Open('default', resource, 'main_weapons_creator_menu', {
        title = locale('title_17'),
        subtext = 'Options ',
        align = "bottom-left",
        elements = elements,
        itemHeight = "2vh",
    }, function(data, menu)
        local action = mainWeaponCompMenus[data.current.value]
        if action then
            action(weaponObjectHash)
        else
            print('Error: Acción:', data.current.value)
        end

    end, function(data, menu)
        menu.close()
        TriggerEvent('rsg-weaponcomp:client:exitCustomsCamera')
        resetCache()
        Wait(1000)
    end)
end

local _combineFinalTableForSave = function(original, creator)
    local finalComponents = {}
    for key, value in pairs(original) do
        finalComponents[key] = value
    end

    for key, value in pairs(creator) do
        finalComponents[key] = value
    end    

    return finalComponents
end

ButtomApplyAllComponents = function (objecthash)

    MenuData.CloseAll()

    local promise = promise.new()
    RSGCore.Functions.TriggerCallback('rsg-weapons:server:getweaponinfo', function(result)
        local savedComponents = {}
        if result and #result > 0 then
            for i = 1, #result do
                savedComponents = json.decode(result[i].components)
            end
            promise:resolve(savedComponents)
        end
    end, currentSerial)

    local savedComponents = Citizen.Await(promise)
    local currentPrice = CalculatePrice(savedComponents, creatorCache)

    if currentPrice == 0.0 or savedComponents == nil then TriggerEvent('rsg-weaponcomp:client:exitCustomsCamera') return end
    if Config.Debug then print('currentPrice '.. currentPrice) end

    local options = {
        {   label = locale('label_26'),
            type = 'select',
            options = {
                { value = 'yes', label = locale('label_27') },
                { value = 'no', label = locale('label_28') }
            },
            required = true,
        },
    }
    local input = lib.inputDialog(locale('label_29').. tonumber(currentPrice) .. locale('label_30'), options)

    if not input then TriggerEvent('rsg-weaponcomp:client:exitCustomsCamera') return end
    if input[1] == 'no' then TriggerEvent('rsg-weaponcomp:client:exitCustomsCamera') return end

    if input[1] == 'yes' then
        local data = _combineFinalTableForSave(savedComponents, creatorCache)
        TriggerServerEvent('rsg-weaponcomp:server:price', currentPrice, objecthash)
        Wait(1000)
        TriggerServerEvent("rsg-weaponcomp:server:apply_weapon_components", data, currentName, currentSerial)
        Wait(100)
        resetCache()
    end
    savedComponents = nil
end

ButtomRemoveAllComponents = function (objecthash)
    MenuData.CloseAll()

    local promise = promise.new()
    RSGCore.Functions.TriggerCallback('rsg-weapons:server:getweaponinfo', function(result)
        local savedComponents = {}
        if result and #result > 0 then
            for i = 1, #result do
                savedComponents = json.decode(result[i].components)
            end
            promise:resolve(savedComponents)
        end
    end, currentSerial)

    local savedComponents = Citizen.Await(promise)
    local currentRemove = CalculatePrice(savedComponents, creatorCache)
    if currentRemove == 0.0 or savedComponents == nil then TriggerEvent('rsg-weaponcomp:client:exitCustomsCamera') return end

    local options = {
        {   label = locale('label_31'),
            type = 'select',
            options = {
                { value = 'yes', label = locale('label_32') },
                { value = 'no', label = locale('label_33') }
            },
            required = true,
        },
    }

    local input = lib.inputDialog(locale('label_34').. tonumber(currentRemove) .. locale('label_35'), options)
    if not input then TriggerEvent('rsg-weaponcomp:client:exitCustomsCamera') return end
    if input[1] == 'no' then TriggerEvent('rsg-weaponcomp:client:exitCustomsCamera') return end

    if input[1] == 'yes' then

        TriggerServerEvent('rsg-weaponcomp:server:price', currentRemove, objecthash)
        Wait(1000)
        TriggerServerEvent("rsg-weaponcomp:server:removeComponents", "DEFAULT", currentName, currentSerial) -- update SQL
        Wait(100)
        resetCache()
    end
    savedComponents = nil
end