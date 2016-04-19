library IEEE;
use IEEE.std_logic_1164.ALL;

entity LFO is
    generic(
        bitWidth  : natural := 12;
        amplitude : natural := 12);
    port( 
        clk       : in std_logic;
        reset     : in std_logic;
        
        rate      : in std_logic_vector (7 downto 0);   --  Index the period list
        depth     : in std_logic_vector (4 downto 0);   
        
        waveForm  : in WAVE;
        dutyCycle : in std_logic_vector (6 downto 0);
        
        output    : out std_logic_vector (bitWidth-1 downto 0));
end LFO;

architecture arch_LFO of LFO is

    type romArray is array (0 to romSize-1) of integer;

--    component sineWave 
--    port( 
--        clk    : in std_logic;
--        reset  : in std_logic;
--        enable : in std_logic;
--        note   : in std_logic_vector (7 downto 0);
--        semi   : in std_logic_vector (4 downto 0);
--        sinOut : out std_logic_vector (16 downto 0);
--        cosOut : out std_logic_vector (16 downto 0));
--    end component;

--  The periods are 0.1Hz to 20Hz.
    signal T_ROM  : romArray := (2000000000, 1000000000, 666666666, 500000000, 400000000, 333333334, 285714286, 250000000, 222222222, 200000000, 181818182, 166666666, 153846154, 142857142, 133333334, 125000000, 117647058, 111111112, 105263158, 100000000, 95238096, 90909090, 86956522, 83333334, 80000000, 76923076, 74074074, 71428572, 68965518, 66666666, 64516130, 62500000, 60606060, 58823530, 57142858, 55555556, 54054054, 52631578, 51282052, 50000000, 48780488, 47619048, 46511628, 45454546, 44444444, 43478260, 42553192, 41666666, 40816326, 40000000, 39215686, 38461538, 37735850, 37037038, 36363636, 35714286, 35087720, 34482758, 33898306, 33333334, 32786886, 32258064, 31746032, 31250000, 30769230, 30303030, 29850746, 29411764, 28985508, 28571428, 28169014, 27777778, 27397260, 27027028, 26666666, 26315790, 25974026, 25641026, 25316456, 25000000, 24691358, 24390244, 24096386, 23809524, 23529412, 23255814, 22988506, 22727272, 22471910, 22222222, 21978022, 21739130, 21505376, 21276596, 21052632, 20833334, 20618556, 20408164, 20202020, 20000000, 19801980, 19607844, 19417476, 19230770, 19047620, 18867924, 18691588, 18518518, 18348624, 18181818, 18018018, 17857142, 17699116, 17543860, 17391304, 17241380, 17094018, 16949152, 16806722, 16666666, 16528926, 16393442, 16260162, 16129032, 16000000, 15873016, 15748032, 15625000, 15503876, 15384616, 15267176, 15151516, 15037594, 14925374, 14814814, 14705882, 14598540, 14492754, 14388490, 14285714, 14184398, 14084508, 13986014, 13888888, 13793104, 13698630, 13605442, 13513514, 13422818, 13333334, 13245034, 13157894, 13071896, 12987012, 12903226, 12820512, 12738854, 12658228, 12578616, 12500000, 12422360, 12345680, 12269938, 12195122, 12121212, 12048192, 11976048, 11904762, 11834320, 11764706, 11695906, 11627906, 11560694, 11494252, 11428572, 11363636, 11299436, 11235956, 11173184, 11111112, 11049724, 10989010, 10928962, 10869566, 10810810, 10752688, 10695188, 10638298, 10582010, 10526316, 10471204, 10416666, 10362694, 10309278, 10256410, 10204082, 10152284, 10101010, 10050252);
    signal Fs_ROM : romArray := (11299435, 5649718, 3766478, 2824859, 2259887, 1883239, 1614205, 1412429, 1255493, 1129944, 1027221, 941620, 869187, 807103, 753296, 706215, 664673, 627746, 594707, 564972, 538068, 513611, 491280, 470810, 451977, 434594, 418498, 403551, 389636, 376648, 364498, 353107, 342407, 332336, 322841, 313873, 305390, 297354, 289729, 282486, 275596, 269034, 262778, 256805, 251099, 245640, 240414, 235405, 230601, 225989, 221558, 217297, 213197, 209249, 205444, 201776, 198236, 194818, 191516, 188324, 185237, 182249, 179356, 176554, 173837, 171204, 168648, 166168, 163760, 161421, 159147, 156937, 154787, 152695, 150659, 148677, 146746, 144865, 143031, 141243, 139499, 137798, 136138, 134517, 132935, 131389, 129879, 128403, 126960, 125549, 124170, 122820, 121499, 120207, 118941, 117702, 116489, 115300, 114136, 112994, 111876, 110779, 109703, 108648, 107614, 106598, 105602, 104624, 103665, 102722, 101797, 100888, 99995, 99118, 98256, 97409, 96576, 95758, 94953, 94162, 93384, 92618, 91865, 91124, 90395, 89678, 88972, 88277, 87593, 86919, 86255, 85602, 84958, 84324, 83700, 83084, 82478, 81880, 81291, 80710, 80138, 79573, 79017, 78468, 77927, 77393, 76867, 76348, 75835, 75330, 74831, 74338, 73853, 73373, 72900, 72432, 71971, 71515, 71066, 70621, 70183, 69750, 69322, 68899, 68481, 68069, 67661, 67259, 66861, 66467, 66079, 65694, 65315, 64939, 64568, 64201, 63839, 63480, 63125, 62775, 62428, 62085, 61746, 61410, 61078, 60750, 60425, 60103, 59785, 59471, 59159, 58851, 58546, 58245, 57946, 57650, 57358, 57068, 56781);
    signal MAXtriInc : integer := 23;
    signal MAXsawInc : integer := 46;

