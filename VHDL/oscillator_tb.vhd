library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aids.ALL;

entity oscillator_tb is
end oscillator_tb;

architecture Behavioral of oscillator_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component oscillator is
        Port (  clk : in STD_LOGIC;
                reset : in STD_LOGIC;
                enable : in STD_LOGIC;
                frequency : in STD_LOGIC_VECTOR (12 downto 0);
                wave : in WAVE;
                output : out STD_LOGIC_VECTOR (16 downto 0));
    end component;
    
    -- Inputs
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal enable : STD_LOGIC := '0';
    signal frequency : STD_LOGIC_VECTOR (12 downto 0) := (others => '0');
    signal wave : WAVE := SINE;
    
    -- Outputs
    signal output : STD_LOGIC_VECTOR (16 downto 0);
    
    -- Clock period definitions
    constant clk_period : time := 1 ns;
begin
    uut: oscillator 
        port map (clk, reset, enable, frequency, wave, output);
        
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
     
        -- hold reset state for 100 ns.
        reset <= '0';
        wait for 10 ns;
        reset <= '1';
        enable <= '1';
        
        wait for clk_period*468;
        
        wave <= COSINE;

        
        wait for clk_period*468;
        assert false report "End of simulation" severity FAILURE;
    end process;
end Behavioral;
