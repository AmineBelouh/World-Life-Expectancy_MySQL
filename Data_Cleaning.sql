SELECT * FROM world_life_expectancy.world_life_expectancy;

USE world_life_expectancy;

# Deleting Duplicates (We shouldn't have same country and year in more than a record)
SELECT
	*
FROM (
SELECT
	ROW_NUMBER() OVER(PARTITION BY Country, Year) AS row_num,
	Country,
    Year,
    Row_ID
FROM
	world_life_expectancy
) table_row_num
WHERE row_num > 1;

DELETE FROM world_life_expectancy
WHERE Row_ID IN (
	SELECT
		Row_ID
	FROM (
	SELECT
		ROW_NUMBER() OVER(PARTITION BY Country, Year) AS row_num,
		Country,
		Year,
		Row_ID
	FROM
		world_life_expectancy
	) table_row_num
	WHERE row_num > 1
);

# Populating missing values in 'Status' Column
SELECT * FROM world_life_expectancy;

UPDATE world_life_expectancy
SET status = NULL
WHERE status = '';

UPDATE world_life_expectancy t1
JOIN (
	SELECT DISTINCT
		Country,
        Status
	FROM world_life_expectancy
    WHERE Status IS NOT NULL
) AS t2 ON t1.Country = t2.Country
SET t1.Status = t2.Status WHERE t1.Status IS NULL;


# Populating missing values in 'Life expectancy' Column -> Avg between previous year and next year life expectancy of the same country

UPDATE world_life_expectancy
SET `Life expectancy` = NULL
WHERE `Life expectancy` = '';

SELECT * FROM world_life_expectancy; 

UPDATE world_life_expectancy t1
SET `Life expectancy` = (
	SELECT 
		ROUND((previous_year + next_year) / 2, 1)
	FROM (
		SELECT
			ROW_ID,
			Country,
			Year ,
			LEAD(`Life expectancy`) OVER(PARTITION BY Country ORDER BY Year DESC) AS previous_year,
			`Life expectancy` AS life_expectancy_this_year,
			LAG(`Life expectancy`) OVER(PARTITION BY Country ORDER BY Year DESC) AS next_year
		FROM world_life_expectancy
	) AS t2
	WHERE 
		t1.ROW_ID = t2.ROW_ID
)
WHERE t1.`Life expectancy` IS NULL;








