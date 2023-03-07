select * from CovidDeaths
where continent is not null
order by 3,4

--Selecting data 

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

--Total cases vs Total deaths
--Showing likelihood of dying if you contract covid in your country

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where Location like 'Poland'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationInfected
from CovidDeaths
where Location like 'Poland'
and continent is not null
order by 1,2


--Looking at the countries with the highest infecion rate compared to population

Select Location, max(total_cases) as TotalInfected, population, max(total_cases/population)*100 as PopulationInfected
from CovidDeaths
where continent is not null
group by location, population
order by PopulationInfected desc


-- Country with highest death count per population
--We need to change total_death into integer

Select Location, max(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null 
group by location
order by TotalDeaths desc

-- Continent with highest death count per population

Select Continent, max(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null 
group by continent
order by TotalDeaths desc

--Global numbers


Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2

--Total vaccination on a population

select *
from CovidDeaths as cd
join CovidVaccination as vs
	on cd.location= vs.location 
	and cd.date=vs.date

--Global Numbers


Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100
From CovidDeaths
where continent is not null
group by date
order by 1,2

--Looking at total population vs vaccinations using CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
from PopvsVac 
where new_vaccinations is not null

--Creating temp table


DROP Table #PercentagePeopleVaccinated
Create table #PercentagePeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinatedPeople
From #PercentagePeopleVaccinated
where Location like 'Poland' and New_vaccination is not null



-- Creating a view of percent of vaccinated people

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null