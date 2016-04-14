library IEEE;
library ieee_proposed;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aids.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity top_filter is
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
end top_filter;

architecture arch_top of top_filter is

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
    signal note2     : STD_LOGIC_VECTOR (7 downto 0);
    signal semi      : STD_LOGIC_VECTOR (4 downto 0);
    signal dutyCycle : STD_LOGIC_VECTOR (7 downto 0);
    signal oscOutput : STD_LOGIC_VECTOR (11 downto 0);
    signal oscOutput2 : STD_LOGIC_VECTOR (11 downto 0);
    signal oscOutComb : STD_LOGIC_VECTOR (12 downto 0);

    --  Prescale component
    component prescaler is
        generic ( prescale : NATURAL);
        port ( clk    : IN STD_LOGIC;
               preClk : OUT STD_LOGIC);
    end component;

    signal preClk : STD_LOGIC;

    -- IIR filter
    component IIR is
        generic ( WIDTH : INTEGER := 12;
                  F_WIDTH : INTEGER := 12);
        port ( clk      : STD_LOGIC;
               fclk     : STD_LOGIC;
               reset    : in STD_LOGIC;
               ftype    : FILTER;
               cutoff   : in integer;
               Q        : in sfixed(16 downto -F_WIDTH);
               x        : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
               y        : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
    end component;

    signal cutoff : integer;
    signal Q : sfixed(16 downto -12);
    signal ftype : FILTER := LP;
    signal filterOut : STD_LOGIC_VECTOR(11 downto 0);
    signal filterIn  : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal enablefilter : STD_LOGIC;

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

    --  Next below here...
    --  ...

begin
--------------------------------------------------------------------------------
--MAGI

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
    -- standard Q
    Q <= to_sfixed(0.7071,Q);

    -- GPIO coupling
    waveForm <= to_wave(GPIO_DIP_SW2 & GPIO_DIP_SW1 & GPIO_DIP_SW0);
    reset <= not GPIO_SW_C;
    enable <=  '1';
    enablefilter <= GPIO_DIP_SW3;
    --oscOutComb <= std_logic_vector(to_signed(to_integer(signed(oscOutput))+to_integer(signed(oscOutput2)), 13));
    --filterIn <= oscOutComb(12 downto 1);
    filterIn <= oscOutput;
--------------------------------------------------------------------------------

oscillator_comp:component oscillator
    port map( clk, reset, enable, waveForm, note, semi, dutyCycle, oscOutput );

oscillator_comp2:component oscillator
    port map( clk, reset, enable, waveForm, note2, semi, dutyCycle, oscOutput2 );

prescale_comp:component prescaler
    generic map ( prescale => 5000 )
    port map ( clk, preClk );

IIR_comp:component IIR
    port map ( preClk, clk, reset, ftype, cutoff, Q, filterIn, filterOut );

DAC_comp:component AD5065_DAC
    port map( clk, reset, DACdata, DACstart, DACready, XADC_GPIO_1, XADC_GPIO_3, XADC_GPIO_2, XADC_GPIO_0 );

--------------------------------------------------------------------------------

top_process:
process(clk)
begin
    if rising_edge(clk) then
        if reset = '0' then
            note <= std_logic_vector(to_unsigned(47, 8));
            note2 <= std_logic_vector(to_unsigned(95, 8));
            dutyCycle <= std_logic_vector(to_unsigned(50, 8));
            cutoff <= 1000;
            semi <= "00000";
        else
            if GPIO_SW_N = '1' then -- filter up
                if cutoff < 5000 then
                    cutoff <= cutoff+500;
                end if;
            elsif GPIO_SW_S = '1' then -- filter down
                if cutoff > 0 then
                    cutoff <= cutoff-500;
                end if;
            elsif GPIO_SW_E = '1' then -- Tune up
                if unsigned(note) < 95 then
                    note <= std_logic_vector(unsigned(note)+1);
                end if;
            elsif GPIO_SW_W = '1' then -- Tune down
                if unsigned(note) > 0 then
                    note <= std_logic_vector(unsigned(note)-1);
                end if;
            end if;
            if preClk = '1' then
                if DACready = '1' then
                    DACdata(3 downto 0) <= (OTHERS => '0');
                    if enablefilter = '1' then
                        DACdata(15 downto 4) <= std_logic_vector(signed(filterOut) + 2048);
                    else
                        DACdata(15 downto 4) <= std_logic_vector(signed(oscOutput) + 2048);
                    end if;
                    DACstart <= '1';
                else
                    DACstart <= '0';
                end if;
            end if;
        end if;
    end if;
end process;

end arch_top;
