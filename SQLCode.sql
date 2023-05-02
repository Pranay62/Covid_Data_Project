
Select *
From CovidDeaths$
Where continent is not null 
order by 3,4


--Select *
--From CovidVaccinations$
--Where continent is not null 
--order by 3,4

-- Select Data that we are going to be start with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths,
ROUND((total_deaths/total_cases)*100.00,2) as DeathPercentage
From CovidDeaths$
Where location like '%india%' 
and continent is not null 
order by 1,2


--- Looking at total cases vs population
-- Show what percentage of population got Covid

Select Location, date, total_cases,population,
(total_cases/population)*100.00 as PopulationPercentage
From CovidDeaths$
--Where location like '%india%'
 where continent is not null 
order by 1,2

-- Top countries with highest infection rates compare to population

Select Location,population, MAX(total_cases) as HighestInfections,
MAX((total_cases/population))*100 as HighestPopulationPercentage
From CovidDeaths$
--Where location like '%india%'
 where continent is not null 
 group by Location,population
order by HighestPopulationPercentage desc


-- Top countries with highest death count perpopulation

Select Location, MAX(CAST (total_deaths as int))  as TotalDeaths
From CovidDeaths$
--Where location like '%india%'
 where continent is not null 
 group by Location,population
order by TotalDeaths desc

-- Breaks things by continent
-- Showing continent with highest death count per population
Select continent, MAX(CAST (total_deaths as int))  as TotalDeaths
From CovidDeaths$
--Where location like '%india%'
 where continent is not null 
 group by continent
order by TotalDeaths desc

---- GLOBAL NUMBERS

Select  SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int)) as Total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From CovidDeaths$
--Where location like '%india%' 
where continent is not null 
--group by date
order by 1,2


--Looking at total population vs Vaccination

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(CAST(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths$ cd join CovidVaccinations$ cv
on cd.location =cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3


--- How many percentage population are vaccinated with the help of cte 
with cte as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(CAST(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths$ cd join CovidVaccinations$ cv
on cd.location =cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select continent,location,date,
population,new_vaccinations,RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100  as PercentagePeoplevaccinated
from cte

--- Alternate option using temp table

DROP table if exists #PercentagePopulationVaccinated

create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(CAST(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths$ cd join CovidVaccinations$ cv
on cd.location =cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3

select continent,location,date,
population,new_vaccinations,RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100  as PercentagePeoplevaccinated
from #PercentagePopulationVaccinated


------Creating view to store data for later visualiztions

create view PercentagePopulationVaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(CAST(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths$ cd join CovidVaccinations$ cv
on cd.location =cv.location
and cd.date = cv.date
where cd.continent is not null



select * 
from PercentagePopulationVaccinated