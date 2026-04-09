Config = {}

Config.Command = "safezone"

-- turn perms on/off
Config.UseAcePerms = false

Config.AdminAce = "safezone.admin"
Config.StaffAce = "safezone.staff"

Config.DefaultRadius = 25.0
Config.DrawDistance = 120.0

Config.SafeBlip = {
    sprite = 280,
    color = 2,
    scale = 0.9,
    name = "Safe Zone"
}

Config.StaffBlip = {
    sprite = 487,
    color = 1,
    scale = 0.9,
    name = "Staff Sit Area"
}