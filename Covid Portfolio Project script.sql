Select * from PortfolioProject..CovidDeaths
where continent is not null
Order by 3, 4

--Select * from PortfolioProject..CovidVaccinations
--Order by 3, 4

-- Select the data that I am going to use now

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- Looking at the Total cases vs Total deaths
--Shows the likelihood of  dying if you get covid in your Country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

--Looking at the total cases vs the Population
Select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
--where location like '%Haiti%'
where continent is not null
order by 1, 2

--Let's look at Countries with highest infection rate compared to Pouplation
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CasePercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by CasePercentage DESC

--Shoing countries with highest death rate per populations
Select location, population, Max(cast(total_deaths as int)) as HighestdeathCount, Max((total_deaths/population))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by HighestdeathCount DESC

--Let's see by continent now death count
Select continent, Max(cast(total_deaths as int)) as HighestdeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by HighestdeathCount DESC

-- Global numbers
Select SUM(new_cases) as Totalcases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1, 2

--Looking at the Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating to views to store data for Visualizations later

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


