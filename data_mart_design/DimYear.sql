use Crime

create table Crime.DimYear(
	YearID int identity(1,1) not null,
	Year int null,
	ChineseNewYear varchar(50) null,
	constraint PK_Crime_DimYear_YearID primary key clustered (YearID)
)
