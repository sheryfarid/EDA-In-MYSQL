-- EXPLORATORY DATA ANALYSIS
select * from layoffs_staging2;
-- What are the maximum values of total_laid_off and percentage_laid_off in the dataset?
select max(total_laid_off) ,max(percentage_laid_off) from layoffs_staging2;

-- Which companies laid off 100% of their workforce, and what are the details sorted by the total number of layoffs?
select * from layoffs_staging2
where percentage_laid_off = 1 
order by total_laid_off desc;

--  What is the date range of the data available in the layoffs_staging2 table?
select min(`date`) ,max(`date`) from layoffs_staging2;

--  Which companies have laid off the most employees, and how many employees were laid off by each company?
select company , sum(total_laid_off) from layoffs_staging2 group by company order by 2 desc;

--  Which industries have laid off the most employees, and how many employees were laid off by each industry?
select industry , sum(total_laid_off) from layoffs_staging2 group by industry order by 2 desc;

-- Which locations within each country have the highest total layoffs?
select country , location , sum(total_laid_off) from layoffs_staging2 group by country,location order by 3 desc;

--  How many employees were laid off each year, and how does it vary year by year?
select year(`date`) , sum(total_laid_off) from layoffs_staging2 group by year(`date`)  order by 1 desc;

-- How many layoffs occurred at each stage of the company’s lifecycle?
select stage , sum(total_laid_off) from layoffs_staging2 group by stage order by 2 desc;

-- Which countries have the highest summed percentage of layoffs?
select country, sum(percentage_laid_off) from layoffs_staging2
 group by country order by 2 desc;
 
-- How many employees were laid off each month, and how do monthly layoffs trend over time?
 select substring(`date`,1,7) as `month` , sum(total_laid_off) from layoffs_staging2
 where substring(`date`,1,7) is not null
 group by `month` 
 order by 1 ;

-- What is the cumulative total of layoffs by month?
with rolling_total as ( select substring(`date`,1,7) as `month` , sum(total_laid_off) as total_sum
from layoffs_staging2
 where substring(`date`,1,7) is not null
 group by `month` 
 order by 1 )
 select `month`, total_sum ,sum(total_sum) over (order by `month`) as sum_by_month from rolling_total;
 
-- Which companies had the highest number of layoffs each year?
 select company , sum(total_laid_off) ,year(`date`)
 from layoffs_staging2
 group by company,year(`date`) order by 2 desc;
 
-- How do companies rank in terms of layoffs each year, using both DENSE_RANK and RANK functions?
with rolling_company(company,total_laid_off,years) as
( select company , sum(total_laid_off) ,year(`date`)
 from layoffs_staging2
 group by company,year(`date`) ), 
 company_rank as
( select *,
dense_rank() over (partition by years order by total_laid_off desc) as dense_ranking,
rank()  over (partition by years order by total_laid_off desc) as ranking
from rolling_company where years is not null )
select * from company_rank ;

-- Which industries had the highest percentage of layoffs in each year?
select industry,year(`date`) , max(percentage_laid_off) from layoffs_staging2 group by industry,year(`date`)
order by  max(percentage_laid_off) desc;

--  Which countries raised the most funds, and what is the maximum amount raised in each country?
select  country , max(funds_raised_millions) as max_funds from layoffs_staging2 
where funds_raised_millions  is not null
group by country 
