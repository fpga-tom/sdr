library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;
use work.config.all;

entity delay is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay;

architecture Behavioral of delay is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          dout <= zero_c;
        else
          dout <= din;
        end if;
      end if;
    end process;
end Behavioral;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;
use work.config.all;

entity conj is
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end conj;

architecture Behavioral of conj is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          dout <= zero_c;
        else
          dout <= (r=>din.r,i=>-din.i);
        end if;
     end if;
    end process;
end Behavioral;

library IEEE;
use IEEE.std_logic_1164.all;
use work.config.all;
use work.data_types.all;

entity sum is
  port(
    clk: in std_logic;
    reset: in std_logic;
    din1: in cplx;
    din2: in cplx;
    dout: out cplx
    );
end sum;

architecture Behavioral of sum is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if reset='1' then
          dout <= zero_c;
        else
          dout <= din1+din2;
        end if;
      end if;
    end process;
end Behavioral;

library IEEE;
use IEEE.std_logic_1164.all;
use work.config.all;
use work.data_types.all;

entity diff is
  port(
    clk: in std_logic;
    reset: in std_logic;
    din1: in cplx;
    din2: in cplx;
    dout: out cplx
    );
end diff;

architecture Behavioral of diff is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if reset='1' then
          dout <= zero_c;
        else
          dout <= din1-din2;
        end if;
      end if;
    end process;
end Behavioral;

library IEEE;
use IEEE.std_logic_1164.all;
use work.config.all;
use work.data_types.all;

entity mul is
  port(
    clk: in std_logic;
    reset: in std_logic;
    din1: in cplx;
    din2: in cplx;
    dout: out cplx
    );
end mul;

architecture Behavioral of mul is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if reset='1' then
          dout <= zero_c;
        else
          dout <= din1*din2;
        end if;
      end if;
    end process;
end Behavioral;

library IEEE;
use IEEE.std_logic_1164.all;
use work.config.all;
use work.data_types.all;

entity mul_conj is
  port(
    clk: in std_logic;
    reset: in std_logic;
    din1: in cplx;
    din2: in cplx;
    dout: out cplx
    );
end mul_conj;

architecture Behavioral of mul_conj is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if reset='1' then
          dout <= zero_c;
        else
          dout <= din1*conj(din2);
        end if;
      end if;
    end process;
end Behavioral;
