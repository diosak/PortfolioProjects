
-- Cleaning Nashville Housing Data in SQL



select *
from HousingPortfolioProject.dbo.NashvilleHousing

select SaleDate
from HousingPortfolioProject.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- Let's alter the sale date column to not display 00:00:00...


select SaleDate, CONVERT(Date,SaleDate) as SaleDateConverted
from HousingPortfolioProject.dbo.NashvilleHousing

ALTER TABLE HousingPortfolioProject.dbo.NashvilleHousing
add SaleDateConverted Date;

Update HousingPortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

select SaleDateConverted
from HousingPortfolioProject.dbo.NashvilleHousing
 --------------------------------------------------------------------------------------------------------------------------

-- Some Property Address data is missing...

select PropertyAddress
from HousingPortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

select *
from HousingPortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- There is adress data for a given ParcelID that can be found at another UniqueID.
-- So we could populate such missing values.

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from HousingPortfolioProject.dbo.NashvilleHousing a
join HousingPortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Time to update our table with the "newly found" values!

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from HousingPortfolioProject.dbo.NashvilleHousing a
join HousingPortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- There are now no rows that have NULL as PropertyAdress.
select PropertyAddress
from HousingPortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking down PropertyAddress into Individual Columns (Address, City)

select PropertyAddress
from HousingPortfolioProject.dbo.NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress + ',') - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress + ',') + 1, LEN(PropertyAddress)) as City
from HousingPortfolioProject.dbo.NashvilleHousing

ALTER TABLE HousingPortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255)

update HousingPortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress + ',') - 1)


ALTER TABLE HousingPortfolioProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255)

update HousingPortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress + ',') + 1, LEN(PropertyAddress))


select *
from HousingPortfolioProject.dbo.NashvilleHousing

select PropertyAddress, PropertySplitAddress, PropertySplitCity
from HousingPortfolioProject.dbo.NashvilleHousing


-- Now let's do the same thing for the OwnerAddress column,
-- but this time we have to split in 3 columns (Address, City, State)

select OwnerAddress
from HousingPortfolioProject.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from HousingPortfolioProject.dbo.NashvilleHousing

-- So 3 gives us State, 2 City and 1 Address.
-- Now let's add those values into new columns.

alter table HousingPortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update HousingPortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


alter table HousingPortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255);

update HousingPortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


alter table HousingPortfolioProject.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255);

update HousingPortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Time to see the newly formed columns

select *
from HousingPortfolioProject.dbo.NashvilleHousing

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from HousingPortfolioProject.dbo.NashvilleHousing



-- The SoldAsVacant column contains Y and N insted of Yes and No, respectively.
-- We can change that...


select Distinct(SoldAsVacant), Count(SoldAsVacant)
from HousingPortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from HousingPortfolioProject.dbo.NashvilleHousing

-- Update our column with the "new" values...

update HousingPortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

-- Time to see if that worked properly

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from HousingPortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant


-- There are several columns with NULL values inside
-- We can i.e. replace NULL with 'N/A' in column OwnerName

select OwnerName, ISNULL(OwnerName, 'N/A') as ModifiedOwnerName
from HousingPortfolioProject.dbo.NashvilleHousing

alter table HousingPortfolioProject.dbo.NashvilleHousing
add ModifiedOwnerName nvarchar(255);

update HousingPortfolioProject.dbo.NashvilleHousing
set ModifiedOwnerName = ISNULL(OwnerName, 'N/A')


-- We can now remove any redundant columns as we have either converted or split their contents

select *
from HousingPortfolioProject.dbo.NashvilleHousing


alter table HousingPortfolioProject.dbo.NashvilleHousing
drop column OwnerName, OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



-- Last but not least, we could find and remove any duplicates that are present

WITH DuplicatesCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from HousingPortfolioProject.dbo.NashvilleHousing
)
select *
from DuplicatesCTE
where row_num > 1
order by LegalReference

--Now let's delete those duplicates

WITH DuplicatesCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from HousingPortfolioProject.dbo.NashvilleHousing
)
delete
from DuplicatesCTE
where row_num > 1
--order by LegalReference

select *
from HousingPortfolioProject.dbo.NashvilleHousing
