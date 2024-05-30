/*

Cleaning Data in SQL Queries

*/


Select *
From PortofolioProjects.dbo.Nashville

-- Standardize Date Format


Select saleDateconverted, CONVERT(Date,SaleDate)
From PortofolioProjects.dbo.Nashville


Update PortofolioProjects.dbo.Nashville
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE PortofolioProjects.dbo.Nashville
Add SaleDateConverted Date;

Update PortofolioProjects.dbo.Nashville
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data

Select *
From PortofolioProjects.dbo.Nashville
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortofolioProjects.dbo.Nashville a
JOIN PortofolioProjects.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortofolioProjects.dbo.Nashville a
JOIN PortofolioProjects.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortofolioProjects.dbo.Nashville
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortofolioProjects.dbo.Nashville

ALTER TABLE PortofolioProjects.dbo.Nashville
Add PropertySplitAddress Nvarchar(255);

Update PortofolioProjects.dbo.Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortofolioProjects.dbo.Nashville
Add PropertySplitCity Nvarchar(255);

Update PortofolioProjects.dbo.Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortofolioProjects.dbo.Nashville

Select OwnerAddress
From PortofolioProjects.dbo.Nashville


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortofolioProjects.dbo.Nashville

ALTER TABLE PortofolioProjects.dbo.Nashville
Add OwnerSplitAddress Nvarchar(255);

Update PortofolioProjects.dbo.Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortofolioProjects.dbo.Nashville
Add OwnerSplitCity Nvarchar(255);

Update PortofolioProjects.dbo.Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortofolioProjects.dbo.Nashville
Add OwnerSplitState Nvarchar(255);

Update PortofolioProjects.dbo.Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select *
from PortofolioProjects.dbo.Nashville

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortofolioProjects.dbo.Nashville
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortofolioProjects.dbo.Nashville


Update PortofolioProjects.dbo.Nashville
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortofolioProjects.dbo.Nashville
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--Delete Unused Columns

select *
from PortofolioProjects.dbo.Nashville

ALTER TABLE PortofolioProjects.dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

