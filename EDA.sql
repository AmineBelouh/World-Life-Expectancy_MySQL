USE world_life_expectancy;

SELECT * FROM world_life_expectancy;

# min max avg life expectancy for each country
SELECT 
	Country,
    MIN(`Life expectancy`) AS min_life_expectancy,
	ROUND(AVG(`Life expectancy`), 1) AS avg_life_expectancy,
	MAX(`Life expectancy`) AS max_life_expectancy
FROM world_life_expectancy 
GROUP BY Country;

# Countries with no data
SELECT * 
FROM world_life_expectancy 
WHERE `Life expectancy` = 0;

# Avg life expectancy worldwide across the 15 years we have
SELECT 
	Year,
    ROUND(AVG(`Life expectancy`), 1) AS avg_life_expectancy
FROM world_life_expectancy
WHERE `Life expectancy` > 0
GROUP BY Year
ORDER BY Year;


# Is there a correlation between GDP and life expectancy
SELECT 
	Country,
    ROUND(AVG(`Life expectancy`), 1) AS avg_life_expectancy,
    ROUND(AVG(GDP), 1) AS avg_GDP
FROM world_life_expectancy
GROUP BY Country
HAVING AVG(`Life expectancy`) > 0 AND AVG(GDP) > 0
ORDER BY avg_GDP DESC;


SELECT 
    SUM(CASE WHEN avg_GDP > (SELECT AVG(GDP) FROM world_life_expectancy WHERE GDP != 0) THEN 1 END) AS countries_GDP_above_world_avg,
    ROUND(AVG(CASE WHEN avg_GDP > (SELECT AVG(GDP) FROM world_life_expectancy WHERE GDP != 0) THEN avg_life_expectancy_country END), 1) AS avg_life_expectancy,
	SUM(CASE WHEN avg_GDP < (SELECT AVG(GDP) FROM world_life_expectancy WHERE GDP != 0) THEN 1 END) AS countries_GDP_below_world_avg,
	ROUND(AVG(CASE WHEN avg_GDP < (SELECT AVG(GDP) FROM world_life_expectancy WHERE GDP != 0) THEN avg_life_expectancy_country END), 1) AS avg_life_expectancy
FROM (
	SELECT 
		Country,
		AVG(GDP) AS avg_GDP,
        AVG(`Life expectancy`) AS avg_life_expectancy_country
	FROM world_life_expectancy
	WHERE GDP > 0 AND `Life expectancy` > 0
	GROUP BY Country
) AS avg_GDP_subquery;


# Life expectancy by Status of the country
SELECT
	Status,
    COUNT(DISTINCT Country) As num_countries,
    ROUND(AVG(`Life expectancy`), 1) AS avg_life_expectancy
FROM world_life_expectancy
WHERE `Life expectancy` > 0
GROUP BY Status;


# Is there correlation between life expectancy and BMI
SELECT 
	Country,
	ROUND(AVG(`Life expectancy`), 1) AS avg_life_expectancy,
	ROUND(AVG(BMI), 1) AS avg_BMI
FROM world_life_expectancy
WHERE BMI > 0 AND `Life expectancy` > 0
GROUP BY Country
ORDER BY avg_BMI DESC;


# Adult mortality Rolling total
SELECT
	Country,
    Year,
    `Adult Mortality`,
    SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy;

