use Crime

create table Crime.DimCity(
	CityID int identity(1,1) not null,
	City varchar(50) null,
	StateID int null,
	constraint PK_Crime_DimCity_CityID primary key clustered (CityID),
)

alter table Crime.DimCity with check add constraint [FK_StateID] foreign key ([StateID])
references [Crime].[DimState] ([StateID])

alter table Crime.DimCity
alter column City varchar(100)