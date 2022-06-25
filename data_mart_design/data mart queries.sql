use Crime

--SQL Server Integration Services (SSIS) was used for this process...

select * from Crime.Source_Data_Staging

select * from Crime.DimState

--load State dimension
select distinct [State]
from [Crime].[Source_Data_Staging]
order by [State] asc

--update StateID into Staging table
/*
update Crime.Source_Data_Staging
set Crime.Source_Data_Staging.StateID = Crime.DimState.StateID
from Crime.Source_Data_Staging
inner join Crime.DimState on Crime.Source_Data_Staging.[State] = Crime.DimState.[State]
*/
--now every State gets its distinct StateID in the Stagin table
select * from Crime.Source_Data_Staging

--load City and StateID dimension
select distinct [City], [StateID]
from [Crime].[Source_Data_Staging]
order by [StateID] asc

--now City and StateID our loaded
select * from Crime.DimCity

----update CityID into Staging table
/*
update Crime.Source_Data_Staging
set Crime.Source_Data_Staging.CityID = Crime.DimCity.CityID
from Crime.Source_Data_Staging
inner join Crime.DimCity on Crime.Source_Data_Staging.[City] = Crime.DimCity.[City]
and Crime.Source_Data_Staging.[StateID] = Crime.DimCity.[StateID]
*/
--now every City gets its distinct CityID in the Staging table
select * from Crime.Source_Data_Staging

--now it is time to populate the YearID dimension
select * from Crime.DimYear
--it's empty

--now let's execute an sql task with the code below
/*
insert into Crime.DimYear ([Year])
select distinct [Year]
from Crime.Source_Data_Staging
order by [Year] asc

update Crime.DimYear
set Crime.DimYear.ChineseNewYear = 'Dog'
where Crime.DimYear.[Year] = 2006

update Crime.DimYear
set Crime.DimYear.ChineseNewYear = 'Pig'
where Crime.DimYear.[Year] = 2007

update Crime.DimYear
set Crime.DimYear.ChineseNewYear = 'Rat'
where Crime.DimYear.[Year] = 2008
*/
--now it is populated
select * from Crime.DimYear

--so now we have to update the YearID in the Staging table
select * from Crime.Source_Data_Staging

--so we again execute an SQL task
update Crime.Source_Data_Staging
set Crime.Source_Data_Staging.YearID = Crime.DimYear.YearID
from Crime.Source_Data_Staging
inner join Crime.DimYear on Crime.Source_Data_Staging.[Year] = Crime.DimYear.[Year]

--so now YearID has been populated
select * from Crime.Source_Data_Staging

--lastly, we have to populate the FactCrime table which as of now is empty
select * from Crime.FactCrime

--after a Data Flow Task with OLE DB Source and OLE DB Destination tasks inside...
select * from Crime.FactCrime
--everything is populated

--So now we can write any number of queries and test our data

select
	CrimeState.[State],
	CrimeCity.City,
	CrimeYear.ChineseNewYear,
	Crime.Robbery
from Crime.FactCrime as Crime
inner join Crime.DimYear as CrimeYear on Crime.YearID = CrimeYear.YearID
inner join Crime.DimCity as CrimeCity on Crime.CityID = CrimeCity.CityID
inner join Crime.DimState as CrimeState on CrimeCity.StateID = CrimeState.StateID
where CrimeState.[State] = 'Florida'
and CrimeYear.ChineseNewYear = 'Rat'
order by CrimeCity.City asc

select
	CrimeYear.[Year],
	sum(Crime.Robbery) as total_robberies_per_year
from Crime.FactCrime as Crime
join Crime.DimYear as CrimeYear on Crime.YearID = CrimeYear.YearID
group by CrimeYear.[Year]
order by sum(Crime.Robbery) desc

select
	CrimeState.[State],
	sum(Crime.Robbery) as total_robberies_per_state
