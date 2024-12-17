function GetWeaponType(objecthash)
    local weapon_type = nil
    if objecthash ~= nil then
        if GetHashKey('GROUP_REPEATER') == GetWeapontypeGroup(objecthash) then
            weapon_type = "LONGARM"
        elseif GetHashKey('GROUP_SHOTGUN') == GetWeapontypeGroup(objecthash) then
            weapon_type = "SHOTGUN"
        elseif GetHashKey('GROUP_HEAVY') == GetWeapontypeGroup(objecthash) then
            weapon_type = "LONGARM"
        elseif GetHashKey('GROUP_RIFLE') == GetWeapontypeGroup(objecthash) then
            weapon_type = "LONGARM"
        elseif GetHashKey('GROUP_SNIPER') == GetWeapontypeGroup(objecthash) then
            weapon_type = "LONGARM"
        elseif GetHashKey('GROUP_REVOLVER') == GetWeapontypeGroup(objecthash) then
            weapon_type = "SHORTARM"
        elseif GetHashKey('GROUP_PISTOL') == GetWeapontypeGroup(objecthash) then
            weapon_type = "SHORTARM"
        elseif GetHashKey('GROUP_BOW') == GetWeapontypeGroup(objecthash) then
            weapon_type = "GROUP_BOW"
        elseif GetHashKey('GROUP_MELEE') == GetWeapontypeGroup(objecthash) then
            weapon_type = "MELEE_BLADE"
        end
    end
    return weapon_type
end

function getWordsFromHash(hash)
    local words = {}
    for word in hash:gmatch("[^|']+") do
        table.insert(words, word)
    end
    return words
end

function tableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end