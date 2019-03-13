--On -boarding Task - Technical Preparation #1
--Created by Larissa Kilemtieva 
--Date: Feb 2019

--TASK 1-----------------------------------------------------------------------------------------------------:

--(a) Display a list of all the Property Names and their Property Ids for Owner Id: 1426
select		Prop.Name as [Property Name], OwnrProp.PropertyId as [Property Id], OwnerId as [Owner ID]
from		[dbo].[OwnerProperty] OwnrProp  
inner Join	[dbo].[Property] Prop on OwnrProp.PropertyId=Prop.Id where OwnrProp.OwnerId = 1426;

--------------------------------
--(b) Display the current home value for each property in question (a)
 select		OwnerId as [Owner ID], OwnrProp.PropertyId as [PropertyID], Name as [PRoperty Name],
			PropFin.CurrentHomeValue as [Current Home Value]
from		[dbo].[OwnerProperty] as OwnrProp 
inner join	[dbo].[Property] Prop on OwnrProp.PropertyId = Prop.Id
left join	[dbo].[PropertyFinance] PropFin on Prop.Id = PropFin.PropertyId
where		OwnrProp.OwnerId = 1426; 

--------------------------------
 --(c) For each property in question a), return the following: 
	--i. Using rental payment amount, rental payment frequency, tenant start date and tenant end date to write a query
	--	 that returns the sum of all payments from start date to end date. 
	--ii.Display the yield. 

--i		 Using rental payment amount, rental payment frequency, tenant start date and tenant end date to write a query
		 --that returns the sum of all payments from start date to end date. 

select		TenantProperty.PropertyId, PaymentStartDate,TenantProperty.EndDate, 
			DATEDIFF(MONTH, (PaymentStartDate), (EndDate) + 1) as NumOfMonths ,
			PaymentFrequencyId, PaymentAmount,
CASE
    when PaymentFrequencyId=1 then (4*PaymentAmount)
    when PaymentFrequencyId=2 then (2*PaymentAmount)
    when PaymentFrequencyId=3 THEN (1*PaymentAmount)
	else 'This Payment Frequency code is not valid...'
end as	 [Calculeted Payment Per Month] 
from		TenantProperty 
inner join	OwnerProperty on TenantProperty.PropertyId = OwnerProperty.PropertyId
where		OwnerProperty.OwnerId=1426;
--------------------------------
--ii.Display the yield. 
--TO BE DONE LATER........

--------------------------------
--( d )Display all the jobs available in the marketplace (jobs that owners have advertised for service suppliers)
select		Id, OwnerId, ProviderId, PropertyId,  JobDescription, JobStatusId
from		Job
where		OwnerId is not NUll and ProviderId is not null and JobStatusId=1  
order by	OwnerId;

--------------------------------
--(e)---Dispaly all pproperty names, current tenant first name, and last name, and rental payments frequency
select		p.Id as [Property ID], p.Name as [Property Name], psn.FirstName as [Tenant First Name],
			psn.LastName as [Tenant Last Name], tp.PaymentAmount as [Rental Payment Amount],tpfrq.Code as [Payment Frequency]
from		(((([dbo].[OwnerProperty] op
inner join	[dbo].[Property] p on op.PropertyId=p.Id)
inner join	[dbo].[TenantProperty] tp on p.Id=tp.PropertyId) 
inner join	[dbo].[Person] psn on tp.TenantId=psn.Id)
inner join  [dbo].[TenantPaymentFrequencies] as tpfrq on tp.PaymentFrequencyId=tpfrq.Id)
where op.OwnerId=1426

--------------------------------


