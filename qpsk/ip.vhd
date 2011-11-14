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

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.config.all;
use work.data_types.all;

entity slicer is
  port (
    clk: in std_logic;
    reset: in std_logic;
    din : in cplx;
    dout : out cplx
  );
end entity;

-- architecture Behavioral of slicer is
-- begin
--   process(clk)
--     begin
--       if rising_edge(clk) then
--         if reset = '1' then
--           dout.r <= (others=>'0');
--           dout.i <= (others=>'0');
--         else
--           case din.r(din.r'left) is
--           when '1' => dout.r <= (din.r'left downto frac_part=>'1', others=>'0');
--           when '0' => dout.r <= (frac_part=>'1', others=>'0');
--           when others=> dout.r <= (others=>'0');
--           end case;
          
--           case din.i(din.i'left) is
--           when '1' => dout.i <= (din.i'left downto frac_part=>'1', others=>'0');
--           when '0' => dout.i <= (frac_part=>'1', others=>'0');
--           when others=> dout.i <= (others=>'0');
--           end case;
--         end if;
--        end if;
--     end process;
-- end Behavioral;

architecture Behavioral of slicer is
begin
  -- this slicer also conjugates
  process(clk)
    begin
      if rising_edge(clk) then
        if reset='1' then
          dout<=zero_c;
        else
          if din.r > zero then
            if din.i > zero then
              dout.r <= one;
              dout.i <= one_m;
            else
              dout.r <= one;
              dout.i <= one;
            end if;
          else
            if din.i > zero then
              dout.r <= one_m;
              dout.i <= one_m;
            else
              dout.r <= one_m;
              dout.i <= one;
            end if;
         end if;
      end if;
    end if;
    end process;
  end Behavioral;
  

library IEEE;
use IEEE.std_logic_1164.all;
use work.config.all;
use work.data_types.all;

entity tree_adder is
  generic(log2_order: positive);
  port(
    clk: in std_logic;
    reset: in std_logic;
    din: in cplx_vector(0 to 2**log2_order-1);
    dout: out cplx
    );
end entity;

architecture Structural of tree_adder is
component sum is
  port(
    clk: in std_logic;
    reset: in std_logic;
    din1: in cplx;
    din2: in cplx;
    dout: out cplx
    );
end component;
constant order: positive := 2**log2_order;
type d_type is array(0 to order-1) of cplx;
type tree_type is array(0 to log2_order) of d_type;
signal tree: tree_type;
begin
    c: for i in 0 to log2_order-1 generate
    cc: for j in 0 to 2**i-1 generate
      st: sum
        port map(clk=>clk,reset=>reset,din1=>tree(i+1)(2*j),din2=>tree(i+1)(2*j+1),dout=>tree(i)(j));
    end generate;
  end generate;
  
  d: for i in 0 to 2**log2_order-1 generate
    tree(log2_order)(i)<=din(i);
  end generate;
  dout <= tree(0)(0);
end Structural;
    


library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;
use work.config.all;

entity adaptive_fir is
  generic(log2_order, shift: positive);
  port(
    clk: in std_logic;
    reset: in std_logic;
    din: in cplx;
    dout: out cplx;
    epsilon: in cplx
    );
end adaptive_fir;

architecture Structural of adaptive_fir is
component delay is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
component mul is
  port(
    clk: in std_logic;
    reset: in std_logic;
    din1: in cplx;
    din2: in cplx;
    dout: out cplx
    );
end component;
component mul_conj is
  port(
    clk: in std_logic;
    reset: in std_logic;
    din1: in cplx;
    din2: in cplx;
    dout: out cplx
    );
end component;
component sum is
  port(
    clk: in std_logic;
    reset: in std_logic;
    din1: in cplx;
    din2: in cplx;
    dout: out cplx
    );
end component;
component tree_adder is
  generic(log2_order: positive);
  port(
    clk: in std_logic;
    reset: in std_logic;
    din: in cplx_vector(0 to 2**log2_order-1);
    dout: out cplx
    );
end component;

constant order: positive := 2**log2_order;
type d_type is array(0 to order-1) of cplx;
type s_type is array(0 to order-1) of cplx;
type m_type is array(0 to log2_order+shift) of cplx;
type s1_type is array(0 to log2_order+shift+1) of cplx;
type del_sum_type is array(0 to order-1) of d_type;
type del_mul_type is array(0 to order-1) of m_type;
type del_sum_type1 is array(0 to order-1) of s1_type;
--type tree_type is array(0 to log2_order) of d_type;
signal del, del8, del81: d_type;
signal del_sum : del_sum_type;
signal del_mul : del_mul_type;
signal del_sum1 : del_sum_type1;
signal s1sig,disig, dosig: s_type;
signal s2sig: cplx_vector(0 to order-1);
--signal tree: tree_type;

begin
  del(0)<=din;
  --dout<=tree(0)(0);
  
  b: for i in 0 to order - 1 generate
    process(clk)
      begin
        if rising_edge(clk) then
          if reset='1' then
            del_mul(i)<=(others=>zero_c);
            del_sum1(i)<=(others=>zero_c);
          else
            del_mul(i)(0 to del_mul(i)'high-1)<=del_mul(i)(1 to del_mul(i)'high);
            del_mul(i)(del_mul(i)'high)<=del(i);
            
            del_sum1(i)(0 to del_sum1(i)'high-1)<=del_sum1(i)(1 to del_sum1(i)'high);
            del_sum1(i)(del_sum1(i)'high)<=dosig(i);
          end if;
        end if;
      end process;
      del8(i)<=del_mul(i)(0);
      del81(i)<=del_sum1(i)(0);
  end generate;
  
  ta1: tree_adder
    generic map(log2_order=>log2_order)
    port map(clk=>clk,reset=>reset,din=>s2sig,dout=>dout);

    
  e: for i in 0 to order-1 generate
    dg: if i > 0 generate
      d: delay
        port map(clk=>clk,reset=>reset,din=>del(i-1),dout=>del(i));
    end generate;
    m1: mul
      port map(clk=>clk,reset=>reset,din1=>del8(i),din2=>epsilon,dout=>s1sig(i));
    s1: sum
      port map(clk=>clk,reset=>reset,din1=>s1sig(i),din2=>del81(i),dout=>disig(i));
    d1: delay
      port map(clk=>clk,reset=>reset,din=>disig(i),dout=>dosig(i));
    m2: mul_conj
      port map(clk=>clk,reset=>reset,din1=>del(i),din2=>dosig(i),dout=>s2sig(i));
  end generate;
end Structural;


library IEEE;
use IEEE.std_logic_1164.all;
use work.config.all;
use work.data_types.all;

entity fir is
  generic(log2_order: positive);
  port(
    clk: in std_logic;
    reset: in std_logic;
    din: in cplx;
    dout: out cplx;
    w: in cplx_vector(0 to 2**log2_order)
    );
end fir;

architecture Structural of fir is
component delay is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
component mul is
  port(
    clk: in std_logic;
    reset: in std_logic;
    din1: in cplx;
    din2: in cplx;
    dout: out cplx
    );
end component;
component tree_adder is
  generic(log2_order: positive);
  port(
    clk: in std_logic;
    reset: in std_logic;
    din: in cplx_vector(0 to 2**log2_order-1);
    dout: out cplx
    );
end component;
constant order: positive:=2**log2_order;
signal del,m: cplx_vector(0 to order-1);
begin
  del(0)<=din;
  f: for i in 0 to order-1 generate
    dg: if i > 0 generate
      d: delay
        port map(clk=>clk,reset=>reset,din=>del(i-1),dout=>del(i));
    end generate;
    s: mul
      port map(clk=>clk,reset=>reset,din1=>del(i),din2=>w(i),dout=>m(i));
  end generate;
  a: tree_adder
    generic map(log2_order=>log2_order)
    port map(clk=>clk,reset=>reset,din=>m,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;
use work.config.all;

entity cross_correlation is
  generic(log2_order: positive);
  port(
    clk: in std_logic;
    reset: in std_logic;
    din: in cplx;
    dout: out cplx
    );
end cross_correlation;

architecture Structural of cross_correlation is
component fir is
  generic(log2_order: positive);
  port(
    clk: in std_logic;
    reset: in std_logic;
    din: in cplx;
    dout: out cplx;
    w: in cplx_vector(0 to 2**log2_order)
    );
end component;
component conj is
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
constant order: positive:=2**log2_order;
signal del: cplx_vector(0 to order-1);
signal fi: cplx;
begin
  del(0)<=din;
  c: conj
    port map(clk=>clk,reset=>reset,din=>del(del'high),dout=>fi);
  f1: fir
    generic map(log2_order=>log2_order)
    port map(clk=>clk,reset=>reset,din=>fi,w=>del,dout=>dout);
  
end architecture;