-- Preview data
Select *
From [dbo].[covid death]
order by 3, 4

Select *
From Portfolioproject..CovidVacin
order by 3, 4

-- Select data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From [dbo].[covid death]
order by 1, 2

-- Check total cases vs total deaths in United States
-- Shows the likelihood of dying if one contracts covid. It is now less than 1%

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
From [dbo].[covid death]
Where location like '%states%'
order by 1, 2

-- Check total cases vs Population in United States
-- Shows the % of population who got covid

Select Location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Deathpercentage
From [dbo].[covid death]
Where location like '%states%'
order by 1, 2

-- Check countries with the highest infecton rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulatedInfected
From [dbo].[covid death]
--Where location like '%states%'
Group by location, population
order by PercentPopulatedInfected desc

-- Check countries with the highest death count compared per population

Select Location, Max(total_deaths) as TotalDeathCount
From [dbo].[covid death]
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- EXPLORE BY CONTINENT

select continent,  sum(total_deaths) as TotalDeathCount
From [dbo].[covid death]
where continent!=''
group by continent
order by TotalDeathCount desc

-- EXPLORE Global data

Select date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
From [dbo].[covid death]
where continent is not null
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Partitioned by location 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..[covid death] dea
Join Portfolioproject..CovidVacin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..[covid death] dea
Join Portfolioproject..CovidVacin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- TEMP TABLE
DROP Table if exists #PercentpopulationVacinnated
Create Table #PercentpopulationVacinnated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vacinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentpopulationVacinnated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..[covid death] dea
Join Portfolioproject..CovidVacin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentpopulationVacinnated

-- Creating View to store data for later visualizations

Create View PercentpopulationVacinnated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..[covid death] dea
Join Portfolioproject..CovidVacin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 