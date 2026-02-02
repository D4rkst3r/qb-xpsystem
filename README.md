# 🎮 QB-XPSystem - Modernes XP-System für QBCore

Ein vollständig ausgestattetes XP-System für QBCore mit ACE-Permissions, Anti-Exploit-Mechanismen, Discord-Logging und anpassbarer UI.

## ✨ Features

### 🔥 Kern-Features
- **Dynamische XP-Kurve**: Anpassbare Berechnung mit `XP_benötigt = Base × (Level × Multiplier)`
- **Automatisches Speichern**: Verwendet `oxmysql` für zuverlässige Datenpersistenz
- **Multi-Level-Ups**: Unterstützt mehrere Level-Ups auf einmal
- **Level-Belohnungen**: Automatische Ausschüttung von Geld und Items bei bestimmten Levels

### 🛡️ Sicherheit & Administration
- **ACE-Permissions**: Native FiveM ACE-Berechtigungen statt QBCore-Permissions
- **Anti-Exploit-System**: 
  - Cooldown zwischen XP-Events (1 Sekunde pro Spieler)
  - Maximale XP-Menge pro Event
  - Logging von verdächtigen Aktivitäten
- **Admin-Commands**: `/givexp`, `/setlevel`, `/resetxp`, `/checkstats`

### 📊 Logging & Überwachung
- **Discord-Webhooks**: Detaillierte Logs für Level-Ups und Admin-Aktionen
- **In-Game Stats**: Sofortige Anzeige von Spielerstatistiken
- **Verdachtsprotokoll**: Automatische Erkennung von XP-Exploits

### 🎨 UI-System
- **Zwei Modi**: Circular (Kreis) und Rectangular (Rechteck)
- **Anpassbare Position**: Konfigurierbar in der Config
- **Level-Up-Animationen**: Spektakuläre Effekte beim Level-Aufstieg
- **Responsive Design**: Funktioniert auf allen Bildschirmgrößen

### 🔧 Entwickler-Features
- **Exports**: Klare API für andere Ressourcen
- **Ereignis-Hooks**: Events für Level-Ups und XP-Änderungen
- **Erweiterbar**: Einfache Integration neuer Features

---

## 📦 Installation

### 1. Ressource herunterladen
```bash
# Kopiere den qb-xpsystem Ordner in deinen resources Ordner
cd /path/to/server/resources
```

### 2. Abhängigkeiten prüfen
Stelle sicher, dass folgende Ressourcen installiert sind:
- `qb-core` (QBCore Framework)
- `oxmysql` (MySQL-Bibliothek)

### 3. Datenbank einrichten
Die Tabelle wird automatisch erstellt beim ersten Start. Falls du sie manuell erstellen möchtest:

```sql
CREATE TABLE IF NOT EXISTS `player_xp` (
    `citizenid` VARCHAR(50) NOT NULL,
    `level` INT(11) NOT NULL DEFAULT 1,
    `xp` INT(11) NOT NULL DEFAULT 0,
    `total_xp` INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 4. Server.cfg konfigurieren
Füge diese Zeile zu deiner `server.cfg` hinzu:

```cfg
ensure qb-xpsystem
```

### 5. ACE-Permissions einrichten
Öffne deine `server.cfg` und füge die Admin-Berechtigungen hinzu:

```cfg
# XP System Admin-Gruppe erstellen
add_ace group.admin command.xpadmin allow

# Admins zur Gruppe hinzufügen (ersetze mit echten Identifiers)
add_principal identifier.steam:110000XXXXXXX group.admin
add_principal identifier.license:XXXXXXXXXXXXXXXX group.admin
```

**💡 Tipp**: Siehe `permissions.cfg` für detaillierte Beispiele und verschiedene Methoden.

### 6. Discord-Webhook einrichten (optional)
Öffne `config.lua` und trage deinen Webhook ein:

```lua
Config.DiscordWebhook = 'https://discord.com/api/webhooks/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXX'
```

---

## ⚙️ Konfiguration

### XP-System Einstellungen

```lua
-- Basis XP für Level 1
Config.BaseXP = 100

-- Multiplikator für XP-Kurve
Config.LevelMultiplier = 1.5

