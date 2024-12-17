local camera = nil

function StartCam(x, y, z, zoom)
    if camera then
        DestroyCam(camera, true)
        camera = nil
    end
    camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x, y, z, -90.00, 00.00, -180.0, zoom, true, 0)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 2000, true, true)
end

function ExitCam()
    RenderScriptCams(false, true, 2000, true, false)
    DestroyCam(camera, false)
    camera = nil
    DestroyAllCams(true)
end

function GameCam(hash, move_coords, objecthash)
    local weaponType = GetWeaponType(objecthash)
    local words = getWordsFromHash(hash)

    for _, word in ipairs(words) do
        if weaponType == "LONGARM" then
            if string.match(word, "SIGHT") then
                StartCam(move_coords.x+0.15, move_coords.y-0.10, move_coords.z+0.30, 60.0)
            elseif string.match(word, "SCOPE") then
                StartCam(move_coords.x+0.20, move_coords.y-0.05, move_coords.z+0.30, 60.0)

            elseif string.match(word, "WRAP") then
                StartCam(move_coords.x+0.20, move_coords.y+0.00, move_coords.z+0.40, 90.0-5.0)
            elseif string.match(word, "GRIP") then
                StartCam(move_coords.x+0.20, move_coords.y+0.00, move_coords.z+0.40, 90.0-5.0)

            elseif string.match(word, "BARREL") then
                StartCam(move_coords.x+0.40, move_coords.y+0.00, move_coords.z+0.40, 90.0-15.0)
            elseif string.match(word, "TRIGGER") then
                 StartCam(move_coords.x+0.00, move_coords.y+0.00, move_coords.z+0.30, 60.0)
            elseif string.match(word, "CYLINDER") then
                StartCam(move_coords.x+0.0, move_coords.y+0.00, move_coords.z+0.30, 75.0)
            else
                StartCam(move_coords.x+0.20, move_coords.y, move_coords.z+0.5, 75.0)
            end
        elseif weaponType == "SHOTGUN" then
            if string.match(word, "SIGHT") then
                StartCam(move_coords.x+0.15, move_coords.y-0.10, move_coords.z+0.20, 60.0)
            elseif string.match(word, "SCOPE") then
                StartCam(move_coords.x+0.20, move_coords.y-0.05, move_coords.z+0.30, 60.0)
            elseif string.match(word, "WRAP") then
                StartCam(move_coords.x+0.20, move_coords.y+0.00, move_coords.z+0.40, 90.0-10.0)
            elseif string.match(word, "GRIP") then
                StartCam(move_coords.x+0.20, move_coords.y+0.00, move_coords.z+0.40, 90.0-10.0)
            elseif string.match(word, "BARREL") then
                StartCam(move_coords.x+0.40, move_coords.y+0.00, move_coords.z+0.40, 90.0-15.0)
            elseif string.match(word, "TRIGGER") then
                 StartCam(move_coords.x+0.00, move_coords.y+0.00, move_coords.z+0.30, 60.0)
            elseif string.match(word, "CYLINDER") then
                StartCam(move_coords.x+0.0, move_coords.y+0.00, move_coords.z+0.30, 75.0)
            else
                StartCam(move_coords.x+0.20, move_coords.y, move_coords.z+0.5, 75.0)
            end
        elseif weaponType == "SHORTARM" then
            if string.match(word, "GRIP") then
                StartCam(move_coords.x-0.08, move_coords.y+0.02, move_coords.z+0.25, 60.0)
            elseif string.match(word, "SIGHT") then
                StartCam(move_coords.x-0.01, move_coords.y-0.05, move_coords.z+0.20, 60.0)
            elseif string.match(word, "CLIP") then
                StartCam(move_coords.x+0.03, move_coords.y-0.02, move_coords.z+0.25, 60.0)
            else
                StartCam(move_coords.x+0.08, move_coords.y, move_coords.z+0.30, 90.0-10.0)
            end
        elseif weaponType == "GROUP_BOW" then
            StartCam(move_coords.x-0.02, move_coords.y-0.1, move_coords.z+0.4, 90.0)
        elseif weaponType == "MELEE_BLADE" then
            StartCam(move_coords.x+0.10, move_coords.y-0.15, move_coords.z+0.4, 90.0-15)
        end
        if Config.Debug then
            print('Cam Move', weaponType, hash, word, move_coords.x, move_coords.y, move_coords.z)
        end
    end
end

RegisterNetEvent("rsg-weaponcomp:client:StartCamObj", function(hash, coords, objecthash)
    while not HasCollisionLoadedAroundEntity(cache.ped) do
        Wait(500)
    end

    DoScreenFadeOut(100)
    Wait(100)
    DoScreenFadeIn(100)
    GameCam(hash, coords, objecthash)
    if Config.Debug then print('ComponentDetailCamera', coords.x, coords.y, coords.z) end
end)

local c_zoom = nil
local c_offset = nil
local playerHeading = nil
local weaponCamera = nil

function StartCamClean(zoom, offset)
    DestroyAllCams(true)

    DoScreenFadeOut(1000)
    Wait(0)
    DoScreenFadeIn(1000)

    local coords = GetEntityCoords(cache.ped)
    local zoomOffset = tonumber(zoom)
    local angle

    if playerHeading == nil then
        playerHeading = GetEntityHeading(cache.ped)
        angle = playerHeading * math.pi / 180.0
    else
        angle = playerHeading * math.pi / 180.0
    end

    local pos = {
        x = coords.x - tonumber(zoomOffset * math.sin(angle)),
        y = coords.y + tonumber(zoomOffset * math.cos(angle)),
        z = coords.z + offset
    }

    if not weaponCamera then
        local camera_pos = GetObjectOffsetFromCoords(pos.x, pos.y, pos.z, 0.0, 1.0, 1.0, 1.0)

        weaponCamera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z + 0.5, 300.00, 0.00, 0.00, 50.00, false, 0)
        local pCoords = GetEntityCoords(cache.ped)
        PointCamAtCoord(weaponCamera, pCoords.x, pCoords.y, pCoords.z + offset)

        SetCamActive(weaponCamera, true)
        RenderScriptCams(true, true, 1000, true, true)

    end
end