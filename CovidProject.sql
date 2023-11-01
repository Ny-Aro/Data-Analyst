select * from CovidDeaths

-- Select les données à utiliser
select Location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
order by 1,2

-- Le pourcentage de mourir après contamination (Exemple: Madagascar année 2020 à 2021)
select Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as PercentageToDeath
from CovidDeaths
where location like'%mada%'
order by 1,2

-- Le pourcentage des cas pour toute la population 
select Location, date, total_cases, population, (total_cases / population) *100 as CasesPercentage
from CovidDeaths
--where location like'%mada%' (décommenter ceci pour spécifier un lieu)
order by 1,2

-- Voir la plus grosse infection d'un pays par rapport aux nombres de population
select Location, max(total_cases) as HighestInfection, population, max((total_cases / population)) *100 as CasesPercentage
from CovidDeaths
group by  location, population
order by CasesPercentage

-- Voir la plus grosse décès d'un pays par rapport aux nombres de population
select Location, max(cast(total_deaths as int)) as HighestDeath
from CovidDeaths
where continent is not null
group by location
order by HighestDeath desc

-- Le même chose mais par continent
select location, max(cast(total_deaths as int)) as HighestDeath
from CovidDeaths
where continent is null
group by location
order by HighestDeath desc

-- Montrer le Contient  et son plus grand nombre de décès
select continent, max(cast(total_deaths as int)) as HighestDeath
from CovidDeaths
where continent is not null
group by continent
order by HighestDeath desc

-- Nombres des nouvelles cas globales / décès par jour
select date, sum(new_cases ), sum(cast(new_deaths as int)),
(sum(cast(new_deaths as int)) / sum(new_cases )) *100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- Le nombre de personne vacciné
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as VaccinatedPeople
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Utilisation CTE
With PopVaccinated (Continent, Location, Date, Population,New_Vaccination, VaccinatedPeople)
as (
	select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as VaccinatedPeople
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
)

select *, (VaccinatedPeople / Population)*100 as PercentageOfVaccinatedPeople
from PopVaccinated 
order by 2,3

-- Utilisation Temp Tabe
DROP TABLE IF EXISTS #PercentageOfVaccinatedPeople 

create table #PercentageOfVaccinatedPeople(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_vaccination numeric,
VaccinatedPeople numeric
)

insert into #PercentageOfVaccinatedPeople 
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as VaccinatedPeople
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 

select *, (VaccinatedPeople / Population)*100 as PercentageOfVaccinatedPeople
from #PercentageOfVaccinatedPeople 
order by 2,3

-- Creation d'un Views
Create view PercentageOfVaccinatedPeople as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as VaccinatedPeople
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 

