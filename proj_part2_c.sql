select distinct customer
from shippedVsCustDemand s
where s.suppliedQty<s.demandQty;

select distinct supplier
from suppliedvsshipped svs
where svs.shippedqty<svs.suppliedqty;

select distinct manuf as manufacturer
from matsusedvsshipped mvs
where mvs.requiredqty>mvs.shippedqty;

select distinct manuf as manufacturer
from producedvsshipped pvs
where pvs.shippedoutqty<pvs.orderedqty