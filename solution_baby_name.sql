-- Objective 1: Track changes in name popularityYour first objective is to see how the most popular names have changed over time, and also to identify the names that have jumped the most in terms of popularity.

-- Find the overall most popular girl and boy names and show how they have changed in popularity rankings over the years

--Most popular girl name
SELECT name, SUM(births) AS num_babies 
FROM names 
WHERE gender = 'F' 
GROUP BY name
ORDER BY num_babies DESC LIMIT 1; --Jessica

--Most popular boy name
SELECT name, SUM(births) AS num_babies 
FROM names 
WHERE gender = 'M' 
GROUP BY name
ORDER BY num_babies DESC LIMIT 1; --Michael

--change in popularity for jessica over the year
SELECT * FROM
	(WITH girl_name AS (
		SELECT year, name, SUM(births) AS num_birth 
		FROM names 
		WHERE gender = 'F'
		GROUP BY year, name)
	SELECT year, name, 
	ROW_NUMBER() OVER (PARTITION BY year ORDER BY num_birth DESC) AS girl_popularity 
	FROM girl_name )
	WHERE name = 'Jessica'

--change in popularity for Michael over the year
SELECT * FROM 
	(WITH boy_name AS (SELECT year, name, SUM(births) AS num_babies 
	FROM names 
	WHERE gender = 'F'
	GROUP BY year, name)
SELECT year, name,
	ROW_NUMBER() OVER (PARTITION BY year ORDER BY num_babies DESC) from boy_name) AS boyname_popularity
	WHERE name = 'Michael'


-- popularity for 1980
WITH all_names AS (
	SELECT year, name, SUM(births) AS num_babies 
	FROM names
	GROUP BY year, name)
SELECT year, name,
	ROW_NUMBER() OVER (PARTITION BY year ORDER BY num_babies DESC) 
	FROM all_names AS popularity_1980
	WHERE year = 1980 

-- popularity for 2009
WITH all_names AS (
	SELECT year, name, SUM(births) AS num_babies 
	FROM names
	GROUP BY year, name)
SELECT year, name,
	ROW_NUMBER() OVER (PARTITION BY year ORDER BY num_babies DESC) AS popularity_2009
	FROM all_names 
	WHERE year = 2009

-- Find the names with the biggest jumps in popularity from the first year of the data set to the last year

WITH names_1980 AS (WITH 
all_names AS (
	SELECT year, name, SUM(births) AS num_babies 
	FROM names
	GROUP BY year, name)
		SELECT year, name,
		ROW_NUMBER() OVER (PARTITION BY year
		ORDER BY num_babies DESC) AS p_1980
		FROM all_names 
		WHERE year = 1980),
names_2009 AS (WITH 
	all_names AS (
		SELECT year, 
		name, SUM(births) AS num_babies 
		FROM names
		GROUP BY year, name)
			SELECT year, name,
			ROW_NUMBER() OVER (PARTITION BY year
			ORDER BY num_babies DESC) AS p_2009
			FROM all_names 
			WHERE year = 2009)
SELECT t2009.name, p_1980, p_2009,t1980.year, t2009.year, p_1980 - p_2009 AS pop_diff
FROM names_1980 t1980 JOIN names_2009 t2009
ON t1980.name = t2009.name
ORDER BY pop_diff DESC;

-- Objective 2: Compare popularity across decadesYour second objective is to find the top 3 girl names and top 3 boy names for each year, and also for each decade.

-- For each year, return the 3 most popular girl names and 3 most popular boy names

-- 3 most popular girl name each year
SELECT * FROM
	(WITH girl_name AS (
		SELECT year, name, SUM(births) AS num_birth 
		FROM names WHERE gender = 'F'
		GROUP BY year, name)
	SELECT year, name, ROW_NUMBER() 
	OVER (PARTITION BY year ORDER BY num_birth DESC) 
	AS girl_popularity 
	FROM girl_name )
	WHERE girl_popularity < 4

-- 3 most popular boy name each year
SELECT * FROM
	(WITH boy_name AS (
		SELECT year, name, SUM(births) AS num_birth 
		FROM names WHERE gender = 'M'
		GROUP BY year, name)
	SELECT year, name, ROW_NUMBER() 
	OVER (PARTITION BY year ORDER BY num_birth DESC) 
	AS boy_popularity 
	FROM boy_name )
	WHERE boy_popularity < 4


-- For each decade, return the 3 most popular girl names and 3 most popular boy names

-- 3 most popular boy name for each decades
WITH pop_decade AS (
	WITH boy_name AS (
	SELECT name, CASE 
	WHEN year BETWEEN 1980 AND 1990 THEN 'Decade1' 
	WHEN year BETWEEN 1990 AND 2000 THEN 'Decade2' 
	WHEN year BETWEEN 2000 AND 2010 THEN 'Decade3' 
	ELSE 'Others'
	END AS decade,
	SUM(births) AS num_birth 
	FROM names WHERE gender = 'M'
	GROUP BY decade, name)
	SELECT name, decade, ROW_NUMBER() 
	OVER (PARTITION BY decade ORDER BY num_birth DESC) 
	AS boy_popularity
	FROM boy_name )
