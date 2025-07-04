-- ====================================
# DATA CLEANING
-- 1. Remove duplicates
-- 2. Standardize the data
-- 3. Null values or blank values
-- 4. Remove any columns
-- ====================================

-- ====================================
# Membuat table baru (menduplikat raw data) tujuannya agar kita dapat membandingkan dataset sebelum dan setelah di data cleaning 
SELECT * FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * FROM layoffs;
-- ============================

-- ============================
#1.) Remove duplicates
-- ============================
-- Memberikan row_num pada tiap2 baris berdasarkan kolom2 yang ada
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Tentukan row mana yang lebih dari satu alias duplikat
WITH duplicate_cte AS(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;

-- CREATE TABLE baru untuk menghapus row_num > 1
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL, 
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging2
WHERE row_num = 1;

DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- ============================
#2.) Standardizing data (finding issues then fixing it)
-- ============================
-- Menghilangkan space diawal kalimat (jadi rata kiri)
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Mengupdate kalimat yang seharusnya menjadi satu kesamaan tadinya (CryptoCurrency, Crypto Curr)
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Mengecek di tiap kolom apakah ada issue
SELECT DISTINCT company
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- Ditemukan sebuah issue disini ada 2 us 'united states' dan 'united states.'
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Mengupdate issue tersebut
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Mengubah format date text menjadi format date sql (serta mengubah tipe datanya menjadi DATE)
SELECT `date`
FROM layoffs_staging2
ORDER BY `date` ASC;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') AS date_time
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- ============================
#3.) Null and blank values 
-- ============================
-- Mengecek satu persatu kolom, mana saja yang terdapat blank or null
SELECT *
FROM layoffs_staging2
WHERE company IS NULL OR industry = '';

-- Setelah itu cari tahu baris tersebut (barangkali ada baris lain yang berkaitan dan tidak null atau blank maka bisa di update dengan mudah)
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Airbnb';

# Jika dari baris yang null atau blank values tidak terdapat baris lain yang berkaitan
# maka bisa saja langsung mengupdate data tersebut (namun harus dengan pertimbangan yang matang dan data yang diupdate harus relate)
# kalau benar-benar tidak tahu maka lebih baik dibiarkan saja atau dihapus (jika terdapat banyak kolom yang null)
UPDATE layoffs_staging2
SET industry = 'Travel'
WHERE company LIKE 'Airbnb';

-- Jika ditemukan baris lain yang tidak null maka ubah baris yang blank menjadi null
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Lihat perbandingan dengan self-join
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- Lalu update data yang null menjadi seperti data yang is not null
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- ============================
#4.) Remove pointless columns or rows
-- ============================
-- Mencari satu persatu baris mana saja yang terdapat banyak NULL
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

# Jika data yang null merupakan data yang penting dan kita tidak bisa mengupdatenya dikarenakan tidak tahu 
# Maka bisa jadi pertimbangan untuk dihapus, karena untuk mempermudah proses eda (jadi buat apa banyak data yang null)
# Namun jika bisa kita update silahkan diupdate
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;







