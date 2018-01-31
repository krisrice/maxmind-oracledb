REM
REM Drop and recreate the table
REM
drop table geo_lite_asn;

create table geo_lite_asn (
   "network" varchar2(32),
   "autonomous_system_number" number,
   "autonomous_system_organization" varchar2(200))
/

REM SQLcl Command
REM Adjust path to csv as needed

load geo_lite_asn GeoLite2-ASN-CSV_20180116/GeoLite2-ASN-Blocks-IPv4.csv

REM
REM LOAD command must have table and csv matching column names
REM      renaming post-loading to make names unquoted
REM
alter table geo_lite_asn rename column "network" to network;
alter table geo_lite_asn rename column "autonomous_system_number" to autonomous_system_number;
alter table geo_lite_asn rename column "autonomous_system_organization" to autonomous_system_organization;

REM
REM Adding columns for the low and high ipnumbers
REM

alter table geo_lite_asn add (
   low_num number,
   high_num number)
/


@iputils.sql

REM
REM Add an index
REM
create  index geo_list_asn_idx1 on geo_lite_asn(high_num,low_num);

REM
REM populate the low and high
REM
 update geo_lite_asn set low_num =  ip_utils.ip2num(substr(network,0,instr(network,'/')-1)),
                                     high_num =  ip_utils.maxnum_in_cidr(network) ;
commit;
