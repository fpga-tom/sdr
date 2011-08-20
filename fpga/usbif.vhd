----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:01:48 07/19/2011 
-- Design Name: 
-- Module Name:    blinky - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PWM is
  port (
   clk : in std_logic;
   PWM_in : in std_logic_vector (7 downto 0) := "00000000";
   PWM_out : out std_logic
  );
end PWM;

architecture PWM_arch of PWM is
  signal  PWM_Accumulator : std_logic_vector(8 downto 0) := "000000000";
begin
  process(clk,PWM_in)
  begin
    if rising_edge(clk) then      
      PWM_Accumulator  <=  ("0" & PWM_Accumulator(7 downto 0)) + ("0" & PWM_in);
    end if;
  end process;

  PWM_out <= PWM_Accumulator(8);
end PWM_arch;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RdyLogic is
        port( clk : in std_logic;
                        start : in std_logic;
                        rdy : out std_logic
                );
end entity;

architecture behavior of RdyLogic is
signal counter : std_logic_vector(10 downto 0) := "00000000000";
signal state : std_logic := '0';
begin
process(clk)
begin
        if rising_edge(clk) then
                case state is
                        when '0' => if start='0' then
                                                                state <= '1';
                                                                rdy <= '1';
                                                        end if;
                        when '1' => if counter(9) = '1' then
                                                                state <= '0';
                                                                counter <= "00000000000";
                                                                rdy <= '0';
                                                        else
                                                                counter <= counter + '1';
                                                        end if;
                        when others => counter <= "00000000000";
                end case;
        end if;
end process;
end behavior;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity usbif is
        port( clk: in std_logic;
                        clk_out: out std_logic;
                        ctl0 : in std_logic;
                        data_in : in std_logic_vector(7 downto 0);
                        data_out : out std_logic_vector(7 downto 0);
                        PWM_out : out std_logic;
                        rdy : out std_logic
                );
end usbif;

architecture structure of usbif is
component PWM is
        port(
                clk : in std_logic;
                PWM_in : in std_logic_vector (7 downto 0) := "00000000";
                PWM_out : out std_logic
);
end component;
component RdyLogic is
        port (
                        clk : in std_logic;
                        start : in std_logic;
                        rdy : out std_logic
        );
end component;
signal PWM_in : std_logic_vector(7 downto 0) := "00000000";
signal c : std_logic_vector(6 downto 0) := "0000000";
begin
clk_out <= clk;
PWM1:PWM
        port map(clk=>c(6), PWM_in=>PWM_in, PWM_out=>PWM_out);
RdyLogic1:RdyLogic
        port map(clk=>clk, start=>ctl0, rdy=>rdy);
process(clk)
begin
        if falling_edge(clk) then
			 c<=c+'1';
			 if ctl0 = '0' then
						data_out <= data_in;
						PWM_in <= data_in;
			 end if;
        end if;
end process;
end structure;