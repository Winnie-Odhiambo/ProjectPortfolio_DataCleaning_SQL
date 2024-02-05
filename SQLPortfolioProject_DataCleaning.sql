Select * 
from NashvilleHousing

--Standardizing the Saledate column. It is a datetime data type but I want to do away with the time
Select SaleDate
from NashvilleHousing

Select SaleDate, CONVERT(Date,SaleDate)
from NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
from NashvilleHousing

--Populating the Null PropertyAddress Values
Select * --[UniqueID ],ParcelID, PropertyAddress
from NashvilleHousing
where PropertyAddress is null
--Properties with same ParcelID share the same PropertyAdress 
--We will fill the Null address that have the same ParcelID
--First we'll join the table on itself using the ParcelID as the common column 
--ISNULL checks if the column is null then it populates it witht the values of the column that you specify to it
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID=b.ParcelID
And a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID=b.ParcelID
And a.[UniqueID ]<>b.[UniqueID ]

--I will break out the PropertyAddress into individual columns(Address,City)
--The -1 removes the comma from the output
Select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) - 1) as Address,
   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

from NashvilleHousing

ALTER TABLE NashvilleHousing
Add NewPropertyAddress Nvarchar(255);

Update NashvilleHousing
Set NewPropertyAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertyCity Nvarchar(255);

Update NashvilleHousing
Set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select * from NashvilleHousing

--Breaking out the OwnerAddress into Address,City and State
--The first option is to use the Substring as we did for the PropertyAddress

--The second option is using PARSENAME which is simpler but it outputs in reverse so you have to number them in reverse. In this example it's numbered 3,2,1
Select 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3) as NewOwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as NewOwnerCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as NewOwnerState
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add NewOwnerAddress Nvarchar(255);

Update NashvilleHousing
Set NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)

ALTER TABLE NashvilleHousing
Add NewOwnerCity Nvarchar(255);

Update NashvilleHousing
Set NewOwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add NewOwnerState Nvarchar(255);

Update NashvilleHousing
Set NewOwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select * From NashvilleHousing

--I want to fing the distinct values in the SolsAsVacant column
Select Distinct(SoldAsVacant)
from NashvilleHousing
--So some values were inserted as Y and N
--The below code shows the total numbers according to the groupings
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
Order by 2
--Changing them to Yes and No
Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
	 From NashvilleHousing
 
 Update NashvilleHousing
 SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
	 From NashvilleHousing

--Removing Duplicates
Select * from NashvilleHousing
--Identifying all the rows with duplicates
With RowNumCTE As(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID)
				row_num
From NashvilleHousing
)
Select * 
From RowNumCTE
Where row_num>1
Order by PropertyAddress
--Deleting the duplicates
With RowNumCTE As(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID)
				row_num
From NashvilleHousing
)
Delete 
From RowNumCTE
Where row_num>1


--Deleting Unused Columns
Select * From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

