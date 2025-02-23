Select *
From portfolioproject .. CovidDeaths
where continent is not null
order by 3,4

--Select *
--From portfolioproject.. CovidVaccinations
--order by 3,4

--selected Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioproject .. CovidDeaths
where continent is not null
order by 1,2

--Looking at Total cases vs Total Deaths 
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths,(Total_deaths/total_cases)*100 as deathpercentage
From portfolioproject .. CovidDeaths
Where location like '%kingdom%'
order by 1,2

--Looking at the total cases vs the population
-- Shows what percentage of population had covid

Select Location, date, population, total_cases,(Total_cases/population)*100 as percentagepopulationinfected
From portfolioproject .. CovidDeaths
--Where location like '%Kingdom%'
order by 1,2

--Looking at coumtries with highest infection rate compared to population

Select Location,population, MAX(total_cases) as highestinfectioncount,MAX((Total_cases/population))*100 as percentagepopulationinfected
From portfolioproject .. CovidDeaths
--Where location like '%Kingdom%'
Group by Location, population
order by percentagepopulationinfected desc

--Breaking it down by continent

--Showing cotinent with highest death count per population

Select continent, MAX(CAST(total_deaths as int)) as Totaldeathcount
From portfolioproject .. CovidDeaths
--Where location like '%Kingdom%'
where continent is not null
Group by continent
order by Totaldeathcount desc


--Globl numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/ SUM
 (new_cases)*100 as Deathpercentage
From portfolioproject..CovidDeaths
--Where location like '%kingdom%'
where continent is not null
--Group by date
order by 1,2

--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.Location order by dea.location,dea.Date) as RollingpeopleVaccinated
--, (Rollingpeoplevaccinated/population)*100
From Portfolioproject..covidDeaths dea
Join portfolioproject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.continent is not null
	 order by 2,3

 
 -- USE CTE

With popvsVac (Continent, Location, Date, Population,New_vaccinations, RollingpeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
  dea.Date) as Rollingppeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (Rollingpeoplevaccinated/population)*100
From popvsVac



--- Temp Table 

Drop Table if exists #Percentpopulationvaccinated
Create Table #Percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #Percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
  dea.Date) as Rollingppeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (Rollingpeoplevaccinated/population)*100
From  #Percentpopulationvaccinated


--Creating view to store data for later visualisation

Create view PercentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
  dea.Date) as Rollingppeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
from PercentpopulationVaccinated 