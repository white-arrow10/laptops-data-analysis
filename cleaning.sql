USE test;

SELECT * FROM laptops_backup;

-- 1.) Number of rows -
SELECT COUNT(*) FROM laptops_backup;

-- 2.) check memory consumption by data - 

SELECT `DATA_LENGTH`/1024 AS 'data occupied in KBs'
FROM information_schema.TABLES
WHERE table_schema = 'test'
AND table_name = 'laptops_backup';

-- 3.) droppping non imp columns -

SELECT * FROM laptops_backup;
-- no column seems futile in the data but lets rename first column to index for convinience

-- rename works in certain version or else use change col syntax
-- ALTER TABLE laptops_backup
-- RENAME COLUMN `Unnamed: 0` TO `index`;

ALTER TABLE laptops_backup
CHANGE COLUMN `Unnamed: 0` `index` INT(11);
SELECT * FROM laptops_backup;

-- 4.) dropping null values -

SELECT * FROM laptops_backup
WHERE `Company` IS ?NULL AND `TypeName` IS NULL AND `ScreenResolution` IS NULL AND `Cpu` IS NULL AND
`Ram` IS NULL AND `Memory` IS NULL AND `Gpu` IS NULL AND `OpSys` IS NULL AND `Weight` IS NULL;
-- this won't return null rows as there might be some problem while importing how different sql environment treats null values

-- try this then -
SELECT * FROM laptops_backup WHERE `Company` IS NULL OR `Company` = '' AND
`TypeName` IS NULL OR `TypeName` = '' AND
`ScreenResolution` IS NULL OR `ScreenResolution` = '' AND
`Cpu` IS NULL OR `Cpu` = '' AND
`Ram` IS NULL OR `Ram` = '' AND
`Memory` IS NULL OR `Memory` = '' AND
`Gpu` IS NULL OR `Gpu` = '' AND
`OpSys` IS NULL OR `OpSys` = '' AND
`Weight` IS NULL OR `Weight` = '';

-- on using count(*) - we get to know there are total 30 such rows

DELETE FROM laptops_backup
WHERE `Company` IS NULL OR `Company` = '' AND
`TypeName` IS NULL OR `TypeName` = '' AND
`ScreenResolution` IS NULL OR `ScreenResolution` = '' AND
`Cpu` IS NULL OR `Cpu` = '' AND
`Ram` IS NULL OR `Ram` = '' AND
`Memory` IS NULL OR `Memory` = '' AND
`Gpu` IS NULL OR `Gpu` = '' AND
`OpSys` IS NULL OR `OpSys` = '' AND
`Weight` IS NULL OR `Weight` = '';

SELECT COUNT(*) FROM laptops_backup;
-- perfectly done - 1303-1273 = 30 

-- 5.) drop duplicates - 


SELECT *, COUNT(*) AS total_count
FROM laptops_backup
GROUP BY Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price
HAVING total_count > 1;

SELECT * FROM laptops_backup;
