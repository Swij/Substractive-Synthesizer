library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aids.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity top is
    port ( SYSCLK_P  : in STD_LOGIC;
           SYSCLK_N  : in STD_LOGIC;
           GPIO_SW_N : in STD_LOGIC;
           GPIO_SW_S : in STD_LOGIC;
           GPIO_SW_W : in STD_LOGIC;
           GPIO_SW_E : in STD_LOGIC;
           GPIO_SW_C : in STD_LOGIC;
           GPIO_LED_0 : out STD_LOGIC;
           GPIO_LED_1 : out STD_LOGIC;
           GPIO_LED_2 : out STD_LOGIC;
           GPIO_LED_3 : out STD_LOGIC;
           --FMC1_HPC_HA09_P : in STD_LOGIC;
           --FMC1_HPC_HA09_N : in STD_LOGIC;
           ROTARY_INCA : in STD_LOGIC;
           ROTARY_INCB : in STD_LOGIC;
           ROTARY_PUSH : in STD_LOGIC;
           GPIO_DIP_SW0 : in STD_LOGIC;
           GPIO_DIP_SW1 : in STD_LOGIC;
           GPIO_DIP_SW2 : in STD_LOGIC;
           GPIO_DIP_SW3 : in STD_LOGIC;
           XADC_GPIO_0 : out STD_LOGIC;  --  LDAC
           XADC_GPIO_1 : out STD_LOGIC;  --  SCLK
           XADC_GPIO_2 : out STD_LOGIC;  --  DIN
           XADC_GPIO_3 : out STD_LOGIC   --  SYNC
    );
end top;

architecture arch_top of top is

    --  Clock signals
    signal clk : STD_LOGIC;
    signal counter : STD_LOGIC_VECTOR(31 downto 0) :=(others => '0');
    signal I : STD_LOGIC;
    signal IB : STD_LOGIC;

    --  Oscillator component and signals
    component oscillator is
    port ( clk       : in STD_LOGIC;
           reset     : in STD_LOGIC;
           enable    : in STD_LOGIC;
           waveForm  : in WAVE;
           note      : in STD_LOGIC_VECTOR (7 downto 0);
           semi      : in STD_LOGIC_VECTOR (4 downto 0);
           dutyCycle : in STD_LOGIC_VECTOR (7 downto 0);
           output    : out STD_LOGIC_VECTOR (11 downto 0));
    end component;

    signal reset     : STD_LOGIC;
    signal enable    : STD_LOGIC;
    signal waveForm  : WAVE;
    signal note      : STD_LOGIC_VECTOR (7 downto 0);
    signal semi      : STD_LOGIC_VECTOR (4 downto 0);
    signal dutyCycle : STD_LOGIC_VECTOR (7 downto 0);
    signal output    : STD_LOGIC_VECTOR (11 downto 0);

    --  Encoder component
    component encoderTop is
    port(
        clk    : in STD_LOGIC;
        reset  : in STD_LOGIC;        
        A      : in STD_LOGIC;        
        B      : in STD_LOGIC;                
        C      : in STD_LOGIC;        
        change : out STD_LOGIC;
        dir    : out STD_LOGIC;
        btn    : out STD_LOGIC);
    end component;
    
--    --signal btnPin   : STD_LOGIC;
    signal change : STD_LOGIC;
    signal dir    : STD_LOGIC;
    signal btn    : STD_LOGIC;

    --  Prescale component
--    component prescaler is
--        generic (prescale : NATURAL := 4000);
--        port ( 
--            clk    : IN STD_LOGIC;
--            preClk : OUT STD_LOGIC
--        );
--    end component;
    
--    signal preClk : STD_LOGIC;
     
    -- IIR filter component
--    component IIR is
--        generic ( WIDTH : INTEGER:=12);
--        port ( clk      : STD_LOGIC;
--               x        : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
--               reset    : in STD_LOGIC;
--               y        : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
--               finished : out STD_LOGIC);
--    end component;

