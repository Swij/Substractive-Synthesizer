library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ascii.ALL;

entity LCD_main is
  Generic ( input_clk : integer := 50_000_000;
            i2c_bus_clk : integer := 100_000); -- Delay to wait between commands
  Port (  clk : in  std_logic;
          reset : in  std_logic;
          lcd_bl : in std_logic;
          value : in std_logic_vector(15 downto 0);
          value_type : in integer range 0 to 15;
          lcd_addr : in std_logic_vector(6 downto 0);
          i2c_sda : inout std_logic;
          i2c_scl : inout std_logic);
end LCD_main;

architecture Behavioral of LCD_main is
  type states is (init, idle, update, line_break, clear, ready_down, ready_up);
  signal state : states := init;

  -- Integer to ascii string
  type mem_numbers is array(0 to 15) of std_logic_vector(15 downto 0);
  signal numbers : mem_numbers;

  -- LCD controller component
  component LCD_controller is
    Generic ( input_clk   : integer;
              i2c_bus_clk : integer); -- Delay to wait between commands
    Port (  clk       : in  std_logic;
            reset     : in  std_logic;
            init      : in std_logic; -- Init LCD
            bl        : in std_logic; -- Backlight
            RS        : in std_logic; -- Register select, '0' command, '1' write char
            enable    : in std_logic; -- Send command
            command   : in std_logic_vector(7 downto 0);  -- Command to be sent
            i2c_addr  : in std_logic_vector(6 downto 0); -- Slave address
            ready     : out std_logic; -- ready for new command
            i2c_sda   : inout std_logic;
            i2c_scl   : inout std_logic);
  end component;

  signal lcd_RS : std_logic;
  signal lcd_init : std_logic;
  signal lcd_ready : std_logic;
  signal lcd_enable : std_logic;
  signal lcd_command : std_logic_vector(7 downto 0);

begin
  LCD_controller_inst: LCD_controller
    generic map (input_clk, i2c_bus_clk)
    port map (clk, reset, lcd_init, lcd_bl, lcd_RS, lcd_enable, lcd_command, lcd_addr, lcd_ready, i2c_sda, i2c_scl);

  main_loop:process(clk)
    variable cmd : mem_row;
    variable count : integer range 0 to (mem_row'LENGTH-1) := 0;
    variable updating, row : std_logic := '0';
    variable prev_value : std_logic_vector(15 downto 0) := (others => '0');
    variable prev_value_type, value_type_t : integer range 0 to 15 := 0;
    variable value_BCD_row : BCD_row := (others => (others => '0'));
  begin
    if rising_edge(clk) then
      if reset = '0' then
        state <= init;
        prev_value := (others => '0');
        prev_value_type := 0;
        value_BCD_row := (others => (others => '0'));
        lcd_command <= "00000000";
        lcd_enable <= '0';
        lcd_init <= '0';
        lcd_RS <= '0';
        updating := '0';
        count := 0;
        row := '0';
      else
        case state is
          when init =>
            lcd_init <= '1';
            state <= ready_down;
          when idle =>
            if (prev_value /= value OR prev_value_type /= value_type) then
              value_BCD_row := to_BCD_row(value);
              value_type_t := value_type;
              state <= clear;
              updating := '1';
            end if;
            prev_value := value;
            prev_value_type := value_type;
          when clear =>
            lcd_enable <= '1';
            lcd_command <= X"01";
            state <= ready_down;
          when update =>
            lcd_enable <= '1';
            if row = '0' then
              lcd_command <= types(value_type_t)(count);
            else
              lcd_command <= value_BCD_row(count);
            end if;
            state <= ready_down;
            if count = (mem_row'LENGTH-1) AND row = '0' then
              lcd_RS <= '0';
              row := '1';
              count := 0;
            elsif count = (BCD_row'LENGTH-1) AND row = '1' then
              lcd_RS <= '1';
              updating := '0';
              row := '0';
              count := 0;
            else
              lcd_RS <= '1';
              count := count+1;
            end if;
          when ready_down =>
            if lcd_ready = '0' then
              lcd_init <= '0';
              lcd_enable <= '0';
              state <= ready_up;
            end if;
          when ready_up =>
            if lcd_ready = '1' then
              lcd_RS <= '0';
              if updating = '1' then
                state <= update;
              else
                state <= idle;
              end if;
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process;
end Behavioral;
