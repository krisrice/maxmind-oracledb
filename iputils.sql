create or replace package ip_utils as
  -- Convert an IPv4 to a number
  -- Ex: ip_utils.ip2num('192.168.1.1')
  --    Returns : 3232235777
  function ip2num (p_ip varchar2) return number result_cache;
  -- convert a number back to the ip address
  -- Ex: ip_utils.num2ip(3232235777)
  --    Returns: 192.168.1.1

  function num2ip  (p_num number) return varchar2 result_cache;

  -- returns the highest ip address in a CIDR block
  -- Ex: ip_utils.maxip_in_cidr('192.168.1.1/24')
  --    Returns: 192.168.1.255
  function maxip_in_cidr (p_cidr varchar2) return varchar2 result_cache;

  -- returns the highest ip number in a CIDR block
  -- Ex: ip_utils.maxnum_in_cidr('192.168.1.1/24')
  --    Returns: 3232236031
  function maxnum_in_cidr (p_cidr varchar2) return number result_cache;
 end;
 /

create or replace package body  ip_utils as
   function maxnum_in_cidr (p_cidr varchar2) return number
     result_cache
   as
     l_ret number;
     l_ipnum number;
     l_block number;
   begin
        l_block := substr(p_cidr,instr(p_cidr,'/')+1);
        l_ipnum := ip2num(substr(p_cidr,0,instr(p_cidr,'/')-1));
        l_ret := l_ipnum + power(2,(32-l_block)) -2 ;
        return l_ret;
   end;

  function maxip_in_cidr (p_cidr varchar2) return varchar2
    result_cache
    as
      l_ret varchar2(25);
    begin
      l_ret := num2ip(maxnum_in_cidr(p_cidr) );
      return l_ret;
    end;

  function ip2num (p_ip varchar2) return number
       result_cache
    as
      l_ret number;
    begin
         l_ret := to_number(regexp_substr(p_ip,'[^.]+',1,1))*power(256,3)+
                  to_number(regexp_substr(p_ip,'[^.]+',1,2))*power(256,2)+
                  to_number(regexp_substr(p_ip,'[^.]+',1,3))*256+
                  to_number(regexp_substr(p_ip,'[^.]+',1,4)) ;
       return l_ret;
     end;

  function num2ip  (p_num number) return varchar2
       result_cache
    as
      l_ret varchar2(25);
    begin
      l_ret :=  floor(mod(p_num/power(256,3),256)) ||'.'||
                floor(mod(p_num/power(256,2) ,256)) ||'.'||
                floor(mod(p_num/power(256,1),256)) ||'.'||
                floor(mod(p_num ,256)) ;
      return l_ret;
    end;

 end;
 /
show errors
