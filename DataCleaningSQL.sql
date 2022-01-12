Select *
From PortfolioProjects.dbo.NashvilleHousing

--Standardize date format
Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From PortfolioProjects.dbo.NashvilleHousing
--column much easier to use now


Select *
From PortfolioProjects.dbo.NashvilleHousing
Where PropertyAddress is null
Order by ParcelID

--removing the nulls
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Making addresses useful
Select PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Town
From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add NewPropertyAddress nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
Set NewPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add PropertyTown nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
Set PropertyTown = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProjects.dbo.NashvilleHousing

Select OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) NewOwnerAddress
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) OwnerTown
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) OwnerState
From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add NewOwnerAddress nvarchar(255);

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerTown nvarchar(255);

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerState nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update PortfolioProjects.dbo.NashvilleHousing
Set OwnerTown = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

Update PortfolioProjects.dbo.NashvilleHousing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--changing Y to Yes and N to No in "Sold as Vacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group By SoldAsVacant

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
    When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProjects.dbo.NashvilleHousing

Update PortfolioProjects.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
    When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--Removing duplicates
WITH RowNumCTE AS (
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
From PortfolioProjects.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num >1

--Deleting Unused Columns
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
