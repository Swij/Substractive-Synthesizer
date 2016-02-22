library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity top is
    
    port(
        SYSCLK_P  : in STD_LOGIC;
        SYSCLK_N  : in STD_LOGIC;
        GPIO_SW_N : in STD_LOGIC
    );
          
end top;

architecture arch_top of top is

    --  State machine stuff     
    type States is (Restart,Idle);
    signal state : States;
   
    --  Clock signals
    signal clk : STD_LOGIC;
    signal counter : STD_LOGIC_VECTOR(31 downto 0) :=(others => '0');
    signal I : STD_LOGIC;
    signal IB : STD_LOGIC;

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
           
    signal reset     : STD_LOGIC;
    signal enable    : STD_LOGIC;
    signal waveForm  : STD_LOGIC_VECTOR (1 downto 0);
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
    component prescaler is
        generic (prescale : NATURAL := 4);
        port ( 
            clk    : IN STD_LOGIC;
            preClk : OUT STD_LOGIC
        );
    end component;
    
    signal preClk : STD_LOGIC;
     
    --  Next below here...
    --  ...
       
begin

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
   
oscillator_comp:
component oscillator
    port map(
        clk, reset, enable, waveForm, note, semi, dutyCycle, restart, output
    );

encoder_comp:
component encoder
    port map(
        clk, reset, grayPins, btnPin, change, dir, btn
    );

prescale_comp:
component prescaler
    port map(
        clk, preClk
    );
    
--------------------------------------------------------------------------------

    enable <= '0';
    waveForm <= "001";
    note <= "10000011";
    dutyCycle <= "00010010";
    semi <= "00000";    

--------------------------------------------------------------------------------
   
top_process:
process(clk)
begin

    if rising_edge(clk) then
    
        if GPIO_SW_N = '1' then
    
            reset <= '0';
            state <= Restart;
            
        else
            
            case state is
            
            when Restart =>
                
                enable <= '0';
                restart <= '1';
                state <= Idle;
            
            when Idle =>
            
                enable <= '1';
                restart <= '0';
            
            end case;            
                        
        end if;
    
    
        if GPIO_DIP_SW0 = '1' then
              GPIO_LED_0 <= '1';
        else
              GPIO_LED_0 <= '0';
        end if;
        
    end if;
    
end process;    
end arch_top;
