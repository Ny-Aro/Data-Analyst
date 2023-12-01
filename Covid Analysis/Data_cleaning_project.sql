select * from Nashville


-- Standardize date format
select SaleDateConverted, CONVERT(date,SaleDate) 
from Nashville

update Nashville
set SaleDate = CONVERT(date,SaleDate) 

alter table Nashville
add SaleDateConverted date;

update Nashville
set SaleDateConverted = CONVERT(date,SaleDate) 


-- Property address
select *
from Nashville
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville a
join Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville a
join Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]


-- Breaking out Address into individual columns (Adress, city, state)
select *
from Nashville

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , Len(PropertyAddress)) as City
from Nashville

alter table Nashville
add Adrress nvarchar(255);

update Nashville
set Adrress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

alter table Nashville
add City nvarchar(255);

update Nashville
set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , Len(PropertyAddress)) 

select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
from Nashville

alter table Nashville
add OwnerAdrress nvarchar(255);

update Nashville
set OwnerAdrress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

alter table Nashville
add OwnerCity nvarchar(255);

update Nashville
set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

alter table Nashville
add OwnerState nvarchar(255);

update Nashville
set OwnerState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


-- Change Y and N in "SoldAsVacant" to Yes and No
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Nashville
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Nashville

update Nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end


-- Removes Duplicates Data
with RowNumCTE as (
select *,
	ROW_NUMBER () over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				 ) row_num
from Nashville
)

select * 
from RowNumCTE
where row_num >1


-- Delete unused columns (not useful) 
select * from Nashville

alter table Nashville
drop column SaleDate, OwnerAddress,PropertyAddress
