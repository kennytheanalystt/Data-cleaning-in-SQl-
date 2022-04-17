/* Cleaning data in SQl Queries */
 select * from nash;
 
-- 1 Standardise Date

select SaleDate,(SaleDate)::date from nash OR
select SaleDate,CAST(SaleDate as date) from nash

-- 2 populate PropertyAddress

select * from nash where PropertyAddress is null 
   /* we can note here that where the propertyAdress is null there's another
      row with the same Parcelid and has the addres which means Parcelid = propertyAddress
      we can populate the PA with others rows that has same PI and PA by Selfjoin */
	  
select Coalesce(ns.PropertyAddress,nsh.PropertyAddress) from nash ns
      join nash nsh on ns.ParcelID = nsh.ParcelID and ns.UniqueID <> nsh.UniqueID
   where ns.PropertyAddress is null
   
   -- Now lets update the table nash
   
update nash SET PropertyAddress = nsh.PropertyAddress
      from nash nsh where nash.ParcelID = nsh.ParcelID and nash.UniqueID <> nsh.UniqueID 
	  and nash.PropertyAddress is null
   
-- 3.1 Breaking address into individual colummn (Address,city,state)

select PropertyAddress from nash

Select PropertyAddress,
       substring(PropertyAddress,1,position(',' in PropertyAddress)-1) as address,
	   substring(PropertyAddress,position(',' in PropertyAddress)+1,length(PropertyAddress)) as address
	from nash
 -- Now let us alter the table by adding new column
Alter table nash add propertyadd varchar(500)
update nash set propertyadd = substring(PropertyAddress,1,position(',' in PropertyAddress)-1)

Alter table nash add propertycity varchar(500)
update nash set propertycity =
substring(PropertyAddress,position(',' in PropertyAddress)+1,length(PropertyAddress))

/*  3.2 Breaking  owners address
Sequel to the above we can use a more simpler way to break/split a column */

Select SPLIT_PART(owneraddress,',',1),
       SPLIT_PART(owneraddress,',',2),
	   SPLIT_PART(owneraddress,',',3) from nash
	   
-- NOW lets update the table

Alter table nash add owneradd varchar(500)
update nash set owneradd = SPLIT_PART(owneraddress,',',1)

Alter table nash add ownercity varchar(500)
update nash set ownercity = SPLIT_PART(owneraddress,',',2)

Alter table nash add ownerstate varchar(500)
update nash set ownerstate = SPLIT_PART(owneraddress,',',3)

-- 4 changing Y and N to Yes and No in 'SoldAsVacant'
select distinct(SoldAsVacant),count(SoldAsVacant)
 from nash group by SoldAsVacant order by 2
 
 -- to the work
Select SoldAsVacant,
 case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
 end
from nash
-- let's update 
update nash set soldAsVacant =  case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
 end

-- 5 Removing duplicate value 

 With rowcte as(select *,
  ROW_NUMBER() over (partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
		order by UniqueID) as row_num from nash)
delete  from nash where UniqueID in (select UniqueID from rowcte where row_num > 1)

-- Delete unused colunm 

Alter table nash drop column OwnerAddress,drop column TaxDistrict,drop column PropertyAddress