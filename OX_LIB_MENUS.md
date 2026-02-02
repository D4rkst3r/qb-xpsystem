# 🎮 XP SYSTEM - ox_lib Menüs Guide

## ✅ Was wurde hinzugefügt:

### **1. Admin-Menü** 🔧
**Command:** `/xpadmin`

**Features:**
- ✅ Spieler-Auswahl mit Live-Level-Anzeige
- ✅ XP geben (mit Grund-Angabe)
- ✅ Level setzen
- ✅ Stats anzeigen (detailliert)
- ✅ XP zurücksetzen (mit Bestätigung)
- ✅ Sortiert nach Level (Höchste zuerst)
- ✅ Visuelle Level-Indicator (Gold ab Level 50)

**Benötigt:** ACE Permission `command.xpadmin`

---

### **2. Spieler-Menü** 👤
**Command:** `/xpmenu`

**Features:**
- ✅ Meine Stats (Level, XP, Rang, Fortschritt)
- ✅ Leaderboard (Top 10 mit Medaillen 🥇🥈🥉)
- ✅ Level-Belohnungen (Übersicht aller Rewards)
- ✅ System-Info (Wie funktioniert alles?)

**Benötigt:** Keine Permissions - für alle Spieler

---

## 🚀 Installation:

1. **ox_lib muss installiert sein!**
   ```
   ensure ox_lib
   ```

2. **Server.cfg:**
   ```cfg
   ensure ox_lib
   ensure qb-xpsystem
   ```

3. **Restart:**
   ```
   restart qb-xpsystem
   ```

---

## 🎮 Verwendung:

### **Als Admin:**

```
/xpadmin
```

1. **Spieler auswählen** aus der Liste
2. **Aktion wählen:**
   - 📊 Stats anzeigen
   - 📈 XP geben
   - 🎯 Level setzen
   - 🔄 XP zurücksetzen

### **Als Spieler:**

```
/xpmenu
```

1. **Meine Stats** - Deine XP-Daten
2. **Leaderboard** - Top 10 Ranking
3. **Belohnungen** - Was du erreichen kannst
4. **Info** - Wie das System funktioniert

---

## 🎨 Features im Detail:

### **Admin-Menü:**

#### **Spieler-Auswahl:**
- Zeigt alle online Spieler
- Sortiert nach Level (höchste zuerst)
- Zeigt aktuelles Level und XP
- Gold-Highlight für Level 50+

#### **XP geben:**
- Input: 1-100,000 XP
- Optionaler Grund (wird geloggt)
- Live-Vorschau
- Notification an Spieler

#### **Level setzen:**
- Input: 1 bis MaxLevel
- Validation eingebaut
- Notification an Spieler

#### **Stats anzeigen:**
- Level-Info (Aktuell, Max, Fortschritt)
- XP-Info (Aktuell, Gesamt, Bis Next)
- Account-Info (CitizenID, Spieler-ID)

#### **XP zurücksetzen:**
- Confirmation-Dialog
- Warnung: Nicht rückgängig!
- Notification an Spieler

---

### **Spieler-Menü:**

#### **Meine Stats:**
- Aktuelles Level
- XP-Fortschritt (%)
- Server-Rang (#1, #2, etc.)
- Nächste Belohnung
- XP bis Level-Up

#### **Leaderboard:**
- Top 10 Spieler
- Medaillen: 🥇🥈🥉
- Online-Status: 🟢/⚫
- Gesamt-XP anzeigen

#### **Level-Belohnungen:**
- Alle konfigurierten Rewards
- Status: ✅ Freigeschaltet / 🔒 Gesperrt
- Details: Geld, Items, Message

#### **System-Info:**
- Wie funktioniert es?
- XP-Quellen
- Verfügbare Commands
- Tipps & Tricks

---

## ⚙️ Anpassungen:

### **Farben ändern:**

In `client/admin_menu.lua` oder `client/player_menu.lua`:

```lua
iconColor = '#3B82F6'  -- Blau
iconColor = '#10B981'  -- Grün
iconColor = '#F59E0B'  -- Orange
iconColor = '#EF4444'  -- Rot
iconColor = '#8B5CF6'  -- Lila
iconColor = '#FFD700'  -- Gold
```

### **Keybinds hinzufügen:**

In deiner FiveM-Einstellungen unter "Key Bindings":
- Suche "XP Admin Menu öffnen"
- Setze eigene Taste (z.B. F9)

---

## 🐛 Troubleshooting:

### **Menü öffnet nicht:**
```
Stelle sicher dass ox_lib läuft:
ensure ox_lib
restart qb-xpsystem
```

### **"Keine Berechtigung":**
```cfg
# In server.cfg:
add_ace group.admin command.xpadmin allow
add_principal identifier.steam:DEINE_ID group.admin
```

### **Leaderboard zeigt keine Namen:**
```
Warte 1-2 Sekunden nach dem Öffnen
(Datenbank-Abfrage läuft im Hintergrund)
```

---

## 📊 Vorteile gegenüber Commands:

✅ **Übersichtlicher** - Alle Optionen auf einen Blick
✅ **Einfacher** - Keine Commands merken
✅ **Schneller** - Weniger Tipparbeit
✅ **Sicherer** - Validation eingebaut
✅ **Schöner** - Professionelles Design
✅ **Informativer** - Live-Vorschau und Details

---

## 🎯 Was als Nächstes?

Die Menüs sind jetzt die Basis für weitere Features:

1. **Daily Login Bonus** - Button im Spieler-Menü
2. **XP Leaderboard** - Erweitert mit mehr Stats
3. **Achievements** - Eigener Menü-Punkt
4. **Prestige System** - Admin kann Prestige setzen
5. **XP-Boost Items** - Im Spieler-Menü aktivieren

Alle zukünftigen Features können einfach als neue Menü-Punkte hinzugefügt werden!

---

**Viel Spaß mit den neuen Menüs!** 🎉
