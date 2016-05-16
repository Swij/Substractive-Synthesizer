library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--  This component delays a push of a button and at the same times
--  works as a debouncer.

entity button is
    port(
        clk     : in STD_LOGIC;
        reset   : in STD_LOGIC;
        btn_in  : in STD_LOGIC;
        btn_out : out STD_LOGIC
    );
end button;

architecture arch_button of button is
    
    signal press : std_logic;
    signal btn : std_logic;
    signal btnCnt : integer range 0 to 20000000;

begin

    btn_out <= btn;

button_process:
process(clk, reset)
begin
    
    if reset = '0' then

        press <= '0';
        btn <= '0';
        btnCnt <= 0;
        
    elsif rising_edge(clk) then

        if btn_in = '1' and press = '0' then
            if btnCnt = 20000000 then
                btnCnt <= 0;
                btn <= '1';
                press <= '1';
            else
                btnCnt <= btnCnt + 1;
            end if;
        elsif btn_in = '1' and press = '1' then
            btn <= '1';
        else
            btn <= '0';
            press <= '0';
            btnCnt <= 0;
        end if;

    end if;
end process;
end arch_button;
