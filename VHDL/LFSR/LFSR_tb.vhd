library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LFSR_tb is
end LFSR_tb;

architecture Behavioral of LFSR_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component LFSR_Fibonacci is
        Generic ( WIDTH : NATURAL := 16;
                  POLY_PAT : STD_LOGIC_VECTOR(15 downto 0) := "1011010000000000"; -- Changes depending on width!
                  SEED : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000001");
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               output : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
    end component;

    -- Component Declaration for the Unit Under Test (UUT)
    component LFSR_Galois is
        Generic ( WIDTH : NATURAL := 16;
                  POLY_PAT : STD_LOGIC_VECTOR(15 downto 0) := "1011010000000000"; -- Changes depending on width!
                  SEED : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000001");
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               output : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
    end component;

    -- Inputs
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';

    -- Outputs
    signal output_F : STD_LOGIC_VECTOR(15 downto 0);
    signal output_G : STD_LOGIC_VECTOR(15 downto 0);

    -- Clock period definitions
    constant clk_period : time := 1 ns;

begin

Fibonacci: LFSR_Fibonacci
    port map (clk, reset, output_F);

Galois: LFSR_Galois
    port map (clk, reset, output_G);

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
    wait for 10 ns;
    reset <= '1';

    wait for clk_period*175535;

    assert false report "End of simulation" severity FAILURE;

end process;
end Behavioral;
