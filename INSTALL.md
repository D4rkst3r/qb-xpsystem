# 🚀 Schritt-für-Schritt Installation

Diese Anleitung führt dich durch die komplette Installation des QB-XPSystem.

---

## 📋 Voraussetzungen

Bevor du anfängst, stelle sicher, dass du Folgendes installiert hast:

- ✅ **QBCore Framework** (aktuelle Version)
- ✅ **oxmysql** (für Datenbank-Operationen)
- ✅ **MySQL/MariaDB** Datenbank
- ✅ FiveM Server mit Zugriff auf `server.cfg`

---

## 📦 Schritt 1: Ressource herunterladen

1. Lade den `qb-xpsystem` Ordner herunter
2. Kopiere ihn in deinen `resources` Ordner
3. Der Pfad sollte sein: `resources/[qb]/qb-xpsystem/`

```bash
# Beispiel-Struktur
resources/
├── [qb]/
│   ├── qb-core/
│   ├── qb-xpsystem/    ← Hier
│   └── ...
```

---

## 🔧 Schritt 2: Server.cfg bearbeiten

Öffne deine `server.cfg` und füge hinzu:

```cfg
# ========================================
# QB-XPSYSTEM
# ========================================

# Ressource starten
ensure qb-xpsystem

# Admin-Berechtigungen einrichten
add_ace group.admin command.xpadmin allow

# Deine Steam-ID zur Admin-Gruppe hinzufügen
# ERSETZE "110000XXXXXXX" mit deiner echten Steam64-ID
add_principal identifier.steam:110000XXXXXXX group.admin

# Weitere Admins hinzufügen (optional)
# add_principal identifier.steam:110000YYYYYYY group.admin
# add_principal identifier.license:XXXXXXXXXXXXXXXX group.admin
```

### 🔍 So findest du deine Steam-ID:

**Methode 1 - Im Spiel:**
1. Verbinde dich mit deinem Server
2. Öffne die Server-Konsole (F8)
3. Tippe `status` ein
4. Suche deine Steam-ID (beginnt mit `steam:110000...`)

**Methode 2 - Online:**
1. Gehe zu https://steamid.io/
2. Gib deine Steam-Profil-URL ein
3. Nutze die **steamID64** (z.B. 76561198012345678)
4. Konvertiere zu FiveM-Format: `steam:110000` + die letzten 8 Ziffern deiner steamID64 (in Hex)

**Einfacher Weg:** Nutze einfach `identifier.license:` statt Steam:
```cfg
# License findest du auch mit "status" im Spiel
add_principal identifier.license:3a4b5c6d7e8f9g0h1i2j3k4l5m6n7o8p group.admin
```

---

## 🗄️ Schritt 3: Datenbank (Optional)

Die Datenbank-Tabelle wird **automatisch erstellt** beim ersten Start!

Falls du Probleme hast, erstelle sie manuell:

```sql
CREATE TABLE IF NOT EXISTS `player_xp` (
    `citizenid` VARCHAR(50) NOT NULL,
    `level` INT(11) NOT NULL DEFAULT 1,
    `xp` INT(11) NOT NULL DEFAULT 0,
    `total_xp` INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## ⚙️ Schritt 4: Konfiguration anpassen

Öffne `config.lua` und passe an:

### 4.1 Grundeinstellungen

```lua
-- XP-System
Config.BaseXP = 100              -- Wie viel XP für Level 1→2
Config.LevelMultiplier = 1.5     -- Steigerung pro Level
Config.MaxLevel = 100            -- Max Level (0 = unbegrenzt)