-- Maximales Level (0 = unbegrenzt)
Config.MaxLevel = 100
```

### UI-Einstellungen

```lua
-- UI-Modus: 'circular' oder 'rectangular'
Config.UIMode = 'circular'

-- UI-Position (Prozent vom Rand)
Config.UIPosition = {
    x = 95,  -- Von links
    y = 85   -- Von oben
}
```

### Anti-Exploit-Konfiguration

```lua
-- Cooldown zwischen XP-Events (Millisekunden)
Config.XPCooldown = 1000

-- Maximale XP pro Event
Config.MaxXPPerEvent = 1000

-- Verdächtige Aktivitäten loggen
Config.LogSuspiciousActivity = true
```

### Level-Belohnungen konfigurieren

```lua
Config.LevelRewards = {
    enabled = true,
    
    rewards = {
        [5] = {
            money = 5000,
            items = {
                {name = 'phone', amount = 1}
            },
            message = 'Level 5 erreicht! €5,000 und ein Telefon!'
        },
        [10] = {
            money = 10000,
            items = {
                {name = 'weapon_pistol', amount = 1}
            },
            message = 'Level 10! Du hast eine Pistole erhalten!'
        }
    }
}
```

---

## 🎮 Admin-Commands

### `/givexp [id] [amount]`
Gibt einem Spieler XP.

**Beispiel:**
```
/givexp 1 500
```
Gibt Spieler ID 1 → 500 XP

---

### `/setlevel [id] [level]`
Setzt das Level eines Spielers direkt.

**Beispiel:**
```
/setlevel 1 25
```
Setzt Spieler ID 1 → Level 25

---

### `/resetxp [id]`
Setzt XP und Level eines Spielers zurück.

**Beispiel:**
```
/resetxp 1
```
Setzt Spieler ID 1 zurück auf Startlevel

---

### `/checkstats [id]`
Zeigt die Statistiken eines Spielers an. Ohne ID werden eigene Stats angezeigt.

**Beispiel:**
```
/checkstats 1     # Zeigt Stats von Spieler 1
/checkstats       # Zeigt eigene Stats
```

---

## 👨‍💻 Entwickler-Dokumentation

### Exports

#### GetPlayerXP
Holt die XP-Daten eines Spielers.

```lua
local xpData = exports['qb-xpsystem']:GetPlayerXP(source)
-- Returns: { level = 5, xp = 250, totalXP = 1750, citizenid = "ABC123" }
```

---

#### GiveXP
Gibt einem Spieler XP.

```lua
local success = exports['qb-xpsystem']:GiveXP(source, 100, "Quest abgeschlossen")
-- Returns: true/false
```

**Parameter:**
- `source` (number): Spieler-ID
- `amount` (number): XP-Menge
- `reason` (string, optional): Grund für XP-Vergabe

---

#### RemoveXP
Entfernt XP von einem Spieler.

```lua
local success = exports['qb-xpsystem']:RemoveXP(source, 50)
-- Returns: true/false
```

---

#### SetLevel
Setzt das Level eines Spielers direkt.

```lua
local success = exports['qb-xpsystem']:SetLevel(source, 10)
-- Returns: true/false
```

---

#### GetLevel
Holt nur das Level eines Spielers.

```lua
local level = exports['qb-xpsystem']:GetLevel(source)
-- Returns: number (level)
```

---

#### CalculateXPForLevel
Berechnet benötigte XP für ein bestimmtes Level.

```lua
local requiredXP = exports['qb-xpsystem']:CalculateXPForLevel(5)
-- Returns: number (XP benötigt)
```

---

### Events

#### Server-Events

**qb-xpsystem:server:playerLevelUp**
Wird gefeuert, wenn ein Spieler ein Level aufsteigt.

```lua
AddEventHandler('qb-xpsystem:server:playerLevelUp', function(source, oldLevel, newLevel)
    print(string.format("Spieler %d ist von Level %d auf %d gestiegen!", source, oldLevel, newLevel))
end)
```

---

#### Client-Events

**qb-xpsystem:client:updateXP**
Wird gefeuert, wenn XP-Daten aktualisiert werden.

```lua
RegisterNetEvent('qb-xpsystem:client:updateXP', function(data)
    print("XP aktualisiert: Level " .. data.level .. ", XP: " .. data.xp)
end)
```

**qb-xpsystem:client:levelUp**
Wird gefeuert, wenn der Client ein Level aufsteigt.

```lua
RegisterNetEvent('qb-xpsystem:client:levelUp', function(newLevel, levelsGained)
    print("Level Up! Neues Level: " .. newLevel)
end)
```

---

### Beispiel-Integration

#### XP für einen Job geben

```lua
-- In deinem Job-Script (z.B. qb-policejob)
RegisterNetEvent('police:server:arrest', function(targetId)
    local src = source
    
    -- Normaler Arrest-Code hier...
    
    -- XP geben
    exports['qb-xpsystem']:GiveXP(src, 50, "Verdächtigen verhaftet")
end)
```

---

#### XP für Aktivitäten geben

```lua
-- In einem Fishing-Script
RegisterNetEvent('fishing:server:catchFish', function()
    local src = source
    
    -- Fish-Logic...
    
    -- XP basierend auf Fischart
    local xpReward = 15
    exports['qb-xpsystem']:GiveXP(src, xpReward, "Fisch gefangen")
end)
```

---

#### Level-basierte Freischaltungen

```lua
-- Prüfe Level vor Aktion
local playerLevel = exports['qb-xpsystem']:GetLevel(source)

