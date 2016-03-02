library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aids.ALL;
use work.geometryPackage.all;

entity AD5065_DAC_tb1 is
end AD5065_DAC_tb1;

architecture Behavioral of AD5065_DAC_tb1 is

    -- Component Declaration for the Unit Under Test (UUT)
    component AD5065_DAC is
       generic(
        totalBits : natural := 32;
        dataBits : natural := 16
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        data  : in std_logic_vector(dataBits-1 DOWNTO 0);
        start : in std_logic;
        ready : out std_logic;
         
        SCLK : out std_logic;   
        SYNC : out std_logic;
        SDO  : out std_logic;
        LDAC : out std_logic

    );
    end component;
    
    -- Inputs
    signal clk   : std_logic := '0';
    signal reset   : std_logic := '0';
    signal data  : std_logic_vector(16-1 DOWNTO 0);
    signal start : std_logic := '0';
    
    -- Outputs
    signal ready : std_logic := '0';
    signal SCLK  : std_logic := '0';
    signal SYNC  : std_logic := '0';
    signal SDO   : std_logic := '0';
    signal LDAC  : std_logic := '0';
    
    -- Clock period definitions
    constant clk_period : time := 5 ns;
    
begin

uut: AD5065_DAC 
    port map (clk, reset, data, start, ready, SCLK, SYNC, SDO, LDAC);
        
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

    reset <= '0';
    data <= "1010101010101010";
    start <= '0';
    
    wait for 10 ns;

    reset <= '1';
    
    wait for 20 ns;
    
        start <= '1';
        
        wait for clk_period;
        
        start <= '0';
            
        wait for 4000 ns;
            
            start <= '1';
            
            wait for clk_period;
            
            start <= '0';
                
            wait for 4000 ns;
                
                start <= '1';
                
                wait for clk_period;
                
                start <= '0';
                    
                wait for 4000 ns;
                    
                    start <= '1';
                    
                    wait for clk_period;
                    
                    start <= '0';
                        
                    wait for 4000 ns;
    
    
    assert false report "End of simulation" severity FAILURE;

end process;
end Behavioral;
