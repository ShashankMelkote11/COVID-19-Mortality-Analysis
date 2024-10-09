Select *
From PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject1..CovidVaccine
--order by 3,4

--Select the Data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths in India
-- Shows likelihood of dying if you contracted covid in India

Select Location, date, total_cases, total_deaths, (Total_deaths/nullif(total_cases,0)*100) as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%india%'
and continent is not null
order by 1,2


--Looking at total Cases vs Total Deaths

Select Location, date, population, total_deaths, (Total_deaths/nullif(population,0)*100) as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%india%'
and continent is not null
order by 1,2

--Looking at total cases vs Population
--Shows what percentage of population got Covid 

Select Location, date, population, total_cases, (Total_cases/nullif(population,0)*100) as PercentagePopulationInfected
From PortfolioProject1..CovidDeaths
Where location like '%india%'
and continent is not null
order by 1,2


--Looking at Countries with Highest Infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/nullif(population,0)*100)) as PercentagePopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like '%india%'
Group by  Location, population
order by PercentagePopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%india%
Where continent is not null
Group by  Location
order by TotalDeathCount desc


--Dividing this by CONTINENT

Select continent, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%india%
Where continent is not null
Group by continent
order by TotalDeathCount 


--Dividing this by CONTINENT
--Showing continents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%india%
Where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(nullif(New_cases,0))*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%india%'
Where continent is not null
--Group by date
order by 1,2


--Joining both the tables by Date and location

Select *
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccine vac
 On dea.location = vac.location
 and dea.date = vac.date


 --Looking at Total Population vs Vaccinations

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations,0))) OVER (Partition by dea.location Order by dea.location,dea.Date) as Total_Vaccinations_as_of_Date
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccine vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
-- and dea.location like '%india%'
 order by 2,3


 --USE CTE
 With PopvsVac (Continent, Location, Date, Population, New_vaccinations, Total_Vaccinations_as_of_Date)
 as
 (
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations,0))) OVER (Partition by dea.location Order by dea.location,dea.Date) as Total_Vaccinations_as_of_Date
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccine vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
-- and dea.location like '%india%'
 --order by 2,3
 )
 Select*, (Total_Vaccinations_as_of_Date/Population)*100 
 From PopvsVac


 --Temp Table


 DROP table if exists #PercentagePopulationVaccinated
 Create table #PercentagePopulationVaccinated
 (
 Continent nvarchar(255), 
 Location varchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric, 
 Total_Vaccinations_as_of_Date numeric
 )

 INSERT into #PercentagePopulationVaccinated
 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations,0))) OVER (Partition by dea.location Order by dea.location,dea.Date) as Total_Vaccinations_as_of_Date
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccine vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
-- and dea.location like '%india%'
 --order by 2,3

 Select*, (Total_Vaccinations_as_of_Date/Population)*100 
 From #PercentagePopulationVaccinated


  USE PortfolioProject1
 --Creating View to store data for data visualization
 
Create View PercentPopulationVaccinated as 
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations,0))) OVER (Partition by dea.location Order by dea.location,dea.Date) as Total_Vaccinations_as_of_Date
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccine vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 and dea.location like '%india%'
 --order by 2,3


Select * 
From PercentPopulationVaccinated
