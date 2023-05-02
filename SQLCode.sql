
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

Select Location, date, CONVERT(int,total_cases),convert(int,total_deaths),
(convert(int,total_deaths)/CONVERT(int,total_cases))*100.00 as DeathPercentage
From CovidDeaths$
--Where location like '%india%' 
where continent is not null 
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
DROP view if exists PercentagePopulationVaccinated

create view PercentagePopulationVaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(CAST(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths$ cd join CovidVaccinations$ cv
on cd.location =cv.location
and cd.date = cv.date
where cd.continent is not null



select * 
from PercentagePopulationVaccinated




--In SQL, TEMP tables, VIEWs, and CTEs (Common Table Expressions) are all ways to organize and manipulate data, but they serve different purposes.

--1. TEMP tables:
--A TEMP table is a temporary table that is created and destroyed automatically within a session. 
--It is usually used to store intermediate results during a complex query or to cache data for faster access. 
--TEMP tables are stored in memory or on disk, depending on the size of the data, and they can be indexed and queried like regular tables.

--2. VIEW:
--A VIEW is a virtual table that is defined by a query. 
--It is not a physical table, but rather a stored SELECT statement that can be used as a table in other queries. 
--A VIEW is a read-only object, which means that you cannot insert, update, or delete data from it directly. 
--Views are often used to simplify complex queries or to hide sensitive data from users.

--3. CTE:
--A CTE (Common Table Expression) is a named temporary result set that is defined within a query. 
--Unlike a TEMP table or a VIEW, a CTE is not stored on disk or in memory, and it is only visible within the scope of the query in which it is defined. 
--CTEs are often used to simplify complex queries, to break a query down into smaller steps, or to define a recursive query.

--In summary, 
--TEMP tables are used to store intermediate results during a complex query, 
--VIEWS are used to simplify complex queries or hide sensitive data from users, and 
--CTEs are used to break a query down into smaller steps or to define a recursive query.