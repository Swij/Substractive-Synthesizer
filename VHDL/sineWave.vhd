library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aids.ALL;

entity sineWave is
    port(
        clk      : in STD_LOGIC;
        reset    : in STD_LOGIC;
        enable   : in STD_LOGIC;    
        note     : in STD_LOGIC_VECTOR (7 downto 0);
        semi     : in STD_LOGIC_VECTOR (4 downto 0);
        sinOut   : out STD_LOGIC_VECTOR (16 downto 0);
        cosOut   : out STD_LOGIC_VECTOR (16 downto 0)
    );
end sineWave;

architecture arch_sine of sineWave is

    component cordic
    port( clk   : IN  std_logic;
          reset : IN  std_logic;
          angle : IN  std_logic_vector(31 downto 0);
          Xin   : IN  std_logic_vector(15 downto 0);
          Yin   : IN  std_logic_vector(15 downto 0);
          Xout  : OUT  std_logic_vector(16 downto 0);
          Yout  : OUT  std_logic_vector(16 downto 0));
    end component;
    
    type romArray is array (0 to 131) of integer;
    constant F_s : romArray := (33976, 32069, 30269, 28570, 26966, 25453, 24024, 22676, 21403, 20202, 19068, 17998, 16988, 16034, 15134, 14285, 13483, 12726, 12012, 11338, 10702, 10101, 9534, 8999, 8494, 8017, 7567, 7142, 6742, 6363, 6006, 5669, 5351, 5051, 4767, 4499, 4247, 4009, 3784, 3571, 3371, 3182, 3003, 2835, 2675, 2525, 2384, 2250, 2123, 2004, 1892, 1786, 1685, 1591, 1502, 1417, 1338, 1263, 1192, 1125, 1062, 1002, 946, 893, 843, 795, 751, 709, 669, 631, 596, 562, 531, 501, 473, 446, 421, 398, 375, 354, 334, 316, 298, 281, 265, 251, 236, 223, 211, 199, 188, 177, 167, 158, 149, 141, 133, 125, 118, 112, 105, 99, 94, 89, 84, 79, 74, 70, 66, 63, 59, 56, 53, 50, 47, 44, 42, 39, 37, 35, 33, 31, 30, 28, 26, 25, 23, 22, 21, 20, 19, 18);
   

    constant XIN    : integer := 19429;              -- 32000 / 1.647;
    signal angle    : std_logic_vector(31 downto 0);
    signal noteReg  : std_logic_vector( 7 downto 0);
    
begin

cordic_comp: cordic
    port map(clk,reset,angle, std_logic_vector(to_signed(XIN,16)), 
             (others => '0'), sinOut, cosOut);
	
sine_process:
process(reset, clk, enable, note)
variable i : natural := 0;
variable clkCnt : natural := 0;
variable Fs : natural := 0;
begin

    if reset = '0' then
    
        angle <= (others => '0');
        noteReg <= (others => '0');
        i := 0;
        clkCnt := 0;
        Fs := 0;    
        
    elsif rising_edge(clk) then
    
        if enable = '1' then
        
            --  If note hasn't changed
            if noteReg = note then
            
                clkCnt := clkCnt + 1;
                
                if clkCnt = Fs then
                
                    clkCnt := 0;
                    if i = 359 then i := 0; else i := i + 1; end if;
                    angle <= angles(i);              
                    
                end if;
            
            else
                
                noteReg <= note;
                i := 0;
                clkCnt := 0;
                Fs := F_s(to_integer(unsigned(note)));                
            
            end if;
            
        end if;
        
    end if;
end process;
end arch_sine;
