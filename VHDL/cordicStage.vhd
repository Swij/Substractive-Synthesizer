library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cordicStage is
 
    generic(
        i     : natural := 0;
        XY_SZ : natural := 0
    );
    port(
        clk     : in STD_LOGIC;
        reset   : in STD_LOGIC;
        
        Xin     : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
        Yin     : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
        Zin     : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
        
        atan    : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
        
        Xout    : out STD_LOGIC_VECTOR (XY_SZ downto 0);
        Yout    : out STD_LOGIC_VECTOR (XY_SZ downto 0);
        Zout    : out STD_LOGIC_VECTOR (XY_SZ downto 0)
  );
end cordicStage;

architecture Behavioral of cordicStage is

signal Z_sign : std_logic_vector;
signal X_shr : std_logic_vector(STG-1 downto 0);
signal Y_shr : std_logic_vector(STG-1 downto 0);

--wire Z_sign;
--wire signed  [XY_SZ:0] X_shr, Y_shr; 

begin

    X_shr <= shift_right(signed(X),i);      -- >>> i; -- signed shift right
    Y_shr <= shift_right(signed(Y),i);      -- Y >>> i;   
    Z_sign <= Z(31);                        -- Z[i][31];
    
    process(reset, clk)
    begin
    
    if reset = '0' then
    
    elsif rising_edge(clk) then

        if Z_sign then
 
            Xout <= X + Y_shr;
            Yout <= Y - X_shr;
            Zout <= Z + atan;
   
        else
        
            Xout <= X - Y_shr;
            Yout <= Y + X_shr;
            Zout <= Z - atan;
        
        end if;
 
    end if;
    
    
--    genvar i;
--    generate
--    for (i=0; i < (STG-1); i=i+1)
--    begin: XYZ

    
--       assign X_shr = X[i] >>> i; -- signed shift right
--       assign Y_shr = Y[i] >>> i;
    
--       //the sign of the current rotation angle
--       assign Z_sign = Z(i)(31);--Z[i][31]; // Z_sign = 1 if Z[i] < 0
    
--       always @(posedge clock)
--       begin
--          // add/subtract shifted data
--          X[i+1] <= Z_sign ? X[i] + Y_shr         : X[i] - Y_shr;
--          Y[i+1] <= Z_sign ? Y[i] - X_shr         : Y[i] + X_shr;
--          Z[i+1] <= Z_sign ? Z[i] + atan_table[i] : Z[i] - atan_table[i];
--       end
--    end
--    endgenerate
    
    
end process;
end Behavioral;
