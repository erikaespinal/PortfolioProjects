SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER by 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER by 3, 4


--SELECT data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER by 1, 2

-- looking at tot cases vs tot deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER by 1, 2

-- Looking at  tot cases vs population
-- Shows what percentage of pop got covid
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PercentPopInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
ORDER by 1, 2

-- looking at countries with highest infection rates compared to the population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER by 4 DESC;



--Look at countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER by TotalDeathCount DESC;

-- Break down by continent --THIS IS THE CORRECT QUERY
SELECT location,  MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER by TotalDeathCount DESC;

--Break down by continent -- This is NOT correct but Alex made project with following query:
SELECT continent,  MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER by TotalDeathCount DESC;


-- Showing the continents with the highest death counts per population

SELECT continent,  MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER by TotalDeathCount DESC;

--Global Numbers - Per day 
SELECT date, SUM(new_cases) AS total_cases, 
			 SUM(cast(new_deaths AS int)) AS total_deaths, 
			 SUM(cast(new_deaths AS int))/SUM(new_cases)*100  AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER by 1, 2


--Global Numbers - Eliminated date, gives overall global death percentage

SELECT SUM(new_cases) AS total_cases, 
	   SUM(cast(new_deaths AS int)) AS total_deaths, 
	   SUM(cast(new_deaths AS int))/SUM(new_cases)*100  AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER by 1, 2

--Covid Vaccination Queries


SELECT * 
FROM PortfolioProject..CovidDeaths dea	
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location


--New to me why is he doing an 'AND' statement with the ON statement
SELECT * 
FROM PortfolioProject..CovidDeaths dea	
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date

--Looking at Total Population vs Vaccinations 
--- Going to calculate rolling vaccinations, a rolling count
--USing CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(cast(vac.new_vaccinations AS int))	
		   OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	     
FROM PortfolioProject..CovidDeaths dea	
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE (Same as above but now a temp table)

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(cast(vac.new_vaccinations AS int))	
		   OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	     
FROM PortfolioProject..CovidDeaths dea	
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--CREATING VIEW to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(cast(vac.new_vaccinations AS int))	
		   OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	     
FROM PortfolioProject..CovidDeaths dea	
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

--Query from view

SELECT * 
FROM PercentPopulationVaccinated