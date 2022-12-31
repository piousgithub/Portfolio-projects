SELECT *
FROM portfolio_project..CovidDeaths
ORDER BY location, date;

--SELECT *
--FROM portfolio_project..CovidVaccinations
--ORDER BY location, date;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project..CovidDeaths
ORDER BY location, date;

-- total cases vs total deaths in percentage

SELECT location, date, total_cases, total_deaths, 100 * (total_deaths / total_cases) AS percent_deaths
FROM portfolio_project.dbo.CovidDeaths 
ORDER BY location, date;

-- total cases vs total deaths in percentage in the US

SELECT location, date, total_cases, total_deaths, 100 * (total_deaths / total_cases) AS percent_deaths
FROM portfolio_project.dbo.CovidDeaths 
WHERE location LIKE '%states%'
ORDER BY location, date;

-- total cases vs population

SELECT location, continent, date, total_cases, population, 
	100 * (total_cases/population) AS percent_infected
FROM portfolio_project..CovidDeaths
ORDER BY location, date;

-- what country has the highest infection rate?

SELECT location, MAX(total_cases) AS highest_infection
FROM portfolio_project..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY highest_infection DESC;

-- what country has the highest infection rate compared to the population?

SELECT location, MAX(total_cases) AS highest_infection, 
	MAX(100 * total_cases/ population) AS percent_infected
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY  highest_infection DESC, percent_infected DESC; 

SELECT location, MAX(total_cases) AS highest_infection,
	 MAX(100 * total_cases/ population) AS percent_infected
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_infected DESC; -- if you aren't interested in how population affects the order

-- countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS highest_deaths, 
	MAX(CAST(total_deaths AS INT)/population) AS percent_deaths
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_deaths DESC, percent_deaths DESC;

-- WHAT continent has the highest infection rate

SELECT continent, MAX(total_cases) AS highest_infections
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_infections DESC

-- WHAT continent has the highest deaths?

SELECT continent, MAX(CAST(total_deaths AS INT)) AS highest_deaths
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_deaths DESC

-- global numbers

SELECT date, SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS total_new_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS percent_new_deaths
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY date, total_new_cases;

-- total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY  dea.location ORDER BY dea.location, 
	dea.date) AS rolling_vaccinations
FROM portfolio_project..CovidDeaths dea 
JOIN portfolio_project..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- 1. CTE METHOD

WITH CTE (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY  dea.location ORDER BY dea.location, 
	dea.date) AS rolling_vaccinations
FROM portfolio_project..CovidDeaths dea 
JOIN portfolio_project..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
-- ORDER BY dea.location, dea.date
)

SELECT *, (rolling_vaccinations/population)*100 AS percent_population_vaccinated
FROM CTE;


-- 2. TEMP TABLE 

DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY  dea.location ORDER BY dea.location, 
	dea.date) AS rolling_vaccinations
FROM portfolio_project..CovidDeaths dea 
JOIN portfolio_project..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
-- ORDER BY dea.location, dea.date


SELECT *, (rolling_vaccinations/population)*100 AS percent_vaccinated
FROM #percent_population_vaccinated


-- CREATING VIEW to store data for later visualization
-- DOESN'T allow ORDER BY

USE portfolio_project
GO
CREATE VIEW  percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY  dea.location ORDER BY dea.location, 
	dea.date) AS rolling_vaccinations
FROM portfolio_project..CovidDeaths dea 
JOIN portfolio_project..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
-- ORDER BY dea.location, dea.date
;

SELECT *
FROM percent_population_vaccinated;













