--    signal finished : STD_LOGIC;
--    signal filterOut : STD_LOGIC_VECTOR(11 downto 0);
--    signal filterIn  : STD_LOGIC_VECTOR(11 downto 0);

    --  DAC component
    component AD5065_DAC is
    generic( totalBits : natural := 32;
             dataBits  : natural := 16 );
    port( clk   : in std_logic;
          reset : in std_logic;
          data  : in std_logic_vector(dataBits-1 DOWNTO 0);
          start : in std_logic;
          ready : out std_logic;
          SCLK  : out std_logic;   
          SYNC  : out std_logic;
          SDO   : out std_logic;
          LDAC  : out std_logic);
    end component;

    signal DACdata  : std_logic_vector(15 DOWNTO 0);
    signal DACstart : std_logic;
    signal DACready : std_logic;

    --  Envelope component
    component ASR is
    generic( WIDTH : integer := 12);
    port( clk      : in std_logic;
          reset    : in std_logic;
          x        : in std_logic_vector(WIDTH-1 downto 0);
          attack   : in std_logic;
          release  : in std_logic;
          atk_time : in std_logic_vector(WIDTH-1 downto 0);
          rls_time : in std_logic_vector(WIDTH-1 downto 0);
          y        : out std_logic_vector(WIDTH-1 downto 0));
    end component;
    
    signal ASR_x        : std_logic_vector(12-1 downto 0);
    signal ASR_attack   : std_logic;
    signal ASR_release  : std_logic;
    signal ASR_atk_time : std_logic_vector(12-1 downto 0);
    signal ASR_rls_time : std_logic_vector(12-1 downto 0);
    signal ASR_y        : std_logic_vector(12-1 downto 0);
    
    --  Next below here...
    --  ...


    --  Test signals and others...
    signal gpioLEDS   : std_logic_vector(3 downto 0);
    
       
begin    
--------------------------------------------------------------------------------

IBUFDS_inst: IBUFDS
generic map (
    --IBUF_LOW_PWR => TRUE,
    IOSTANDARD => "LVDS_25")
port map (
    O => clk,     -- clock buffer output
    I => I,       -- diff_p clock buffer input
    IB => IB      -- diff_n clock buffer input
);

    I <= SYSCLK_P;
    IB <= SYSCLK_N;

--------------------------------------------------------------------------------

oscillator_comp:component oscillator
    port map( clk, reset, enable, waveForm, note, semi, dutyCycle, output );

encoderTop_comp:component encoderTop
    port map( clk, '1', ROTARY_INCA, ROTARY_INCB, ROTARY_PUSH, change, dir, btn );

--prescale_comp:component prescaler
--    generic map ( prescale => 4000 )
--    port map ( clk, preClk );

--IIR_comp:component IIR
--    port map ( preClk, filterIn, reset, filterOut, finished );

DAC_comp:component AD5065_DAC
    port map( clk, reset, DACdata, DACstart, DACready, XADC_GPIO_1, XADC_GPIO_3, XADC_GPIO_2, XADC_GPIO_0 );

ASR_comp:component ASR
    port map( clk, reset, ASR_x, ASR_attack, ASR_release, ASR_atk_time, ASR_rls_time, ASR_y );

--------------------------------------------------------------------------------
----         GPIO     coupling
--------------------------------------------------------------------------------

    GPIO_LED_0 <= gpioLEDS(0);
    GPIO_LED_1 <= gpioLEDS(1);
    GPIO_LED_2 <= gpioLEDS(2);
    GPIO_LED_3 <= gpioLEDS(3);

top_process:
process(clk)
begin

    if rising_edge(clk) then
    
    --  CHANGING NOTE
        if GPIO_SW_N = '1' then     --tryck ner, blir hög
        
            reset <= '0';            
            gpioLEDS(0) <= '0';
            gpioLEDS(1) <= '0';
            gpioLEDS(2) <= '1';
            gpioLEDS(3) <= '1';
            
        else
        
            reset <= '1';
            
         
       --  NOTE CHANGE WITH THE ENCODER
            if change = '1' then
                if dir = '1' then
                    gpioLEDS(0) <= not(gpioLEDS(0));
                    gpioLEDS(1) <= not(gpioLEDS(1));                    
                    if unsigned(note) < 95 then
                        note <= std_logic_vector(unsigned(note) + 1);
                    end if;
                else
                    gpioLEDS(2) <= not(gpioLEDS(2));
                    gpioLEDS(3) <= not(gpioLEDS(3));                    
                    if unsigned(note) > 0 then
                        note <= std_logic_vector(unsigned(note) - 1);
                    end if;
                end if;
            end if;   
            
        --  DAC               
            if DACready = '1' then
                DACdata(15 downto 12) <= (OTHERS => '0');
                DACdata(11 downto 0) <= std_logic_vector(signed(output) + 2048);
                DACstart <= '1';
            else
                DACstart <= '0';
            end if;
            
        --  Select Wave
        --  000=Sine, 001=Cosine, 010=Square, 011=Triangle, 100=Saw1, 101=Saw2, 110=Noise, 111=???
            waveForm <= to_wave(GPIO_DIP_SW2 & GPIO_DIP_SW1 & GPIO_DIP_SW0);
            dutyCycle <= "00110010";
            semi <= "00000";
            enable <= '1';
            
        end if;  
         

    end if;
    
end process;    
end arch_top;