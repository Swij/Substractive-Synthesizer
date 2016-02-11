library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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

--    type triTable is array (0 to 30) of std_logic_vector(31 downto 0);
    
    component cordicStage 
--    generic(
--        i     : natural;
--        XY_SZ : natural
--    )
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

type stageReg is array (0 to XY_SZ) of std_logic_vector(STG-1 downto 0);
type stageReg2 is array (0 to 31) of std_logic_vector(STG-1 downto 0);
   
signal X : stageReg;
signal Y : stageReg;
signal Z : stageReg2;

signal quadrant : std_logic_vector(1 downto 0);


begin

    quadrant <= angle(31 downto 30);

   
    stages:
    for i in 0 to (STG-1) generate 
        begin coridicStages:
        entity work.cordicStage
        generic map(
            i, STG
        )
        port map(
            clk,
            reset,
            
            X(i),
            Y(i),
            Z(i),
            
            --atan(i),
            
            X(i+1),
            Y(i+1),
            Z(i+1)        
        );
    end generate;    

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