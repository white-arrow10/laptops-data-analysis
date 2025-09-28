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


-- SELECT MIN(Price), COUNT(*) AS total_count
-- FROM laptops_backup
-- GROUP BY Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight
-- HAVING total_count > 1;

-- first verify  using select then delete - 
-- SELECT T1.*
DELETE T1
FROM laptops_backup AS T1
INNER JOIN laptops_backup AS T2
  ON T1.Company = T2.Company
  AND T1.TypeName = T2.TypeName
  AND T1.Inches = T2.Inches
  AND T1.ScreenResolution = T2.ScreenResolution
  AND T1.Cpu = T2.Cpu
  AND T1.Ram = T2.Ram
  AND T1.Memory = T2.Memory
  AND T1.Gpu = T2.Gpu
  AND T1.OpSys = T2.OpSys
  AND T1.Weight = T2.Weight
WHERE
  -- Condition 1: T1 has a HIGHER price than its duplicate T2
  T1.Price > T2.Price
  -- Condition 2 (Tie-breaker): If prices are equal, delete the one with the HIGHER index
  OR (T1.Price = T2.Price AND T1.`index` > T2.`index`);

SELECT COUNT(*) FROM laptops_backup;
-- 1273 - 1205 = 68 rows deleted - perfect count 


-- 6.) certain column operations - 

ALTER TABLE laptops MODIFY COLUMN Inches DECIMAL(10,1);

UPDATE laptops_backup l1
SET Ram = (SELECT REPLACE(Ram,'GB','') FROM laptops_backup l2 WHERE l2.index = l1.index);

SELECT * FROM laptops_backup;

ALTER TABLE laptops MODIFY COLUMN Ram INT;

SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'test'
AND TABLE_NAME = 'laptops_backup';
-- can compare with val in step 2 to see memory optimization

UPDATE laptops_backup l1
SET Weight = (SELECT REPLACE(Weight,'kg','') 
		   FROM laptops_backup l2 WHERE l2.index = l1.index);
SELECT * FROM laptops_backup;

UPDATE laptops_backup l1
SET Price = (SELECT ROUND(Price) 
			FROM laptops_backup l2 WHERE l2.index = l1.index);
            
ALTER TABLE laptops_backup MODIFY COLUMN Price INTEGER;

SELECT DISTINCT OpSys FROM laptops;

-- cleaning os names -
-- mac
-- windows
-- linux
-- no os
-- others

SELECT OpSys,
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END AS 'os_brand'
FROM laptops_backup;

UPDATE laptops_backup
SET OpSys = 
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END;

SELECT * FROM laptops_backup;

ALTER TABLE laptops_backup
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

SELECT * FROM laptops_backup;

UPDATE laptops_backup l1
SET gpu_brand = (SELECT SUBSTRING_INDEX(Gpu,' ',1) 
				FROM laptops_backup l2 WHERE l2.index = l1.index);

UPDATE laptops_backup l1
SET gpu_name = (SELECT REPLACE(Gpu,gpu_brand,'') 
				FROM laptops_backup l2 WHERE l2.index = l1.index);

SELECT * FROM laptops_backup;
ALTER TABLE laptops_backup DROP COLUMN Gpu;

ALTER TABLE laptops_backup
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

UPDATE laptops_backup l1
SET cpu_brand = (SELECT SUBSTRING_INDEX(Cpu,' ',1) 
				 FROM laptops_backup l2 WHERE l2.index = l1.index);

UPDATE laptops_backup l1
SET cpu_speed = (SELECT CAST(REPLACE(SUBSTRING_INDEX(Cpu,' ',-1),'GHz','')
				AS DECIMAL(10,2)) FROM laptops_backup l2 
                WHERE l2.index = l1.index);

UPDATE laptops_backup l1
SET cpu_name = (SELECT
					REPLACE(REPLACE(Cpu,cpu_brand,''),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,''),' ',-1),'')
					FROM laptops_backup l2 
					WHERE l2.index = l1.index);

ALTER TABLE laptops_backup DROP COLUMN Cpu;

SELECT * FROM laptops_backup;

SELECT ScreenResolution,
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1)
FROM laptops_backup;

ALTER TABLE laptops_backup
ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width;

UPDATE laptops_backup
SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1);

SELECT * FROM laptops_backup;

ALTER TABLE laptops_backup
ADD COLUMN touchscreen INTEGER AFTER resolution_height;

UPDATE laptops_backup
SET touchscreen = ScreenResolution LIKE '%Touch%';

ALTER TABLE laptops_backup DROP COLUMN ScreenResolution;

SELECT cpu_name, SUBSTRING_INDEX(TRIM(cpu_name),' ',2)
FROM laptops_backup;

UPDATE laptops_backup
SET cpu_name = SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

SELECT DISTINCT cpu_name FROM laptops_backup;

SELECT Memory FROM laptops_backup;

ALTER TABLE laptops_backup
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

-- SELECT Memory,
-- CASE
-- 	WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
--     WHEN Memory LIKE '%SSD%' THEN 'SSD'
--     WHEN Memory LIKE '%HDD%' THEN 'HDD'
--     WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
--     WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
--     WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
--     ELSE NULL
-- END AS 'memory_type'
-- FROM laptops_backup;

UPDATE laptops_backup
SET memory_type = CASE
	WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END;

-- SELECT Memory,
-- REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
-- CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END
-- FROM laptops_backup;

UPDATE laptops_backup
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;

-- SELECT primary_storage,
-- CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
-- secondary_storage,
-- CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END
-- FROM laptops_backup;

-- 1TB/2TB to 1024/2048 GB conversion used in case of small values like 1 or 2
UPDATE laptops_backup
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END;


SELECT * FROM laptops_backup;

ALTER TABLE laptops_backup DROP COLUMN gpu_name;
ALTER TABLE laptops_backup DROP COLUMN Memory;

SELECT * FROM laptops_backup;