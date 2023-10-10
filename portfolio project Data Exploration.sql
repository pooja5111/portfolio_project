select*
from portfolio_project..CovidDeaths
where continent is not null
order by 3,4
 -- select the items we need 

 select location, date, total_cases,new_cases,total_deaths,population
 from portfolio_project..CovidDeaths
 where continent is not null
 order by 1,2

 --looking at total cases vs total deaths
 -- shows the likelihood of dying if you contract covid
  select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
 from portfolio_project..CovidDeaths
 where location like '%states%' -- having states at the end 
 and continent is not null
 order by 1,2


 -- Looking at the total cases vs population
 -- shows what percentage of population got covid
 select location, date,population, total_cases,(total_cases/population)*100 as infectedPercentage
 from portfolio_project..CovidDeaths
 --where location like '%states%' -- having states at the end 
 order by 1,2

 -- looking at coutries with highest infection rate compare to population 
select location,population,MAX( total_cases)AS InfectionCount,MAX((total_cases/population))*100 as infectedPercentage
from portfolio_project..CovidDeaths
 --where location like '%states%' -- having states at the end 
Group  by location, population
order by infectedPercentage desc


-- showing highest death count over per population 
select location,MAX(cast(total_deaths as int)) AS TotalDeathCount
from portfolio_project..CovidDeaths
 --where location like '%states%' -- having states at the end
where continent is not null
Group  by location
order by TotalDeathCount desc


-- lets break things down by continent
-- by breking things down by continent doesnot provide the correct result
-- so we use location instead of continent and filter by "where continent is null"

select location,MAX(cast(total_deaths as int)) AS TotalDeathCount
from portfolio_project..CovidDeaths
 --where location like '%states%' -- having states at the end
where continent is null
Group  by location
order by TotalDeathCount desc   -- the result of this query is perfect compare to continent


-- showing the continents with highest death counts 
select continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
from portfolio_project..CovidDeaths
 --where location like '%states%' -- having states at the end
where continent is not null
Group  by continent
order by TotalDeathCount desc 


-- global numbers

 select  SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100   as deathPercentage
 from portfolio_project..CovidDeaths
 --where location like '%states%' -- having states at the end 
 where continent is not null
 --group by date
 order by 1,2



 -- looking at total population vs vaccinations
 select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
 --,(rollingPeopleVaccinated/population)*100
  from portfolio_project..CovidDeaths as dea
 Join portfolio_project..CovidVacsinations as vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- to find the total  number of people vaccinated using rollingPeopleVaccinated we use CTE as after using the col for same we just created gives an error 

-- USE CTE
with popvsvac(continent, location,date,population,new_vaccinations,rollingPeopleVaccinated)
as
(
 select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
 --,(rollingPeopleVaccinated/population)*100
  from portfolio_project..CovidDeaths as dea
 Join portfolio_project..CovidVacsinations as vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null

--order by 2,3
)
select*,(rollingPeopleVaccinated/population)*100
from popvsvac



-- TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
 --,(rollingPeopleVaccinated/population)*100
  from portfolio_project..CovidDeaths as dea
 Join portfolio_project..CovidVacsinations as vac
      on dea.location = vac.location
	  and dea.date = vac.date
--where dea.continent is not null

--order by 2,3
select*,(rollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualization

Create View PercentPopulationsVaccinated as
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
 --,(rollingPeopleVaccinated/population)*100
  from portfolio_project..CovidDeaths as dea
 Join portfolio_project..CovidVacsinations as vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null

--order by 2,3

select*
from PercentPopulationVaccinated