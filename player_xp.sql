-- ========================================
-- QB-XPSYSTEM DATABASE SETUP
-- ========================================
-- 
-- Diese Datei erstellt die benötigte Tabelle für das XP-System.
-- HINWEIS: Die Tabelle wird normalerweise AUTOMATISCH erstellt!
-- Nutze diese Datei nur, wenn du Probleme mit der Auto-Erstellung hast.
-- 
-- ========================================

-- Tabelle für Spieler-XP erstellen
CREATE TABLE IF NOT EXISTS `player_xp` (
    `citizenid` VARCHAR(50) NOT NULL COMMENT 'QBCore CitizenID des Spielers',
    `level` INT(11) NOT NULL DEFAULT 1 COMMENT 'Aktuelles Level des Spielers',
    `xp` INT(11) NOT NULL DEFAULT 0 COMMENT 'Aktuelle XP für das nächste Level',
    `total_xp` INT(11) NOT NULL DEFAULT 0 COMMENT 'Gesamt-XP (über alle Level)',
    PRIMARY KEY (`citizenid`),
    INDEX `level_index` (`level`),
    INDEX `total_xp_index` (`total_xp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='XP System Spielerdaten';

-- ========================================
-- OPTIONALE QUERIES
-- ========================================

-- Top 10 Spieler nach Gesamt-XP anzeigen
-- SELECT citizenid, level, total_xp FROM player_xp ORDER BY total_xp DESC LIMIT 10;

-- Durchschnittliches Level aller Spieler
-- SELECT AVG(level) as average_level FROM player_xp;

-- Anzahl Spieler pro Level
-- SELECT level, COUNT(*) as player_count FROM player_xp GROUP BY level ORDER BY level;

-- Spieler mit höchstem Level
-- SELECT * FROM player_xp ORDER BY level DESC, xp DESC LIMIT 1;

-- ========================================
-- WARTUNG & BACKUP
-- ========================================

-- Backup der XP-Daten erstellen
-- CREATE TABLE player_xp_backup AS SELECT * FROM player_xp;

-- Backup wiederherstellen
-- TRUNCATE TABLE player_xp;
-- INSERT INTO player_xp SELECT * FROM player_xp_backup;

-- Alte Backup-Tabelle löschen
-- DROP TABLE IF EXISTS player_xp_backup;

-- ========================================
-- RESET (NUR IN NOTFÄLLEN!)
-- ========================================

-- VORSICHT: Löscht ALLE XP-Daten!
-- TRUNCATE TABLE player_xp;

-- Oder: Alle Spieler auf Level 1 zurücksetzen
-- UPDATE player_xp SET level = 1, xp = 0, total_xp = 0;

-- ========================================
-- MIGRATIONEN
-- ========================================

-- Falls du von einem alten System migrierst:

-- Beispiel: Importiere Level von einer alten Tabelle
-- UPDATE player_xp p
-- INNER JOIN old_level_table o ON p.citizenid = o.citizenid
-- SET p.level = o.level, p.total_xp = (o.level * 100);

-- ========================================
-- PERFORMANCE OPTIMIERUNG
-- ========================================

-- Falls du eine sehr große Datenbank hast (10.000+ Spieler),
-- kannst du zusätzliche Indizes erstellen:

-- Index für schnellere Leaderboard-Queries
-- CREATE INDEX idx_leaderboard ON player_xp (total_xp DESC, level DESC);

-- Index für Level-basierte Suchen
-- CREATE INDEX idx_level_search ON player_xp (level, total_xp);

-- ========================================
-- DATENBANK INFORMATIONEN
-- ========================================

-- Tabellengröße anzeigen
-- SELECT 
--     table_name AS 'Table',
--     ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
-- FROM information_schema.TABLES
-- WHERE table_schema = DATABASE()
-- AND table_name = 'player_xp';

-- Anzahl der Einträge
-- SELECT COUNT(*) as total_players FROM player_xp;

-- ========================================
-- ENDE
-- ========================================
