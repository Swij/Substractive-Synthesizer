library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aids.ALL;
use work.geometryPackage.all;

entity oscillator_tb1 is
end oscillator_tb1;

architecture Behavioral of oscillator_tb1 is

    -- Component Declaration for the Unit Under Test (UUT)
    component oscillator is
    port( clk       : in STD_LOGIC;
          reset     : in STD_LOGIC;
          enable    : in STD_LOGIC;
          waveForm  : in WAVE;
          note      : in STD_LOGIC_VECTOR (7 downto 0);
          semi      : in STD_LOGIC_VECTOR (4 downto 0);
          dutyCycle : in STD_LOGIC_VECTOR (6 downto 0);
          output    : out STD_LOGIC_VECTOR (11 downto 0));
    end component;
    
    -- Inputs
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal enable : STD_LOGIC := '0';
    signal waveForm : WAVE;
    signal note : STD_LOGIC_VECTOR (7 downto 0);
    signal semi : STD_LOGIC_VECTOR (4 downto 0);
    signal dutyCycle : STD_LOGIC_VECTOR (6 downto 0);
    
    -- Outputs
    signal output : STD_LOGIC_VECTOR (11 downto 0);
    
    -- Clock period definitions
    constant clk_period : time := 1 ns;
    
begin

uut: oscillator 
    port map (clk, reset, enable, waveForm, note, semi, dutyCycle, output);
        
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
    enable <= '0';
    waveForm <= SINE;
    note <= "01011111";
    --semi <= "01011";
    semi <= "10101";
    dutyCycle <= "0110010";
    
    wait for 10 ns;

    reset <= '1';
    enable <= '1';
    
    wait for clk_period;

    for i in 95 downto 0 loop

        wait for clk_period*getT(i)*4;
        
        waveForm <= to_wave(std_logic_vector(to_unsigned(i mod 7,3)));        
        note <= std_logic_vector(unsigned(note) - 1);
        
        wait for clk_period;
        
    end loop;

    assert false report "End of simulation" severity FAILURE;

end process;
end Behavioral;