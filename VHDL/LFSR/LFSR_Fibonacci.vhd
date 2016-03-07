library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Galois LFSR
entity LFSR_Fibonacci is
    Generic ( WIDTH : NATURAL := 16;
              POLY_PAT : STD_LOGIC_VECTOR(15 downto 0) := "1011010000000000"; -- Changes depending on width!
              SEED : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000001");
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end LFSR_Fibonacci;

architecture Behavioral of LFSR_Fibonacci is
    signal output_tmp : STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    signal feedback : STD_LOGIC;

begin
-- Feedback bit calculation
feedback <= output_tmp(15) XOR output_tmp(13) XOR output_tmp(12) XOR output_tmp(10);

-- Shift and insert feedback
LFSR_proc:process(clk, reset)
begin
    if reset = '0' then
        output_tmp <= SEED;
    elsif rising_edge(clk) then
        output_tmp(0) <= feedback;
        shifter:for i in WIDTH-1 downto 1 loop
            output_tmp(i) <= output_tmp(i-1);
        end loop;
    end if;
    output <= output_tmp;
end process;
end Behavioral;
