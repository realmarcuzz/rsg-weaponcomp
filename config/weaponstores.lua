Config = Config or {}

Config.Debug = false 

Config.CustomsPromptKey = 'J' -- must be available in rsg-core\shared\keybinds.lua
Config.CustomsMenuResource = 'menu_base' -- 'menu_base' or 'rsg-menubase'
Config.StartCamObj = true
Config.Notify = true

Config.Payment = 'money' --  'item' or  'money'
Config.PaymentType = 'cash' -- Payment = money you can select 'cash' or 'bloodmoney' / Payment = item you can select 'cash' or 'bloodmoney'
Config.RemovePrice = .3 -- (0 - 1) = 100 % cost remove component 120%
Config.animationSave = 10000 -- Waiting time for application or removal components

Config.Command = { --move outside store config
    ['inspect']       = "w_inspect",
    ['loadweapon']    = "loadweapon",
  }

Config.RepairItem = 'weapon_repair_kit' --move outside store config

Config.Webhooks = {
    ['weaponCustom'] = '',
}

Config.CustomsLocations = {
    val_custom = {
        label = 'Valentine Customs',
        promptCoords = vector3(-281.3202, 778.9372, 119.5440),
        tableCoords = vector4(-281.3081, 779.7899, 119.6094, 40.0),
        requireJob = false,
        job = 'valweaponsmith',
    },
    rho_custom = {
        label = 'Rhodes Customs',
        promptCoords = vector3(1321.98, -1323.23, 77.89),
        tableCoords = vector4(1322.368, -1322.256, 77.937, 75.0),
        requireJob = false,
        job = 'rhoweaponsmith',
    },
    tum_custom = {
        label = 'Customs',
        promptCoords = vector3(-5508.35, -2964.26, -0.54),
        tableCoords = vector4(-5507.34, -2963.81, -0.59, 75.0),
        requireJob = false,
        job = 'tumgunsmith',
    },
    std_custom = {
        label = 'Customs',
        promptCoords = vector3(2716.06, -1287.55, 49.63),
        tableCoords = vector4(2715.55322265625, -1286.741455078125, 49.6799087524414, 75.0),
        requireJob = false,
        job = 'stdgunsmith',
    },
    ann_custom = {
        label = 'Customs',
        promptCoords = vector3(2948.48, 1319.55, 44.82),
        tableCoords = vector4(2947.630, 1319.90, 44.86, 75.0),
        requireJob = false,
        job = 'anngunsmith',
    },
    --[[ 
    str_custom = {
        name = 'Customs',
        promptCoords = vector3(-1752.0, -386.7, 156.52),
        tableCoords = vector4(-1752.85, -386.86, 156.48, 60.0),
        requireJob = false,
        job = 'strgunsmith',
    },
    blk_custom = {
        name = 'Customs',
        promptCoords = vector3(-859.30, -1277.90, 43.66),
        tableCoords = vector4(-859.31, -1278.66, 43.50, 6.0),
        requireJob = false,
        job = 'blkgunsmith',
    },
    gua_custom ={
        name = 'Customs',
        promptCoords = vector3(1322.02, -6980.69, 61.97),
        tableCoords = vector4(1322.02, -6980.69, 61.97, 6.0),
        requireJob = false,
        job = 'guagunsmith',
    }, 
    ]]--
}