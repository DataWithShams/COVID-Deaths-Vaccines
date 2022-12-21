-- Looks at entire table 

select *
from coviddata
where continent is not null
order by 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as "Death Percentage"
from coviddata
Where location like '%states%'
where continent is not null
order by 1, 2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population contracted COVID

SELECT location, date, population, total_cases,(total_cases/population)*100 as "Percent of Confirmed Cases"
from coviddata
Where location like '%states%'
and continent is not null
order by 1, 2;


-- Looking at countries with HIGHEST infection rate compared to Population

SELECT location, population, MAX(total_cases) as "Highest Infection Count", MAX((total_deaths/total_cases))*100 as PercentPopulationInfected
from coviddata
group by location, population
order by PercentPopulationInfected desc;


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX( CAST(total_deaths as signed) ) as TotalDeathCount
from coviddata
where continent is not null
group by location
order by TotalDeathCount desc;


-- Showing Continents with Highest Death Count per Population

SELECT continent, MAX( CAST(total_deaths as signed) ) as TotalDeathCountContinent
from coviddata
where continent is not null
group by continent
order by TotalDeathCountContinent desc;


-- Global Numbers

SELECT SUM(new_cases) as TotalCases,SUM( CAST(new_deaths as signed) ) as GlobalDeaths, SUM( CAST(new_deaths as signed) ) / SUM(new_cases)*100 as DeathPercentage
from coviddata
where continent is not null
order by 1, 2;


-- Looking at Total Population vs New Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from coviddata as dea
join covidvaccines as vac 
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2, 3;


-- Looking at Total Population vs Rolling Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM( CAST(vac.new_vaccinations as signed) ) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingVaccinations
from coviddata as dea
join covidvaccines as vac 
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2, 3;


-- USE CTE for Rolling Vaccinations over Population

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM( CAST(vac.new_vaccinations as signed) ) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingVaccinations
from coviddata as dea
join covidvaccines as vac 
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
select * , (rollingvaccinations/population)*100
from popvsvac;

-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated 
CREATE Table #PercentPopulationVaccinated 
(
Continent, varchar(255), 
Location varchar(255),
Date datetime,
Population int NOT NULL auto_increment,
New_vaccinations int NOT NULL auto_increment,
RollingVacciniations int NOT NULL auto_increment
)

INSERT into 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM( CAST(vac.new_vaccinations as signed) ) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingVaccinations
from coviddata as dea
join covidvaccines as vac 
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null

select * , (rollingvaccinations/population)*100
from #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations 

Create View PercentPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM( CAST(vac.new_vaccinations as signed) ) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingVaccinations
from coviddata as dea
join covidvaccines as vac 
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null;


