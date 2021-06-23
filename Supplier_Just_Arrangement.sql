-- Supplier to Just - Arrangment File
drop table #arr

-- Map arr file here
Select 
            [Client Account Number] AS ClientAccountNumber
		  , [Client Name]
		  , [Supplier Reference] as SupplierReferenceNumber
		  , [Date Set] as ArrangementDateSet
		  , [Arrangement Method] as ArrangementMethod
		  , [Arrangement Type] as ArrangementType
		  , [Arrangement Frequency] AS ArrangementFrequency
		  , [First Payment Date] as FirstPaymentDate
		  , [First Payment Amount] as [FirstPaymentAmount]
		  , [Ongoing Payment Amount] as [OngoingPaymentAmount]
into #arr
from Bulb_RM.dbo.Test_Arr

select * from #arr




insert into Bulb_RM.dbo.Arrangements
select  
       newid() as ArrangementID
	  , act.AccountID as AccountID
	  , ent.EntityID as EntityID
	  , arr.SupplierReferenceNumber as SupplierReferenceNumber
	  , arr.ArrangementDateSet as ArrangementDateSet
	  , arr.ArrangementMethod as ArrangementMethod
	  , arr.ArrangementType as ArrangementType
	  , arr.ArrangementFrequency as ArrangementFrequency
	  , arr.FirstPaymentDate as FirstPaymentDate
	  , arr.FirstPaymentAmount as FirstPaymentAmount
	  , arr.OngoingPaymentAmount as OngoingPaymentAmount
	  , getdate() as DTStamp
from #arr arr
JOIN Bulb_RM.dbo.Account act on act.ClientAccountNumber = arr.ClientAccountNumber
JOIN Bulb_RM.dbo.Entity ent on ent.EntityName = 'Bulb'


-- is there a better way to join the entity ID?