from Crime.FactCrime as Crime
join Crime.DimCity as CrimeCity on Crime.CityID = CrimeCity.CityID
join Crime.DimState as CrimeState on CrimeCity.StateID = CrimeState.StateID
group by CrimeState.[State]
order by sum(Crime.Robbery) desc

select
	CrimeCity.[City],
	CrimeState.[State],
	sum(Crime.Robbery) as total_robberies_per_city
from Crime.FactCrime as Crime
join Crime.DimCity as CrimeCity on Crime.CityID = CrimeCity.CityID
join Crime.DimState as CrimeState on CrimeCity.StateID = CrimeState.StateID
group by CrimeCity.[City],
	CrimeState.[State]
order by sum(Crime.Robbery) desc

select
	CrimeYear.[Year],
	sum(Crime.ViolentCrime) as total_violentcrimes_per_year
from Crime.FactCrime as Crime
join Crime.DimYear as CrimeYear on Crime.YearID = CrimeYear.YearID
group by CrimeYear.[Year]
order by sum(Crime.ViolentCrime) desc

select
	CrimeCity.[City],
	CrimeState.[State],
	sum(Crime.ViolentCrime) as total_violentcrimes_per_city
from Crime.FactCrime as Crime
join Crime.DimCity as CrimeCity on Crime.CityID = CrimeCity.CityID
join Crime.DimState as CrimeState on CrimeCity.StateID = CrimeState.StateID
group by CrimeCity.[City],
	CrimeState.[State]
order by sum(Crime.ViolentCrime) desc

select
	CrimeCity.[City],
	CrimeState.[State],
	sum(Crime.ForcibleRape) as total_rapes_per_city
from Crime.FactCrime as Crime
join Crime.DimCity as CrimeCity on Crime.CityID = CrimeCity.CityID
join Crime.DimState as CrimeState on CrimeCity.StateID = CrimeState.StateID
group by CrimeCity.[City],
	CrimeState.[State]
order by sum(Crime.ForcibleRape) desc

select
	CrimeYear.[Year],
	sum(Crime.ForcibleRape) as total_rapes_per_year
from Crime.FactCrime as Crime
join Crime.DimYear as CrimeYear on Crime.YearID = CrimeYear.YearID
group by CrimeYear.[Year]
order by sum(Crime.ForcibleRape) desc

select
	CrimeCity.[City],
	CrimeState.[State],
	CrimeYear.[Year],
	Crime.ViolentCrime as violentcrimes_per_city_year
from Crime.FactCrime as Crime
join Crime.DimCity as CrimeCity on Crime.CityID = CrimeCity.CityID
join Crime.DimState as CrimeState on CrimeCity.StateID = CrimeState.StateID
join Crime.DimYear as CrimeYear on Crime.YearID = CrimeYear.YearID
order by Crime.ViolentCrime desc

select avg(Crime.ViolentCrime) as average_violence
from Crime.FactCrime as Crime

--any City with violence above 116 is considered a place where violent crimes are likely to occur
with total_violentcrimes ([City], [State], total_violence) as
(
select CrimeCity.[City],
	CrimeState.[State],
	sum(Crime.ViolentCrime) as total_violence
from Crime.FactCrime as Crime
join Crime.DimCity as CrimeCity on Crime.CityID = CrimeCity.CityID
join Crime.DimState as CrimeState on CrimeCity.StateID = CrimeState.StateID
join Crime.DimYear as CrimeYear on Crime.YearID = CrimeYear.YearID
group by CrimeCity.[City],
	CrimeState.[State]
), average_violence (average_violence) as
(
select AVG(Crime.ViolentCrime)
from Crime.FactCrime as Crime
)
select total_violentcrimes.[City],
	total_violentcrimes.[State],
	total_violence,
	case
		when total_violence >= average_violence*3/2 then 'Very Likely'
		when total_violence >= average_violence then 'Likely'
		when total_violence >= average_violence/2 then 'Unlikely'
		else 'Very Unlikely'
	end as violence_occurence
from total_violentcrimes, average_violence