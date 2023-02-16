Select *
From CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From CovidVaccinations
-- Order by 3,4

--Selce Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location = 'Ethiopia'
Order by 4 Desc


--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location = 'Ethiopia'
Order by 5

--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location = 'Ethiopia'
Group by location, population
Order by PercentPopulationInfected Desc



--Showing Countries with Highest Death Count per Population
Select location, population, MAX(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
--Where location = 'Ethiopia'
Where continent is not null
Group by location
Order by HighestDeathCount Desc


--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents wit highest death count per population
Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
--Where location = 'Ethiopia'
Where continent is not null
Group by continent
Order by HighestDeathCount Desc


--GLOBAL NUMBERS
Select date,SUM(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_death,  SUM(cast(new_deaths as int))/SUM(new_cases) as HiDeathCount
From CovidDeaths
--Where location = 'Ethiopia'
Where continent is not null
Group by date
Order by 1,2 Desc


--Global Total Death Percentage 
Select SUM(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_death,  SUM(cast(new_deaths as int))/SUM(new_cases) as Deathpercentage
From CovidDeaths
--Where location = 'Ethiopia'
Where continent is not null
Order by 1,2 Desc


--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location , dea.date) as ToDateVaccinationTotal --(ToDateVaccinationTotal/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
		On dea.location =vac.location
		and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, ToDateVaccinationTotal) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location , dea.date) as ToDateVaccinationTotal
From CovidDeaths dea
Join CovidVaccinations vac
		On dea.location =vac.location
		and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (ToDateVaccinationTotal/population)*100
From PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
 (
 continent nvarchar(255), 
 location nvarchar(255), 
 date datetime, 
 population numeric, 
 new_vaccinations numeric, 
 ToDateVaccinationTotal numeric
 )
 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location , dea.date) as ToDateVaccinationTotal
From CovidDeaths dea
Join CovidVaccinations vac
		On dea.location =vac.location
		and dea.date = vac.date
Where dea.continent is not null

Select *, (ToDateVaccinationTotal/population)*100 
From #PercentPopulationVaccinated

--Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location , dea.date) as ToDateVaccinationTotal
From CovidDeaths dea
Join CovidVaccinations vac
		On dea.location =vac.location
		and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated