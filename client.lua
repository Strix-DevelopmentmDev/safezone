local zones = {}
local blips = {}
local uiOpen = false

local function notify(msg)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

RegisterNetEvent("safezone:client:notify", function(msg)
    notify(msg)
end)

local function closeUi()
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "close"
    })
end

local function openUi(data)
    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        data = data
    })
end

RegisterNetEvent("safezone:client:openUi", function(data)
    openUi(data)
end)

local function clearBlips()
    for _, info in pairs(blips) do
        if info.radius and DoesBlipExist(info.radius) then
            RemoveBlip(info.radius)
        end
        if info.center and DoesBlipExist(info.center) then
            RemoveBlip(info.center)
        end
    end
    blips = {}
end

local function rebuildBlips()
    clearBlips()

    for i = 1, #zones do
        local zone = zones[i]
        local cfg = zone.zoneType == "staff" and Config.StaffBlip or Config.SafeBlip

        local radiusBlip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.radius)
        SetBlipColour(radiusBlip, cfg.color)
        SetBlipAlpha(radiusBlip, 90)

        local centerBlip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
        SetBlipSprite(centerBlip, cfg.sprite)
        SetBlipColour(centerBlip, cfg.color)
        SetBlipScale(centerBlip, cfg.scale)
        SetBlipAsShortRange(centerBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.name or cfg.name)
        EndTextCommandSetBlipName(centerBlip)

        blips[zone.id] = {
            radius = radiusBlip,
            center = centerBlip
        }
    end
end

RegisterNetEvent("safezone:client:syncZones", function(serverZones)
    zones = serverZones or {}
    rebuildBlips()

    if uiOpen then
        SendNUIMessage({
            action = "setZones",
            data = zones
        })
    end
end)

RegisterNUICallback("close", function(_, cb)
    closeUi()
    cb("ok")
end)

RegisterNUICallback("createZone", function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    TriggerServerEvent("safezone:server:createZone", {
        name = data.name,
        zoneType = data.zoneType,
        radius = tonumber(data.radius) or Config.DefaultRadius,
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        }
    })

    closeUi()
    cb("ok")
end)

RegisterNUICallback("deleteZone", function(data, cb)
    TriggerServerEvent("safezone:server:deleteZone", data.id)
    cb("ok")
end)

CreateThread(function()
    Wait(1000)
    closeUi()
    TriggerServerEvent("safezone:server:requestZones")
end)

CreateThread(function()
    while true do
        if uiOpen and IsControlJustPressed(0, 322) then -- ESC
            closeUi()
        end
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local inSafe = false

        for i = 1, #zones do
            local zone = zones[i]
            local dist = #(coords - vector3(zone.coords.x, zone.coords.y, zone.coords.z))

            if dist <= Config.DrawDistance then
                sleep = 0

                DrawMarker(
                    28,
                    zone.coords.x, zone.coords.y, zone.coords.z - 0.95,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    zone.radius, zone.radius, 3.0,
                    zone.zoneType == "staff" and 255 or 0,
                    zone.zoneType == "staff" and 50 or 255,
                    zone.zoneType == "staff" and 50 or 0,
                    100,
                    false, false, 2, false, nil, nil, false
                )
            end

            if dist <= zone.radius then
                inSafe = true

                if zone.zoneType == "safe" then
                    DisablePlayerFiring(PlayerId(), true)
                    DisableControlAction(0, 24, true)
                    DisableControlAction(0, 25, true)
                    DisableControlAction(0, 37, true)
                    DisableControlAction(0, 44, true)
                    DisableControlAction(0, 140, true)
                    DisableControlAction(0, 141, true)
                    DisableControlAction(0, 142, true)
                    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                end
            end
        end

        if not inSafe then
            -- nothing to reset right now
        end

        Wait(sleep)
    end
end)