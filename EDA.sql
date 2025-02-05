-- Exploratory Data Analysis
USE world_layoffs;
SELECT *
FROM layoff_staging2;

SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM layoff_staging2;

SELECT *
FROM layoff_staging2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;

SELECT company,SUM(total_laid_off)
FROM layoff_staging2
GROUP BY company 
ORDER BY 2 DESC;

SELECT MIN(`date`),MAX(`date`)
FROM layoff_staging2;

SELECT industry,SUM(total_laid_off)
FROM layoff_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country,SUM(total_laid_off)
FROM layoff_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`),SUM(total_laid_off)
FROM layoff_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT *
FROM layoff_staging2;

-- Find the Rolling total
SELECT SUBSTR(`date`,1,7) AS `MONTH`,SUM(total_laid_off)
FROM layoff_staging2
WHERE SUBSTR(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT SUBSTR(`date`,1,7) AS `MONTH`,SUM(total_laid_off) AS total_off
FROM layoff_staging2
WHERE SUBSTR(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`,total_off,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Company wise analysis
SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoff_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

WITH Company_Years (company,years,total_laid_off) AS
(
SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoff_staging2
GROUP BY company, YEAR(`date`)
), Company_Rank AS
(SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Years
WHERE years IS NOT NULL
)
SELECT * FROM
Company_Rank WHERE
Ranking<=5;

-- Industry wise analysis
WITH Industry_year (industry,years,total_laid_off) AS
(SELECT industry,YEAR(`date`),SUM(total_laid_off)
FROM layoff_staging2
GROUP BY industry, YEAR(`date`)
ORDER BY industry ASC
)
SELECT *,DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Industry_year
WHERE industry IS NOT NULL AND years IS NOT NULL AND total_laid_off IS NOT NULL;



