Select * from PortfolioProject.dbo.NashvilleHousing;

-- Standardize Date format

Select SaleDateConverted, CONVERT(Date, SaleDate) as Dates
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing 
SET SaleDate = CONVERT(Date, SaleDate)

Alter TABLE NashvilleHousing 
add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate);

-- Let's Populate Property Address
Select * 
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID;


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a 
Join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NUll

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a 
Join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NUll

-- Breaking out address into Individual Columns (Address, City, State)
Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
--order by ParcelID;

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));




Select *
From PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject.dbo.NashvilleHousing


-- Change  Y and N to Yes and No in "Sold as Vacant" Field
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2;


Select  SoldAsVacant
,Case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No' 
	ELSE SoldAsVacant 
	END
From PortfolioProject.dbo.NashvilleHousing;

Update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No' 
	ELSE SoldAsVacant 
	END

-- Remove duplicate
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

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Delete Unused 
Select * 
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

