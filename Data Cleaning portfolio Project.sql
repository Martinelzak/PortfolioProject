--Cleaning Data in SQL Queries

select * 
from PortfolioProject.dbo.NashvilleHousing


--Standardize Data Format

select SaleDateConverted, convert(date,SaleDate)  
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
add SaleDateConverted date;

Update NashvilleHousing
Set SaleDateConverted=convert(date,SaleDate)



--Populate property Address data

select * 
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b 
     on a.ParcelID=b.ParcelID
	 and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b 
     on a.ParcelID=b.ParcelID
	 and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Adress into Individual Columns(Adress, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(225);

Update NashvilleHousing
Set PropertySplitAddress=SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
add PropertySplitCity Nvarchar(225);

Update NashvilleHousing
Set PropertySplitCity=SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

select * 
from PortfolioProject.dbo.NashvilleHousing




select OwnerAddress 
from PortfolioProject.dbo.NashvilleHousing

select 
PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),1)
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(225);

Update NashvilleHousing
Set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress, ',','.'),3)


ALTER TABLE NashvilleHousing
add OwnerSplitCity Nvarchar(225);

Update NashvilleHousing
Set OwnerSplitCity=PARSENAME(Replace(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
add OwnerSplitState Nvarchar(225);

Update NashvilleHousing
Set OwnerSplitState=PARSENAME(Replace(OwnerAddress, ',','.'),1)


select * 
from PortfolioProject.dbo.NashvilleHousing






--Change Y and N to Yes and No in "Sold as vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant) as Scount 
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant, 
 case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing


Update  NashvilleHousing
set SoldAsVacant= case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
	 end



--Remove Duplicates
WITH RowNumCTE as (
select *,
row_number() over(partition by parcelID, PropertyAddress, Saleprice, SaleDate, LegalReference Order by uniqueID) Row_num
from PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
DELETE
from RowNumCTE
where Row_num > 1
--Order by PropertyAddress

WITH RowNumCTE as (
select *,
row_number() over(partition by parcelID, PropertyAddress, Saleprice, SaleDate, LegalReference Order by uniqueID) Row_num
from PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
select *
from RowNumCTE
where Row_num > 1
Order by PropertyAddress





--Delete Unused Columns

select *
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop column OwnerAddress, taxDistrict, propertyAddress


Alter Table PortfolioProject.dbo.NashvilleHousing
Drop column SaleDate
