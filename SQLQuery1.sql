


Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths 
order by 1,2


-- Looking at Total Cases vs Total Deaths


Select Location, date, total_cases, total_deaths, CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases))) * 100 as [DeathPercentage]
From PortfolioProject..CovidDeaths
Where location like '%Turkey%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths 
Where location like '%Turkey%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths 
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, Max(CONVERT(DECIMAL(18, 2), total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
Where continent is  null
Group by location
order by TotalDeathCount desc

---Showing Continent with Highest Death Count per Population

Select continent, Max(CONVERT(DECIMAL(18, 2), total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) as DeathPersentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2


-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.Location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.Location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac


-- TEMP Table

DROP Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated int
)

insert into #PercentpopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.Location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) *100
From #PercentpopulationVaccinated


--Creating View to store data for later visualations

Create View PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.Location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select * 
From PercentPopulationVaccinated