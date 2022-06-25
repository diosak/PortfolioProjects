use [Crime]

create table [Crime].[DimState](
	[StateID] int identity(1,1) not null,
	[State] varchar(50) null,
	constraint [PK_Crime_DimState_StateID] primary key clustered (StateID)
)