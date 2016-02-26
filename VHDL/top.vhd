-- DIP-Switch 2->0 selects wave
--   000=Sine, 001=Cosine, 010=Square, 011=Triangle, 100=Saw1, 101=Saw2, 110=Noise, 111=???
--
-- DIP-Switch 3 enable/disable oscillator
--
-- GPI0_SW_N - Semi up
-- GPI0_SW_S - Semi down
-- GPI0_SW_E - Tune up
-- GPI0_SW_W - Tune down
-- GPI0_SW_C - Reset

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
           GPIO_DIP_SW3 : in STD_LOGIC);
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
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;        
        A       : in STD_LOGIC;        
        B       : in STD_LOGIC;                
        C      : in STD_LOGIC;        
        change      : out STD_LOGIC;
        dir         : out STD_LOGIC;
        btn         : out STD_LOGIC);
    end component;
    
--    signal btnPin   : STD_LOGIC;
    signal change   : STD_LOGIC;
    signal dir      : STD_LOGIC;
    signal btn      : STD_LOGIC;

    --  Prescale component
    component prescaler is
        generic (prescale : NATURAL := 4000);
        port ( 
            clk    : IN STD_LOGIC;
            preClk : OUT STD_LOGIC
        );
    end component;
    
    signal preClk : STD_LOGIC;
     
    -- IIR filter
    component IIR is
        generic ( WIDTH : INTEGER:=12);
        port ( clk      : STD_LOGIC;
               x        : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
               set      : in STD_LOGIC;
               y        : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
               finished : out STD_LOGIC);
    end component;

    signal set : STD_LOGIC;
    signal finished : STD_LOGIC;
    signal filterOut : STD_LOGIC_VECTOR(11 downto 0);
    signal filterIn  : STD_LOGIC_VECTOR(11 downto 0);

    --  Next below here...
    --  ...
       
    signal tgl : std_logic := '0';
    signal encoderSig : std_logic_vector(3 downto 0); 
    signal gpioLEDS : std_logic_vector(3 downto 0);
    
       
begin
--------------------------------------------------------------------------------
    -- GPIO coupling
    waveForm <= to_wave(GPIO_DIP_SW2 & GPIO_DIP_SW1 & GPIO_DIP_SW0);
    reset <= not GPI0_SW_C;
    enable <=  GPIO_DIP_SW3;
    set <= not reset;

    GPIO_LED_0 <= gpioLEDS(0);
    GPIO_LED_1 <= gpioLEDS(1);
    GPIO_LED_2 <= gpioLEDS(2);
    GPIO_LED_3 <= gpioLEDS(3);

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

  IIR_comp:component IIR
    port map ( clk, filterIn, set, filterOut, finished );

--------------------------------------------------------------------------------
   
top_process:
process(clk)
begin
    if rising_edge(clk) then
      if reset = '0' then
          note <= "01000010"; -- note 66
          dutyCycle <= "10000000";
          semi <= "00000";
      else
          if GPI0_SW_N = '1' then -- Semi up

          elsif GPI0_SW_S = '1' then -- Semi down

          elsif GPI0_SW_E = '1' then -- Tune up
              if unsigned(note) < 131 then
                  note <= std_logic_vector(unsigned(note)+1);
              end if;
          elsif GPI0_SW_W = '1' then -- Tune down
              if unsigned(note) > 0 then
                  note <= std_logic_vector(unsigned(note)-1);
              end if;
          end if;
      end if;

--        if change = '1' then
--            if dir = '1' then
--                if encoderSig /= "1000" then
--                    encoderSig <= std_logic_vector(shift_left(unsigned(encoderSig),1));
--                else
--                    encoderSig <= "0001";
--                end if;
--            else
--                if encoderSig /= "0001" then
--                    encoderSig <= std_logic_vector(shift_right(unsigned(encoderSig),1));
--                else
--                    encoderSig <= "1000";
--                end if;
--            end if;
--        end if;
    
    if change = '1' then
        if dir = '1' then
            gpioLEDS(0) <= not(gpioLEDS(0));
            gpioLEDS(1) <= not(gpioLEDS(1));
        else
            gpioLEDS(2) <= not(gpioLEDS(2));
            gpioLEDS(3) <= not(gpioLEDS(3));
        end if;
    end if;
        
        --gpioLEDS <= encoderSig;
        
--        if encoderSig = "0000" then        
--            encoderSig <= "0001";
--        end if;
        
--        cnt := cnt + 1;
--        if cnt = 200000 then
        
--            cnt := 0;
--            tgl <= not(tgl);
--            FMC1_HPC_HA09_P <= tgl;
                   
        
--        end if;

        
        
--        if FMC1_HPC_HA09_N = '1' then
--            GPIO_LED_1 <= '1';
--        else
--            GPIO_LED_1 <= '0';
--        end if;
        
        
        
--        if FMC1_HPC_HA09_P = '0' then
--            GPIO_LED_2 <= '1';        
--        else
--            GPIO_LED_2 <= '0';
--        end if;
        
    
    
--        if GPIO_SW_N = '1' then
--              GPIO_LED_0 <= '1';
--        else
--              GPIO_LED_0 <= '0';
--        end if;
        
    end if;
    
end process;    
end arch_top;
