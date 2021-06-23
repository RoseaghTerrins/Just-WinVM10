-- Supplier to Just - Pay File
drop table #pay
--remove underscore from PaymentMethod
-- Map arr file here
Select 
  [Client Account Number] as ClientAccountNumber
, [Supplier Reference] as TransactionReference
, [Client Name] as ClientName
, [Adjustment Type] as AdjustmentType
, [Adjustment Amount] as TransactionAmount
, [Adjustment Date] as TransactionDate
, [Payment Method] as PaymentMethod
, null as CommissionRate
, null as CommissionValue
into #pay
from Bulb_RM.dbo.Test_Pay


select * from #pay

insert into Bulb_RM.dbo.AccountTransaction
select 
	   newid() as TransactionID,
	   acc.AccountID as AccountID,
	   d.ClientAccountNumber as ClientAccountNumber,
	   AdjustmentType as AdjustmentType,
	   CAST(TransactionAmount AS FLOAT) as TransactionAmount,
	   TransactionDate as  TransactionDate,
	   PaymentMethod as PaymentMethod,
	   comm.CommissionRate as CommissionRate,
	   CASE WHEN AdjustmentType in ('PAY','PRV','FPY','FPR') THEN CAST(TransactionAmount*comm.CommissionRate AS FLOAT)else null END as CommissionValue,
	   null as FeeValue,
	   TransactionReference as TransactionReference,
	   ass.AssignmentID as AssignmentID,
	   null as SourceEntityID,
	   ass.EntityID as AssignedEntityID,
	   getdate() as DTStamp
from #pay d
join Bulb_RM.dbo.Account  acc on acc.ClientAccountNumber=d.ClientAccountNumber
join Bulb_RM.dbo.Assignment ass on acc.AccountID = ass.AccountID and d.TransactionDate between ass.AssignedDate and ass.ClosureDate
join Bulb_RM.dbo.Entity ent on ent.EntityID= ass.EntityID
join Bulb_RM.dbo.Commission comm on comm.EntityID = ent.EntityID and comm.Segment = ass.Segment



UPDATE Bulb_RM.dbo.Account
set OutstandingBalance = CASE
	WHEN d.AdjustmentType = 'PAY' then acc.OutstandingBalance-(d.TransactionAmount)
	WHEN d.AdjustmentType = 'PRV' then acc.OutstandingBalance+d.TransactionAmount
	WHEN d.AdjustmentType = 'PBA' then acc.OutstandingBalance+d.TransactionAmount
	WHEN d.AdjustmentType = 'NBA' then acc.OutstandingBalance-(d.TransactionAmount)
	WHEN d.AdjustmentType = 'FPA' then acc.OutstandingBalance+(d.TransactionAmount)
	WHEN d.AdjustmentType = 'FNA' then acc.OutstandingBalance-d.TransactionAmount
	WHEN d.AdjustmentType = 'FPY' then acc.OutstandingBalance-d.TransactionAmount
	WHEN d.AdjustmentType = 'FPR' then acc.OutstandingBalance+(d.TransactionAmount)
	END
from Bulb_RM.dbo.Account acc
join #pay d on  acc.ClientAccountNumber = d.ClientAccountNumber

UPDATE Bulb_RM.dbo.Account
set DebtBalance = CASE
	WHEN d.AdjustmentType = 'PAY' then acc.DebtBalance-(d.TransactionAmount)
	WHEN d.AdjustmentType = 'PRV' then acc.DebtBalance+d.TransactionAmount
	WHEN d.AdjustmentType = 'PBA' then acc.DebtBalance+d.TransactionAmount
	WHEN d.AdjustmentType = 'NBA' then acc.DebtBalance-(d.TransactionAmount)
	END
from Bulb_RM.dbo.Account acc
join #pay d on  acc.ClientAccountNumber = d.ClientAccountNumber

UPDATE Bulb_RM.dbo.Account
set FeeBalance = CASE
	WHEN d.AdjustmentType = 'FPA' then acc.FeeBalance+(d.TransactionAmount)
	WHEN d.AdjustmentType = 'FNA' then acc.FeeBalance-d.TransactionAmount
	WHEN d.AdjustmentType = 'FPY' then acc.FeeBalance-d.TransactionAmount
	WHEN d.AdjustmentType = 'FPR' then acc.FeeBalance+(d.TransactionAmount)
	END
from Bulb_RM.dbo.Account acc
join #pay d on  acc.ClientAccountNumber = d.ClientAccountNumber


-- Ask SL about below method
--UPDATE Bulb_RM.dbo.Account
--Set OutstandingBalance = acc.OutstandingBalance - colls
--from Bulb_RM.dbo.Account acc
--join (select acc.Accountid, 
				--sum(CASE WHEN d.AdjustmentType = 'PAY' then acc.OutstandingBalance-(d.TransactionAmount*-1)
						 --WHEN d.AdjustmentType = 'PRV' then acc.OutstandingBalance+d.TransactionAmount
						 --WHEN d.AdjustmentType = 'PBA' then acc.OutstandingBalance+d.TransactionAmount
						 --WHEN d.AdjustmentType = 'NBA' then acc.OutstandingBalance-(d.TransactionAmount*-1)
					--END) colls
--) colls
--from Bulb_RM.dbo.Account acc
--join rm.dbo.AccountTransaction act on acc.ClientAccountNumber = act.ClientAccountNumber
--group by acc.AccountID
--) act on act.AccountID = acc.AccountID
--join (
	 --select ClientAccountNumber
	 --from #pay d
	 --group by ClientAccountNumber
	 --) d on d.ClientAccountNumber = acc.ClientAccountNumber