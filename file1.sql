SELECT * FROM laptops;

CREATE TABLE laptops_backup LIKE laptops;
INSERT INTO laptops_backup
SELECT * FROM laptops;

SELECT * FROM laptops_backup;