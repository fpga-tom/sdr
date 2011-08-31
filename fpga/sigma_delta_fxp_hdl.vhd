-- -------------------------------------------------------------
-- 
-- File Name: hdlsrc\sigma_delta_fxp_hdl.vhd
-- Created: 2011-08-24 15:40:06
-- 
-- Generated by MATLAB 7.12 and Simulink HDL Coder 2.1
-- 
-- 
-- -------------------------------------------------------------
-- Rate and Clocking Details
-- -------------------------------------------------------------
-- Model base rate: 1e-007
-- Target subsystem base rate: 1e-007
-- 
-- 
-- Clock Enable  Sample Time
-- -------------------------------------------------------------
-- ce_out        1e-007
-- -------------------------------------------------------------
-- 
-- 
-- Output Signal                 Clock Enable  Sample Time
-- -------------------------------------------------------------
-- Out1                          ce_out        1e-007
-- -------------------------------------------------------------
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: sigma_delta_fxp_hdl
-- Source Path: sigma_delta_fxp_hdl
-- Hierarchy Level: 0
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY sigma_delta_fxp_hdl IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        clk_enable                        :   IN    std_logic;
        In1                               :   IN    std_logic_vector(7 DOWNTO 0);  -- int8
        ce_out                            :   OUT   std_logic;
        Out1                              :   OUT   std_logic
        );
END sigma_delta_fxp_hdl;


ARCHITECTURE rtl OF sigma_delta_fxp_hdl IS

  -- Component Declarations
  COMPONENT sigma_delta_fxp_hdl_tc
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          clk_enable                      :   IN    std_logic;
          enb                             :   OUT   std_logic;
          enb_1_1_1                       :   OUT   std_logic;
          enb_1_512_0                     :   OUT   std_logic
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : sigma_delta_fxp_hdl_tc
    USE ENTITY work.sigma_delta_fxp_hdl_tc(rtl);

  -- Signals
  SIGNAL enb_1_512_0                      : std_logic;
  SIGNAL enb                              : std_logic;
  SIGNAL enb_1_1_1                        : std_logic;
  SIGNAL In1_signed                       : signed(7 DOWNTO 0);  -- int8
  SIGNAL Constant_out1                    : signed(15 DOWNTO 0);  -- sfix16_En7
  SIGNAL Rate_Transition_out1             : signed(7 DOWNTO 0);  -- int8
  SIGNAL Constant1_out1                   : signed(15 DOWNTO 0);  -- sfix16_En7
  SIGNAL Compare_To_Zero_out1             : std_logic;
  SIGNAL switch_compare_1                 : std_logic;
  SIGNAL Switch_out1                      : signed(15 DOWNTO 0);  -- sfix16_En7
  SIGNAL Sum_sub_cast                     : signed(31 DOWNTO 0);  -- sfix32_En7
  SIGNAL Sum_sub_cast_1                   : signed(31 DOWNTO 0);  -- sfix32_En7
  SIGNAL Sum_sub_temp                     : signed(31 DOWNTO 0);  -- sfix32_En7
  SIGNAL Sum_out1                         : signed(15 DOWNTO 0);  -- sfix16_En7
  SIGNAL Unit_Delay_out1                  : signed(15 DOWNTO 0);  -- sfix16_En7
  SIGNAL Add_add_cast                     : signed(31 DOWNTO 0);  -- sfix32_En7
  SIGNAL Add_add_cast_1                   : signed(31 DOWNTO 0);  -- sfix32_En7
  SIGNAL Add_add_temp                     : signed(31 DOWNTO 0);  -- sfix32_En7
  SIGNAL Add_out1                         : signed(15 DOWNTO 0);  -- sfix16_En7

BEGIN
  u_sigma_delta_fxp_hdl_tc : sigma_delta_fxp_hdl_tc
    PORT MAP( clk => clk,
              reset => reset,
              clk_enable => clk_enable,
              enb => enb,
              enb_1_1_1 => enb_1_1_1,
              enb_1_512_0 => enb_1_512_0
              );

  In1_signed <= signed(In1);

  Constant_out1 <= to_signed(-16256, 16);

  Rate_Transition_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Rate_Transition_out1 <= to_signed(0, 8);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb_1_512_0 = '1' THEN
        Rate_Transition_out1 <= In1_signed;
      END IF;
    END IF;
  END PROCESS Rate_Transition_process;


  Constant1_out1 <= to_signed(16256, 16);

  
  switch_compare_1 <= '1' WHEN Compare_To_Zero_out1 > '0' ELSE
      '0';

  
  Switch_out1 <= Constant_out1 WHEN switch_compare_1 = '0' ELSE
      Constant1_out1;

  Sum_sub_cast <= resize(Rate_Transition_out1 & '0' & '0' & '0' & '0' & '0' & '0' & '0', 32);
  Sum_sub_cast_1 <= resize(Switch_out1, 32);
  Sum_sub_temp <= Sum_sub_cast - Sum_sub_cast_1;
  Sum_out1 <= Sum_sub_temp(15 DOWNTO 0);

  Add_add_cast <= resize(Unit_Delay_out1, 32);
  Add_add_cast_1 <= resize(Sum_out1, 32);
  Add_add_temp <= Add_add_cast + Add_add_cast_1;
  Add_out1 <= Add_add_temp(15 DOWNTO 0);

  Unit_Delay_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Unit_Delay_out1 <= to_signed(0, 16);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        Unit_Delay_out1 <= Add_out1;
      END IF;
    END IF;
  END PROCESS Unit_Delay_process;


  
  Compare_To_Zero_out1 <= '1' WHEN Unit_Delay_out1 < 0 ELSE
      '0';

  ce_out <= enb_1_1_1;

  Out1 <= Compare_To_Zero_out1;

END rtl;

