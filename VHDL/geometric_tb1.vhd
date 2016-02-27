LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.geometryPackage.ALL;
USE work.aids.ALL;
 
ENTITY geometric_tb1 IS
END geometric_tb1;
 
ARCHITECTURE behavior OF geometric_tb1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT geometric
    PORT(
        clk : IN  std_logic;
        reset : IN  std_logic;
        enable : IN  std_logic;
        waveForm : IN  WAVE;
        note : IN  std_logic_vector(7 downto 0);
        dutyCycle : IN  std_logic_vector(7 downto 0);
        semi        : in STD_LOGIC_VECTOR (4 downto 0);
        output : OUT  std_logic_vector(11 downto 0)
    );
    END COMPONENT;
    

    --Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal enable : std_logic := '0';
    signal waveForm : WAVE;
    signal note : std_logic_vector(7 downto 0) := (others => '0');
    signal dutyCycle : std_logic_vector(7 downto 0) := (others => '0');
    signal semi : std_logic_vector(4 downto 0) := (others => '0');

    --Outputs
    signal output : std_logic_vector(11 downto 0);

    -- Clock period definitions
    constant clk_period : time := 5 ns;

    signal clockWait : integer := 0;
    signal nrOfClks  : integer range 0 to 2**31 - 1 := 0;

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
    uut: geometric PORT MAP (
        clk =>          clk,
        reset =>        reset,
        enable =>       enable,
        waveForm =>     waveForm,
        note =>         note,
        dutyCycle =>    dutyCycle,
        semi =>         semi,
        output =>       output
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
        --nrOfClks <= nrOfClks +1;
    end process;
 

    -- Stimulus process
    stim_proc: process
    begin		
    
    reset <= '0';
    
    enable <= '0';
    waveForm <= "00";
    note <= "10000011";
    dutyCycle <= "01010010";
    semi <= "00000";
    
    wait for 100 ns;
    reset <= '1';
    enable <= '1';
    wait for clk_period;   
    
    for i in 131 downto 0 loop

        wait for clk_period*getT(i)*4;
        
        waveForm <= std_logic_vector(to_unsigned(i mod 4,2));
        
        note <= std_logic_vector(unsigned(note) - 1);
        wait for clk_period;
        
    end loop;

    wait;
    end process;

END;

