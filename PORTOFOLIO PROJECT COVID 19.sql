Select * 
FROM PortofolioProject.dbo.CovidDeaths	

Select location, date,  total_cases, new_cases, total_deaths, population
FROM PortofolioProject.dbo.CovidDeaths
Order by 1,2

-- todo
-- 1. total cases vs total deaths
-- 2. shows likelihood of dying if you contract covid in your country


-- no.1
Select location, date,  total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is not null
Order by 1,2

-- karena Divide by zero error encountered. maka total_cases = 0 diubah menjadi NULL atau dihapus

UPDATE PortofolioProject.dbo.CovidDeaths
SET total_cases = NULL
WHERE total_cases = 0


-- no.2
-- Looking at total cases vs population
-- show what percentage of population got covid
Select location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is not null
Order by 1,2

-- Looking at countries with the highest infection rate compared to population

Select location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
Order by PercentPopulationInfected DESC


-- showing country with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
Order by TotalDeathCount DESC

-- LETS BREAK THIS DOWN BY CONTINENT	

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is  not null
GROUP BY continent
Order by TotalDeathCount DESC

-- Showing the Continent with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is  not null
GROUP BY continent
Order by TotalDeathCount DESC


-- GLOBAL NUMBERS
-- RATA-RATA MENINGGAL DIDUNIA
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeath, SUM (new_deaths)/SUM(new_cases)*100  as DeathsPercentage
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
Order by 1,2

-- ubah new_cases jadi NULL
UPDATE PortofolioProject.dbo.CovidDeaths
SET new_cases = NULL
WHERE new_cases = 0


-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated	
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject.dbo.CovidDeaths dea
JOIN PortofolioProject.dbo.CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (Continent, location, date , population , new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated	
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject.dbo.CovidDeaths dea
JOIN PortofolioProject.dbo.CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select * , (RollingPeopleVaccinated/population)*100 
from PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated	
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject.dbo.CovidDeaths dea
JOIN PortofolioProject.dbo.CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
Select * , (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated	
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject.dbo.CovidDeaths dea
JOIN PortofolioProject.dbo.CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


DROP view PercentPopulationVaccinated

