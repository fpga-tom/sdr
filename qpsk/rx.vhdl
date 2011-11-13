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
use work.data_types.all;
use work.config.all;

entity adder is
  port(
    clk : in std_logic;
    reset : in std_logic;
    p: in data;
    c : out std_logic;
    frac : out data
    );
end entity adder;

architecture Behavioral of adder is
signal phase,acc : real := 0.0;
signal cc : std_logic;
begin
  process(clk)
    begin
      case reset is
      when '1' => c <=clk;
      when '0' => c <=cc;
      when  others => c <= cc;
      end case;
    if rising_edge(clk) then
      if reset = '1' then
        acc<=0.0;
        phase<=1.0;
        cc<='0';
        frac<=0.0;
      else
--        phase <= phase + p;
        acc<=acc + 1.0;--(1.0/(1.0+p));
        if integer(acc) = integer(Up*(1.0+p))-1 then
          cc <= '1';
          acc<=Up*p;
        else
          cc <= '0';
        end if;
      end if;
    end if;
  end process;
end Behavioral;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity sampler is
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
    );
end entity;

architecture Behavioral of sampler is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          dout.r <= 0.0;
          dout.i <= 0.0;
        else
          dout <= din;
        end if;
      end if;
    end process;
end Behavioral;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity interpolator is
  port(
    clk : in std_logic;
    reset : in std_logic;
    y1 : in cplx;
    y2 : in cplx;
    frac: in data;
    dout : out cplx
    );
end interpolator;

architecture Behavioral of interpolator is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          dout <= (r=>0.0, i=>0.0);
        else
          dout <= y1;--y2*frac + y1*(1.0-frac);
        end if;
      end if;
  end process;
end Behavioral;



library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay_i is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    init : in cplx;
    din : in cplx;
    dout : out cplx
  );
end delay_i;

architecture Behavioral of delay_i is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          dout <= init;
        else
          dout <= din;
        end if;
      end if;
    end process;
end Behavioral;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay2 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay2;

