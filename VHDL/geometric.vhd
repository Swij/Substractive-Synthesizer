library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.geometryPackage.all;

entity geometric is
    generic(accSize : natural := 22);
    port( 
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        enable      : in STD_LOGIC;

        waveForm    : in STD_LOGIC_VECTOR (1 downto 0);
        note        : in STD_LOGIC_VECTOR (7 downto 0);
        dutyCycle   : in STD_LOGIC_VECTOR (7 downto 0);
        
        restart     : in STD_LOGIC;
        output      : out STD_LOGIC_VECTOR (11 downto 0)
    );
end geometric;

architecture arch_geometric of geometric is

signal squareWave : STD_LOGIC_VECTOR(accSize-1 downto 0);
signal triangleWave : STD_LOGIC_VECTOR(accSize-1 downto 0);
signal saw1Wave : STD_LOGIC_VECTOR(accSize-1 downto 0);
signal saw2Wave : STD_LOGIC_VECTOR(accSize-1 downto 0);

signal triangleState : STD_LOGIC;

signal T : STD_LOGIC_VECTOR(32-1 downto 0);
signal F_s : STD_LOGIC_VECTOR(32-1 downto 0);
signal inc : STD_LOGIC_VECTOR(32-1 downto 0);
signal duty : STD_LOGIC_VECTOR(32-1 downto 0);

signal clkCnt : integer range 0 to 2**32 - 1;



--type noteType is array(0 to 131) of integer;
--signal notes: noteType;

begin

    geometric_process:
	process(reset, clk)
    begin
    if reset = '0' then
    
        output <= (OTHERS => '0');
                
        squareWave <= (OTHERS => '0');
        triangleWave <= (OTHERS => '0');
        saw1Wave <= (OTHERS => '0');
        saw2Wave <= (OTHERS => '0');

        triangleState <= '1';

        T <= (OTHERS => '0');
        F_s <= (OTHERS => '0');
        inc <= (OTHERS => '0');
        duty <= (OTHERS => '0');
        
    elsif rising_edge(clk) then

        if restart = '1' then
    
            T <= getT(to_integer(unsigned(note))); 
                        
            F_s <= getFs(to_integer(unsigned(note)));
                       
            inc <= getInc(to_integer(unsigned(note)));
    
    
        -- 	Square
            if waveForm = "00" then
                
                --duty <= STD_LOGIC_VECTOR(getT(to_integer(note)) / 100 * to_integer(dutyCycle));
                output <= ('1',OTHERS => '0');
                                
        --  Triangle	
            elsif waveForm = "01" then
        
                output <= (OTHERS => '0');
                --clkCnt <= shift_right(to_integer(getT(to_integer(note))),1);
                triangleState <= '1';
        
        --  Saw 1
            elsif waveForm = "10" then
        
                output <= ('0',OTHERS => '1');
                
        --  Saw 2    
            elsif waveForm = "0011" then
        
                output <= ('1',OTHERS => '0');
        
            end if;
        
        elsif enable = '1' then
        
        -- 	Square
            if waveForm = "0010" then
        
        
        --  Triangle	
            elsif waveForm = "0010" then
        
        
        --  Saw 1
            elsif waveForm = "0010" then
        
        
        --  Saw 2    
            elsif waveForm = "0010" then
        
        
        --  Off
            else
            
                output <= (OTHERS => '0');
            
            end if;
        
            clkCnt <= clkCnt + 1;
--                
--            if counter < duty then 
--                output <= (OTHERS => '0');
--            else
--                output <= (OTHERS => '1');
--            end if;
--            
--            counter <= counter + 1;
--            
--            if counter = period then
--                counter <= 0;
--            end if;
            
        end if;
        
    end if;
    end process;
    
end arch_geometric;
