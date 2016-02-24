library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity top_sim is
    port (  clk     : in STD_LOGIC; 
            fclk    : in STD_LOGIC;
            reset   : in STD_LOGIC);
end top_sim;

architecture arch_top of top_sim is
    --  Clock signals
    signal counter : STD_LOGIC_VECTOR(31 downto 0) :=(others => '0');

    --  Oscillator component and signals
    component oscillator is
    port(
        clk       : in STD_LOGIC;
        reset     : in STD_LOGIC;
        enable    : in STD_LOGIC;
        waveForm  : in STD_LOGIC_VECTOR (2 downto 0);
        note      : in STD_LOGIC_VECTOR (7 downto 0);
        semi      : in STD_LOGIC_VECTOR (4 downto 0);
        dutyCycle : in STD_LOGIC_VECTOR (7 downto 0);
        output    : out STD_LOGIC_VECTOR (11 downto 0)
        );
    end component;

    --signal reset     : STD_LOGIC;
    signal enable    : STD_LOGIC;
    signal waveForm  : STD_LOGIC_VECTOR (2 downto 0);
    signal note      : STD_LOGIC_VECTOR (7 downto 0);
    signal semi      : STD_LOGIC_VECTOR (4 downto 0);
    signal dutyCycle : STD_LOGIC_VECTOR (7 downto 0);
    signal output    : STD_LOGIC_VECTOR (11 downto 0);

    --  Encoder component
    component encoder is
    port(
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        grayPins    : in STD_LOGIC_VECTOR (1 downto 0);
        btnPin      : in STD_LOGIC;
        change      : out STD_LOGIC;
        dir         : out STD_LOGIC;
        btn         : out STD_LOGIC);
    end component;

    signal grayPins : STD_LOGIC_VECTOR (1 downto 0);
    signal btnPin   : STD_LOGIC;
    signal change   : STD_LOGIC;
    signal dir      : STD_LOGIC;
    signal btn      : STD_LOGIC;

    --  Prescale component
--    component prescaler is
--        generic (prescale : NATURAL := 4);
--        port (
--            clk    : IN STD_LOGIC;
--            preClk : OUT STD_LOGIC
--        );
--    end component;

    signal preClk : STD_LOGIC;

    -- IIR filter
    component IIR is
          generic(WIDTH:INTEGER:=12);
          port(clk:STD_LOGIC;
             x:in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
             set:in STD_LOGIC;
             y:out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
             finished:out STD_LOGIC);
       end component;

    signal set : STD_LOGIC;
    signal finished : STD_LOGIC;
    signal filterOut : STD_LOGIC_VECTOR(11 downto 0);
    signal filterIn  : STD_LOGIC_VECTOR(11 downto 0);

    --  Next below here...
    --  ...

begin
--------------------------------------------------------------------------------
set <= not reset;

oscillator_comp:
component oscillator
    port map(
        clk, reset, enable, waveForm, note, semi, dutyCycle, output
    );

encoder_comp:
component encoder
    port map(
        clk, reset, grayPins, btnPin, change, dir, btn
    );

--prescale_comp:
--component prescaler
--    port map(
--        clk, preClk
--    );

IIR_comp:
component IIR
    port map(
        clk, filterIn, set, filterOut, finished
    );

--------------------------------------------------------------------------------

    

--------------------------------------------------------------------------------

top_process:
process(clk)
begin
    if reset = '0' then
        enable <= '0';
        waveForm <= "000";
        note <= "00000000";
        dutyCycle <= "00000000";
        semi <= "00000";
    elsif rising_edge(clk) then
        enable <= '1';
        waveForm <= "001";
        note <= "01011001";--"10000011";
        dutyCycle <= "00010010";
        semi <= "00000";
    end if;
end process;

filter_clk:process(fclk)
begin
    if reset = '0' then
        filterIn <= (others => '0');
    elsif rising_edge(fclk) then
        filterIn <= output(11 downto 0);
    end if;
end process;

end arch_top;


