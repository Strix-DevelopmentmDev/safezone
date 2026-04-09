const app = document.getElementById("app");
const closeBtn = document.getElementById("close");
const createBtn = document.getElementById("createBtn");
const zoneList = document.getElementById("zoneList");

const nameInput = document.getElementById("name");
const typeInput = document.getElementById("zoneType");
const radiusInput = document.getElementById("radius");

let perms = {
  canMakeSafe: false,
  canMakeStaff: false
};

function post(name, data = {}) {
  fetch(`https://${GetParentResourceName()}/${name}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(data)
  });
}

function renderZones(zones) {
  zoneList.innerHTML = "";

  if (!zones || !zones.length) {
    zoneList.innerHTML = `<div class="zone-card"><p>No zones saved.</p></div>`;
    return;
  }

  zones.forEach((zone) => {
    const card = document.createElement("div");
    card.className = "zone-card";

    const title = document.createElement("h3");
    title.textContent = zone.name || "Unnamed Zone";

    const info = document.createElement("p");
    info.textContent = `${zone.zoneType} • radius ${zone.radius}`;

    const del = document.createElement("button");
    del.textContent = "Delete";
    del.onclick = () => post("deleteZone", { id: zone.id });

    card.appendChild(title);
    card.appendChild(info);
    card.appendChild(del);
    zoneList.appendChild(card);
  });
}

closeBtn.onclick = () => post("close");

createBtn.onclick = () => {
  const zoneType = typeInput.value;

  if (zoneType === "safe" && !perms.canMakeSafe) return;
  if (zoneType === "staff" && !perms.canMakeStaff) return;

  post("createZone", {
    name: nameInput.value.trim(),
    zoneType: zoneType,
    radius: Number(radiusInput.value) || 25
  });
};

window.addEventListener("message", (e) => {
  const msg = e.data;

  if (msg.action === "open") {
    app.classList.remove("hidden");

    perms.canMakeSafe = !!msg.data.canMakeSafe;
    perms.canMakeStaff = !!msg.data.canMakeStaff;

    renderZones(msg.data.zones || []);
  }

  if (msg.action === "close") {
    app.classList.add("hidden");
  }

  if (msg.action === "setZones") {
    renderZones(msg.data || []);
  }
});