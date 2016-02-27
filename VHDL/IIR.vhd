library ieee;
library ieee_proposed;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;

entity IIR is
   generic ( WIDTH : INTEGER:=12);
   port ( clk      : in STD_LOGIC;
          x        : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
          reset    : in STD_LOGIC;
          y        : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
          finished : out STD_LOGIC);
end IIR;

architecture arch_IIR of IIR is
    signal a1, a2, b0, b1, b2, yf, xf, test : sfixed(WIDTH-1 downto -6);
    
    type SFParray is array(2 downto 0) of sfixed(WIDTH-1 downto -6);
    signal xs, ys : SFParray;
    
begin
    -- Fixed point of input
    xf <= resize(to_sfixed(x, 11, 0),xf);

    -- Direct implementation
    yf <= resize(b0*xs(0) + b1*xs(1) + b2*xs(2) - a1*ys(1) - a2*ys(2), yf);
    
    -- Output
    y <= std_logic_vector(resize(ys(0), y'LENGTH-1, 0));
    
    -- Filter coefficients
    -- all divided by a0
    a1 <= to_sfixed(-1.4123991259705462, a1); -- -1.2847
    a2 <= to_sfixed(0.6117635048723451, a2);  --  0.6468
    b0 <= to_sfixed(0.04984109472544971, b0);  --  0.0483
    b1 <= to_sfixed(0.09968218945089942, a1);  --  0.0967
    b2 <= to_sfixed(0.04984109472544971, b2);  --  0.0483
        
filter_proc:
process(clk, reset)
begin
    if reset = '0' then
        xs <= (others => (others => '0'));
        ys <= (others => (others => '0'));
    elsif rising_edge(clk) then
        xs(0) <= xf;
        xs(1) <= xs(0);
        xs(2) <= xs(1);
        
        ys(0) <= yf; 
        ys(1) <= yf;
        ys(2) <= ys(1);
    end if;
end process;
       
end arch_IIR;