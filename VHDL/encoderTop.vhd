library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity encoderTop is
    port(
        clk    : in STD_LOGIC;
        reset  : in STD_LOGIC;
        A      : in STD_LOGIC;
        B      : in STD_LOGIC;
        C      : in STD_LOGIC;
        change : out STD_LOGIC;
        dir    : out STD_LOGIC;
        btn    : out STD_LOGIC
    );
end encoderTop;

architecture arch_encoderTop of encoderTop is

    component encoder is
    port(clk    : in STD_LOGIC;
         reset  : in STD_LOGIC;        
         A      : in STD_LOGIC;        
         B      : in STD_LOGIC;                
         C      : in STD_LOGIC;        
         change : out STD_LOGIC;
         dir    : out STD_LOGIC;
         btn    : out STD_LOGIC);
    end component;
    
    component debounce is 
    port(clk : in STD_LOGIC;
         A   : in STD_LOGIC;
         B   : out std_logic);
    end component;
    
    signal Ax : std_logic;
    signal Bx : std_logic;

begin

encoder_comp:
component encoder
    port map(
        clk, '1', Ax, Bx, C, change, dir, btn
    );
    
debounce_compA:
    component debounce
        port map(clk, A, Ax);

debounce_compB:
    component debounce
        port map(clk, B, Bx);

end arch_encoderTop;
