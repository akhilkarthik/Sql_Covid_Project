--importing the two datasets
Select * from
covid_project.dbo.covid_death
 where continent is not null --need to make sure that there are no null values coming 
order by 3,4;


Select * from
covid_project.dbo.Vaccination
 where continent is not null
order by 3,4;

--select the data that we are going to be using.
--order it as per the first and second columns are in alphabetical order. 

Select location,date,total_cases,new_cases,total_deaths,population
 from covid_project.dbo.covid_death
 where continent is not null
 order by 1,2;


 --Taking total cases vs total deaths

 Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100as death_percentage
 from covid_project.dbo.covid_death
  where continent is not null
 order by 1,2;


 --Taking total cases vs population

 Select location,date,total_cases,population,(total_cases/population)*100as caseBy_population 
 from covid_project.dbo.covid_death
  where continent is not null
 order by 1,2;

 -- Taking countries of highest infection rate vs population

 Select location,population,max(total_cases) as highest_infection_count, max((total_cases/population))*100as caseBy_HighInfection 
 from covid_project.dbo.covid_death
  where continent is not null
 group by location,population
 order by 1,2;

 --Taking countries having higher death count per the population

 Select location,population,max(cast (total_deaths as int)) as highest_Death_count, max((total_deaths/population))*100as caseBy_HighDeath
 from covid_project.dbo.covid_death
  where continent is not null
 group by location,population
 order by 1,2;


---breaking it by continent

 --Taking the continents with highest death count

 Select continent,max(cast (total_deaths as int)) as highest_Death_count, max((total_deaths/population))*100as caseBy_HighDeath
 from covid_project.dbo.covid_death
  where continent is not null
 group by continent
 order by highest_Death_count desc;

 --Global numbers

  Select sum(new_cases) as Total_Cases,sum(cast (new_deaths as int))as Total_Deaths, sum(cast (new_deaths as int))/sum(new_cases)as death_percentage
 from covid_project.dbo.covid_death
  where continent is not null
 order by 1,2;


 --Taking the vaccination data also and joining it with death data


 --Taking total populations vs vaccinations

 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rolling_peopleVaccinated
 from covid_project.dbo.covid_death dea
 join covid_project.dbo.Vaccination vac
on (vac.location=dea.location)
and (vac.date=dea.date)
where dea.continent is not null
order by 2,3

--USE CTE for the above case

with popVsVacc( continent,location,date,population,New_vaccination,RollingPeopleVaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_peopleVaccinated
 from covid_project.dbo.covid_death dea
 join covid_project.dbo.Vaccination vac
on (vac.location=dea.location)
and (vac.date=dea.date)
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
 from
popVsVacc;


--Create a Temp Table.

Drop table if exists #PercentpopulationVaccinated
Create table #PercentpopulationVaccinated
(continent varchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentpopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 from covid_project.dbo.covid_death dea
 join covid_project.dbo.Vaccination vac
on (vac.location=dea.location)
and (vac.date=dea.date)
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
 from
#PercentpopulationVaccinated;



--Creating Views for visualization

create view PercentpopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 from covid_project.dbo.covid_death dea
 join covid_project.dbo.Vaccination vac
on (vac.location=dea.location)
and (vac.date=dea.date)
where dea.continent is not null
--order by 2,3

select * 
from PercentpopulationVaccinated