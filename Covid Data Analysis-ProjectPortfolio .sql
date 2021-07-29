
select * from covid_deaths
order by 2,3;

select * from covid_vaccinations
order by new_vaccinations;


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select LOCATION, DATE_, TOTAL_CASES, TOTAL_DEATHS, (total_deaths/total_cases)*100 as DeathPercentage 
from covid_deaths
where LOCATION like '%States%'
order by 1,2;


--Looking at Total Cases vs Population
--Show the percentage of population got covid

select LOCATION, DATE_, Population, TOTAL_CASES, (total_cases/population)*100 as CovidPercentage 
from covid_deaths
--where LOCATION like '%States%'
order by 1,2;



-- Looking at countries with Highest Infection Rate Compared to Population

select LOCATION, Population, max(TOTAL_CASES) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected 
from covid_deaths
--where LOCATION like '%States%'
where continent is not null
group by Location, Population
order by PercentPopulationInfected desc;



-- Showing COuntries with Highest Death COunt per Population

select LOCATION,  max(cast(TOTAL_Deaths as int)) as TotalDeathCount 
from covid_deaths
--where LOCATION like '%States%'
where continent is not null
group by Location 
order by TotalDeathCount desc;



-- LET'S BREAK BY CONTINENT

-- Showing Continent with highest death count

select continent,  max(cast(TOTAL_Deaths as int)) as TotalDeathCount 
from covid_deaths
--where LOCATION like '%States%'
where continent is not null
group by continent 
order by TotalDeathCount desc;



-- GLOBAL NUMBERS
-- SHowing Death Percentage for particular Day

select date_, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, sum(new_deaths)/sum(new_cases)*100 as DeathsPercentage
from covid_deaths
--where LOCATION like '%States%'
where continent is not null
group by date_
order by 1,2;



-- Global DeathsPercentage across world

select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, sum(new_deaths)/sum(new_cases)*100 as DeathsPercentage
from covid_deaths
--where LOCATION like '%States%'
where continent is not null
--group by date_
order by 1,2;




-- JOIN
-- Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date_ , dea.population, vac.new_vaccinations
from covid_deaths dea
join covid_vaccinations vac
    on dea.location = vac.location
    and dea.date_ = vac.date_
where dea.continent is not null
order by 2,3;



-- Summation of new_vaccination every day in particular country

select dea.continent, dea.location, dea.date_ , dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date_)
  as RollingPeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac
    on dea.location = vac.location
    and dea.date_ = vac.date_
where dea.continent is not null
order by 2,3;




-- USE CTE

with PopvsVac (Continent, location, date_, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date_ , dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date_)
  as RollingPeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac
    on dea.location = vac.location
    and dea.date_ = vac.date_
where dea.continent is not null
--order by 2,3;
)
select Continent, location, date_, population, new_vaccinations, RollingPeopleVaccinated,(RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PopvsVac;




-- TEMP TABLE


create table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinated numeric,
RollingPeopleVaccinated numeric,
PercentageVaccinated numeric
)

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date_ , dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date_)
  as RollingPeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac
    on dea.location = vac.location
    and dea.date_ = vac.date_
where dea.continent is not null
order by 2,3;

select Continent, location, date_, population, new_vaccinations, RollingPeopleVaccinated,(RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PercentPopulationVaccinated




-- Creating view to store data for later visualizations


Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date_ , dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date_)
  as RollingPeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac
    on dea.location = vac.location
    and dea.date_ = vac.date_
where dea.continent is not null
--order by 2,3;

select *
from PercentPopulationVaccinated










