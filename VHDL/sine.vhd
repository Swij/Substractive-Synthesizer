library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sine is
    generic(
        XY_SZ : integer := 16;
        STG   : integer := 16 --= XY_SZ
    );
    port(
        clk     : in STD_LOGIC;
        reset   : in STD_LOGIC;
        
        angle   : in STD_LOGIC_VECTOR (31 downto 0); -- angle is a signed value in the range of -PI to +PI that must be represented as a 32 bit signed number
        
        Xin     : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
        Yin     : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
        
        Xout    : out STD_LOGIC_VECTOR (XY_SZ downto 0);
        Yout    : out STD_LOGIC_VECTOR (XY_SZ downto 0)
    );
end sine;

architecture arch_sine of sine is

    type triTable is array (0 to 30) of std_logic_vector(31 downto 0);
    
    component cordicStage 
    generic(
        i     : natural;
        XY_SZ : natural
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
    end component;
------------------------------------------------------------------------------
--                             arctan table
------------------------------------------------------------------------------
   -- Note: The atan_table was chosen to be 31 bits wide giving resolution up to atan(2^-30)

   -- upper 2 bits = 2'b00 which represents 0 - PI/2 range
   -- upper 2 bits = 2'b01 which represents PI/2 to PI range
   -- upper 2 bits = 2'b10 which represents PI to 3*PI/2 range (i.e. -PI/2 to -PI)
   -- upper 2 bits = 2'b11 which represents 3*PI/2 to 2*PI range (i.e. 0 to -PI/2)
   -- The upper 2 bits therefore tell us which quadrant we are in.


    signal atan_table : triTable := (
       "00100000000000000000000000000000",  -- 45.000 degrees -> atan(2^0)
       "00010010111001000000010100011101",  -- 26.565 degrees -> atan(2^-1)
       "00001001111110110011100001011011",  -- 14.036 degrees -> atan(2^-2)
       "00000101000100010001000111010100",  -- atan(2^-3)
       "00000010100010110000110101000011",
       "00000001010001011101011111100001",
       "00000000101000101111011000011110",
       "00000000010100010111110001010101",
       "00000000001010001011111001010011",
       "00000000000101000101111100101110",
       "00000000000010100010111110011000",
       "00000000000001010001011111001100",
       "00000000000000101000101111100110",
       "00000000000000010100010111110011",
       "00000000000000001010001011111001",
       "00000000000000000101000101111101",
       "00000000000000000010100010111110",
       "00000000000000000001010001011111",
       "00000000000000000000101000101111",
       "00000000000000000000010100011000",
       "00000000000000000000001010001100",
       "00000000000000000000000101000110",
       "00000000000000000000000010100011",
       "00000000000000000000000001010001",
       "00000000000000000000000000101000",
       "00000000000000000000000000010100",
       "00000000000000000000000000001010",
       "00000000000000000000000000000101",
       "00000000000000000000000000000010",
       "00000000000000000000000000000001",  -- atan(2^-29)
       "00000000000000000000000000000000"
       );
   
   ------------------------------------------------------------------------------
   --                              registers
   ------------------------------------------------------------------------------
   
--  stage outputs
type stageReg is array (0 to XY_SZ) of std_logic_vector(STG-1 downto 0);
type stageReg2 is array (0 to 31) of std_logic_vector(STG-1 downto 0);
   
signal X : stageReg;
signal Y : stageReg;
signal Z : stageReg2;

signal quadrant : std_logic_vector(1 downto 0);
 
--   reg [7:0] a[0:3] will give you a 4x8 bit array   
--   reg signed [XY_SZ:0] X [0:STG-1];
--   reg signed [XY_SZ:0] Y [0:STG-1];
--   reg signed    [31:0] Z [0:STG-1]; // 32bit

begin

    quadrant <= angle(31 downto 30);

   
------------------------------------------------------------------------------
--                           generate stages 1 to STG-1
------------------------------------------------------------------------------

    stages:
    for i in 0 to STG-1 generate 
        cordicStages: coridicStage
        generic map(
            i, STG
        )
        port map(
            clk,
            reset,
            
            X(i),
            Y(i),
            Z(i),
            
            atan(i),
            
            X(i+1),
            Y(i+1),
            Z(i+1)        
        );
    end generate;    

--   genvar i;

--   generate
--   for (i=0; i < (STG-1); i=i+1)
--   begin: XYZ
--      wire                   Z_sign;
--      wire signed  [XY_SZ:0] X_shr, Y_shr; 
   
--      assign X_shr = X[i] >>> i; -- signed shift right
--      assign Y_shr = Y[i] >>> i;
   
--      //the sign of the current rotation angle
--      assign Z_sign = Z(i)(31);--Z[i][31]; // Z_sign = 1 if Z[i] < 0
   
--      always @(posedge clock)
--      begin
--         // add/subtract shifted data
--         X[i+1] <= Z_sign ? X[i] + Y_shr         : X[i] - Y_shr;
--         Y[i+1] <= Z_sign ? Y[i] - X_shr         : Y[i] + X_shr;
--         Z[i+1] <= Z_sign ? Z[i] + atan_table[i] : Z[i] - atan_table[i];
--      end
--   end
--   endgenerate

   
--------------------------------------------------------------------------------
--                                 output
--------------------------------------------------------------------------------
    Xout <= X(STG-1);
    Yout <= Y(STG-1);

------------------------------------------------------------------------------
--                               stage 0
------------------------------------------------------------------------------
    process(reset, clk)
    begin 
       
        if reset = '0' then
        
        elsif rising_edge(clk) then
        
            --// make sure the rotation angle is in the -pi/2 to pi/2 range.  If not then pre-rotate
            if quadrant = "00" or quadrant = "11" then --no pre-rotation needed for these quadrants
             
                X(0) <= Xin;
                Y(0) <= Yin;
                Z(0) <= angle;
                
            elsif quadrant = "01" then
                
                X(0) <= -Yin;
                Y(0) <= Xin;
                Z(0) <= "00" & angle(29 downto 0); -- subtract pi/2 from angle for this quadrant
                     
            else--         2'b10:
                X(0) <= Yin;
                Y(0) <= -Xin;
                Z(0) <= "11" & angle(29 downto 0); -- add pi/2 to angle for this quadrant
            
            end if;
            
        end if;
        
    end process;
end arch_sine;