--  These are the signals used for the wave generation.
    signal squareWave   : STD_LOGIC_VECTOR(11 downto 0);
    signal triangleWave : STD_LOGIC_VECTOR(11 downto 0);
    signal sawWave      : STD_LOGIC_VECTOR(11 downto 0);
    
    signal triangleState : STD_LOGIC;
    
    signal T       : integer range 0 to 2**31 - 1;
    signal F_s     : integer range 0 to 2**31 - 1;
    signal F_s_clk : integer range 0 to 2**31 - 1;
    signal duty    : integer range 0 to 2**31 - 1;
    
    signal inc     : integer range 0 to 2**31 - 1;
    signal sum     : integer;-- range -2**(accSize) to (2**(accSize)-1);
    
    signal clkCnt  : integer range 0 to 2**31 - 1;
    signal noteReg : STD_LOGIC_VECTOR (7 downto 0);
    signal waveReg : WAVE;
    signal dutyReg : STD_LOGIC_VECTOR (7 downto 0);
    signal semiReg : STD_LOGIC_VECTOR (4 downto 0);
    
begin

--  If sine wave is to be used, a variating amlitude has to be implemented.
--sineWave_comp: sineWave
--    port map( clk, reset, enable, note, semi, out_cos, out_sin );


lfo_process:
process(reset, clk)
begin

    if reset = '0' then
                    
        squareWave   <= (OTHERS => '0');
        triangleWave <= (OTHERS => '0');
        sawWave      <= (OTHERS => '0');

        triangleState <= '1';

        T <= 0;
        F_s <= 0;
        inc <= 0;
        duty <= 0;
        
        noteReg <= (OTHERS => '0');
        waveReg <= TRIANGLE;
        
    elsif rising_edge(clk) then

-------------------------------------------------------------------------------
--      RESTART
-------------------------------------------------------------------------------
        if noteReg /= note or waveReg /= waveForm or dutyReg /= dutyCycle or semiReg /= semi then
        
            noteReg <= note;
            waveReg <= waveForm;
            dutyReg <= dutyCycle;
            semiReg <= semi;
                                   
            semit := to_integer(unsigned(semi));
            clkCnt <= 0;--T_ROM(to_integer(unsigned(note)))/2 - T_ROM(to_integer(unsigned(note)))/32;
            F_s_clk <= 0;
            triangleState <= '1';

                T   <= T_ROM(to_integer(unsigned(note)));
                F_s <= Fs_ROM(to_integer(unsigned(note)));
                
                if to_integer(unsigned(dutyCycle)) < 1 or to_integer(unsigned(dutyCycle)) > 99 then
                    duty <= T_ROM(to_integer(unsigned(note))) / 2;
                else            
                    duty <= T_ROM(to_integer(unsigned(note))) / 100 * to_integer(unsigned(dutyCycle));
                end if;
            
        --  Square
            if waveForm = SQUARE then
                sum <= 0;        
                squareWave <= ('0',OTHERS => '1');
                output <= squareWave;

        --  Triangle    
            elsif waveForm = TRIANGLE then
                sum <= -2**(11)+1;
                inc <= getInc(0);
                triangleWave <= STD_LOGIC_VECTOR(to_signed(sum,12));                  
                output <= triangleWave;
                
        --  Saw
            elsif waveForm = SAW1 then
                sum <= -2**(11) + 1;
                inc <= getInc(1);
                sawWave <= STD_LOGIC_VECTOR(to_signed(sum,12));
                output <= sawWave;
                
            else --  waveForm = "11" then
                sum <= 2**(11) - 1;
                inc <= getInc(1);
                sawWave <= STD_LOGIC_VECTOR(to_unsigned(sum,12));
                output <= sawWave;
                
            end if;
                
-------------------------------------------------------------------------------
--
--      ENABLED
--
-------------------------------------------------------------------------------
        elsif enable = '1' then

        --  Counter increment
            clkCnt <= clkCnt + 1;
            F_s_clk <= F_s_clk + 1;

-------------------------------------------------------------------------------
--          Triangle + Square
-------------------------------------------------------------------------------
            if waveForm = TRIANGLE or waveForm = SQUARE then
                
                ----------------------------------------------------------------
                --  Set triangle state - down or up
                ----------------------------------------------------------------
                if clkCnt = T/2 then                    
                    triangleState <= not triangleState;
                    sum <= 2**(11)-1;                    
                elsif clkCnt = T then                
                    clkCnt <= 0;
                    F_s_clk <= 0;
                    squareWave <= not squareWave;
                    triangleState <= not triangleState;
                end if;
                ----------------------------------------------------------------
                --  Sample Increment
                ----------------------------------------------------------------
                if F_s_clk = F_s then                
                    F_s_clk <= 0;                    
                    if triangleState = '1' then                    
                        sum <= sum + inc;                        
                    else                    
                        sum <= sum - inc;                        
                    end if;                    
                end if;
                ----------------------------------------------------------------
                --  Square wave
                ----------------------------------------------------------------
                if clkCnt = duty then                
                    squareWave <= not squareWave;                    
                end if;
                
                triangleWave <= STD_LOGIC_VECTOR(to_signed(sum,12));                
                
                if waveForm = SQUARE then                
                    output <= squareWave;                    
                else                
                    output <= triangleWave;
                end if;
                
-------------------------------------------------------------------------------
--          Saw
-------------------------------------------------------------------------------
            elsif waveForm = SAW1 or waveForm = SAW2 then
            
                --  Set triangle down or up
                if clkCnt = T then
                
                    F_s_clk <= 0;
                    clkCnt <= 0;
                    
                    if waveForm = SAW1 then                    
                        sum <= -2**(11);
                    else
                        sum <= 2**(11)-1;
                    end if;
                    
                --  Increment
                elsif F_s_clk = F_s then
                
                    F_s_clk <= 0;
                    
                    if waveForm = SAW1 then
                        sum <= sum + inc;
                    else
                        sum <= sum - inc;
                    end if;
                
                end if;
                
                sawWave <= STD_LOGIC_VECTOR(to_signed(sum,12));
                output <= sawWave;--(17 downto 6);--18-1 to 18-12 = 17 to 6
                
                
-------------------------------------------------------------------------------
--          Off
-------------------------------------------------------------------------------              
            else
            
                output <= (OTHERS => '0');
            
            end if;
            
        end if;
        
    end if;
 
end process;
end arch_LFO;
