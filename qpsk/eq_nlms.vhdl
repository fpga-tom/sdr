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
signal wi,x,del: w_type;
signal s: eq_pilot_t(0 to eq_filter_order-1);
signal es:cplx;
signal msig,u: data;
signal din,dout:cplx;
begin
  din.r<=dinr;
  din.i<=dini;
  doutr<=dout.r;
  douti<=dout.i;
  process(clk)
    variable tmp : cplx;
    variable ev,wii: w_type;
    begin
      if rising_edge(clk) then
        if reset='1' then
          x <= (others=>zero_c);
          wi <= (others=>zero_c);
          wii := (others=>zero_c);
          ev := (others=>zero_c);
          es <= zero_c;
          del <= (others=>zero_c);
          er<=zero;
          ei<=zero;
--          s <= eq_pilots;
        else
          -- input shift register

          x(1 to eq_filter_order-1) <= x(0 to eq_filter_order-2);
          x(0) <= din;


          -- error computation

          for i in 0 to eq_filter_order-1 loop
              ev(i) := conj(wi(i))*x(i);
          end loop;
          tmp:=zero_c;
          for i in 0 to eq_filter_order-1 loop
            tmp:=tmp+ev(i);
          end loop;
          es<=tmp;
          tmp := (slice(tmp)-tmp);
          er<=tmp.r;
          ei<=tmp.i;
          -- weight adjustment
          for i in 0 to eq_filter_order-1 loop
            wii(i) := wi(i)+ x(i)*conj(tmp)*mu;
          end loop;
          wi <= wii;
          dout <= es;
        end if;
      end if;
    end process;
end Behavioral;


architecture Structural of eq_nlms is
component adaptive_fir is
  generic(log2_order,shift: positive);
  port(
    clk: in std_logic;
    reset: in std_logic;
    din: in cplx;
    dout: out cplx;
    epsilon: in cplx
    );
end component;
component delay is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
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
component mul is
  port(
    clk: in std_logic;
    reset: in std_logic;
    din1: in cplx;
    din2: in cplx;
    dout: out cplx
    );
end component;

signal esig,msig,esig_conj: cplx;
signal u: cplx:=emu;
signal din,dout:cplx;
signal sl_out,s3sig_delayed : cplx;
begin
  din.r<=dinr;
  din.i<=dini;
  doutr<=dout.r;
  douti<=dout.i;
  
  sl1: slicer_not_conj
    port map(clk=>clk,reset=>reset,din=>dout,dout=>sl_out);

  af1: adaptive_fir
    generic map(log2_order=>log2_eq_filter_order,shift=>4)
    port map(clk=>clk,reset=>reset,din=>din,dout=>dout,epsilon=>msig);
  
  d2: delay
    port map(clk=>clk,reset=>reset,din=>dout,dout=>s3sig_delayed);
  s2: diff
    port map(clk=>clk,reset=>reset,din1=>sl_out,din2=>s3sig_delayed,dout=>esig);
  c2: conj
    port map(clk=>clk,reset=>reset,din=>esig,dout=>esig_conj);
  m3: mul
    port map(clk=>clk,reset=>reset,din1=>u,din2=>esig_conj,dout=>msig);
  er<=esig.r;
  ei<=esig.i;
end Structural;