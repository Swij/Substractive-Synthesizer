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
                SYSCLK_P  : in STD_LOGIC;
                SYSCLK_N  : in STD_LOGIC;
                GPIO_SW_N : in STD_LOGIC;
                GPIO_SW_S : in STD_LOGIC;
                GPIO_SW_W : in STD_LOGIC;
                GPIO_SW_E : in STD_LOGIC;
                GPIO_SW_C : in STD_LOGIC;
                GPIO_LED_0 : out STD_LOGIC;
                GPIO_LED_1 : out STD_LOGIC;
                GPIO_LED_2 : out STD_LOGIC;
                GPIO_LED_3 : out STD_LOGIC;
                --FMC1_HPC_HA09_P : in STD_LOGIC;
                --FMC1_HPC_HA09_N : in STD_LOGIC;
                ROTARY_INCA : in STD_LOGIC;
                ROTARY_INCB : in STD_LOGIC;
                ROTARY_PUSH : in STD_LOGIC;
                GPIO_DIP_SW0 : in STD_LOGIC;
                GPIO_DIP_SW1 : in STD_LOGIC;
                GPIO_DIP_SW2 : in STD_LOGIC;
                GPIO_DIP_SW3 : in STD_LOGIC;
                --  DAC
                XADC_GPIO_0 : out STD_LOGIC;  --  LDAC
                XADC_GPIO_1 : out STD_LOGIC;  --  SCLK
                XADC_GPIO_2 : out STD_LOGIC;  --  DIN
                XADC_GPIO_3 : out STD_LOGIC;  --  SYNC
        
                --  ENCODERS
                FMC1_HPC_HA02_P : in STD_LOGIC;
                FMC1_HPC_HA02_N : in STD_LOGIC;
                FMC1_HPC_HA03_P : in STD_LOGIC;
                FMC1_HPC_HA03_N : in STD_LOGIC;
                FMC1_HPC_HA04_P : in STD_LOGIC;
                FMC1_HPC_HA04_N : in STD_LOGIC;
                FMC1_HPC_HA05_P : in STD_LOGIC;
                FMC1_HPC_HA05_N : in STD_LOGIC;
                FMC1_HPC_HA06_P : in STD_LOGIC;
                FMC1_HPC_HA06_N : in STD_LOGIC;
                FMC1_HPC_HA07_P : in STD_LOGIC;
                FMC1_HPC_HA07_N : in STD_LOGIC;
                FMC1_HPC_HA08_P : in STD_LOGIC;
                FMC1_HPC_HA08_N : in STD_LOGIC;
                FMC1_HPC_HA09_P : in STD_LOGIC;
                FMC1_HPC_HA09_N : in STD_LOGIC;
                FMC1_HPC_HA19_P : in STD_LOGIC;
                FMC1_HPC_HA19_N : in STD_LOGIC;
        
                FMC1_HPC_HA10_P : out STD_LOGIC; -- +
                FMC1_HPC_HA10_N : out STD_LOGIC); -- - 
    end component;
    
    -- Inputs
    signal clk       : STD_LOGIC := '0'; 
    signal reset     : STD_LOGIC := '0';
    signal SYSCLK_P  : STD_LOGIC := '0';
    signal SYSCLK_N  : STD_LOGIC := '0';
    signal GPIO_SW_N : STD_LOGIC := '0';
    signal GPIO_SW_S : STD_LOGIC := '0';
    signal GPIO_SW_W : STD_LOGIC := '0';
    signal GPIO_SW_E : STD_LOGIC := '0';
    signal GPIO_SW_C : STD_LOGIC := '0';
    signal GPIO_LED_0 : STD_LOGIC := '0';
    signal GPIO_LED_1 : STD_LOGIC := '0';
    signal GPIO_LED_2 : STD_LOGIC := '0';
    signal GPIO_LED_3 : STD_LOGIC := '0';
    --signal FMC1_HPC_HA09_P : STD_LOGIC := '0';
    --signal FMC1_HPC_HA09_N : STD_LOGIC := '0';
    signal ROTARY_INCA : STD_LOGIC := '0';
    signal ROTARY_INCB : STD_LOGIC := '0';
    signal ROTARY_PUSH : STD_LOGIC := '0';
    signal GPIO_DIP_SW0 : STD_LOGIC := '0';
    signal GPIO_DIP_SW1 : STD_LOGIC := '0';
    signal GPIO_DIP_SW2 : STD_LOGIC := '0';
    signal GPIO_DIP_SW3 : STD_LOGIC := '0';
    --  DAC
    signal XADC_GPIO_0 : STD_LOGIC := '0';  --  LDAC
    signal XADC_GPIO_1 : STD_LOGIC := '0';  --  SCLK
    signal XADC_GPIO_2 : STD_LOGIC := '0';  --  DIN
    signal XADC_GPIO_3 : STD_LOGIC := '0';  --  SYNC
    
    --  ENCODERS
    signal FMC1_HPC_HA02_P : STD_LOGIC := '0';
    signal FMC1_HPC_HA02_N : STD_LOGIC := '0';
    signal FMC1_HPC_HA03_P : STD_LOGIC := '0';
    signal FMC1_HPC_HA03_N : STD_LOGIC := '0';
    signal FMC1_HPC_HA04_P : STD_LOGIC := '0';
    signal FMC1_HPC_HA04_N : STD_LOGIC := '0';
    signal FMC1_HPC_HA05_P : STD_LOGIC := '0';
    signal FMC1_HPC_HA05_N : STD_LOGIC := '0';
    signal FMC1_HPC_HA06_P : STD_LOGIC := '0';
    signal FMC1_HPC_HA06_N : STD_LOGIC := '0';
    signal FMC1_HPC_HA07_P : STD_LOGIC := '0';
    signal FMC1_HPC_HA07_N : STD_LOGIC := '0';
    signal FMC1_HPC_HA08_P : STD_LOGIC := '0';
    signal FMC1_HPC_HA08_N : STD_LOGIC := '0';
    signal FMC1_HPC_HA09_P : STD_LOGIC := '0';
    signal FMC1_HPC_HA09_N : STD_LOGIC := '0';
    signal FMC1_HPC_HA19_P : STD_LOGIC := '0';
    signal FMC1_HPC_HA19_N : STD_LOGIC := '0';
    
    signal FMC1_HPC_HA10_P : STD_LOGIC := '0'; -- +
    signal FMC1_HPC_HA10_N : STD_LOGIC := '0';
    
    -- Clock period definitions
    constant clk_period : time := 5 ns; -- 200MHz

