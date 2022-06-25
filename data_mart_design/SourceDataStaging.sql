use Crime

create table Crime.Source_Data_Staging(
	[Source_StagingID] int identity(1,1) not null,
	[Source_RowID] int null,
	[State] varchar(50) null,
	[StateID] int null,
	[City] [varchar](100) null,
	[CityID] int null,
	[Year] int null,
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
	constraint [PK_Source_StagingID] primary key clustered ([Source_StagingID])
)