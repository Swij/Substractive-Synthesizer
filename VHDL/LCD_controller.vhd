library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--P0 = RS pin
--P1 = RW Pin
--P2 = EnablePin
--P3 = LCD Backlight control pin
--P4 = D4
--P5 = D5
--P6 = D6
--P7 = D7

entity LCD_controller is
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
          ready     : out std_logic;    -- ready for new command
          i2c_sda   : inout std_logic;
          i2c_scl   : inout std_logic);
end LCD_controller;

architecture Behavioral of LCD_controller is
  CONSTANT cmd_delay : INTEGER := integer(real(input_clk)*0.000043);
  CONSTANT clear_delay : INTEGER := integer(real(input_clk)*0.00153);
  type mem_init is array(0 to 5) of std_logic_vector(7 downto 0);
  type states is (idle, initiate, send, busy_up, busy_down, delayer );

  signal state : states;
  constant init_instr : mem_init := (X"33", X"32", X"28", X"0C", X"01", X"80");

  component i2c_master is
    generic(
      input_clk : integer;    --input clock speed from user logic in Hz
      bus_clk   : integer);   --speed the i2c bus (scl) will run at in Hz
    port(
      clk       : IN     std_logic;                    --system clock
      reset_n   : IN     std_logic;                    --active low reset
      ena       : IN     std_logic;                    --latch in command
      addr      : IN     std_logic_vector(6 DOWNTO 0); --address of target slave
      rw        : IN     std_logic;                    --'0' is write, '1' is read
      data_wr   : IN     std_logic_vector(7 DOWNTO 0); --data to write to slave
      busy      : OUT    std_logic;                    --indicates transaction in progress
      data_rd   : OUT    std_logic_vector(7 DOWNTO 0); --data read from slave
      ack_error : BUFFER std_logic;                    --flag if improper acknowledge from slave
      sda       : INOUT  std_logic;                    --serial data output of i2c bus
      scl       : INOUT  std_logic);                   --serial clock output of i2c bus
  end component;

  signal i2c_enable : std_logic;
  signal i2c_data_wr : std_logic_vector(7 downto 0);
  signal i2c_busy : std_logic;
  signal i2c_data_rd : std_logic_vector(7 downto 0);
  signal i2c_ack_error : std_logic;

  signal temp_cmd : std_logic_vector(7 downto 0);
  signal temp_RS : std_logic;
begin
  I2C_inst: i2c_master
    generic map (input_clk, i2c_bus_clk)
    port map (clk, reset, i2c_enable, i2c_addr, '0', i2c_data_wr, i2c_busy, i2c_data_rd, i2c_ack_error, i2c_sda, i2c_scl);

  test:process(clk)
    variable init_cnt : integer range 0 to init_instr'LENGTH := 0;
    variable delay, max_delay : integer range 0 to 400_000 := 0;
    variable send_cnt : integer range 0 to 4 := 0;
    variable initializing : std_logic := '0';
  begin
    if rising_edge(clk) then
      if reset = '0' then
        state <= idle;
        i2c_enable <= '0';
        temp_RS <= '0';
        initializing := '0';
        delay := 0;
        init_cnt := 0;
        send_cnt := 0;
      else
        case state is
          when idle =>
            if enable = '1' then
              temp_cmd <= command;
              temp_RS <= RS;
              ready <= '0';
              state <= send;
            elsif init = '1' then
              initializing := '1';
              temp_RS <= '0';
              ready <= '0';
              state <= initiate;
            else
              ready <= '1';
              state <= idle;
            end if;
          when initiate => -- Run initiation commands for the LCD
            if init_cnt < init_instr'LENGTH then
              temp_cmd <= init_instr(init_cnt);
              init_cnt := init_cnt+1;
              state <= send;
            else
              init_cnt := 0;
              initializing := '0';
              state <= idle;
            end if;
          when send =>
            if send_cnt = 4 then -- All four send stages completed
              if initializing = '0' then -- Check if command was part of init
                state <= idle;
              else
                state <= initiate;
              end if;
              send_cnt := 0;
            else
              i2c_enable <= '1';
              state <= busy_up;
              case send_cnt is
                when 0 => -- Send bits 7-4 first with EN=1
                  i2c_data_wr <= ((temp_cmd AND X"F0") OR ("0000" & bl & "10" & temp_RS));
                when 1 => -- Send same command but with EN=0
                  i2c_data_wr <= ((temp_cmd AND X"F0") OR ("0000" & bl & "00" & temp_RS));
                when 2 => -- Send bits 3-0 with with EN=1
                  i2c_data_wr <= ((temp_cmd(3 downto 0) & "0000") OR ("0000" & bl & "10" & temp_RS));
                when others => -- Send same command but with EN=0
                  i2c_data_wr <= ((temp_cmd(3 downto 0) & "0000") OR ("0000" & bl & "00" & temp_RS));
              end case;
              send_cnt := send_cnt+1;
            end if;
          when busy_up => -- Wait for i2c busy flag to be raised
            if i2c_busy = '0' then
              state <= busy_up;
            else
              state <= busy_down;
            end if;
          when busy_down =>  -- Wait for i2c busy flag to be lowered
            if i2c_busy = '1' then
              i2c_enable <= '0';
              state <= busy_down;
            else
              state <= delayer;
            end if;
          when delayer => -- Wait for 2ms to allow LCD to complete the command
            if initializing = '1' OR temp_cmd = X"01" then
              max_delay := clear_delay; -- 2ms
            else
              max_delay := cmd_delay; -- 50us
            end if;
            if delay < max_delay then -- 2ms delay @ 50MHz
              state <= delayer;
              delay := delay+1;
            else
              state <= send;
              delay := 0;
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process;
end Behavioral;
