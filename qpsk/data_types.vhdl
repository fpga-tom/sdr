library IEEE;
use IEEE.STD_LOGIC_1164.all;

package data_types is
  -- subtype data is std_logic_vector(word_length-1 downto 0);
  subtype data is real;
  type cplx is 
    record
      r : data;
      i : data;
  end record;
  type eq_pilot_t is array(natural range<>) of cplx;
  function "*" (a1 : cplx; a2: cplx) return cplx;
  function "*" (a1 : cplx; a2: data) return cplx;
  function "+" (a1 : cplx; a2: cplx) return cplx;
  function "-" (a1 : cplx; a2: cplx) return cplx;
  function conj(a1 : cplx) return cplx;
end data_types;

package body data_types is
  function conj(a1 : cplx) return cplx is
    variable ret: cplx;
  begin
    ret.r:=a1.r;
    ret.i:=-a1.i;
    return ret;
  end conj;
  function "*" (a1 : cplx; a2: cplx) return cplx is
    variable ret : cplx := (r=>0.0, i=>0.0);
  begin
    ret.r := (a1.r*a2.r) - (a1.i*a2.i);
    ret.i := (a1.r*a2.i) + (a1.i*a2.r);
    return ret;
  end "*";
  function "*" (a1 : cplx; a2: data) return cplx is
    variable ret : cplx := (r=>0.0, i=>0.0);
  begin
    ret.r := a1.r*a2;
    ret.i := a1.i*a2;
    return ret;
  end "*";
  function "+" (a1 : cplx; a2: cplx) return cplx is
    variable ret : cplx := (r=>0.0, i=>0.0);
  begin
    ret.r := a1.r+a2.r;
    ret.i := a1.i+a2.i;
    return ret;
  end "+";
  function "-" (a1 : cplx; a2: cplx) return cplx is
    variable ret : cplx := (r=>0.0, i=>0.0);
  begin
    ret.r := a1.r-a2.r;
    ret.i := a1.i-a2.i;
    return ret;
  end "-";
end data_types;