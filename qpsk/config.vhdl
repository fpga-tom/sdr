library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.data_types.all;

package config is
  constant word_length: integer;
  constant frac_part: integer;
  constant mu: real;
  constant emu: cplx;
  constant Up: real;
  constant eq_filter_order: natural;
  constant zero: data;
  constant zero_c: cplx;
  constant one: data;
  constant one_m: data;
--  constant eq_pilots : eq_pilot_t;
end config;

package body config is
  constant word_length: integer:= 8;
  constant frac_part: integer:= 4;
  constant mu:real:=0.01;
  constant emu: cplx:= (r=>2*0.01,i=>0.0);
  constant Up: real:= 100.0;
  constant zero: data := 0.0;
  constant zero_c: cplx:= (r=>zero,i=>zero);
  constant one: data:= 1.0;
  constant one_m: data:= -1.0;
  constant eq_filter_order: natural:= 31;
--  constant eq_pilots : eq_pilot_t(0 to eq_filter_order-1):= (
--      (r=>1.0,i=>1.0),(r=>-1.0,i=>1.0),(r=>1.0,i=>-1.0),(r=>-1.0,i=>-1.0)
--      (r=>1.0,i=>1.0),(r=>-1.0,i=>1.0),(r=>1.0,i=>-1.0),(r=>-1.0,i=>-1.0)
--      (r=>1.0,i=>1.0),(r=>-1.0,i=>1.0),(r=>1.0,i=>-1.0),(r=>-1.0,i=>-1.0),
--      (r=>1.0,i=>1.0),(r=>-1.0,i=>1.0),(r=>1.0,i=>-1.0),(r=>-1.0,i=>-1.0),
--      (r=>1.0,i=>1.0),(r=>-1.0,i=>1.0),(r=>1.0,i=>-1.0),(r=>-1.0,i=>-1.0),
--      (r=>1.0,i=>1.0),(r=>-1.0,i=>1.0),(r=>1.0,i=>-1.0),(r=>-1.0,i=>-1.0),
--      (r=>1.0,i=>1.0),(r=>-1.0,i=>1.0),(r=>1.0,i=>-1.0),(r=>-1.0,i=>-1.0),
--      (r=>1.0,i=>1.0),(r=>-1.0,i=>1.0),(r=>1.0,i=>-1.0),(r=>-1.0,i=>-1.0)                                              
--);
end config;
