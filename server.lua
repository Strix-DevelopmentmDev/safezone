local res = GetCurrentResourceName()
local zones = {}

local function saveZones()
    SaveResourceFile(res, "zones.json", json.encode(zones, { indent = true }), -1)
end

local function loadZones()
    local data = LoadResourceFile(res, "zones.json")

    if not data or data == "" then
        zones = {}
        saveZones()
        return
    end

    local ok, decoded = pcall(json.decode, data)
    if not ok or type(decoded) ~= "table" then
        print("^1[safezone] zones.json was invalid, resetting it.^7")
        zones = {}
        saveZones()
        return
    end

    zones = decoded
end

local function syncZones(target)
    TriggerClientEvent("safezone:client:syncZones", target, zones)
end

local function canOpen(src)
    if not Config.UseAcePerms then
        return true
    end

    return IsPlayerAceAllowed(src, Config.AdminAce) or IsPlayerAceAllowed(src, Config.StaffAce)
end

local function canMakeSafe(src)
    if not Config.UseAcePerms then
        return true
    end

    return IsPlayerAceAllowed(src, Config.AdminAce)
end

local function canMakeStaff(src)
    if not Config.UseAcePerms then
        return true
    end

    return IsPlayerAceAllowed(src, Config.StaffAce) or IsPlayerAceAllowed(src, Config.AdminAce)
end

loadZones()

RegisterCommand(Config.Command, function(source)
    if source == 0 then
        print("^1This command is in-game only.^7")
        return
    end

    if not canOpen(source) then
        TriggerClientEvent("safezone:client:notify", source, "No permission.")
        return
    end

    TriggerClientEvent("safezone:client:openUi", source, {
        zones = zones,
        canMakeSafe = canMakeSafe(source),
        canMakeStaff = canMakeStaff(source)
    })
end, false)

RegisterNetEvent("safezone:server:createZone", function(data)
    local src = source
    if type(data) ~= "table" then return end

    local zoneType = data.zoneType == "staff" and "staff" or "safe"

    if zoneType == "safe" and not canMakeSafe(src) then
        TriggerClientEvent("safezone:client:notify", src, "No permission for safe zones.")
        return
    end

    if zoneType == "staff" and not canMakeStaff(src) then
        TriggerClientEvent("safezone:client:notify", src, "No permission for staff zones.")
        return
    end

    local radius = tonumber(data.radius) or Config.DefaultRadius
    local coords = data.coords
    local name = tostring(data.name or (zoneType == "staff" and "Staff Sit Area" or "Safe Zone"))

    if type(coords) ~= "table" or not coords.x or not coords.y or not coords.z then
        print("^1[safezone] createZone got invalid coords.^7")
        return
    end

    zones[#zones + 1] = {
        id = ("zone_%s_%s"):format(os.time(), math.random(1000, 9999)),
        name = name,
        zoneType = zoneType,
        radius = radius,
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        }
    }

    saveZones()
    syncZones(-1)
    TriggerClientEvent("safezone:client:notify", src, "Zone created.")
end)

RegisterNetEvent("safezone:server:deleteZone", function(zoneId)
    local src = source
    if type(zoneId) ~= "string" then return end

    for i = 1, #zones do
        local zone = zones[i]

        if zone.id == zoneId then
            local zoneType = zone.zoneType or "safe"

            if zoneType == "safe" and not canMakeSafe(src) then
                TriggerClientEvent("safezone:client:notify", src, "No permission.")
                return
            end

            if zoneType == "staff" and not canMakeStaff(src) then
                TriggerClientEvent("safezone:client:notify", src, "No permission.")
                return
            end

            table.remove(zones, i)
            saveZones()
            syncZones(-1)
            TriggerClientEvent("safezone:client:notify", src, "Zone deleted.")
            return
        end
    end
end)

RegisterNetEvent("safezone:server:requestZones", function()
    syncZones(source)
end)

AddEventHandler("onResourceStart", function(name)
    if name ~= res then return end
    Wait(500)
    syncZones(-1)
end)