insert into Bulb_RM.dbo.Closurecodes
select * from
Bulb_RM.dbo.Closurecodes_MetaData



-- Supplier to Just - Closure File
drop table #closure

-- Map Closure File
Select 
	  [Client Account Number] as ClientAccountNumber
	, [Client Name] as ClientName
	, [Closure Reason] as	ClosureReason
	, [Closure Date] as ClosureDate
into #Closure 
from Bulb_RM.dbo.Test_Closure c
join Bulb_RM.dbo.Closurecodes cc on cc.Code = c.[Closure Reason]

select * from #Closure


-- Validation
--Checks for any invalid or new closure codes
-- Ask SL to check the below

select			* 
from			Bulb_RM.dbo.Test_Closure c
left join		#Closure cc on cc.ClientAccountNumber = c.[Client Account Number] 
where			cc.ClientAccountNumber is null


--Checks if account has already been closed back to the client
select			'account' as [table], acc.ClientAccountNumber, acc.ClientRecallDate, acc.ClientRecallReason, acc.ClosureDate , acc.ClosureReason
from			#closure	cl
join			Bulb_RM.dbo.Account acc on acc.ClientAccountNumber=cl.ClientAccountNumber
									and (acc.ClosureDate is not null)


-- Logic for a Closure in response to a Recall:
-- If Assignment.RecallReason and Assignment.RecallDate populated then a Closure update against the Assignment should trigger a “Final” closure 
-- and update the Account table 
-- Set Account.ClosureReason and Account.ClosureDate = to those entries just processed into the Assignment table.
-- Also set Account.ActiveFlag to 0
-- Unless Assignment.RecallReason = RATC (Return Account to Client) in which case do not update Account table 
-- and keep the Assignment closed but leave the Account as ActiveFlag = 1


update Bulb_RM.dbo.Assignment
SET		ClosureReason = C.ClosureReason
		, ClosureDate = getdate()
		, Active = '0'
from Bulb_rm.dbo.Assignment ass
join Bulb_RM.dbo.Account acc on acc.AccountID = ass.AccountID
join #Closure c on c.ClientAccountNumber = acc.ClientAccountNumber
where ass.ClosureReason is null
and ass.ClosureDate is null

-- update account table where there is a recall in account table and the closure has just been updated in assignement table
update Bulb_RM.dbo.Account
SET ClosureReason = acc.RecallReason
    , ClosureDate = getdate()
	, Active = '0'
from Bulb_RM.dbo.Account acc
join Bulb_RM.dbo.Assignment ass on acc.AccountID = ass.AccountID
where acc.ClientRecallReason is not null
and Cast(ass.ClosureDate as Date) = Cast(getdate() as Date)

-- Only update account when Closure Reason is not RATC
--  Ant to confirm if this can be removed 
update Bulb_RM.dbo.Account
SET		ClosureReason = C.ClosureReason 
		, ClosureDate = C.ClosureDate
		, ActiveFlag  = '0'
from #closure C 
join Bulb_RM.dbo.Account acc on acc.ClientAccountNumber = C.ClientAccountNumber
where C.ClosureReason  != 'RATC'  



--Logic for Closure without a Recall;
--Set Account.ClosureReason and Account.ClosureDate = to those entries just processed into the Assignment table.
--Also set Account.ActiveFlag to 0
--If Closure reason is classed as Final Closure in table below. 
--If not then just close the Assignment and leave the Account as ActiveFlag = 1 and do not update Account.ClosureReason or Account.ClosureDate

update Bulb_RM.dbo.Account
SET		ClosureReason = C.ClosureReason
		, ClosureDate = getdate()
		, ActiveFlag  = '0'
from Bulb_RM.dbo.Account acc 
join #closure C on acc.ClientAccountNumber = C.ClientAccountNumber
join Bulb_RM.dbo.Closurecodes as cc on C.ClosureReason = cc.Code
where cc.Final = 'Yes' 
