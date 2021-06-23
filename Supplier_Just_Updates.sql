--Supplier to Just - NFU
drop table #nfu



-- Map NFU file here
Select 
          [Client Account Number] AS ClientAccountNumber
		, [Customer Full Name] as CustomerFullName
		, [Address Type] as AddressType
		, [New Address House Name] as AddressHouseName
		, [New Address Number] as AddressHouseNumber
		, [New Address Line 1] as AddressLine1
		, [New Address Line 2] as AddressLine2
		, [New Address Line 3] as AddressLine3
		, [New Address Line 4] as AddressLine4
		, [New Address Line 5] as AddressLine5
		, [New Address Postcode] as AddressPostCode
		, [Date Of Birth] as DateOfBirth
		, [Phone Type] as PhoneTypeCode
		, [Telephone Number] as TelephoneNumber
		, [Email] as EmailAddress
		, 'Bulb' as Source
		, '1' as [Active] 
		, getdate() as DTStamp
into #nfu 
from Bulb_RM.dbo.Test_NFU


-- Update Customer Address Table
-- Mark previous address under account and of same address type as inactive
UPDATE Bulb_RM.dbo.CustomerAddress
SET Active = '0'
FROM #nfu nf
JOIN Bulb_RM.dbo.Account act on act.ClientAccountNumber = nf.ClientAccountNumber
JOIN Bulb_RM.dbo.CustomerAddress ca on ca.AddressType = nf.AddressType
Where nf.AddressType is not null

-- Now insert new address

-- ADD NEW ADDRESS - KEEP ACCOUNT ID AND CLIENT ACCOUNT NUMBER BUT ADD NEW ADDRESS ID??
-- Get SL to check this 

insert into Bulb_RM.dbo.CustomerAddress
select 
		newid()	as AddressID,
		act.AccountID as AccountID,
		nf.AddressType as AddressType,
		nf.AddressHouseName as AddressHouseName,
		nf.AddressHouseNumber as AddressHouseNumber,
		nf.AddressLine1 as AddressLine1,
		nf.AddressLine2 as AddressLine2,
		nf.AddressLine3 as AddressLine3,
		nf.AddressLine4 as AddressLine4,
		nf.AddressLine5 as AddressLine5,
		nf.AddressPostCode as AddressPostcode,
		nf.Source as Source,
		nf.Active as Active,
		nf.DTStamp as DTStamp
from #nfu nf	   
JOIN Bulb_RM.dbo.Account act on act.ClientAccountNumber = nf.ClientAccountNumber
Where nf.AddressType is not null



-- Update Customer telephone Table
-- Mark previous telephonenumber under account and of same phone type as inactive
UPDATE Bulb_RM.dbo.CustomerTelephone
SET Active = '0'
FROM #nfu nf
JOIN Bulb_RM.dbo.Account act on act.ClientAccountNumber = nf.ClientAccountNumber
JOIN Bulb_RM.dbo.CustomerTelephone ct on ct.PhoneTypeCode = nf.PhoneTypeCode
where nf.TelephoneNumber is not null
and nf.PhoneTypeCode is not null


insert into Bulb_RM.dbo.CustomerTelephone
select 
		newid()	as CustomerTelephoneID,
		act.AccountID as AccountID,
		nf.TelephoneNumber as TelephoneNumber,
		nf.PhoneTypeCode as PhoneTypeCode,
		nf.Active as Active,
		nf.Source as Source,
		nf.DTStamp as DTStamp
from #nfu nf	   
JOIN Bulb_RM.dbo.Account act on act.ClientAccountNumber = nf.ClientAccountNumber
where nf.TelephoneNumber is not null
and nf.PhoneTypeCode is not null




-- Update Customer Email Table
-- Mark previous email under account as inactive
UPDATE Bulb_RM.dbo.CustomerEmail
SET Active = '0'
FROM #nfu nf
JOIN Bulb_RM.dbo.Account act on act.ClientAccountNumber = nf.ClientAccountNumber
where nf.EmailAddress is not null



insert into Bulb_RM.dbo.CustomerEmail
select 
		newid()	as CustomerEmailID,
		act.AccountID as AccountID,
		nf.EmailAddress as EmailAddress,
		nf.Active as Active,
		nf.Source as Source,
		nf.DTStamp as DTStamp
from #nfu nf	   
JOIN Bulb_RM.dbo.Account act on act.ClientAccountNumber = nf.ClientAccountNumber
where nf.EmailAddress is not null