if playerLevel < 10 then
    TriggerClientEvent('QBCore:Notify', source, 'Du benötigst Level 10!', 'error')
    return
end

-- Erlaube Aktion...
```

---

## 🔍 Fehlerbehebung

### Admin-Commands funktionieren nicht
1. **ACE-Permissions prüfen:**
   ```
   testace identifier.steam:DEINE_ID command.xpadmin
   ```
   In der Server-Konsole ausführen

2. **Server neu starten** (nicht nur restart)

3. **Identifiers überprüfen:**
   - Gib `status` in der Server-Konsole ein
   - Kopiere die Steam/License-ID korrekt

### XP wird nicht gespeichert
1. **oxmysql installiert?** Prüfe die server.cfg
2. **Datenbank-Verbindung:** Prüfe die oxmysql-Konfiguration
3. **Logs prüfen:** Schau in die Server-Logs nach Fehlern

### UI wird nicht angezeigt
1. **F8-Konsole öffnen** und nach Fehlern suchen
2. **Cache leeren:** `resmon` eingeben und Ressource restart
3. **Konfiguration prüfen:** Stelle sicher, dass die UI in der Config aktiviert ist

### Verdächtige XP-Warnungen
Das System schützt vor:
- Zu schnellen XP-Events (< 1 Sekunde)
- Übermäßigen XP-Mengen (> MaxXPPerEvent)

Diese Warnungen erscheinen in:
- Server-Logs
- Discord-Webhook (falls konfiguriert)

---

## 📝 Changelog

### Version 1.0.0 (Initial Release)
- ✅ Dynamisches XP-System mit konfigurierbarer Kurve
- ✅ ACE-Permissions für Admin-Commands
- ✅ Anti-Exploit mit Cooldown-System
- ✅ Discord-Webhook-Logging
- ✅ Level-Belohnungssystem
- ✅ Zwei UI-Modi (Circular & Rectangular)
- ✅ Umfassende Exports und Events
- ✅ Multi-Level-Up-Support
- ✅ Stats-Übersicht mit `/checkstats`

---

## 🤝 Support

Bei Fragen oder Problemen:
1. Prüfe diese README zuerst
2. Schau in die `permissions.cfg` für ACE-Beispiele
3. Prüfe die Server-Logs auf Fehler
4. Teste die Exports mit den Beispielen

---

## 📜 Lizenz

Dieses Script ist Open Source und kann frei genutzt und modifiziert werden.

---

## 🙏 Credits

Entwickelt für die QBCore-Community mit Fokus auf Sicherheit, Performance und Benutzerfreundlichkeit.

**Features:**
- Native FiveM ACE-Permissions
- Professionelles Anti-Exploit-System
- Discord-Integration
- Moderne, responsive UI
- Vollständig dokumentierte API

---

**Viel Spaß mit dem XP-System! 🎮**
