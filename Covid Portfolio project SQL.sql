select * 
from PortfolioProject..CovidDeaths$
order by 3,4 

select location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2 

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%state%'
order by 1,2

-- looking at Total cases  vs Population
-- shows what percentage of population got covid 
select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%state%'
order by 1,2


--Looking at countries with Highest Infection Rate compared to population 
select location, population, max(total_cases) as HighestInfectionCount,  max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%state%'
Group by location, population
order by PercentPopulationInfected Desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the countries with Highest Deth Count per Population
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is NOT null
Group by continent
order by TotalDeathCount Desc


--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%state%' 
where continent is not null
--Group by date
order by 1,2


--Looking at Total Population Vs vaccinations 

--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
     on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE
drop table if exists #PercentPopualtionVaccinated

Create table #PercentPopualtionVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPopualtionVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
     on dea.location=vac.location and dea.date= vac.date
--where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopualtionVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopualtionVaccinated AS 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
     on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null
--order by 2, 3


select *
from PercentPopualtionVaccinated