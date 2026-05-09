CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;

-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

SELECT * FROM COUNTRY;


-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
    energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM EMISSION_3;


-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);


SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
        consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;

-- Data Analysis Questions
-- General & Comparative Analysis

-- What is the total emission per country for the most recent year available?
SELECT country, SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY country;

-- What are the top 5 countries by GDP in the most recent year?
SELECT Country, value AS gdp
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
ORDER BY gdp DESC
LIMIT 5;

-- Compare energy production and consumption by country and year. 
SELECT p.country, p.year,
       SUM(p.production) AS total_production,
       SUM(c.consumption) AS total_consumption
FROM production p
JOIN consumption c 
ON p.country = c.country AND p.year = c.year
GROUP BY p.country, p.year;

-- Which energy type contribute most to emissions across all countries?
SELECT energy_type, SUM(emission) AS total_emission
FROM emission_3
GROUP BY energy_type
ORDER BY total_emission DESC LIMIT 1;

-- Trend Analysis Over Time

-- How have global emissions changed year over year?
SELECT year, SUM(emission) AS total_emission
FROM emission_3
GROUP BY year
ORDER BY year;

-- What is the trend in GDP for each country over the given years?
SELECT Country, year, value AS gdp
FROM gdp_3
ORDER BY Country, year;

-- How has population growth affected total emissions in each country?
SELECT e.country, e.year,
       SUM(e.emission) AS total_emission,
       p.value AS population
FROM emission_3 e
JOIN population p 
ON e.country = p.countries AND e.year = p.year
GROUP BY e.country, e.year, p.value;

-- Has energy consumption increased or decreased over the years for major economies?
SELECT country, year, SUM(consumption) AS total_consumption
FROM consumption
GROUP BY country, year
ORDER BY country, year DESC;

-- What is the average yearly change in emissions per capita for each country?
SELECT country, AVG(per_capita_emission) AS avg_per_capita
FROM emission_3
GROUP BY country;

-- Ratio & Per Capita Analysis

-- What is the emission-to-GDP ratio for each country by year?
SELECT e.country, e.year,
       Round((SUM(e.emission) / g.value),2) AS emission_gdp_ratio
FROM emission_3 e
JOIN gdp_3 g 
ON e.country = g.Country AND e.year = g.year
GROUP BY e.country, e.year, g.value;

-- What is the energy consumption per capita for each country over the last decade?
SELECT c.country, c.year,
       round((SUM(c.consumption) / p.value),4) AS consumption_per_capita
FROM consumption c
JOIN population p 
ON c.country = p.countries AND c.year = p.year
GROUP BY c.country, c.year, p.value;

-- How does energy production per capita vary across countries?
SELECT pr.country, pr.year,
       SUM(pr.production) / p.value AS production_per_capita
FROM production pr
JOIN population p 
ON pr.country = p.countries AND pr.year = p.year
GROUP BY pr.country, pr.year, p.value;

-- Which countries have the highest energy consumption relative to GDP?
SELECT c.country, c.year,
       ROUND((SUM(c.consumption) / g.value),4) AS consumption_gdp_ratio
FROM consumption c
JOIN gdp_3 g 
ON c.country = g.Country AND c.year = g.year
GROUP BY c.country, c.year, g.value
ORDER BY consumption_gdp_ratio DESC LIMIT 5;

-- What is the correlation between GDP growth and energy production growth? 
SELECT g.country,
       g.year,
       g.value AS gdp,
       SUM(p.production) AS production,
       g.value - SUM(p.production) AS difference
FROM gdp_3 g
JOIN production p
ON g.country = p.country
AND g.year = p.year
GROUP BY g.country, g.year, g.value;

-- Global Comparisons

-- What are the top 10 countries by population and how do their emissions compare? 
SELECT p.countries,
       p.value AS population,
       COALESCE(SUM(e.emission),0) AS total_emission
FROM population p
LEFT JOIN emission_3 e
ON p.countries = e.country
AND p.year = e.year
WHERE p.year = (SELECT MAX(year) FROM population)
GROUP BY p.countries, p.value
ORDER BY population DESC
LIMIT 10;

-- Which countries have improved (reduced) their per capita emissions the most over the last decade?
SELECT country,
       MIN(per_capita_emission) AS lowest_emission
FROM emission_3
GROUP BY country
ORDER BY lowest_emission ASC
LIMIT 10;

-- What is the global share (%) of emissions by country?
SELECT country,
       SUM(emission) * 100 / (SELECT SUM(emission) FROM emission_3) AS emission_percentage
FROM emission_3
GROUP BY country;

-- What is the global average GDP, emission, and population by year?

SELECT e.year,
       AVG(e.emission) AS avg_emission,
       AVG(g.value) AS avg_gdp,
       AVG(p.value) AS avg_population
FROM emission_3 e
JOIN gdp_3 g 
    ON e.country = g.Country AND e.year = g.year
JOIN population p 
    ON e.country = p.countries AND e.year = p.year
GROUP BY e.year
ORDER BY e.year;



