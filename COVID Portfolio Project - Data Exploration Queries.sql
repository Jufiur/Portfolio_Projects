SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--WHERE Continent IS NOT NULL
--ORDER BY 3, 4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2

-- Looking for Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
AND Continent IS NOT NULL
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Singapore%'
AND Continent IS NOT NULL
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Indonesia'
AND Continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases VS Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
AND Continent IS NOT NULL
ORDER BY 1,2

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE Continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Let's Break Things Down By Continent
-- Showing Continents with the Highest Death Count per Population

SELECT Continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT Date, SUM(new_cases) AS Total_New_Cases, SUM(CAST(new_deaths AS int)) AS Total_New_Deaths, 
	   SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY 1, 2

-- To find the total cases in the World

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, 
	   SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
--GROUP BY Date
ORDER BY 1, 2

-- Joining 2 tables (CovidDeaths and CovidVaccinations)

SELECT *
FROM PortfolioProject..CovidDeaths AS Dea
JOIN PortfolioProject..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date

-- Looking at Total Population VS Vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
FROM PortfolioProject..CovidDeaths AS Dea
JOIN PortfolioProject..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2,3

-- -- Looking at Total Population VS Vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS Dea
JOIN PortfolioProject..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated	   
FROM PortfolioProject..CovidDeaths AS Dea
JOIN PortfolioProject..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated	   
FROM PortfolioProject..CovidDeaths AS Dea
JOIN PortfolioProject..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
--WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to Store Data for Later Visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated	   
FROM PortfolioProject..CovidDeaths AS Dea
JOIN PortfolioProject..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated
