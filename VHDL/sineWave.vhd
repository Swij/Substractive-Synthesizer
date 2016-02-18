library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sineWave is
    generic(
        XY_SZ   : integer := 16;
        STAGES  : integer := 16
    );
    port(
        clk     : in STD_LOGIC;
        reset   : in STD_LOGIC;
        -- Angle is a signed value in the range of -PI to +PI represented as a 32 bit signed number
        angle   : in STD_LOGIC_VECTOR (31 downto 0); 
        
        Xin     : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
        Yin     : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
        
        Xout    : out STD_LOGIC_VECTOR (XY_SZ downto 0);
        Yout    : out STD_LOGIC_VECTOR (XY_SZ downto 0);
        Zout    : out STD_LOGIC_VECTOR (31 downto 0)  -- QUICKFIX FOR WARNINGS
    );
end sineWave;

architecture arch_sine of sineWave is

    component cordicStage 
    generic(
        i      : natural;
        XY_SZ  : natural;
        STAGES : natural
    );
    port(
        clk     : in STD_LOGIC;
        reset   : in STD_LOGIC;
        
        Xin     : in STD_LOGIC_VECTOR (XY_SZ downto 0);
        Yin     : in STD_LOGIC_VECTOR (XY_SZ downto 0);
        Zin     : in STD_LOGIC_VECTOR (32-1 downto 0);
        
        atan    : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
        
        Xout    : out STD_LOGIC_VECTOR (XY_SZ downto 0);
        Yout    : out STD_LOGIC_VECTOR (XY_SZ downto 0);
        Zout    : out STD_LOGIC_VECTOR (32-1 downto 0)
    );
    end component;

    type stageReg is array (0 to STAGES-1) of std_logic_vector(XY_SZ downto 0);
    type stageReg2 is array (0 to STAGES-1) of std_logic_vector(32-1 downto 0);
    
        
    signal X : stageReg;
    signal Y : stageReg;
    signal Z : stageReg2;
    
    signal quadrant : std_logic_vector(1 downto 0);

    type triTable is array (0 to 30) of std_logic_vector(31 downto 0);
    signal atan_table : triTable := (       -- 32 bits ala 31 elements
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
       "00000000000000000000000000000000"   -- atan(2^-30)
       );

begin
--------------------------------------------------------------------------------
--                               input / output
--------------------------------------------------------------------------------
    Xout <= X(STAGES-1);
    Yout <= Y(STAGES-1);
    Zout <= Z(STAGES-1); -- QUICKFIX FOR WARNINGS
    quadrant <= angle(31 downto 30);

------------------------------------------------------------------------------
--                               stage 0
------------------------------------------------------------------------------
    process(reset, clk)
    begin 
       
        if reset = '0' then
        
            X(0) <= (others => '0');
            Y(0) <= (others => '0');
            Z(0) <= (others => '0');
            --Xout <= (others => '0');
            --Yout <= (others => '0');
            --Zout <= (others => '0');
        
        elsif rising_edge(clk) then
        
            -- Make sure the rotation angle is in the -pi/2 to pi/2 range.  If not then pre-rotate
            if quadrant = "00" or quadrant = "11" then -- No pre-rotation needed for these quadrants
             
                X(0) <= "0" & Xin;
                Y(0) <= "0" & Yin;
                Z(0) <= angle;
                
            elsif quadrant = "01" then
                
                --X(0) <= std_logic_vector(to_signed((0-to_integer(signed(Yin))),XY_SZ+1));
                
                if Yin(XY_SZ-1) = '0' then
                    X(0) <= "1" & std_logic_vector(signed(not(Yin)) + 1);
                else
                    X(0) <= "0" & std_logic_vector(signed(not(Yin)) + 1);
                end if;
                
                Y(0) <= "0" & Xin;
                Z(0) <= "00" & angle(29 downto 0); -- Subtract pi/2 from angle for this quadrant
                     
            else  --"10"
            
                X(0) <= "0" & Yin;
                --Y(0) <= std_logic_vector(to_signed((0-to_integer(signed(Xin))),XY_SZ+1));
                
                if Xin(XY_SZ-1) = '0' then
                    Y(0) <= "1" & std_logic_vector(signed(not(Xin)) + 1);
                else
                    Y(0) <= "0" & std_logic_vector(signed(not(Xin)) + 1);
                end if;
                    
                Z(0) <= "11" & angle(29 downto 0); -- Add pi/2 to angle for this quadrant
            
            end if;
            
        end if;
        
    end process;

------------------------------------------------------------------------------
--                             stage 1 to STAGES
------------------------------------------------------------------------------   
    coridicStages:
    for i in 0 to (STAGES-2) generate 
        begin stage:
        entity work.cordicStage
        generic map(
            i, 
            XY_SZ, 
            STAGES
        )
        port map(
            clk,
            reset,
            X(i),
            Y(i),
            Z(i),
            atan_table(i),
            X(i+1),
            Y(i+1),
            Z(i+1)
        );
    end generate;

end arch_sine;