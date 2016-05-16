LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MCP3202_ADC IS
    GENERIC ( WIDTH : NATURAL := 12);
    PORT ( 
        clk : IN STD_LOGIC;
    
        cs : OUT STD_LOGIC;
        sck : OUT STD_LOGIC;
        si : IN STD_LOGIC;
        so : OUT STD_LOGIC;
        
        conversion : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
        settings : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        
        get_conversion : IN STD_LOGIC;
        rdy_conversion : OUT STD_LOGIC
    );
END MCP3202_ADC;

ARCHITECTURE arch_MCP3202_ADC OF MCP3202_ADC IS

SIGNAL idle_state : STD_LOGIC := '1';
SIGNAL transmit_state : STD_LOGIC := '0';
SIGNAL setup_state : STD_LOGIC := '0';
SIGNAL run_sck_state : STD_LOGIC := '0';
SIGNAL rx_delay_state : STD_LOGIC := '0';
SIGNAL recieve_state : STD_LOGIC := '0';
SIGNAL end_state : STD_LOGIC := '0';
SIGNAL sck_ref : STD_LOGIC := '0';

BEGIN

    adc_process:
    PROCESS(clk)
    VARIABLE index_cnt : NATURAL RANGE 0 TO (WIDTH-1):= 0;
    VARIABLE setup_cnt : NATURAL RANGE 0 TO 10 := 0;
    VARIABLE sck_cnt : NATURAL RANGE 0 TO 25 := 0;
    VARIABLE do_cnt : NATURAL RANGE 0 TO 99 := 0;
    BEGIN

        IF rising_edge(clk) THEN
        
        --  SCK = 2 MHz, T/2 = 250 ns.
        --  Here the clk is run and input data is read.
            IF run_sck_state = '1' THEN 
                IF sck_cnt = 24 THEN
                
                    sck <= sck_ref;
                    sck_ref <= NOT(sck_ref);
                    sck_cnt := 0;

                    IF end_state = '1' AND sck_ref = '0' THEN
                        
                        run_sck_state <= '0';
                        recieve_state <= '0';
                        cs <= '1';
                        rdy_conversion <= '1';
                        do_cnt := 1;
                                   
                    ELSIF recieve_state = '1' AND sck_ref = '1' THEN
                
                        conversion(index_cnt) <= si;
                    
                        IF index_cnt /= 0 THEN
                            index_cnt := index_cnt - 1;
                        ELSIF index_cnt = 0 THEN 
                            end_state <= '1';

                        END IF;
                    
                    END IF;  
                ELSE
                    sck_cnt := sck_cnt + 1;
                END IF;
            END IF;
                 
        --  Start requested conversion by transmitting setup data.
            IF get_conversion = '1' AND idle_state = '1' THEN
                     --IF transmit_state = '0' THEN
                         rdy_conversion <= '0';
                         idle_state <= '0';
                         setup_state <= '1';
                         setup_cnt := 0;
                         cs <= '0';
                         index_cnt := 3;
                         conversion <= (OTHERS => '0');

                     --END IF;
                --END IF;  

        --  Waiting for setup time for CS (100ns) to pass.		  
            ELSIF setup_state = '1' THEN
            --  After 5 clk 'so' (serial out )is initiated to ensure 
            --  the input setup time of 50 ns.
                IF setup_cnt = (5-1) THEN
                    so <= settings(index_cnt);
                    index_cnt := 2;
                    setup_cnt := setup_cnt + 1;
                    
            --  SCK will start running after 100ns.        
                ELSIF setup_cnt = (10-1) THEN
                --  Reseting clock variables.
                    run_sck_state <= '1';
                    sck_ref <= '1';
                    sck_cnt := 24;
                --  Setup complete, starting transmission state.    
                    setup_state <= '0';
                    transmit_state <= '1';
                    do_cnt := 5;
                ELSE
                    setup_cnt := setup_cnt + 1;
                END IF;

        --  Is transmitting.
            ELSIF transmit_state = '1' THEN
            
                IF do_cnt = 49 THEN
                
                    do_cnt := 0;
                    
                    IF index_cnt /= 0 THEN
                        so <= settings(index_cnt);
                        index_cnt := index_cnt - 1;
                    ELSIF index_cnt = 0 THEN
                        so <= settings(index_cnt);
                        transmit_state <= '0';
                        rx_delay_state <= '1';
                        do_cnt := 0;
                    END IF;
                ELSE
                    do_cnt := do_cnt + 1;
                END IF;

        --  Delay for the incoming NULL-bit.
            ELSIF rx_delay_state = '1' THEN
            
                IF do_cnt = 99 THEN
                
                    do_cnt := 0;
                    rx_delay_state <= '0';
                    recieve_state <= '1';
                    index_cnt := WIDTH-1;
                    
                ELSE
                    do_cnt := do_cnt + 1;
                END IF;

        --  Delay for CS disable time (100 ns).
            ELSIF end_state = '1' AND run_sck_state = '0' THEN
            
                IF do_cnt = 49 THEN                
                    do_cnt := 0;
                    end_state <= '0';
                    idle_state <= '1';                    
                ELSE
                    do_cnt := do_cnt + 1;
                END IF;

        --  Idle-mode, not transmitting.
            ELSIF idle_state = '1' THEN
                cs <= '1';
                sck <= '0';
                rdy_conversion <= '1';
                setup_state <= '0';
                setup_cnt := 0;
                run_sck_state <= '0';
              
            END IF;
            
        END IF;
    
    END PROCESS;

END arch_MCP3202_ADC;