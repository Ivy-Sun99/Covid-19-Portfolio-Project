/*
Covid 19 Data Exploration

Skills used: Joins, Temp Tables, Window Functions, Aggregating Functions, Creating Views

*/

-- Pulling information for CovidDeaths for later analysing
SELECT 
	Location, record_date, total_cases, new_cases, total_deaths, population
FROM 
	CovidDeaths
ORDER BY 1,2;


-- Total Cases vs Total Deaths
-- Show likelihood of dying if you contract Covid in your country

SELECT 
	Location, 
    record_date, 
    total_cases, 
    total_deaths, 
    CONCAT((total_deaths / total_cases)*100, '%') AS death_percentage
FROM 
	CovidDeaths
WHERE 
	Location = 'Ireland'
	AND continent IS NOT NULL
ORDER BY 1,2;


-- Toal Cases vs Population
-- Shows what percentage of population got Covid

SELECT 
	Location, 
    record_date, 
    total_cases, 
    population,
    CONCAT((total_cases / population)*100, '%') AS percent_population_infected
FROM CovidDeaths
-- WHERE Location = 'Ireland'
-- AND continent IS NOT NULL
ORDER BY 1,2;


-- Countries with highest infection rate compared to population

SELECT 
	Location, 
    population,
    MAX(total_cases) as highest_infection_count, 
    CONCAT((MAX(total_cases) / population)*100, '%') AS highest_infection_rate
FROM CovidDeaths
WHERE Location IS NOT NULL
GROUP BY 1,2
ORDER BY (MAX(total_cases) / population) DESC;


-- Countries with highest death count per population

SELECT 
	Location, 
    population,
    MAX(total_deaths) as total_death_count, 
    CONCAT((MAX(total_deaths) / population)*100, '%') AS highest_death_rate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY 1,2
ORDER BY (MAX(total_deaths) / population) DESC;


-- Let's break things down by continent

-- Showing continents with the highest death count

SELECT
	location as continent,
    MAX(total_deaths) as total_death_count
FROM
	CovidDeaths
WHERE
	continent IS NULL
    AND location IN ('World', 'Europe','Asia', 'North America','South America','Africa', 'Oceania')
GROUP BY
	location
ORDER BY
	2 DESC;


-- Showing continents with the highest death count per population

SELECT
	location as continent,
    MAX(population) as population,
    MAX(total_deaths) as total_death_count,
    CONCAT((MAX(total_deaths) / MAX(population))*100, '%') AS highest_death_rate
FROM
	CovidDeaths
WHERE
	continent IS NULL
    AND location IN ('World', 'Europe','Asia', 'North America','South America','Africa', 'Oceania')
GROUP BY
	location
ORDER BY
	4 DESC;
    
    
-- Global Numbers

-- Creating view to store data for later visualizations

CREATE OR REPLACE VIEW GlobalDeaths AS
SELECT
	-- record_date,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage
FROM
	CovidDeaths
WHERE continent IS NOT NULL;
-- GROUP BY 1;


-- Total Population vs Vaccinations

-- Shows Percentage of Population that has received at least one Covid Vaccine

DROP TABLE IF EXISTS pop_vs_vac;
CREATE TEMPORARY TABLE pop_vs_vac
SELECT
	cd.continent,
    cd.location,
    cd.record_date,
    cd.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.record_date) AS total_vaccinations
FROM
	CovidDeaths cd
    JOIN
    CovidVaccinations cv ON cd.location = cv.location 
    AND cd.record_date = cv.record_date
WHERE cd.continent IS NOT NULL
ORDER BY 1,2,3;

-- Use the temp table above to get the percentage of the vaccination rates
SELECT
	continent,
    location,
    record_date,
    population,
    new_vaccinations,
    total_vaccinations,
    (total_vaccinations / population)* 100 AS percent_of_vaccinations
FROM
	pop_vs_vac;
    
