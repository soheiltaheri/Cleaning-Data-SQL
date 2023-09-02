# Cleaning Data In SQL--------------------------------------------------------------

SELECT *
FROM portfolio.`housing-data`;


# Standardize Date Format-----------------------------------------------------------

SELECT SaleDate
FROM `housing-data`;

ALTER TABLE `housing-data`
ADD COLUMN new_SaleDate DATE;

UPDATE `housing-data`
SET new_SaleDate = STR_TO_DATE(SaleDate, '%d-%b-%y');

SELECT new_SaleDate
from `housing-data`;


# Populate Property Address Data----------------------------------------------------

SELECT *
FROM `housing-data`
# WHERE PropertyAddress is null
ORDER BY ParcelID;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress,b.PropertyAddress)
FROM `housing-data` a
    JOIN `housing-data` b
        ON a.ParcelID = b.ParcelID
               and a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is null;

Update `housing-data` a JOIN `housing-data` b
ON a.ParcelID = b.ParcelID
and a.UniqueID != b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress is null;

# Breaking Out Address Into Individual Column(Address, City, State)----------------------------------

SELECT *
FROM `housing-data`;

SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) as Address,
       SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress)) as City
FROM `housing-data`;


ALTER TABLE `housing-data`
ADD COLUMN PropertySplitAddress nvarchar(255);

UPDATE `housing-data`
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1);


ALTER TABLE `housing-data`
ADD COLUMN PropertySplitCity nvarchar(255);

UPDATE `housing-data`
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress));



SELECT OwnerAddress
FROM `housing-data`;


SELECT
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1) AS part1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS part2,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) AS part3
FROM `housing-data`;

ALTER TABLE `housing-data`
ADD COLUMN OwnerSplitAddress nvarchar(255);

UPDATE `housing-data`
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1);

ALTER TABLE `housing-data`
ADD COLUMN OwnerSplitCity nvarchar(255);

UPDATE `housing-data`
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE `housing-data`
ADD COLUMN OwnerSplitState nvarchar(255);

UPDATE `housing-data`
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1);


SELECT *
FROM `housing-data`;


# Change Y and N to Yes And No in 'Sold as vacant' Field---------------------------------------

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM `housing-data`
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant;


SELECT SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'No'
END
FROM `housing-data`;


Update `housing-data`
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'No'
END;


# Remove Duplicates---------------------------------------------------

WITH RowNumCTE as (
    SELECT *, ROW_NUMBER() over (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID
        ) row_num
    FROM `housing-data`
)
Delete
FROM RowNumCTE
WHERE row_num > 1;


# Delete Unused Column---------------------------------------------------------
SELECT *
FROM `housing-data`;

ALTER TABLE `housing-data`
    DROP COLUMN PropertyAddress;

ALTER TABLE `housing-data`
    DROP COLUMN OwnerAddress;

ALTER TABLE `housing-data`
    DROP COLUMN TaxDistrict;

ALTER TABLE `housing-data`
    DROP COLUMN SaleDate;