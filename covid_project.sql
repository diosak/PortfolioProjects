-- Exploration of COVID-19 Death and Vaccination Data https://github.com/owid/covid-19-data/tree/master/public/data
-- As of May 29 2022

select * from CovidDeaths
order by 3,4

select * from CovidVaccinations
order by 3, 4

select *
from CovidPortfolioProject..CovidDeaths
where continent is not null 
order by 3,4


-- The 'where continent is not null' argument is essential in filtering out any continetal/regional aggregates (World/Europe etc.) already in our dataset.

select location, date, total_cases, new_cases, total_deaths, population
from CovidPortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- Daily Mortality Rate aka people who die every day in Greece
-- Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as MortalityRate
from CovidPortfolioProject..CovidDeaths
where location = 'Greece'
--and continent is not null 
order by 1,2

--Now globally...
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as MortalityRate
from CovidPortfolioProject..CovidDeaths
--where location = 'Greece'
where continent is not null 
order by 1,2


-- Let's find out what percentage of each country's population is infected at any given day
-- Total Cases vs Population

select location, date, population, total_cases, (total_cases/population)*100 as PercentageInfected
from CovidPortfolioProject..CovidDeaths
--where location = 'Greece'
order by 1,2


-- Time to find the countries with the highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentageInfected
from CovidPortfolioProject..CovidDeaths
--where location = 'Greece'
group by location, population
order by PercentageInfected desc


-- What are the countries with the highest death count per population?

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidPortfolioProject..CovidDeaths
--where location = 'Greece'
where continent is not null 
Group by location
order by TotalDeathCount desc



-- NOW LET'S BREAK THINGS DOWN BY CONTINENT

-- Which are the contintents with the highest death count per population?

select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
from CovidPortfolioProject..CovidDeaths
--where location = 'Greece'
where continent is not null 
group by continent
order by TotalDeathCount desc



-- GLOBAL TOTAL NUMBERS PER DAY

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
--where location = 'Greece'
where continent is not null 
group by date
order by 1,2

-- GLOBAL TOTAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
--where location = 'Greece'
where continent is not null 


-- Let's discover the rolling number of people that has received a full COVID vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Now to calculate the rolling vaccination percentage per day per country:
-- This includes people vaccinated multiple times, so percentage in some countries may exceed 100% of population!
-- new_vaccinations needs to be converted to a bigint rather than just an int...

-- Using Common Table Expressions (CTEs) to perform the calculations needed

with PopulationVsVaccinations (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as RollingPercentageVaccinations
from PopulationVsVaccinations



-- We can also use a temp table to store the values generated

DROP TABLE IF EXISTS #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as RollingPercentageVaccinations
from #PercentPopulationVaccinated



-- Lastly, we could also create a view to aid future visualization purposes...

drop view if exists PercentPopulationVaccinated

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated