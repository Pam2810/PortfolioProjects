select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Death
-- Shows likelihood of dying if you contract covid in the US
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what pecentage of pop has gotten covid
select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentagePerPop
from PortfolioProject..CovidDeaths$
-- where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to populations

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercentagePerPop
from PortfolioProject..CovidDeaths$
--where location like '%states%'
group by location, population
order by CovidPercentagePerPop desc

-- Showing the countries with the highest death count per population

select location, MAX(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%states%'
group by location
order by TotalDeathCount desc

-- Let's break things down by continent

select location, MAX(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
--where location like '%states%'
group by location
order by TotalDeathCount desc

-- Showing the continents with the highest death count

select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%states%'
group by continent
order by TotalDeathCount desc

-- Global Numbers

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths, SUM(cast(new_deaths as float))/SUM(new_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
-- where location like '%states%'
where continent is not null
group by date
order by 1,2

-- Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Temp Table

DROP table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated