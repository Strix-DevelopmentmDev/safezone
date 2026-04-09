# safezone
🛡️ Strix SafeZone Creator

Lightweight, standalone safe zone system for FiveM with in-game creation, map visualization, and optional staff-only zones.

✨ Features
🧩 Zone Management
/safezone opens an in-game UI
Create and delete zones instantly
Supports:
🟢 Safe Zones
🔴 Staff Sit Areas
No restart required — zones update live
🗺️ Map Visualization
Radius blips for each zone
Center icon with custom name
Separate visuals for:
Safe zones
Staff areas
🛡️ Protection System
Weapons disabled inside safe zones
Shooting + melee blocked
Automatically switches to unarmed
Clean marker rendering
👨‍💻 Staff System
Staff sit areas supported
Controlled via ACE permissions
Optional permission toggle in config
⚙️ Standalone
No ESX / QB / ox required
No database needed
Saves zones to zones.json
Fully lightweight
📦 Installation
# Put resource in your server
resources/[local]/strix_safezone

# Add to server.cfg
ensure strix_safezone

Restart your server.

⚙️ Configuration

Located in config.lua

Config.Command = "safezone"

-- toggle permissions
Config.UseAcePerms = false

Config.AdminAce = "safezone.admin"
Config.StaffAce = "safezone.staff"

Config.DefaultRadius = 25.0
🔐 Permissions (Optional)

If you enable permissions:

Config.UseAcePerms = true

Add this to your server.cfg:

add_ace group.admin safezone.admin allow
add_ace group.admin safezone.staff allow
add_ace group.mod safezone.staff allow
🎮 Usage

Open the UI:

/safezone

Then:

Enter a name
Choose zone type
Set radius
Click Create Zone
📁 Structure
strix_safezone/
├── fxmanifest.lua
├── config.lua
├── client.lua
├── server.lua
├── zones.json
└── ui/
    ├── index.html
    ├── style.css
    └── app.js
💾 Data Storage
Zones are saved in:
zones.json
No database required
Automatically loads on restart
⚠️ Notes
Staff zones currently do not block actions (visual only by default)
Zones are circle-based (polygon coming soon)
Designed for performance and simplicity
🔧 Planned Updates
Polygon zones 📐
In-game zone editing ✏️
3D wall rendering 🧱
UI improvements 🎨
Per-zone settings (godmode, ghost mode, etc.)
Better staff restrictions