begin

-- Instantiate the Unit Under Test (UUT)
uut: top_sim PORT MAP (
        clk,
        SYSCLK_P,
        SYSCLK_N,
        GPIO_SW_N,
        GPIO_SW_S,
        GPIO_SW_W,
        GPIO_SW_E,
        GPIO_SW_C,
        GPIO_LED_0,
        GPIO_LED_1,
        GPIO_LED_2,
        GPIO_LED_3,
        ROTARY_INCA,
        ROTARY_INCB,
        ROTARY_PUSH,
        GPIO_DIP_SW0,
        GPIO_DIP_SW1,
        GPIO_DIP_SW2,
        GPIO_DIP_SW3,
        XADC_GPIO_0,
        XADC_GPIO_1,
        XADC_GPIO_2,
        XADC_GPIO_3,
        FMC1_HPC_HA02_P,
        FMC1_HPC_HA02_N,
        FMC1_HPC_HA03_P,
        FMC1_HPC_HA03_N,
        FMC1_HPC_HA04_P,
        FMC1_HPC_HA04_N,
        FMC1_HPC_HA05_P,
        FMC1_HPC_HA05_N,
        FMC1_HPC_HA06_P,
        FMC1_HPC_HA06_N,
        FMC1_HPC_HA07_P,
        FMC1_HPC_HA07_N,
        FMC1_HPC_HA08_P,
        FMC1_HPC_HA08_N,
        FMC1_HPC_HA09_P,
        FMC1_HPC_HA09_N,
        FMC1_HPC_HA19_P,
        FMC1_HPC_HA19_N,
        FMC1_HPC_HA10_P,
        FMC1_HPC_HA10_N);

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
    GPIO_SW_C <= '1';
    wait for 200 ns;
    GPIO_SW_C <= '0';
    
--    -- SQUARE
--    GPIO_DIP_SW2 <= '0';
--    GPIO_DIP_SW1 <= '1';
--    GPIO_DIP_SW0 <= '0';
--    wait for 3000 us;
       
--    -- TRIANGLE
--    GPIO_DIP_SW2 <= '0';
--    GPIO_DIP_SW1 <= '1';
--    GPIO_DIP_SW0 <= '1';
--    wait for 3000 us;
    
--    -- SAW1
--    GPIO_DIP_SW2 <= '1';
--    GPIO_DIP_SW1 <= '0';
--    GPIO_DIP_SW0 <= '0';
--    wait for 1000 us;
        
--    -- SAW2
--    GPIO_DIP_SW2 <= '1';
--    GPIO_DIP_SW1 <= '0';
--    GPIO_DIP_SW0 <= '1';
--    wait for 1000 us;
    
--    -- NOISE
--    GPIO_DIP_SW2 <= '1';
--    GPIO_DIP_SW1 <= '1';
--    GPIO_DIP_SW0 <= '0';
--    wait for 1000 us;
    
    -- SINE
    GPIO_DIP_SW2 <= '0';
    GPIO_DIP_SW1 <= '0';
    GPIO_DIP_SW0 <= '0';
    wait for 4100 us;
    
--    -- COSINE
--    GPIO_DIP_SW2 <= '0';
--    GPIO_DIP_SW1 <= '0';
--    GPIO_DIP_SW0 <= '1';
--    wait for 1000 us;
    
--    assert false report "End of simulation" severity FAILURE;
      wait;
end process;

end Behavioral;
