library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- NOTE: 1. Input angle is a modulo of 2*PI scaled to fit in a 32bit register. The user must translate
--          this angle to a value from 0 - (2^32-1).  0 deg = 32'h0, 359.9999... = 32'hFF_FF_FF_FF
--          To translate from degrees to a 32 bit value, multiply 2^32 by the angle (in degrees),
--          then divide by 360
--       2. Size of Xout, Yout is 1 bit larger due to a system gain of 1.647 (which is < 2)
entity cordic is
    Generic ( XY_SZ : natural := 16;   -- width of input and output data
              STG : natural := 16); -- same as bit width of X and Y
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           angle : in STD_LOGIC_VECTOR (31 downto 0); -- angle is a signed value in the range of -PI to +PI that must be represented as a 32 bit signed number
           Xin : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
           Yin : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
           Xout : out STD_LOGIC_VECTOR (XY_SZ downto 0);
           Yout : out STD_LOGIC_VECTOR (XY_SZ downto 0));
end cordic;

architecture Behavioral of cordic is
    component cstage
        Generic ( XY_SZ : natural := 16;
                  STG : natural := 16;
                  i : natural := 0);
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               Xin : in STD_LOGIC_VECTOR (XY_SZ downto 0);
               Yin : in STD_LOGIC_VECTOR (XY_SZ downto 0);
               Zin : in STD_LOGIC_VECTOR (31 downto 0);
               atan : in STD_LOGIC_VECTOR (31 downto 0);
               Xout : out STD_LOGIC_VECTOR (XY_SZ downto 0);
               Yout : out STD_LOGIC_VECTOR (XY_SZ downto 0);
               Zout : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    type regXY is array (0 to STG-1) of std_logic_vector(XY_SZ downto 0); -- 17x16
    type regZ is array (0 to STG-1) of std_logic_vector(31 downto 0); -- 32x16
    type regATAN is array (0 to 30) of std_logic_vector(31 downto 0); -- 32x31
    
    signal quadrant : std_logic_vector(1 downto 0);
    signal X : regXY;
    signal Y : regXY;
    signal Z : regZ;
    signal atan_table : regATAN := (
           "00100000000000000000000000000000",
           "00010010111001000000010100011101",
           "00001001111110110011100001011011",
           "00000101000100010001000111010100",
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
           "00000000000000000000000000000000"   -- atan(2^-30)
           );
           
begin
    -- Stage 0
    quadrant <= angle(31 downto 30);
    
    rotate:process(reset, clk)
    begin -- make sure the rotation angle is in the -pi/2 to pi/2 range.  If not then pre-rotate
        if reset = '0' then
            X(0) <= (others => '0');
            Y(0) <= (others => '0');
            Z(0) <= (others => '0');
        elsif rising_edge(clk) then
            case quadrant is
                when "00" | "11" => -- no pre-rotation needed for these quadrants
                    X(0) <= std_logic_vector(resize(signed(Xin),X(0)'length));  -- Xin
                    Y(0) <= std_logic_vector(resize(signed(Yin),Y(0)'length));  -- Yin
                    Z(0) <= angle;
                when "01" =>
                    X(0) <= std_logic_vector(resize(-signed(Yin),X(0)'length)); -- -Yin
                    Y(0) <= std_logic_vector(resize(signed(Xin),Y(0)'length));  -- Xin
                    Z(0) <= "00" & angle(29 downto 0); -- subtract pi/2 from angle for this quadrant
                when "10" =>
                    X(0) <= std_logic_vector(resize(signed(Yin),X(0)'length));  -- Yin
                    Y(0) <= std_logic_vector(resize(-signed(Xin),Y(0)'length)); -- -Xin
                    Z(0) <= "11" & angle(29 downto 0); -- add pi/2 to angle for this quadrant
                when others =>
            end case;
        end if;
    end process;
    
    -- Stages 1 to STG-1
    stages:for i in 0 to (STG-2) generate
    stageX:cstage
        generic map ( XY_SZ, STG, i)
        port map ( clk, reset, X(i), Y(i), Z(i), atan_table(i), X(i+1), Y(i+1), Z(i+1));
    end generate;
    
    -- Output
    Xout <= X(STG-1);
    Yout <= Y(STG-1);
end Behavioral;
