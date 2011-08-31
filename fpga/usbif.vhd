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
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PWM is
  port (
   clk : in std_logic;
   PWM_in : in std_logic_vector (7 downto 0) := "00000000";
   PWM_out : out std_logic
  );
end PWM;

architecture PWM_arch of PWM is
  signal  PWM_Accumulator : signed(8 downto 0) := "000000000";
  signal m : signed(8 downto 0);
begin
  process(clk,PWM_in)
  begin		
		
			
    if falling_edge(clk) then      
		case PWM_Accumulator(PWM_Accumulator'high) is
			when '0' =>
				m <= to_signed(127, 9);
			when '1' =>
				m <= to_signed(-127, 9);
			when others => m <= to_signed(0, 9);
		end case;
      PWM_Accumulator  <=  ("0" & PWM_Accumulator(7 downto 0)) + ("0" & signed(PWM_in)) - m;
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
								clk_out1: out std_logic;
                        ctl0 : in std_logic;
                        data_in : in std_logic_vector(7 downto 0);
                        data_out : out std_logic_vector(7 downto 0);
                   --     PWM_out : out std_logic;
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
component sigma_delta_fxp_hdl is
PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        clk_enable                        :   IN    std_logic;
        In1                               :   IN    std_logic_vector(7 DOWNTO 0);  -- int8
        ce_out                            :   OUT   std_logic;
        Out1                              :   OUT   std_logic
        );
end component;

signal PWM_in : std_logic_vector(7 downto 0) := "00000000";
signal c : std_logic_vector(7 downto 0) := "00000000";
signal c1 : std_logic_vector(9 downto 0) := "0000000000";
signal reset: std_logic :='0';
signal clk_enable: std_logic := '1';
signal ce_out : std_logic;
signal rstate : std_logic:='0';
begin
clk_out <= clk;
clk_out1 <= clk;
--data_out <= "11111111";
--PWM1:PWM
        --port map(clk=>clk, PWM_in=>PWM_in, PWM_out=>PWM_out);
RdyLogic1:RdyLogic
        port map(clk=>clk, start=>ctl0, rdy=>rdy);
--sigma_delta_fxp1:sigma_delta_fxp_hdl
			--port map(clk=>c(2), reset=>reset, clk_enable=>clk_enable, In1=>PWM_in, ce_out=>ce_out, Out1=>PWM_out);
process(clk)
begin
        if falling_edge(clk) then
			 c<=c+'1';
			 case rstate is
				when '0' => reset <= '1'; c1 <= c1+'1'; if c1(9) = '1' then rstate <= '1'; end if;
				when '1' => reset <= '0';
				when others => reset <= '0'; 
				end case;
			 if ctl0 = '0' then
						data_out <= data_in;
				
						PWM_in <= data_in;
			 end if;
        end if;
end process;
end structure;