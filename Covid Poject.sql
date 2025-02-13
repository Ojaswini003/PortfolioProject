Select*
From ProjectPortfolio..CovidDeaths$
--where continent is not null
order by 3,4

--Select*
--From ProjectPortfolio..CovidVaccination$
--order by 3,4

Select Location,date,total_cases,new_cases,total_deaths,population
From ProjectPortfolio..CovidDeaths$
order by 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATHS 
--Show likelyhood of dying of covid if you contract it 
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths$
Where location like '%india%'
order by 1,2

--Looking at Total Cases vs Population
--Show what % population got covid
Select Location,date,total_cases,population,(total_cases/population)*100 as PercentageOfPopulationInfected
From ProjectPortfolio..CovidDeaths$
Where location like '%india%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location,MAX(total_cases) as HighestInfectionCount,population,Max((total_cases/population))*100 as PercentageOfPopulationInfected
From ProjectPortfolio..CovidDeaths$
--Where location like '%india%'
group by location,population
order by PercentageOfPopulationInfected desc

--Showing Countrues with highest death count per population
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths$
--Where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc

--Let's Break Things by Continent
--Showing continents with highest death count per population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths$
--Where location like '%india%'
where continent is  null
group by location
order by TotalDeathCount desc

--GLOBAL numbers
Select SUM(new_cases) as total_cases,SUM(cast (new_deaths as int)) as total_deaths, SUM (cast (new_deaths as int)) * 100.0 / SUM(new_cases)
     as DeathPercentage--date
From ProjectPortfolio..CovidDeaths$
--Where location like '%india%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs Vaccination
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int))OVER(Partition by dea.location order by 
dea.location,dea.date)as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths$ dea
Join ProjectPortfolio..CovidVaccination$ vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac(continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)as
(Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int))OVER(Partition by dea.location order by 
dea.location,dea.date)as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths$ dea
Join ProjectPortfolio..CovidVaccination$ vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3)

Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE 
IF OBJECT_ID('tempdb..#PercentagePopulationVaccinat', 'U') IS NOT NULL
    DROP TABLE #PercentagePopulationVaccinat

Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int))OVER(Partition by dea.location order by 
dea.location,dea.date)as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths$ dea
Join ProjectPortfolio..CovidVaccination$ vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
Select*, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated

--Creating View

Create view PercentagePopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int))OVER(Partition by dea.location order by 
dea.location,dea.date)as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths$ dea
Join ProjectPortfolio..CovidVaccination$ vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentagePopulationVaccinated








