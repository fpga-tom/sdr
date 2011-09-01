----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:45:37 08/31/2011 
-- Design Name: 
-- Module Name:    top - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux is
port(
	din : in std_logic_vector(7 downto 0);
	din1 : in std_logic_vector(7 downto 0);
	dout : out std_logic_vector(7 downto 0);
	sel : in std_logic;
	clk: in std_logic
	);
end entity;

architecture beh of mux is
begin
process(clk)
begin
	if rising_edge(clk) then
		if sel = '1' then
			dout <= din1;
		else
			dout <= din;
		end if;
	end if;
end process;
end architecture;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity top is
        port( clk: in std_logic;
			clk_out: out std_logic;
			ctl0 : in std_logic;
			rdy : out std_logic;
			clk_out1: out std_logic;
			data_in : in std_logic_vector(7 downto 0);
         data_out : out std_logic_vector(7 downto 0)
        );
end top;

architecture Behavioral of top is

component dds_compiler_v4_0 IS
	port (
	clk: in std_logic;
	cosine: out std_logic_vector(7 downto 0);
	phase_out: out std_logic_vector(13 downto 0));
END component;
component mux is 
port(
	din : in std_logic_vector(7 downto 0);
	din1 : in std_logic_vector(7 downto 0);
	dout : out std_logic_vector(7 downto 0);
	sel : in std_logic;
	clk: in std_logic
	);
end component;
COMPONENT multiplier
	PORT(
		clk : IN std_logic;
		a : IN std_logic_vector(7 downto 0);
		b : IN std_logic_vector(7 downto 0);          
		p : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	COMPONENT cic_compiler_v2_0
	PORT(
		din : IN std_logic_vector(7 downto 0);
		clk : IN std_logic;          
		dout : OUT std_logic_vector(7 downto 0);
		rdy : OUT std_logic;
		rfd : OUT std_logic
		);
	END COMPONENT;
	
signal phase_out : std_logic_vector(13 downto 0);
signal cos : std_logic_vector(7 downto 0) := "00000000";
signal c : std_logic_vector(12 downto 0) :="0000000000000";
signal din: std_logic_vector(7 downto 0) := "00000000";
signal cic_out: std_logic_vector(7 downto 0) := "00000000";
signal pout : std_logic_vector(15 downto 0) := X"0000";
signal r : std_logic := '0';
signal rr : std_logic := '0';
begin
clk_out1 <= clk;
clk_out <= clk;
dds1:dds_compiler_v4_0
	port map(clk=>clk, cosine=>cos, phase_out=>phase_out);
--mux1: mux
	--port map(clk=>clk, din=>cos, din1=>"00000000", sel=>c(12), dout=>data_out);
data_out <= pout(13 downto 6);
	Inst_multiplier: multiplier PORT MAP(
		clk => clk,
		a => cos,
		b => cic_out,
		p => pout
	);
	
	Inst_cic_compiler_v2_0: cic_compiler_v2_0 PORT MAP(
		din => din,
		clk => clk,
		dout => cic_out,
		rdy => r,
		rfd => rr
	);
	
rdy <= not rr;
process(clk)
begin
	if rising_edge(clk) then
		--c<=c+'1';
		if ctl0 = '0' then
			din <= data_in;
		end if;
	end if;
end process;

end Behavioral;

