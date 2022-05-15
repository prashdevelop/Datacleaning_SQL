/*

Cleaning Data in SQL Queries

*/
select * from covid.dbo.NashvilleHousing
---------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date format--------------------------------------------------------------------------------------------------------

select SaleDate,CONVERT(Date,SaleDate)
from covid.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly
alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

-----Now Check your Column-----------------------------------------------------------------------------------------------------------------
select SaleDateConverted
from covid.dbo.NashvilleHousing;
----------------------------------------------------------------------------------------------------------------------------------------------

--------Populate Property Address Date--------------------------------------------------------------------------------------

select *
from covid.dbo.NashvilleHousing
--- Check for Null
-- where PropertyAddress is Null
order by ParcelID
-- Here we will be populating the property address for Null values in Propert address column-----------------------------------

--- We will be self joining the table to itself---------

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from covid.dbo.NashvilleHousing a
join covid.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from covid.dbo.NashvilleHousing a
join covid.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------------------------------
----Breaking out Address into Individual Columns (Address, City, State)

--- First for Property Address-------------------------------------------------------------------------------------------
select PropertyAddress
from covid.dbo.NashvilleHousing
-- where PropertyAddress is null
-- order by ParcelID

select
SUBSTRING(PropertyAddress ,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress)) as Address

from covid.dbo.NashvilleHousing

alter table NashvilleHousing
add NewAddress Nvarchar(255) ;

update NashvilleHousing
SET NewAddress = SUBSTRING(PropertyAddress ,1,CHARINDEX(',',PropertyAddress) -1)


alter table NashvilleHousing
add NewCity Nvarchar(255) ;

update NashvilleHousing
set NewCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress))

select *
from covid.dbo.NashvilleHousing

----- Now For Owner's Address-----------------------------------------------------------------------------------------------------------------------
---- Using Parsename Function---------------------------------------
select 
parsename(REPLACE(OwnerAddress, ',', '.'),3),
parsename(replace(OwnerAddress, ',', '.'),2),
parsename(replace(OwnerAddress, ',', '.'),1)

from covid.dbo.NashvilleHousing



alter table NashvilleHousing 
add OwnerSplitAddress Nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(REPLACE(OwnerAddress, ',', '.'),3)


alter table NashvilleHousing 
add OwnerSplitCity Nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename(REPLACE(OwnerAddress, ',', '.'),2)


alter table NashvilleHousing 
add OwnerSplitState Nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(REPLACE(OwnerAddress, ',', '.'),1)

select *
from covid.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from covid.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
Case when SoldAsVacant = 'Y' Then'YES'
	 when SoldAsVacant = 'N' Then 'NO'
	 else SoldAsVacant
	 End

from covid.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' Then'YES'
	 when SoldAsVacant = 'N' Then 'NO'
	 else SoldAsVacant
	 End

----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates--------------------------------------------------------------------------------

-- We will be using CTE - Common table expression for removing duplicates-------

with ROWNUMCTE AS(
select *,
	ROW_NUMBER() OVER(
	partition by ParcelId,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
					UniqueId
					) row_num
from covid.dbo.NashvilleHousing
)

select *
from ROWNUMCTE
where row_num >1



select *
from covid.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------------

-----Delete Unused Columns-----------------------------------------------------


select *
from covid.dbo.NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress,SaleDate,TaxDistrict,PropertyAddress


select *
from covid.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------------------------
