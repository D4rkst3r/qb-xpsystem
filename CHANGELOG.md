# 📋 Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

---

## [1.0.0] - 2025-02-02

### 🎉 Initial Release

#### ✨ Features
- **Dynamisches XP-System**
  - Konfigurierbare XP-Kurve mit Base + Level × Multiplier
  - Automatisches Multi-Level-Up Support
  - Maximales Level konfigurierbar
  - Speichern/Laden über oxmysql

- **ACE-Permissions System**
  - Native FiveM ACE-Berechtigungen
  - Keine Abhängigkeit von QBCore.Functions.GetPermission
  - Granulare Rechtevergabe möglich
  - Server-Console-Commands für RCON

- **Admin-Commands**
  - `/givexp [id] [amount]` - XP geben
  - `/setlevel [id] [level]` - Level setzen
  - `/resetxp [id]` - XP zurücksetzen
  - `/checkstats [id]` - Stats anzeigen

- **Anti-Exploit-System**
  - Cooldown zwischen XP-Events (1 Sekunde)
  - Maximale XP pro Event (1000 Standard)
  - Automatisches Logging verdächtiger Aktivitäten
  - Server-seitige Validierung

- **Discord-Integration**
  - Webhook-Logging für Level-Ups
  - Admin-Action-Logs
  - Suspicious-Activity-Logs
  - Anpassbare Farben und Bot-Einstellungen

- **Level-Belohnungen**
  - Konfigurierbare Belohnungen pro Level
  - Geld-Belohnungen
  - Item-Belohnungen
  - Custom-Messages

- **UI-System**
  - Circular Mode (Kreis-Anzeige)
  - Rectangular Mode (Balken-Anzeige)
  - Anpassbare Position
  - Level-Up-Animationen
  - Stats-Popup
  - Toggle mit F6

- **Exports & API**
  - GetPlayerXP() - XP-Daten abrufen
  - GiveXP() - XP geben
  - RemoveXP() - XP entfernen
  - SetLevel() - Level setzen
  - GetLevel() - Level abrufen
  - CalculateXPForLevel() - XP-Berechnung

- **Events**
  - qb-xpsystem:server:playerLevelUp - Server-Event bei Level-Up
  - qb-xpsystem:client:updateXP - Client-Event bei XP-Update
  - qb-xpsystem:client:levelUp - Client-Event bei Level-Up

#### 📚 Dokumentation
- Umfassende README.md mit API-Dokumentation
- Schritt-für-Schritt INSTALL.md
- permissions.cfg Template mit Beispielen
- EXAMPLES.lua mit 12 Integrations-Beispielen
- SQL-Datei für manuelle Datenbank-Einrichtung

#### 🔧 Technische Details
- Lua 5.4 Support
- oxmysql für Datenbankoperationen
- QBCore Framework Integration
- Automatische Datenbank-Tabellen-Erstellung
- Auto-Save alle 5 Minuten
- Save bei Resource-Stop
- Save bei Player-Disconnect

#### 🎨 UI/UX
- Moderne Gradient-Designs
- Smooth Animationen
- Responsive Design
- Mobile-friendly
- Performance-optimiert
- Custom CSS mit Tailwind-ähnlichen Utilities

---

## [Geplante Features]

### Version 1.1.0 (Geplant)
- [ ] Prestige-System (Level-Reset mit Boni)
- [ ] XP-Boost-Items
- [ ] Tägliche/Wöchentliche XP-Boni
- [ ] XP-Multiplier für Jobs
- [ ] Leaderboard-Command
- [ ] XP-Transfer zwischen Spielern
- [ ] Achievements-System
- [ ] Statistik-Dashboard

### Version 1.2.0 (Geplant)
- [ ] Web-Panel für Admins
- [ ] Grafische XP-Historie
- [ ] Season-System
- [ ] Battle-Pass Integration
- [ ] Custom XP-Kurven pro Job
- [ ] API für externe Tools

### Version 2.0.0 (Geplant)
- [ ] Multi-Character Support (verschiedene XP pro Char)
- [ ] Skill-Trees
- [ ] Perk-System
- [ ] Level-basierte Attribute
- [ ] Mobile-App Integration

---

## 🐛 Known Issues

Aktuell keine bekannten Probleme.

---

## 📝 Notizen

### Migration von anderen XP-Systemen
Wenn du von einem anderen XP-System wechselst, kannst du die Daten mit SQL migrieren:

```sql
-- Beispiel-Migration
INSERT INTO player_xp (citizenid, level, xp, total_xp)
SELECT citizenid, level, current_xp, total_xp
FROM old_xp_table;
```

### Performance-Tipps
- Bei >10.000 Spielern: Zusätzliche Datenbank-Indizes erstellen (siehe player_xp.sql)
- UI-Updates minimieren durch längere Intervalle
- Cooldown-Wert erhöhen bei Performance-Problemen

---

## 🤝 Contributing

Vorschläge und Bug-Reports sind willkommen!

Bitte erstelle ein Issue mit:
- Beschreibung des Problems/Features
- Schritte zur Reproduktion (bei Bugs)
- Server-Logs (bei Bugs)
- Erwartetes vs. aktuelles Verhalten

---

## 📜 License

Open Source - Frei nutzbar und modifizierbar

---

**Version:** 1.0.0  
**Release Date:** 02. Februar 2025  
**Author:** XP System Team  
**Compatibel with:** QBCore Framework (Latest)
