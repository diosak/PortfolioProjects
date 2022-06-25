use [Crime]

create table [Crime].[FactCrime](
	[CrimeID] int identity(1,1) not null,
	[Source_RowID] int null,
	[CityID] int null,
	[YearID] int null,
	[Population] int null,
	[ViolentCrime] int null,
	[MurderAndNonEgligentManslaughter] int null,
	[ForcibleRape] int null,
	[Robbery] int null,
	[AggravatedAssault] int null,
	[PropertyCrime] int null,
	[Buglary] int null,
	[LarcenyTheft] int null,
	[MotorVehicleTheft] int null,
	[Arson] int null,
	constraint [PK_Crime_FactCrime_CrimeID] primary key clustered ([CrimeID]),
	constraint [FK_CityID] foreign key ([CityID])
	references Crime.DimCity ([CityID]),
	constraint [FK_YearID] foreign key ([YearID])
	references Crime.DimYear ([YearID]),
)
