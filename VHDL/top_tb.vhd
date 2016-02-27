-- DIP-Switch 2->0 selects wave
--   000=Sine, 001=Cosine, 010=Square, 011=Triangle, 100=Saw1, 101=Saw2, 110=Noise, 111=???
--
-- DIP-Switch 3 enable/disable oscillator
--
-- GPI0_SW_N - Semi up
-- GPI0_SW_S - Semi down
-- GPI0_SW_E - Tune up
-- GPI0_SW_W - Tune down
-- GPI0_SW_C - Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aids.all;

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component top_sim is
        port (  clk       : in STD_LOGIC; 
                GPI0_SW_C : in STD_LOGIC;
                GPI0_SW_N : in STD_LOGIC;
                GPI0_SW_S : in STD_LOGIC;
                GPI0_SW_E : in STD_LOGIC;
                GPI0_SW_W : in STD_LOGIC;
                GPIO_DIP_SW0 : in STD_LOGIC;
                GPIO_DIP_SW1 : in STD_LOGIC;
                GPIO_DIP_SW2 : in STD_LOGIC;
                GPIO_DIP_SW3 : in STD_LOGIC;
                ROTARY_INCA : in STD_LOGIC;
                ROTARY_INCB : in STD_LOGIC;
                ROTARY_PUSH : in STD_LOGIC);      
    end component;
    
    -- Inputs
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal GPI0_SW_C : STD_LOGIC := '0';
    signal GPI0_SW_N : STD_LOGIC := '0';
    signal GPI0_SW_S : STD_LOGIC := '0';
    signal GPI0_SW_E : STD_LOGIC := '0';
    signal GPI0_SW_W : STD_LOGIC := '0';
    signal GPIO_DIP_SW0 : STD_LOGIC := '0';
    signal GPIO_DIP_SW1 : STD_LOGIC := '0';
    signal GPIO_DIP_SW2 : STD_LOGIC := '0';
    signal GPIO_DIP_SW3 : STD_LOGIC := '0';
    signal ROTARY_INCA : STD_LOGIC := '0';
    signal ROTARY_INCB : STD_LOGIC := '0';
    signal ROTARY_PUSH : STD_LOGIC := '0';
    
    -- Clock period definitions
    constant clk_period : time := 5 ns; -- 200MHz

begin

-- Instantiate the Unit Under Test (UUT)
uut: top_sim PORT MAP (
        clk,
        GPI0_SW_C,
        GPI0_SW_N,
        GPI0_SW_S,
        GPI0_SW_E,
        GPI0_SW_W,
        GPIO_DIP_SW0,
        GPIO_DIP_SW1,
        GPIO_DIP_SW2,
        GPIO_DIP_SW3,
        ROTARY_INCA,
        ROTARY_INCB,
        ROTARY_PUSH);

-- Clock process definitions
clk_process :process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

-- Stimulus process
stim_proc: process
begin 
    GPIO_DIP_SW3 <= '1';
    GPI0_SW_C <= '1';
    wait for 200 ns;
    GPI0_SW_C <= '0';
    
    -- SQUARE
    GPIO_DIP_SW2 <= '0';
    GPIO_DIP_SW1 <= '1';
    GPIO_DIP_SW0 <= '0';
    wait for 1000 us;
       
    -- TRIANGLE
    GPIO_DIP_SW2 <= '0';
    GPIO_DIP_SW1 <= '1';
    GPIO_DIP_SW0 <= '1';
    wait for 1000 us;
    
    -- SAW1
    GPIO_DIP_SW2 <= '1';
    GPIO_DIP_SW1 <= '0';
    GPIO_DIP_SW0 <= '0';
    wait for 1000 us;
        
    -- SAW2
    GPIO_DIP_SW2 <= '1';
    GPIO_DIP_SW1 <= '0';
    GPIO_DIP_SW0 <= '1';
    wait for 1000 us;
    
--    -- NOISE
--    GPIO_DIP_SW2 <= '1';
--    GPIO_DIP_SW1 <= '1';
--    GPIO_DIP_SW0 <= '0';
--    wait for 1000 us;
    
    -- SINE
    GPIO_DIP_SW2 <= '0';
    GPIO_DIP_SW1 <= '0';
    GPIO_DIP_SW0 <= '0';
    wait for 1000 us;
    
    -- COSINE
    GPIO_DIP_SW2 <= '0';
    GPIO_DIP_SW1 <= '0';
    GPIO_DIP_SW0 <= '1';
    wait for 1000 us;
    
    assert false report "End of simulation" severity FAILURE;
end process;

end Behavioral;
