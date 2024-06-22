Select *
From PortfolioProject1..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject1..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if one contract covid in the US
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%states%'
where continent is not null
order by 1,2

-- Look at Total Cases vs Population
-- Shows what percentage of popultaion got Covid
Select Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
-- Where location like '%states%'
order by 1,2

-- Look at Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
Where location like '%states%'
and continent is not null
group by location, population 
order by PercentPopulationInfected desc

-- Show Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
-- Where location like '%states%'
where continent is not null
group by location 
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Show continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
-- Where location like '%states%'
where continent is not null
group by continent 
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
-- Where location like '%states%'
Where continent is not null
order by 1,2 


-- Look at Total population vs Vacciniations

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidVaccinations vac
Join PortfolioProject1..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidVaccinations vac
Join PortfolioProject1..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidVaccinations vac
Join PortfolioProject1..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Create view to store data for future visualizations
USE PortfolioProject1
GO
Create View PercentPopulationVaccination as 
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidVaccinations vac
Join PortfolioProject1..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *
From PercentPopulationVaccination

