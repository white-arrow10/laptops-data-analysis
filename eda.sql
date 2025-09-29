USE test;
SELECT * FROM laptops_backup;

-- head, tail and sample
SELECT * FROM laptops_backup
ORDER BY `index` LIMIT 5;

SELECT * FROM laptops_backup
ORDER BY `index` DESC LIMIT 5;

SELECT * FROM laptops_backup
ORDER BY rand() LIMIT 5;

SELECT COUNT(Price) OVER(),
MIN(Price) OVER(),
MAX(Price) OVER(),
AVG(Price) OVER(),
STD(Price) OVER(),
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q1',
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Price) OVER() AS 'Median',
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q3'
FROM laptops_backup
ORDER BY `index` LIMIT 1;

-- missing value
SELECT COUNT(Price)
FROM laptops_backup
WHERE Price IS NULL;

-- outliers
SELECT * FROM (SELECT *,
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q1',
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q3'
FROM laptops_backup) t
WHERE t.Price < t.Q1 - (1.5*(t.Q3 - t.Q1)) OR
t.Price > t.Q3 + (1.5*(t.Q3 - t.Q1));

-- few more comparisons -

-- laptops group by price range (horizontal histogram)

SELECT t.buckets,REPEAT('*',COUNT(*)/4) FROM (SELECT price, 
CASE 
	WHEN price BETWEEN 0 AND 25000 THEN '0-25K'
    WHEN price BETWEEN 25001 AND 50000 THEN '25K-50K'
    WHEN price BETWEEN 50001 AND 75000 THEN '50K-75K'
    WHEN price BETWEEN 75001 AND 100000 THEN '75K-100K'
	ELSE '>100K'
END AS 'buckets'
FROM laptops_backup) t
GROUP BY t.buckets;

-- pie chart can be made using this -
SELECT Company,COUNT(Company) FROM laptops_backup
GROUP BY Company;

-- scatter plot can be made using this -
SELECT cpu_speed,Price FROM laptops_backup;

-- contingency table (stacked bar chart can be made using this)-
SELECT Company,
SUM(CASE WHEN Touchscreen = 1 THEN 1 ELSE 0 END) AS 'Touchscreen_yes',
SUM(CASE WHEN Touchscreen = 0 THEN 1 ELSE 0 END) AS 'Touchscreen_no'
FROM laptops_backup
GROUP BY Company;

SELECT DISTINCT cpu_brand FROM laptops_backup;

-- similar for cpu_brand -
SELECT Company,
SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS 'intel',
SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS 'amd',
SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS 'samsung'
FROM laptops_backup
GROUP BY Company;

-- categorical vs numerical comparison -
SELECT Company,MIN(price),
MAX(price),AVG(price),STD(price)
FROM laptops_backup
GROUP BY Company;

-- currently dataset has no missing values, lets introduce some and then deal with them

UPDATE laptops_backup
SET price = NULL
WHERE `index` IN (7,869,1148,827,865,821,1056,1043,692,1114)

SELECT * FROM laptops_backup
WHERE price IS NULL;

-- replacing missing values with mean

UPDATE laptops_backup
SET price = (SELECT AVG(price) FROM laptops_backup)
WHERE price IS NULL;


-- replace missing values with mean price of corresponding company
UPDATE laptops_backup l1
SET price = (SELECT AVG(price) FROM laptops_backup l2 WHERE
			 l2.Company = l1.Company)
WHERE price IS NULL;

-- a bit of feature engineering -

-- res h/w/inches can be used to make new feature - ppi (pixels per inch)
-- ppi = sqrt(x^2 + y^2)/inches

ALTER TABLE laptops_backup ADD COLUMN ppi INTEGER;
UPDATE laptops_backup
SET ppi = ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/Inches);

SELECT * FROM laptops_backup
ORDER BY ppi DESC;

-- way too many variations in inches column, lets bucket them
-- creating new feature - screen size - categorical data 
-- small, medium, large - <14, in between ,>17 respectively

ALTER TABLE laptops_backup ADD COLUMN screen_size VARCHAR(255) AFTER Inches;

UPDATE laptops_backup
SET screen_size = 
CASE 
	WHEN Inches < 14.0 THEN 'small'
    WHEN Inches >= 14.0 AND Inches < 17.0 THEN 'medium'
	ELSE 'large'
END;

SELECT screen_size,AVG(price) FROM laptops_backup
GROUP BY screen_size;

-- One Hot Encoding

SELECT gpu_brand,
CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END AS 'intel',
CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END AS 'amd',
CASE WHEN gpu_brand = 'nvidia' THEN 1 ELSE 0 END AS 'nvidia',
CASE WHEN gpu_brand = 'arm' THEN 1 ELSE 0 END AS 'arm'
FROM laptops_backup

