library IEEE;
use IEEE.std_logic_1164.all;
use work.config.all;
use work.data_types.all;

entity acq is 
  generic(log2_order: positive);
  port(
    clk: in std_logic;
    reset: in std_logic;
    din: in cplx;
    dout: out cplx
    );
end acq;

architecture Structural of acq is
signal a,b: real;
begin
  dout.r<=a/b;
end Structural;