SELECT decade, name, boy_popularity
FROM pop_decade
WHERE boy_popularity < 4
ORDER BY decade, boy_popularity

-- 3 most popular girl name for each decades
WITH pop_decade AS (
	WITH girl_name AS (
	SELECT name, CASE 
	WHEN year BETWEEN 1980 AND 1990 THEN 'Decade1' 
	WHEN year BETWEEN 1990 AND 2000 THEN 'Decade2' 
	WHEN year BETWEEN 2000 AND 2010 THEN 'Decade3' 
	ELSE 'Others'
	END AS decade,
	SUM(births) AS num_birth 
	FROM names WHERE gender = 'F'
	GROUP BY decade, name)
	SELECT name, decade, ROW_NUMBER() 
	OVER (PARTITION BY decade ORDER BY num_birth DESC) 
	AS girl_popularity
	FROM girl_name )
SELECT decade, name, girl_popularity
FROM pop_decade
WHERE girl_popularity < 4
ORDER BY decade, girl_popularity

-- Objective 3: Compare popularity across regionsYour third objective is to find the number of babies born in each region, and also return the top 3 girl names and top 3 boy names within each region.

-- added the MI state & midwest region to region table
INSERT INTO regions VALUES ('MI', 'Midwest') 

-- update the New_England region name
UPDATE regions SET region = 'New England' WHERE region = 'New_England';

-- Return the number of babies born in each of the six regions 
SELECT region, SUM(n.births) AS num_birth
FROM names n LEFT JOIN regions r 
ON n.state = r.state 
GROUP BY region
ORDER BY num_birth DESC


-- 3 most popular boy names within each region

SELECT * FROM (WITH region_num AS (SELECT region, name, SUM(n.births) AS num_birth
FROM names n LEFT JOIN regions r 
ON n.state = r.state
WHERE gender = 'M'
GROUP BY region, name)
SELECT region, name, num_birth,
ROW_NUMBER() OVER(PARTITION BY region ORDER BY num_birth DESC ) AS popularity 
FROM region_num)
WHERE popularity < 4
ORDER BY region

-- Return the 3 most popular girl names  

SELECT * FROM (WITH region_num AS (SELECT region, name, SUM(n.births) AS num_birth
FROM names n LEFT JOIN regions r 
ON n.state = r.state
WHERE gender = 'F'
GROUP BY region, name)
SELECT region, name, num_birth,
ROW_NUMBER() OVER(PARTITION BY region ORDER BY num_birth DESC ) AS popularity 
FROM region_num)
WHERE popularity < 4
ORDER BY region


-- Objective 4: Explore unique names in the datasetYour final objective is to find the most popular androgynous names, the shortest and longest names, and the state with the highest percent of babies named "Chris".

-- The 10 most popular androgynous names (names given to both females and males)

SELECT name, COUNT(DISTINCT gender) AS num_gender, SUM(births) AS num_birth 
FROM names GROUP BY name 
HAVING COUNT(DISTINCT gender) = 2
ORDER BY num_birth DESC
LIMIT 10;

-- Find the length of the shortest and longest names, and identify the most popular short names (those with the fewest characters) and long names (those with the most characters)

-- length of the shortest name
SELECT name, LENGTH(name) AS len_name 
FROM names ORDER BY len_name LIMIT 1 --2

-- length of the longest name
SELECT name, LENGTH(name) AS len_name 
FROM names ORDER BY len_name DESC LIMIT 1 --15

-- the most popular short names 
SELECT name, LENGTH(name) AS len_name, SUM(births) AS num_birth
FROM names WHERE LENGTH(name) = 2
GROUP BY name 
ORDER BY num_birth DESC

-- the most popular long names 
SELECT name, LENGTH(name) AS len_name, SUM(births) AS num_birth
FROM names WHERE LENGTH(name) = 15
GROUP BY name 
ORDER BY num_birth DESC

-- The founder of Maven Analytics is named Chris. Find the state with the highest percent of babies named "Chris"

-- number of babies called Chris per state
SELECT n.state, name, SUM(births) AS chris_birth FROM names n
WHERE name = 'Chris'
GROUP BY name, n.state
ORDER BY chris_birth DESC

-- total babies per state
SELECT n.state, SUM(births) AS num_birth FROM names n JOIN regions r
ON n.state = r.state
GROUP BY n.state
ORDER BY num_birth DESC

-- % of babies named chris per state

WITH chris_babies AS (
SELECT state, SUM(births) AS chris_birth FROM names
WHERE name = 'Chris'
GROUP BY state),

all_babies AS (
SELECT state, SUM(births) AS num_birth FROM names 
GROUP BY state)

SELECT c.state, chris_birth , num_birth,
ROUND((chris_birth::numeric / num_birth * 100),4) AS perc
FROM chris_babies c JOIN all_babies a
ON c.state = a.state 
ORDER BY perc DESC