-- UI
Config.UIMode = 'circular'       -- 'circular' oder 'rectangular'
```

### 4.2 Discord-Webhook (Optional aber empfohlen)

```lua
Config.DiscordWebhook = 'https://discord.com/api/webhooks/DEINE_WEBHOOK_URL'
Config.DiscordLogs.enabled = true
```

**So erstellst du einen Webhook:**
1. Öffne deinen Discord-Server
2. Gehe zu Server-Einstellungen → Integrationen → Webhooks
3. Klicke "Neuer Webhook"
4. Wähle den Kanal (z.B. #admin-logs)
5. Kopiere die Webhook-URL
6. Füge sie in die Config ein

### 4.3 Level-Belohnungen anpassen

```lua
Config.LevelRewards = {
    enabled = true,
    
    rewards = {
        [5] = {
            money = 5000,
            items = {
                {name = 'phone', amount = 1}
            },
            message = 'Level 5! Hier ist dein Handy!'
        },
        -- Füge mehr Level hinzu...
    }
}
```

---

## 🎮 Schritt 5: Server starten und testen

1. **Server komplett neu starten** (nicht nur `restart qb-xpsystem`)
   ```
   restart qb-xpsystem
   ```

2. **Verbinde dich mit dem Server**

3. **Teste die Admin-Commands:**
   ```
   /checkstats          # Zeigt deine eigenen Stats
   /givexp 1 500        # Gibt Spieler ID 1 → 500 XP
   /setlevel 1 10       # Setzt Spieler ID 1 auf Level 10
   ```

4. **Prüfe Berechtigungen:**
   - Wenn Commands nicht funktionieren → ACE-Permissions falsch
   - Öffne Server-Konsole und tippe:
     ```
     testace identifier.steam:DEINE_ID command.xpadmin
     ```
   - Sollte `true` zurückgeben

---

## ✅ Schritt 6: Funktionalität prüfen

### UI testen:
- Drücke **F6** im Spiel → XP-Anzeige sollte erscheinen/verschwinden
- Solltest du einen XP-Ring oder Balken sehen

### XP geben testen:
```lua
-- Teste in einem anderen Script oder mit einem Command:
exports['qb-xpsystem']:GiveXP(source, 100, "Test")
```

### Discord-Logs prüfen:
- Gib dir XP mit `/givexp`
- Schau in deinem Discord-Kanal nach
- Solltest du eine schöne Embed-Nachricht sehen

---

## 🔧 Schritt 7: Integration in andere Scripts

### Beispiel: XP für Polizei-Arrests

Öffne `qb-policejob/server/main.lua` und füge hinzu:

```lua
-- Finde die Arrest-Funktion und füge hinzu:
RegisterNetEvent('police:server:JailPlayer', function(playerId)
    -- ... bestehender Code ...
    
    -- XP geben
    exports['qb-xpsystem']:GiveXP(source, 50, "Verdächtigen verhaftet")
end)
```

### Beispiel: XP für EMS-Revives

In `qb-ambulancejob/server/main.lua`:

```lua
RegisterNetEvent('hospital:server:RevivePlayer', function(playerId)
    -- ... bestehender Code ...
    
    -- XP geben
    exports['qb-xpsystem']:GiveXP(source, 40, "Spieler wiederbelebt")
end)
```

---

## 🐛 Häufige Probleme & Lösungen

### Problem: Commands funktionieren nicht
**Lösung:**
1. Überprüfe ACE-Permissions in `server.cfg`
2. Stelle sicher, dass du die richtige Steam/License-ID hast
3. **Server neu starten** (nicht nur restart)
4. Teste mit `testace` in der Konsole

### Problem: UI wird nicht angezeigt
**Lösung:**
1. Drücke F8 und schau nach Fehlern
2. Prüfe `config.lua` → `Config.UIMode`
3. Teste mit F6 (Toggle-Taste)
4. Restart der Ressource: `restart qb-xpsystem`

### Problem: Keine Discord-Logs
**Lösung:**
1. Webhook-URL korrekt in Config?
2. Webhook im richtigen Kanal erstellt?
3. `Config.DiscordLogs.enabled = true`?
4. Teste den Webhook mit: https://discohook.org/

### Problem: XP wird nicht gespeichert
**Lösung:**
1. oxmysql installiert und gestartet?
2. Datenbank-Verbindung funktioniert?
3. Prüfe Server-Logs nach MySQL-Fehlern
4. Tabelle erstellt? (siehe Schritt 3)

### Problem: "No permission" trotz Admin-Gruppe
**Lösung:**
```cfg
# In server.cfg - GENAU SO:
add_ace group.admin command.xpadmin allow
add_principal identifier.steam:DEINE_ID group.admin

# NICHT:
add_ace identifier.steam:DEINE_ID command.admin allow  # ← Falsch!
```

---

## 📞 Weitere Hilfe

Wenn du immer noch Probleme hast:

1. **Prüfe die Server-Logs** (`txData/logs/`)
2. **Prüfe F8-Konsole** im Spiel auf Client-Fehler
3. **Lies die README.md** für detaillierte Dokumentation
4. **Teste die Exports** mit den Beispielen

---

## 🎉 Fertig!

Wenn alles funktioniert, solltest du jetzt:
- ✅ XP-Anzeige im Spiel sehen
- ✅ Admin-Commands nutzen können
- ✅ Discord-Logs erhalten
- ✅ Level-Up-Animationen sehen

**Viel Spaß mit deinem XP-System!** 🚀

---

## 📚 Nächste Schritte

1. Passe die XP-Kurve in `config.lua` an
2. Füge eigene Level-Belohnungen hinzu
3. Integriere XP in deine Jobs und Activities
4. Erstelle Level-basierte Freischaltungen
5. Passe die UI-Position und den Stil an

Schau dir die **README.md** für vollständige API-Dokumentation an!
