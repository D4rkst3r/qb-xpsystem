# ⚡ Quick Start Guide - 5 Minuten Setup

Die schnellste Methode, um das XP-System zum Laufen zu bringen.

---

## 📦 In 5 Schritten startklar

### 1️⃣ Dateien kopieren (30 Sekunden)
```bash
# Kopiere den qb-xpsystem Ordner nach:
resources/[qb]/qb-xpsystem/
```

### 2️⃣ Server.cfg bearbeiten (1 Minute)
Öffne deine `server.cfg` und füge **am Ende** hinzu:

```cfg
# XP System
ensure qb-xpsystem
add_ace group.admin command.xpadmin allow
add_principal identifier.steam:DEINE_STEAM_ID group.admin
```

**Steam-ID finden:**
- Im Spiel: `/status` in F8-Konsole
- Oder: https://steamid.io/ → steamID64

### 3️⃣ Discord-Webhook (Optional, 1 Minute)
Öffne `qb-xpsystem/config.lua`:

```lua
Config.DiscordWebhook = 'https://discord.com/api/webhooks/DEINE_URL'
```

**Webhook erstellen:**
Discord Server → Einstellungen → Integrationen → Webhooks → Neuer Webhook

### 4️⃣ Server starten (1 Minute)
```
restart qb-xpsystem
```

Oder Server neu starten.

### 5️⃣ Testen (30 Sekunden)
Im Spiel:
```
/givexp 1 100
/checkstats
```

**F6** drücken → XP-Anzeige sollte erscheinen

---

## ✅ Das war's!

Du hast jetzt:
- ✅ Funktionierendes XP-System
- ✅ Admin-Commands
- ✅ UI mit Level-Anzeige
- ✅ Automatisches Speichern
- ✅ (Optional) Discord-Logs

---

## 🔧 Nächste Schritte

### XP in deine Scripts einbauen:
```lua
-- In irgendeinem Server-Script:
exports['qb-xpsystem']:GiveXP(source, 50, "Quest abgeschlossen")
```

### Level-Belohnungen anpassen:
Öffne `config.lua` und editiere `Config.LevelRewards`:

```lua
[10] = {
    money = 10000,
    items = {
        {name = 'weapon_pistol', amount = 1}
    },
    message = 'Level 10! Hier ist deine Pistole!'
}
```

### UI anpassen:
```lua
Config.UIMode = 'rectangular'  -- oder 'circular'
Config.UIPosition = { x = 95, y = 85 }  -- Position in %
```

---

## 🐛 Probleme?

### Commands funktionieren nicht?
→ Prüfe ACE-Permissions in server.cfg
→ Server **neu starten** (nicht nur restart)
→ Teste: `testace identifier.steam:DEINE_ID command.xpadmin`

### UI zeigt sich nicht?
→ F8-Konsole auf Fehler prüfen
→ F6 drücken zum Toggle
→ `restart qb-xpsystem`

### XP wird nicht gespeichert?
→ oxmysql installiert?
→ Datenbank-Verbindung ok?
→ Server-Logs prüfen

---

## 📚 Mehr Infos

- **Vollständige Dokumentation:** `README.md`
- **Ausführliche Installation:** `INSTALL.md`
- **Integrations-Beispiele:** `EXAMPLES.lua`
- **Permissions-Beispiele:** `permissions.cfg`

---

## 🎮 Beispiel-Integration

**Polizei-Job:**
```lua
-- In qb-policejob/server/main.lua
RegisterNetEvent('police:server:JailPlayer', function()
    exports['qb-xpsystem']:GiveXP(source, 50, "Arrest")
end)
```

**Fishing:**
```lua
RegisterNetEvent('fishing:server:CatchFish', function()
    exports['qb-xpsystem']:GiveXP(source, 15, "Fish caught")
end)
```

---

**Setup-Zeit: ~5 Minuten**  
**Schwierigkeit: ⭐ Einfach**

Viel Erfolg! 🚀
