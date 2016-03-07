library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aids.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity top_sim is
    port (
        SYSCLK_P  : in STD_LOGIC;
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
        --  DAC
        XADC_GPIO_0 : out STD_LOGIC;  --  LDAC
        XADC_GPIO_1 : out STD_LOGIC;  --  SCLK
        XADC_GPIO_2 : out STD_LOGIC;  --  DIN
        XADC_GPIO_3 : out STD_LOGIC;  --  SYNC

        --  ENCODERS
        FMC1_HPC_HA02_P : in STD_LOGIC;
        FMC1_HPC_HA02_N : in STD_LOGIC;
        FMC1_HPC_HA03_P : in STD_LOGIC;
        FMC1_HPC_HA03_N : in STD_LOGIC;
        FMC1_HPC_HA04_P : in STD_LOGIC;
        FMC1_HPC_HA04_N : in STD_LOGIC;
        FMC1_HPC_HA05_P : in STD_LOGIC;
        FMC1_HPC_HA05_N : in STD_LOGIC;
        FMC1_HPC_HA06_P : in STD_LOGIC;
        FMC1_HPC_HA06_N : in STD_LOGIC;
        FMC1_HPC_HA07_P : in STD_LOGIC;
        FMC1_HPC_HA07_N : in STD_LOGIC;
        FMC1_HPC_HA08_P : in STD_LOGIC;
        FMC1_HPC_HA08_N : in STD_LOGIC;
        FMC1_HPC_HA09_P : in STD_LOGIC;
        FMC1_HPC_HA09_N : in STD_LOGIC;
        FMC1_HPC_HA19_P : in STD_LOGIC;
        FMC1_HPC_HA19_N : in STD_LOGIC;

        FMC1_HPC_HA10_P : out STD_LOGIC; -- +
        FMC1_HPC_HA10_N : out STD_LOGIC  -- -
    );
end top_sim;

architecture arch_top of top_sim is

    --  Clock signals
    signal counter : STD_LOGIC_VECTOR(31 downto 0) :=(others => '0');

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
    signal note2     : STD_LOGIC_VECTOR (7 downto 0);
    signal semi      : STD_LOGIC_VECTOR (4 downto 0);
    signal dutyCycle : STD_LOGIC_VECTOR (7 downto 0);
    signal oscOutput : STD_LOGIC_VECTOR (11 downto 0);
    signal oscOutput2 : STD_LOGIC_VECTOR (11 downto 0);

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


--    signal btnPin   : STD_LOGIC;
    signal change : STD_LOGIC;
    signal dir    : STD_LOGIC;
    signal btn    : STD_LOGIC;


    type encoderArray is array (0 to 5) of std_logic_vector(2 downto 0);
    signal encoders : encoderArray;

    --  Prescale component
    component prescaler is
        generic ( prescale : NATURAL := 4000);
        port ( clk    : IN STD_LOGIC;
               preClk : OUT STD_LOGIC);
    end component;

    signal preClk : STD_LOGIC;

    -- IIR filter
    component IIR is
        generic ( WIDTH : INTEGER:=12);
        port ( clk      : STD_LOGIC;
               fclk     : STD_LOGIC;
               reset    : in STD_LOGIC;
               ftype    : FILTER;
               cutoff   : in integer;
               Q        : in real;
               x        : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
               y        : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
               finished : out STD_LOGIC);
    end component;

    signal cutoff : integer := 1000;
    signal Q : real := 0.7071;
    signal ftype : FILTER := LP;
    signal finished : STD_LOGIC;
    signal filterOut : STD_LOGIC_VECTOR(11 downto 0);
    signal filterIn  : STD_LOGIC_VECTOR(12 downto 0) := (others => '0');

    --  Next below here...
    --  ...

begin
--------------------------------------------------------------------------------

    -- GPIO coupling
    waveForm <= to_wave(GPIO_DIP_SW2 & GPIO_DIP_SW1 & GPIO_DIP_SW0);
    reset <= not GPI0_SW_C;
    enable <=  GPIO_DIP_SW3;
    filterIn <= std_logic_vector(to_signed(to_integer(signed(oscOutput))+to_integer(signed(oscOutput2)), 13));
    --filterIn <= oscOutput & '0';

--------------------------------------------------------------------------------

oscillator_comp:component oscillator
    port map( clk, reset, enable, waveForm, note, semi, dutyCycle, oscOutput );

oscillator_comp2:component oscillator
    port map( clk, reset, enable, waveForm, note2, semi, dutyCycle, oscOutput2 );

encoderTop_comp:component encoderTop
    port map( clk, '1', ROTARY_INCA, ROTARY_INCB, ROTARY_PUSH, change, dir, btn );

prescale_comp:component prescaler
    generic map ( prescale => 1000 )
    port map ( clk, preClk );

IIR_comp:component IIR
    port map ( preClk, clk, reset, ftype, cutoff, Q, filterIn(12 downto 1), filterOut, finished );

--------------------------------------------------------------------------------

top_process:
process(clk)
begin
    if rising_edge(clk) then
        if reset = '0' then
            note <= std_logic_vector(to_unsigned(81, 8));
            note2 <= std_logic_vector(to_unsigned(129, 8));
            dutyCycle <= std_logic_vector(to_unsigned(50, 8));
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
    end if;
end process;

end arch_top;
