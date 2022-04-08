

select total_cases 
from deaths
where total_cases=0;

select case 
	when total_cases=0
	then null else
	(total_deaths/total_cases)*100 
end as percentdeaths

--percentage deaths
select location, date, total_cases, ISNULL((total_deaths / NULLIF(total_cases,0))*100,0) percentdeaths
from deaths
order by location, total_cases;

alter table deaths
alter column population float;

alter table deaths
alter column date date;

select distinct(location)
from deaths;

--death percentage for Sweden, looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location, date, total_cases, ISNULL((total_deaths / NULLIF(total_cases,0))*100,0) percentdeaths
from deaths
where location like '%wede%'
order by location, total_cases;

--total cases vs population, % of population got covid

select location, date, total_cases, population, ISNULL((total_cases / NULLIF(population,0))*100,0) percentofinfected
from deaths
where location like '%wede%'
order by location, date;

--looking at countries with highest infection rate compared to population

select location, max(total_cases) as highestInfectionCount, population, ISNULL((max(total_cases) / NULLIF(population,0))*100,0) percentpopinfected
from deaths
group by location,population
order by percentpopinfected desc;

--showing countries with highest  death count per population

select location, max(total_deaths) as totaldeathCount
from deaths
where continent=''
group by location
order by totaldeathCount desc;

--let's break things down by continent

select continent, max(total_deaths) as totaldeathCount
from deaths
where continent!=''
group by continent
order by totaldeathCount desc;

--global numbers

select date, sum(cast(new_cases as float)) as total_new_cases, sum(cast(new_deaths as float)) as total_new_deaths
from deaths
where continent!=''
group by date
order by 1;

alter table deaths drop column column2,column3,column4,column5,column6,column7,column8;
alter table deaths drop column column9,column10,column11,column12,column13,column14,column15;
alter table deaths drop column column16,column17,column18,column19,column20,column21,column22;

alter table deaths drop column column23,column24,column25,column26,column27,column28,column29;
alter table deaths drop column column30,column31,column32,column33,column34,column35,column36;
alter table deaths drop column column37,column38,column39,column40,column41;

--let's join both table on date and location
select * 
from deaths dea
join vaccination vac
on dea.date = vac.date
and dea.location = vac.location;

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from deaths dea
join vaccination vac
	on dea.date = vac.date
	and dea.location = vac.location 
where dea.continent!=''
order by 2,3;

-- rolling people vaccinated by location and date wise

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(float, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rolling_total_vaccinations
from deaths dea
join vaccination vac
	on dea.date = vac.date
	and dea.location = vac.location 
where dea.continent!=''
order by 2,3;

--with CTC

with PopVsVac(continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(float, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rolling_total_vaccinations
from deaths dea
join vaccination vac
	on dea.date = vac.date
	and dea.location = vac.location 
where dea.continent!=''
--order by 2,3;
)
select *, 
 ISNULL((rolling_total_vaccinations / NULLIF(population,0))*100,0) pervaccinated
from PopVsVac
where location like '%States'
order by 2,3


--creating temp table method

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations float,
rolling_total_vaccinations numeric
)

insert into PercentPopulationVaccinated	
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(float, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rolling_total_vaccinations
from deaths dea
join vaccination vac
	on dea.date = vac.date
	and dea.location = vac.location 
where dea.continent!=''
order by 2,3;

select *,
ISNULL((rolling_total_vaccinations / NULLIF(population,0))*100,0) pervaccinated
from PercentPopulationVaccinated
where location like '%States'
order by location,date;

------------------


