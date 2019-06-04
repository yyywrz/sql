drop view shippedVsCustDemand;
create view shippedVsCustDemand as 
    select cd.customer,cd.item,sum(so.qty) as suppliedQty,cd.qty as demandQty
    from customerDemand cd, shiporders so
    where so.item = cd.item 
          and cd.customer=so.recipient(+)
    group by cd.item,cd.customer,cd.qty;
select * from shippedVsCustDemand;

drop view totalManufItems;   
create view totalManufItems as
    select item, sum(qty) as totalManufQty
    from manuforders m
    group by item;
select * from totalManufItems;
    
drop view matsUsedVsShipped;
create view matsUsedVsShipped as
    select mf as manuf,bm as matItem,qty1 as requiredQty,qty2 shippedQty
    from 
        (select m.manuf as mf, b.matitem as bm, sum(b.qtymatperitem*m.qty) as qty1
        from manuforders m, billofmaterials b
        where m.item=b.proditem 
        group by m.manuf,b.matitem),
        (select s.recipient as rec,s.item as item,sum(s.qty) as qty2
        from shiporders s
        group by s.recipient,s.item)
    where mf=rec 
        and bm=item;
select * from matsUsedVsShipped;

drop view producedVsShipped;
create view producedVsShipped as
    select m.item as item,m.manuf as manuf,sum(m.qty) as shippedOutQty,sum(s.qty) as orderedQty
    from manuforders m, shiporders s
    where s.sender=m.manuf 
        and s.item=m.item
    group by m.item,m.manuf;
select * from producedVsShipped;

drop view suppliedVsshipped;
create view suppliedVsshipped as
    select i1 as item, s1 as supplier,qty1 as shippedQty, qty2 as suppliedQty
    from (    
        select shiporders.item as i1,shiporders.sender as s1,sum(shiporders.qty) as qty1
        from supplyOrders s,shiporders
        where shiporders.item = s.item
        and shiporders.sender = s.supplier
        group by shiporders.item,shiporders.sender),
        (    
       select s.item as i2,s.supplier as s2,sum(s.qty) as qty2
        from supplyOrders s
        group by s.item,s.supplier)
    where i1=i2
    and s1=s2;
select * from suppliedVsshipped;
    
drop view perSupplierCost;
create view perSupplierCost as    
    select supp as supplier,
( case 
                      when base<sd.amt1 then base
                      when base>sd.amt2 then amt1+(amt2-amt1)*(1-disc1)+(base-amt2)*(1-disc2)
                      else amt1+(base-amt1)*(1-disc1)
                      end) as cost        
    from (select s.supplier as supp,sum(s.qty*sup.ppu) as base
        from supplyorders s,supplyunitpricing sup
        where s.supplier=sup.supplier
        and s.item=sup.item
        group by s.supplier),supplierdiscounts sd
    where sd.supplier=supp;
select * from perSupplierCost;

drop view perManufCost;
create view perManufCost as   
select mu as manuf,
( case 
                      when base<md.amt1 then base
                      else md.amt1+(base-md.amt1)*(1-md.disc1)
                      end) as cost        
    from (select mp.manuf as mu,sum(mo.qty*mp.prodcostperunit+mp.setupcost) as base
        from  manuforders mo,manufunitpricing mp
        where mo.manuf=mp.manuf
        and mp.proditem=mo.item
        group by mp.manuf),manufdiscounts md
    where mu=md.manuf;
select * from perManufCost;

drop view allships;
create view allships as
    select so.item as item, so.shipper as shipper,b1.shiploc as floc, b1.shiploc as tloc,so.qty as qty,i.unitweight as unit,sp.priceperlb as pricrperlb,so.qty*i.unitweight*sp.priceperlb as base,sp.minpackageprice
    from shiporders so,items i, busentities b1,busentities b2,shippingpricing sp
    where so.item=i.item
        and b1.shiploc=sp.fromloc
        and b2.shiploc=sp.toloc
        and so.sender=b1.entity
        and so.recipient=b2.entity
        and sp.shipper=so.shipper;


drop view perShipperCost;
create view perShipperCost as
    select s.shipper as shipper ,sum(disp) as Cost
    from(
     select sp.shipper as shipper,(case
        when base<amt1 then base
        when base>amt2 then amt1+(amt2-amt1)*(1-disc1)+(1-disc2)*(base-amt2)
        else (base-amt1)*(1-disc1)+amt1
        end) as disP
        from shippingpricing sp,
        (select a.shipper,a.floc,a.tloc,sum(base) as base
        from allships a
        group by a.shipper,a.floc,a.tloc) al
        where sp.shipper=al.shipper
        and sp.fromloc=al.floc
        and sp.toloc=al.tloc
        ) s
    group by s.shipper;
select * from perShipperCost;

drop view totalCostBreakdown;
create view totalCostBreakdown as
select supplycost,manufcost,shippingCost,(supplycost+manufcost+shippingCost) as totalcost
from  (select sum(s.cost) as supplycost
        from persuppliercost s),(
        select sum(m.cost) as manufcost
        from permanufcost m),(
        select sum(ps.cost) as shippingCost
        from perShipperCost ps);
select * from totalCostBreakdown;