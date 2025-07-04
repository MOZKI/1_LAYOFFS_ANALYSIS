-- ====================================
# EDA (Exploratory Data Analysis) 
-- ====================================
SELECT *
FROM layoffs_staging2;

SELECT DISTINCT country
FROM layoffs_staging2;
-- ====================================

-- ====================================
# Mencari periode / tanggal dari dataset (data yang ada berlaku dari kapan sampai kapan)
-- 1. Mencari max n min date
SELECT MAX(`date`), MIN(`date`)
FROM layoffs_staging2;
-- ====================================

-- ====================================
# Menganalisis total laid off
-- 1. Mencari max n min + SUM(total laid off)
SELECT MAX(total_laid_off) AS 'MAX', MIN(total_laid_off) AS 'MIN ', SUM(total_laid_off) AS 'TOTAL'
FROM layoffs_staging2;

-- 2. total laid off per company (top 5)
SELECT company AS 'Company', SUM(total_laid_off) AS 'Total Laid Off'
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC
LIMIT 5;

-- 3. total laid off per industry (top 5)
SELECT industry AS Industry, SUM(total_laid_off) AS 'Total Laid Off'
FROM layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC
LIMIT 5;

-- 4. total laid off per country (top 5)
SELECT country AS Country, SUM(total_laid_off) AS 'Total Laid Off'
FROM layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC
LIMIT 5
;

-- total laid off yang tersebar diseluruh negara
SELECT country AS Country, SUM(total_laid_off) AS 'Total Laid Off'
FROM layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

-- 5. total laid off company per year (buat rank per tahun, ambil top 3)
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`);

WITH company_year(company, years, total) AS
(
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY company, YEAR(`date`)
),
rank_year AS
(
	SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total DESC ) AS rank_company
    FROM company_year
)
SELECT *
FROM rank_year
WHERE rank_company <= 3;

-- 6. Rolling total laid off company per year to month
SELECT SUBSTRING(`date`,1,7) AS month, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY month;

WITH rolling_cte AS(
	SELECT SUBSTRING(`date`,1,7) AS month, SUM(total_laid_off) AS total_laid
	FROM layoffs_staging2
	GROUP BY month
)
SELECT *, SUM(total_laid) OVER(ORDER BY month) AS rolling_total
FROM rolling_cte;
-- ====================================

-- ====================================
# Menganalisis funds raised millions
-- 1. Mencari max n min + SUM()
SELECT MAX(funds_raised_millions) AS Max, MIN(funds_raised_millions) AS Min, SUM(funds_raised_millions) AS Total
FROM layoffs_staging2;

-- 2. Per company
SELECT company, SUM(funds_raised_millions) AS Total
FROM layoffs_staging2
GROUP BY company
ORDER BY  SUM(funds_raised_millions) DESC
LIMIT 5;

-- 3. Per industry
SELECT industry, SUM(funds_raised_millions)
FROM layoffs_staging2
GROUP BY industry
ORDER BY  SUM(funds_raised_millions) DESC
LIMIT 5;

-- 4. Per country
SELECT country, SUM(funds_raised_millions)
FROM layoffs_staging2
GROUP BY country
ORDER BY  SUM(funds_raised_millions) DESC
LIMIT 5;
-- ====================================






