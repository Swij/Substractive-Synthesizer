library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Galois LFSR
entity LFSR_Galois is
    Generic ( WIDTH : NATURAL := 16;
              POLY_PAT : STD_LOGIC_VECTOR(15 downto 0) := "1011010000000000"; -- Changes depending on width!
              SEED : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000001");
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end LFSR_Galois;

architecture Behavioral of LFSR_Galois is
    signal output_tmp : STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    signal feedback : STD_LOGIC;

begin
-- Feedback bit
feedback <= output_tmp(0);

-- Shift and insert feedback
LFSR_proc:process(clk, reset)
begin
    if reset = '0' then
        output_tmp <= SEED;
    elsif rising_edge(clk) then
        output_tmp(15) <= feedback;
        shifter:for i in 0 to WIDTH-2 loop
            output_tmp(i) <= output_tmp(i+1) XOR (feedback AND POLY_PAT(i));
        end loop;
        output <= output_tmp;
    end if;
end process;
end Behavioral;