architecture Structural of delay2 is
component delay is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
signal b : cplx;
begin
  d1: delay
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay
    port map(clk=>clk,reset=>reset,din=>b,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay3 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay3;

architecture Structural of delay3 is
component delay2 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
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
signal b : cplx;
begin
  d1: delay
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay2
    port map(clk=>clk,reset=>reset,din=>b,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay4 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay4;

architecture Structural of delay4 is
component delay2 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
signal b : cplx;
begin
  d1: delay2
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay2
    port map(clk=>clk,reset=>reset,din=>b,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay5 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay5;

architecture Structural of delay5 is
component delay is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
component delay4 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
signal b : cplx;
begin
  d1: delay
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay4
    port map(clk=>clk,reset=>reset,din=>b,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay6 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay6;

architecture Structural of delay6 is
component delay is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
component delay5 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
signal b : cplx;
begin
  d1: delay
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay5
    port map(clk=>clk,reset=>reset,din=>b,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay8 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay8;

architecture Structural of delay8 is
component delay4 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
signal b : cplx;
begin
  d1: delay4
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay4
    port map(clk=>clk,reset=>reset,din=>b,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay9 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay9;

architecture Structural of delay9 is
component delay8 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
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
signal b : cplx;
begin
  d1: delay
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay8
    port map(clk=>clk,reset=>reset,din=>b,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay10 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay10;

architecture Structural of delay10 is
component delay5 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
signal b : cplx;
begin
  d1: delay5
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay5
    port map(clk=>clk,reset=>reset,din=>b,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay12 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay12;

architecture Structural of delay12 is
component delay10 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
component delay2 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
signal b : cplx;
begin
  d1: delay2
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay10
    port map(clk=>clk,reset=>reset,din=>b,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay13 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay13;

architecture Structural of delay13 is
component delay12 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
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
signal b : cplx;
begin
  d1: delay
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay12
    port map(clk=>clk,reset=>reset,din=>b,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay20 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay20;

architecture Structural of delay20 is
component delay10 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
signal b : cplx;
begin
  d1: delay10
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay10
    port map(clk=>clk,reset=>reset,din=>b,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay50 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay50;

architecture Structural of delay50 is
component delay10 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
component delay20 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
signal b,b1 : cplx;
begin
  d1: delay20
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay20
    port map(clk=>clk,reset=>reset,din=>b,dout=>b1);
  d3: delay10
    port map(clk=>clk,reset=>reset,din=>b1,dout=>dout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay100 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end delay100;

architecture Structural of delay100 is
component delay50 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
signal b: cplx;
begin
  d1: delay50
    port map(clk=>clk,reset=>reset,din=>din,dout=>b);
  d2: delay50
    port map(clk=>clk,reset=>reset,din=>b,dout=>dout);
end Structural;



library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity delay_bit is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in std_logic;
    dout : out std_logic
  );
end delay_bit;

architecture Behavioral of delay_bit is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          dout <= '0';
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

entity muller_slicer is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    yout : out cplx;
    cout : out cplx
    );
end muller_slicer;

architecture Structural of muller_slicer is
component conj is
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
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
component slicer is
  port (
    clk: in std_logic;
    reset: in std_logic;
    din : in cplx;
    dout : out cplx
  );
end component;
--signal so : cplx;
begin
  s1: slicer
    port map(clk=>clk,reset=>reset,din=>din,dout=>cout);
--  c1: conj
--    port map(clk=>clk,reset=>reset,din=>so,dout=>cout);
  d1: delay
    port map(clk=>clk,reset=>reset,din=>din,dout=>yout);
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;
use work.config.all;

entity muller is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din1 : in cplx;
    din2 : in cplx; -- delayed input
    dout : out cplx;
    sa_clk : out std_logic; -- sampler clock
    frac : out data; -- interpolator fractional part
    t: out data
    );
end entity;

architecture Structural of muller is
component adder is
  port(
    clk : in std_logic;
    reset : in std_logic;
    p: in data;
    c : out std_logic;
    frac : out data
    );
end component;
component muller_slicer is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    yout : out cplx;
    cout : out cplx
    );
end component;
signal tau : data := 0.0;
signal ipd1,ipd2,cnj1,cnj2 : cplx;
signal lclk : std_logic:='0';
begin
  sa_clk<=lclk;
  dout<=cnj1;
  ms1: muller_slicer
    port map(clk=>clk,reset=>reset,din=>din1,yout=>ipd1,cout=>cnj1);
  ms2: muller_slicer
    port map(clk=>clk,reset=>reset,din=>din2,yout=>ipd2,cout=>cnj2);
  a1: adder
    port map(clk=>clk,reset=>reset,c=>lclk,p=>tau,frac=>frac);
  process(lclk)
    variable tmp : cplx :=(r=>0.0,i=>0.0);
    begin
      if falling_edge(lclk) then
        if reset='1' then
          tau<=0.0;
        else
          tmp:=(ipd1*cnj2)-(ipd2*cnj1);
          tau<=tau+mu*tmp.r;
          t<=tau;
        end if;
     end if;
   end process;
end Structural;

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

entity rx is
  port(
    clk: in std_logic;
    reset: in std_logic;
    dinr: in data;
    dini: in data;
    doutr: out data;
    douti: out data
    );
end rx;

architecture Structural of rx is
component muller is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din1 : in cplx; 
    din2 : in cplx; -- delayed input
    dout : out cplx;
    sa_clk : out std_logic; -- sampler clock
    frac : out data; -- interpolator fractional part
    t: out data
    );
end component;
component delay100 is 
  port(
    clk : in std_logic;
    reset : in std_logic;
    din : in cplx;
    dout : out cplx
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
signal d1,d2,d3,dint : cplx;
signal frac: data;
signal sa_clk: std_logic;
begin
--  doutr<=dout.r;
--  douti<=dout.i;
  dint.r<=dinr;
  dint.i<=dini;
  
  dl1: delay
    port map(clk=>sa_clk,reset=>reset,din=>dint,dout=>d1);
--  dl2: delay100
--    port map(clk=>clk,reset=>reset,din=>dint,dout=>d2);
  dl3: delay
    port map(clk=>sa_clk,reset=>reset,din=>d1,dout=>d3);
  m1: muller
    port map(clk=>clk,reset=>reset,sa_clk=>sa_clk,din1=>d1,din2=>d3,frac=>frac, dout.r=>doutr, dout.i=>douti);

end Structural;

--library IEEE;
--use IEEE.STD_LOGIC_1164.all;
--use work.data_types.all;

--entity tb is 
--end entity;

--architecture dut of tb is
--component slicer is
--  port (
--    clk: in std_logic;
--    reset: in std_logic;
--    din : in cplx;
--    dout : out cplx
--  );
--end component;
--signal clk : std_logic := '0';
--signal reset : std_logic:= '1';
--signal din, dout : cplx;
--begin
--  clk <= not clk after 10ns;
--  reset <= '0' after 40ns;
--  din.i <= X"FF" after 50ns, X"22" after 70ns, X"FF" after 90ns, X"22" after 110ns;
--  din.r <= X"FF" after 50ns, X"FF" after 70ns, X"22" after 90ns, X"22" after 110ns;
--  s1: slicer
--    port map(clk=>clk, reset=>reset, din=>din, dout=>dout);
--end dut;