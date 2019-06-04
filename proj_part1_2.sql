drop table items cascade constraints;
create table items (
   iid char(9),
   Weight number(4),
   primary key(iid) 
); 
select * from items;

drop table busEntities cascade constraints;
create table busEntities (
   entity char(9),
   shipLocation varchar(20),
   address varchar(20),
   phone number(10),
   web varchar(20),
   contact char(10),
   primary key(entity)
); 
select * from busEntities;

drop table produce cascade constraints;
create table produce(
product_Item char(9), 
matterial_Item char (9), 
nece_quantity number(3),
primary key(product_Item, matterial_Item),
foreign key(product_Item) references items(iid),
foreign key(matterial_Item) references items(iid)
);
select * from produce;

drop table supplier cascade constraints;
create table supplier
(supplier_name char(25), 
price_bound number(5), 
discount decimal(7,2),
primary key(supplier_name));
select * from supplier;

drop table supplyUnitPricing cascade constraints;
create table supplyUnitPricing(
supplier_name char(25), 
iid char(9), 
priceperunit number(4),
primary key(supplier_name,iid),
foreign key(iid) references items(iid));
select * from supplyUnitPricing;

drop table manufacturer cascade constraints;
create table manufacturer(
manufacture_name char(25), 
price_bound number(4), 
discount float(4),
primary key(manufacture_name));
select * from manufacturer;

drop table manufUnitPricing cascade constraints;
create table manufUnitPricing
(manufacturer_name char(25), 
product_item char(9), 
setUpCost number(5), 
CostPerUnit number(5),
primary key(manufacturer_name,product_item),
foreign key(product_item) references items(iid)
);
select * from manufUnitPricing;

drop table shipping cascade constraints;
create table shipping(
 shipper char(9), 
 source_location  varchar(20), 
 destination_location varchar(20), 
 minPackagePrice number(5), 
 pricePerLb number(9), 
 price_bound number(9), 
 discount float(9),
 primary key (shipper,source_location,destination_location));
select * from shipping;

drop table customer cascade constraints;
  create table customer(
 customer char(9), 
 did char(9), 
 qauntity number(5),
 primary key(customer, did),
 foreign key(did) references items(iid));
select * from customer;

drop table supplyOrders cascade constraints;
 create table supplyOrders(
 iid char(9), 
 supplier char(25), 
 qty number(5),
 primary key(iid, supplier),
 foreign key(iid) references items(iid),
 foreign key(supplier) references BUSENTITIES(entity)
 );
 select * from supplyOrders;
 
 drop table manufOrders cascade constraints;
create table manufOrders(
iid char(9), 
manufacturerer char(25), 
qty number(6),
primary key(iid, manufacturerer),
foreign key(iid) references items(iid),
foreign key(manufacturerer) references BUSENTITIES(entity));
select * from manufOrders;

drop table shipOrders cascade constraints;
 create table shipOrders(
 iid char(9), 
 shipper char(9), 
 sender char(25), 
 recipient char(25), 
 qty number(6),
 primary key(iid, shipper, sender, recipient),
 foreign key(iid) REFERENCES items(iid),
 foreign key(sender) REFERENCES BUSENTITIES(entity),
 foreign key(recipient) REFERENCES BUSENTITIES(entity));
 select * from shipOrders;