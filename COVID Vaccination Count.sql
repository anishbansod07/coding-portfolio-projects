-- Total population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) 
       OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountVaccination
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;


-- Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCountVaccination)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS INT)) 
           OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountVaccination
    FROM PortfolioProject..CovidDeaths$ dea
    JOIN PortfolioProject..CovidVaccinations$ vac
      ON dea.location = vac.location
     AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingCountVaccination * 100.0) / Population AS PercentVaccinated
FROM PopvsVac;



-- TEMP Table
DROP TABLE if exists #PercentPopulationVaccination
CREATE TABLE #PercentPopulationVaccination
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingCountVaccination NUMERIC
);

INSERT INTO #PercentPopulationVaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) 
       OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountVaccination
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


-- Final Select with percentage
SELECT *, (RollingCountVaccination * 100.0) / population AS PercentVaccinated
FROM #PercentPopulationVaccination;


--Creating VIEW to store data for future visualization
USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccination as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) 
       OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountVaccination
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccination