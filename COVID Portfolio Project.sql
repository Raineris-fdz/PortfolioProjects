Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Total Cases vs Total Deaths
--Likihood of dying if you contract COVID in your country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Where location like '%states%'
Order by 1,2

--Total Cases vs Population
--% of population got COVID

Select Location, Date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Where location like '%states%'
Order by 1,2

--Countries with Highest Infection Rate compared to Population

Select Location,population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by population, location
Order by PercentPopulationInfected desc


--Countries with Highest Death Count per Population

Select Location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc


--By Continent

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--Continent with Highest Death Count

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global Numbers

Select date, SUM(New_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by date
Order by 1,2

Select SUM(New_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
Order by 1,2


--JOIN the two tables

Select *
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date


--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
	order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--Using CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingVaccinationCount/population)*100
From PopvsVac


--TEMP TABlE
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaccinationCount numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingVaccinationCount/population)*100
From #PercentPopulationVaccinated


--Creating View for Visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


--Table from PercentPopulationVaccinated view

Select *
From PercentPopulationVaccinated
