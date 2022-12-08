SELECT *
FROM sqldata..NashvilleHous

-----STANDARDIZE DATE FORMAT
SELECT SaleDate,CONVERT(Date,SaleDate)
FROM sqldata..NashvilleHous

UPDATE NashvilleHous
SET SaleDate=CONVERT(Date,SaleDate)

----POPULATE PROPERTY DATA
SELECT PropertyAddress
FROM sqldata..NashvilleHous
WHERE PropertyAddress is NULL

SELECT *
FROM sqldata..NashvilleHous
WHERE PropertyAddress is NULL

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
FROM sqldata.dbo.NashvilleHous a
JOIN sqldata..NashvilleHous b
    ON a.ParcelID=b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM sqldata.dbo.NashvilleHous a
JOIN sqldata..NashvilleHous b
    ON a.ParcelID=b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null

---BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(ADRESS,CITY,STATE)
SELECT 
SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM sqldata.dbo.NashvilleHous

ALTER TABLE NashvilleHous
ADD propertysplitaddress Nvarchar(255);

UPDATE NashvilleHous
SET propertysplitaddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE NashvilleHous
ADD propertysplitcity Nvarchar(255);

UPDATE NashvilleHous
SET propertysplitcity=SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

FROM sqldata..NashvilleHous

ALTER TABLE NashvilleHous
ADD Ownersplitaddress Nvarchar(255);

UPDATE NashvilleHous
SET Ownersplitaddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHous
ADD Ownersplitcity Nvarchar(255);

UPDATE NashvilleHous
SET Ownersplitcity=PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHous
ADD Ownersplitstate Nvarchar(255);

UPDATE NashvilleHous
SET Ownersplitstate=PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

---REMOVE DUPLICATES
WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
				    UniqueID
				    ) row_num

FROM sqldata..NashvilleHous
)
DELETE 
FROM RowNumCTE
WHERE row_num>1


---DELETE UNWANTED COLUMNS
ALTER TABLE sqldata..NashvilleHous
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress
