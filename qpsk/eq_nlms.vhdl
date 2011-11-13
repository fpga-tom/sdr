library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.config.all;
use work.data_types.all;

entity slicer_not_conj is
  port (
    clk: in std_logic;
    reset: in std_logic;
    din : in cplx;
    dout : out cplx
  );
end entity;

architecture Behavioral of slicer_not_conj is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if reset='1' then
          dout <= zero_c;
        else
          if din.r > zero then
            if din.i > zero then
              dout.r <= one;
              dout.i <= one;
            else
              dout.r <= one;
              dout.i <= one_m;
            end if;
          else
            if din.i > zero then
              dout.r <= one_m;
              dout.i <= one;
            else
              dout.r <= one_m;
              dout.i <= one_m;
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

entity eq_nlms is
  port(
    clk: in std_logic;
    reset: in std_logic;
    dinr: in data;
    dini: in data;
    doutr: out data;
    douti: out data;
    er: out data;
    ei: out data
  );
end eq_nlms;

architecture Behavioral of eq_nlms is
type w_type is array(0 to eq_filter_order-1) of cplx;
type es_type is array(1 to eq_filter_order-1) of cplx;
signal wi,wii,x,ev,del: w_type;
signal s: eq_pilot_t(0 to eq_filter_order-1);
signal es: es_type;
signal msig,u: data;
signal din,dout:cplx;
begin
  din.r<=dinr;
  din.i<=dini;
  doutr<=dout.r;
  douti<=dout.i;
  er<=0.0;
  ei<=0.0;
  process(clk)
    variable tmp : cplx;
    begin
      if rising_edge(clk) then
        if reset='1' then
          x <= (others=>zero_c);
          wi <= (others=>zero_c);
          wii <= (others=>zero_c);
          ev <= (others=>zero_c);
          es <= (others=>zero_c);
          del <= (others=>zero_c);
--          s <= eq_pilots;
        else
          -- input shift register
          x(0) <= din;
          x(1 to eq_filter_order-1) <= x(0 to eq_filter_order-2);
          -- training sequence rotating register
          for i in 0 to eq_filter_order-2 loop
            s(i+1) <= s(i);
          end loop;
          s(0)<=s(eq_filter_order-1);
          -- error computation
          tmp := (s(0)-es(eq_filter_order-1));
          msig <= tmp.r*u;
          -- weight adjustment
          for i in 0 to eq_filter_order-1 loop
            wii(i) <= wi(i)+ x(i)*msig;
            ev(i) <= wi(i)*x(i);
          end loop;
          -- sum
          for i in 1 to eq_filter_order-1 loop
             es(i)<=ev(i-1)+ev(i);
          end loop;
          wii <= del;
          del <= wi;
          dout <= es(eq_filter_order-1);
        end if;
      end if;
    end process;


end Behavioral;

architecture Structural of eq_nlms is
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
component diff is
  port(
    clk: in std_logic;
    reset: in std_logic;
    din1: in cplx;
    din2: in cplx;
    dout: out cplx
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
component slicer_not_conj is
  port (
    clk: in std_logic;
    reset: in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
component delay12 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
component delay13 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
type d_type is array(0 to eq_filter_order-1) of cplx;
type s_type is array(0 to eq_filter_order-1) of cplx;
type m_type is array(0 to eq_filter_order+3) of cplx;
type s1_type is array(0 to eq_filter_order+4) of cplx;

type del_sum_type is array(0 to eq_filter_order-1) of d_type;
type del_mul_type is array(0 to eq_filter_order-1) of m_type;
type del_sum_type1 is array(0 to eq_filter_order-1) of s1_type;
signal del, del8, del81: d_type;
signal del_sum : del_sum_type;
signal del_mul : del_mul_type;
signal del_sum1 : del_sum_type1;
signal s1sig,disig, dosig,s2sig,s3sig : s_type;
signal s: eq_pilot_t(0 to eq_filter_order-1);
signal esig,msig,esig_conj: cplx;
signal u: cplx:=emu;
signal din,dout:cplx;
signal sl_out,s3sig_delayed : cplx;
begin
  din.r<=dinr;
  din.i<=dini;
  doutr<=dout.r;
  douti<=dout.i;
  del(0)<=din;
  s3sig(0)<=s2sig(0);
  dout<=s3sig(eq_filter_order-1);
  sl1: slicer_not_conj
    port map(clk=>clk,reset=>reset,din=>s3sig(eq_filter_order-1),dout=>sl_out);
  del_sum(0)(0)<=s2sig(0);
  del_sum(1)(0)<=s2sig(1);
  
--  ds1: delay
--    port map(clk=>clk,reset=>reset,din=>s2sig(2),dout=>del_sum(2));
--  ds2: delay2
--    port map(clk=>clk,reset=>reset,din=>s2sig(3),dout=>del_sum(3));
--  ds3: delay3
--    port map(clk=>clk,reset=>reset,din=>s2sig(4),dout=>del_sum(4));
--  ds4: delay4
--    port map(clk=>clk,reset=>reset,din=>s2sig(5),dout=>del_sum(5));  
--  ds5: delay5
--    port map(clk=>clk,reset=>reset,din=>s2sig(6),dout=>del_sum(6));    
--  ds6: delay6
--    port map(clk=>clk,reset=>reset,din=>s2sig(7),dout=>del_sum(7));    
    
  a: for i in 2 to eq_filter_order - 1 generate
    process(clk)
      begin
        if rising_edge(clk) then
          if reset='1' then
            del_sum(i)<=(others=>zero_c);
          else
            del_sum(i)(0 to eq_filter_order-2)<=del_sum(i)(1 to eq_filter_order-1);
            del_sum(i)(i-2)<=s2sig(i);
          end if;
        end if;
      end process;
  end generate;
  
  b: for i in 0 to eq_filter_order - 1 generate
    process(clk)
      begin
        if rising_edge(clk) then
          if reset='1' then
            del_mul(i)<=(others=>zero_c);
            del_sum1(i)<=(others=>zero_c);
          else
            del_mul(i)(0 to eq_filter_order+2)<=del_mul(i)(1 to eq_filter_order+3);
            del_mul(i)(eq_filter_order+3)<=del(i);
            
            del_sum1(i)(0 to eq_filter_order+3)<=del_sum1(i)(1 to eq_filter_order+4);
            del_sum1(i)(eq_filter_order+4)<=dosig(i);
          end if;
        end if;
      end process;
      del8(i)<=del_mul(i)(0);
      del81(i)<=del_sum1(i)(0);
  end generate;

    
  e: for i in 0 to eq_filter_order-1 generate
--    d8: delay12
--      port map(clk=>clk,reset=>reset,din=>del(i),dout=>del8(i));
--    d81: delay13
--      port map(clk=>clk,reset=>reset,din=>dosig(i),dout=>del81(i));
    dg: if i > 0 generate
      d: delay
        port map(clk=>clk,reset=>reset,din=>del(i-1),dout=>del(i));
    end generate;
    m1: mul
      port map(clk=>clk,reset=>reset,din1=>del8(i),din2=>msig,dout=>s1sig(i));
    s1: sum
      port map(clk=>clk,reset=>reset,din1=>s1sig(i),din2=>del81(i),dout=>disig(i));
    d1: delay
      port map(clk=>clk,reset=>reset,din=>disig(i),dout=>dosig(i));
    m2: mul_conj
      port map(clk=>clk,reset=>reset,din1=>del(i),din2=>dosig(i),dout=>s2sig(i));
    sg: if i > 0 generate
      s2: sum
        port map(clk=>clk,reset=>reset,din1=>del_sum(i)(0),din2=>s3sig(i-1),dout=>s3sig(i));
    end generate;
--    pg: if i = 0 generate
--      dp: delay_i
--        port map(clk=>clk,reset=>reset,init=>eq_pilots(i),din=>s(eq_filter_order-1),dout=>s(i));
--    end generate;
--    pg1: if i > 0 generate
--      dp: delay_i
--        port map(clk=>clk,reset=>reset,init=>eq_pilots(i),din=>s(i-1),dout=>s(i));
--    end generate;
  end generate;
  
  d2: delay
    port map(clk=>clk,reset=>reset,din=>s3sig(eq_filter_order-1),dout=>s3sig_delayed);
  s2: diff
    port map(clk=>clk,reset=>reset,din1=>sl_out,din2=>s3sig_delayed,dout=>esig);
  c2: conj
    port map(clk=>clk,reset=>reset,din=>esig,dout=>esig_conj);
  m3: mul
    port map(clk=>clk,reset=>reset,din1=>u,din2=>esig_conj,dout=>msig);
  er<=esig.r;
  ei<=esig.i;
end Structural;