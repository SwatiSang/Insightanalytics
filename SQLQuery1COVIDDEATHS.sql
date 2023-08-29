 Select *
 From PortfolioProject..CovidDeaths
order By 3,4

Select *
 From PortfolioProject..CovidVaccinations
order By 3,4

-- 
Select Location, date, Total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking for total cases vs tatal deaths
----shows the likelyhood of dying if you contract coivid
SELECT Location, date,  Population,Total_cases, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE Location like'%states%'
ORDER BY 1,2



--looking for countries with highest infection rate compared to Population
SELECT Location,  Population, MAX(Total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like'%states%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc


---Showing countries with highest deadth count per Population
Select location, MAX(cast(total_deaths AS INT)) AS HighestDeathCount 
From PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
Group BY Location
ORDER BY HighestDeathCount DESC


--- things according to Continent
--Showing continets with highest death count per population

Select continent, MAX(cast(total_deaths AS INT)) AS HighestDeathCount 
From PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
Group BY continent
ORDER BY HighestDeathCount DESC


----Global cases

SELECT date, SUM(new_cases),
             SUM(cast(new_deaths as int)),
             SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY date
ORDER BY 1,2


----Total population vs Vaccinations

SELECT *
from PortfolioProject..CovidDeaths dea
   Join PortfolioProject..CovidVaccinations vac
   on    dea.location = vac.location 
   AND   dea.date= vac.date

SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations, 
       SUM (convert(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS ROllingPeopleVaccinated
----(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
   Join PortfolioProject..CovidVaccinations vac
   ON    dea.location = vac.location 
   AND   dea.date= vac.date
  WHERE dea.continent is not null
  ORDER BY 2,3
  
  USE CTE 

  WITH PopvsVac (Continent,Location,Date, poppulation, New_Vaccinations,RollingPeopleVaccinated)
  AS
  (
  SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations, 
       SUM (convert(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS ROllingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
   Join PortfolioProject..CovidVaccinations vac
   ON    dea.location = vac.location 
   AND   dea.date= vac.date
  WHERE dea.continent is not null
  --ORDER BY 2,3
  )
  SELECT * ,((RollingPeopleVaccinated/population)*100
  FROM PopvsVac



  ---TEMP TABLE 
  DROP Table if exists #PercentPopulationVaccinated

  CREATE Table #PercentPopulationVaccinated
        (Continent nvarchar (255),
         location nvarchar(255),
         Date datetime,
         Population numeric,
         New_vaccinations numeric,
         RollingPeopleVaccinated numeric)

  INSERT INTO #PercentPopulationVaccinated
  SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations, 
       SUM (convert(int,vac.new_vaccinations))
	       OVER (partition by dea.location ORDER BY dea.location, dea.date) AS ROllingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
   JOIN PortfolioProject..CovidVaccinations vac
           ON    dea.location = vac.location 
           AND   dea.date= vac.date
  WHERE dea.continent is not null
  --ORDER BY 2,3
  
  SELECT * ,(RollingPeopleVaccinated/population)*100
  FROM #PercentPopulationVaccinated


  ---CREATING VIEWS FOR LATER VISUALIZATION

  CREATE view PercentPopulationVaccinated as
  SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations, 
       SUM (convert(int,vac.new_vaccinations))
	       OVER (partition by dea.location ORDER BY dea.location, dea.date) AS ROllingPeopleVaccinated
		   ----(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
   JOIN PortfolioProject..CovidVaccinations vac
           ON    dea.location = vac.location 
           AND   dea.date= vac.date
  WHERE dea.continent is not null
  ----ORDER BY 2,3

  SELECT *
  FROM PercentPopulationVaccinated