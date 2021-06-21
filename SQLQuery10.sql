SELECT *
FROM dbo.NashvilleHouse

--Standardize the Date Sequence

SELECT SaleDate, SaleDateConverted
FROM dbo.NashvilleHouse

ALTER TABLE NashvilleHouse
Add SaleDateConverted Date

UPDATE NashvilleHouse
SET SaleDateConverted = CONVERT(Date,SaleDate)

-------Popoulate Property Address Data


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHouse a
JOIN dbo.NashvilleHouse b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHouse a
JOIN dbo.NashvilleHouse b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


-----Breaking out address into individual columns(Address, City, State)

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 ) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM dbo.NashvilleHouse

ALTER TABLE NashvilleHouse
Add PropertySplitAddress varchar(255);

UPDATE NashvilleHouse
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 )

ALTER TABLE NashvilleHouse
Add PropertySplitCity varchar(255);

UPDATE NashvilleHouse
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHouse


ALTER TABLE NashvilleHouse
Add OwnerSplitAddress varchar(255);

UPDATE NashvilleHouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--

ALTER TABLE NashvilleHouse
Add OwnerSplitCity varchar(255);

UPDATE NashvilleHouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--

ALTER TABLE NashvilleHouse
Add OwnerSplitState varchar(255);

UPDATE NashvilleHouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--- CHanging Yes and No

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHouse
Group by SoldAsVacant
order by 2


SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' then 'YES'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 END
FROM NashvilleHouse

UPDATE NashvilleHouse
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'YES'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 END


---Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From NashvilleHouse
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


--DELETE Unused columns


SELECT *
FROM NashvilleHouse

ALTER TABLE NashvilleHouse
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHouse
DROP Column SaleDate