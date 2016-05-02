library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.geometryPackage.all;

entity LFOduty_tb1 is
end LFOduty_tb1;

architecture Behavioral of LFOduty_tb1 is

    -- LFO component (duty-cycle)
    component LFO_duty is
    port( clk      : in std_logic;
          reset    : in std_logic;
          restart  : in std_logic;
          enable   : in std_logic;
          rate     : in std_logic_vector (7 downto 0);
          depth    : in std_logic_vector (6 downto 0);
          waveForm : in std_logic;
          output   : out std_logic_vector (6 downto 0));
    end component;

    -- Inputs
    signal clk              : STD_LOGIC := '0';
    signal reset            : STD_LOGIC := '0';
    signal LFOduty_restart  : std_logic;
    signal LFOduty_enable   : std_logic;
    signal LFOduty_rate     : std_logic_vector (7 downto 0);
    signal LFOduty_depth    : std_logic_vector (6 downto 0);
    signal LFOduty_waveForm : std_logic;
    signal LFOduty_rateReg  : integer range 0 to 255; -- std_logic_vector (7 downto 0);
    signal LFOduty_depthReg : integer range 0 to 127; -- std_logic_vector (6 downto 0);
    
    -- Outputs
    signal LFOduty_output   : std_logic_vector (6 downto 0);
    signal depthInc : integer := 10;
    -- Clock period definitions
    constant clk_period : time := 10 ns;
        
begin

LFOduty_comp:component LFO_duty
    port map( clk, reset, LFOduty_restart, LFOduty_enable, LFOduty_rate, LFOduty_depth, LFOduty_waveForm, LFOduty_output );
    
-- Clock process definitions
clk_process:
process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;
    
-- Stimulus process
stim_proc:
process
begin
    
    LFOduty_enable <= '1';
    LFOduty_restart <= '0';
    
    LFOduty_depth <= std_logic_vector(to_unsigned(depthInc,7));
    LFOduty_waveForm <= '0';
    reset <= '0';
    wait for 25 ns;
    reset <= '1';

    for i in 197 downto 190 loop
        
        LFOduty_rate <= std_logic_vector(to_unsigned(i,8));
            depthInc <= depthInc + 4;
        wait for clk_period*getLFO_T(i);
        LFOduty_depth <= std_logic_vector(to_unsigned(depthInc,7));
        wait for clk_period*getLFO_T(i);
        
    end loop;
    

    assert false report "End of simulation" severity FAILURE;

end process;

end Behavioral;
