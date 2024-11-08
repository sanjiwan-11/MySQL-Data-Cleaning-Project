-- DATA CLEANING PROJECT 
/*TO-DO
	1.Remove Duplicate Values
    2.Standardize the Data
    3.Identifying NULL Values or Blank Values and Removing them
    4.Remove Any Columns or Rows that was added
*/

USE world_layoffs;
SELECT * FROM layoffs;

CREATE TABLE layoff_staging(SELECT * FROM layoffs);	

SELECT * FROM layoff_staging;

-- Identifying duplicates
WITH duplicate_CTE AS
(
SELECT *,ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions)
AS row_num FROM layoff_staging
)
SELECT* FROM duplicate_CTE
WHERE row_num>1;

SELECT* FROM layoff_staging
WHERE company="Microsoft";

-- Creating new table to delete duplicates
CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoff_staging2
SELECT *,ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions)
AS row_num FROM layoff_staging;

SELECT*FROM layoff_staging2;

-- Disabling safe update mode
SET SQL_SAFE_UPDATES = 0; 

-- Deleting duplicates
DELETE FROM layoff_staging2
WHERE row_num>1;

-- Standarizing Data (Finding issues in data and fixing it)
SELECT company,TRIM(COMPANY)FROM 
layoff_staging2;

UPDATE layoff_staging2
SET company=TRIM(company);

SELECT DISTINCT industry FROM
layoff_staging2 ORDER BY 1;

-- Naming all the different named column into a same name
UPDATE layoff_staging2 
SET industry='Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country,TRIM(TRAILING '.'FROM country) 
FROM layoff_staging2 ORDER BY 1;

UPDATE layoff_staging2
SET country= TRIM(TRAILING '.'FROM country) 
WHERE country LIKE 'United States%';

-- Updating date into date forat from text and into a standard date format
UPDATE layoff_staging2
SET `date`=STR_TO_DATE(`date`,'%m/%d/%Y');
ALTER TABLE layoff_staging2
MODIFY `date` DATE;

/*Identifying NULL values
Removing NULL values */

SELECT *
FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoff_staging2 
WHERE industry IS NULL 
OR industry ='';

SELECT * FROM layoff_staging2
WHERE company='Airbnb';

-- Populating Data with same industry and same company
UPDATE layoff_staging2
SET industry= null
WHERE industry='';    #converting all the blanks into null

SELECT * FROM layoff_staging2 t1
JOIN layoff_staging2 t2
	ON t1.company=t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoff_staging2 t1	
JOIN layoff_staging2 t2
	ON t1.company=t2.company
SET t1.industry=t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Drop the column that was created like row_num and other's if any
ALTER TABLE layoff_staging2
DROP COLUMN row_num;

SELECT *
FROM layoff_staging2;
