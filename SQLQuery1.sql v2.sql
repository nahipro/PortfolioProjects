select  * 
from [dbo].[CovidDeath],[dbo].[Covid Vacination ]
order by 3,4

--select  * 
--from [dbo].[Covid Vacination ] 
--order by 3,4

--select data that we are going to be useing 

select location, date, total_cases, new_cases, total_deaths, population from [dbo].[CovidDeath]

-- looking at total cases vs total death 

select location, date, total_cases ,population, (total_deaths/total_cases)*100 as deathperscentage
from [dbo].[CovidDeath]
where location like '%russia%'
order by 1
 



--looking at the total cases vs population 



select location, date, total_cases, total_deaths, (total_cases/population)*100 as totacaseperpopulation
from [dbo].[CovidDeath]
--here location like '%ethiopia%'

order by 3


-- lookinng at countries with highest infaction rate compared to population 

select location, population,MAX(total_cases)as highst_infaction, max((total_cases/population))*100 as percentpouplation
from [dbo].[CovidDeath]
--where location like '%ethiopia%'
group by location, population
order by  percentpouplation desc

-- showing countries with highest death count per population in each county

select location, population,MAX(cast(total_deaths as int))as totaldeathcount
from [dbo].[CovidDeath]
--where location like '%ethiopia%'
where continent is not null
group by location, population
order by totaldeathcount desc

-- also by continent 


select continent, MAX(cast(total_deaths as int))as totaldeathcount
from [dbo].[CovidDeath]
--where location like '%ethiopia%'
where continent is not null
group by continent
order by totaldeathcount desc

-- or

select location, population,MAX(cast(total_deaths as int))as totaldeathcount
from [dbo].[CovidDeath]
--where location like '%ethiopia%'
where continent is null
group by location, population
order by totaldeathcount desc

--showing the continent with the higest death count per population 


select continent , MAX(cast(total_deaths as int)) as highstdeathperpopulation
from [dbo].[CovidDeath]
where continent is not null
group by continent
order by highstdeathperpopulation desc 


select continent, max(total_deaths /population)*100 as highstdeathperpopulation
from [dbo].[CovidDeath]
where continent is not null
group by continent
order by highstdeathperpopulation asc 


-- Global numberds 

select date,sum(cast(total_deaths as float )) as totaldeath, sum(cast(new_deaths as float)) as sumofnewdeath  ,sum(new_cases) as sumofnewcase,
sum(cast( new_deaths as float))/sum(new_cases )*100 as deathpercentage
from [dbo].[CovidDeath]
where continent   is not null
group by date 
 order by 1,4 


 select *
 from[dbo].[Covid Vacination ] dea
 join [dbo].[CovidDeath] vac
 on dea.location=vac.location

 -- looking at total population vs vaccinations 

 select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
 from[dbo].[Covid Vacination ] vac
 
 join [dbo].[CovidDeath] dea
 on dea.location=vac.location
 and dea.date= vac.date
 where dea.continent is not null
 order by 2,3

 -- looking at total population vs sum of new vaccination 

  select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
  ,sum(cast(vac.new_vaccinations as float))over (partition by dea.location  order by dea.location, dea.date) AS ROllingPeoplevacination ,
  (ROllingPeoplevacination/dea.population) 
 from[dbo].[Covid Vacination ] vac
 join [dbo].[CovidDeath] dea
 on dea.location=vac.location
 and dea.date= vac.date
 where dea.continent is not null
 order by 2,3
  

  -- use CTE

  with popvsvac (continent ,location,date,population,ROllingPeoplevacination,new_vaccinations)
  as 
    (select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
  ,sum(cast(vac.new_vaccinations as float))over (partition by dea.location  order by dea.location, dea.date) AS ROllingPeoplevacination 
 from[dbo].[Covid Vacination ] vac
 join [dbo].[CovidDeath] dea
 on dea.location=vac.location
 and dea.date= vac.date
 where dea.continent is not null
 --order by 2,3
 )

 select *,(ROllingPeoplevacination/population)*100
 from popvsvac




 --- Temp table

 drop table if exists #percentpopulationvaccinated
 create table #percentpopulationvaccinated
 (
 continent nvarchar(225),
 location nvarchar (225),
 date datetime ,
 populations numeric ,
 new_vaccinations numeric,
 RollingpeopleVaccinated numeric
 
 )


 insert into #percentpopulationvaccinated 
 
    select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
  ,sum(cast(vac.new_vaccinations as float))over (partition by dea.location  order by dea.location, dea.date) AS ROllingPeoplevacination 
 from[dbo].[Covid Vacination ] vac
 join [dbo].[CovidDeath] dea
 on dea.location=vac.location
 and dea.date= vac.date
 where dea.continent is not null
 --order by 2,3
 


select *
 from #percentpopulationvaccinated

 -- createing view to store data for later visualization

 create view percentpopulationvaccinated as
 select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
  ,sum(cast(vac.new_vaccinations as float))over (partition by dea.location  order by dea.location, dea.date) AS ROllingPeoplevacination 
 from[dbo].[Covid Vacination ] vac
 join [dbo].[CovidDeath] dea
 on dea.location=vac.location
 and dea.date= vac.date
 where dea.continent is not null
 --order by 2,3

 select * 
 from percentpopulationvaccinated

