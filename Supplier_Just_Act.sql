-- Supplier to Just - Act File
drop table #act
--remove underscore from PaymentMethod
-- Map arr file here
Select 
  [Client Account Number] as 	ClientAccountNumber
 ,[Client Name]	as ClientName
 ,[Activity]	as ActivityDescription
 ,[Activity Date] as ActivityDate
into #act
from Bulb_RM.dbo.Test_act



insert into Bulb_RM.dbo.Activity
select 
	newid() as ActivityID
   , acc.AccountID AS AccountID
   , ActivityDescription as ActivityDescription
   , ActivityDAte as ActivityDate
   , 'Bulb' as SourceEntity
   , getdate() as DTStamp
from #act a
join Bulb_RM.dbo.Account  acc on acc.ClientAccountNumber=a.ClientAccountNumber




