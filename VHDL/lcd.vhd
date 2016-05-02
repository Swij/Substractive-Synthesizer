library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lcd is

    port(
        clk    : in  std_logic;
        reset  : in  std_logic;
        
        --  LCD interface
        LCD_RS : out std_logic;
        LCD_RW : out std_logic;
		LCD_E  : out std_logic;
        DATA   : out std_logic_vector(7 downto 0);
        
        --  Init and write command.
        cmd	   : in std_logic_vector(3 downto 0);   --  Let's say for now there are 16 different prints, for the 1st row.
        int    : in std_logic_vector(13 downto 0);  --  An integer value to print on the 2nd row.

		write  : in std_logic;  					--  Write enable.
		init   : in std_logic;   					--  Init enable.
                clear   : in std_logic;                       --  Init enable.
		
		led	   : out std_logic_vector(3 downto 0) 
	);

end lcd;

architecture arch_lcd of lcd is

	type stateType is (
		 functionSet, idleState, toggleEnable, clearDisplay, displayOn, displayOff, entryMode, printState, returnHome );
	signal currState, nextState : stateType;
	
	type sentence is array (0 to 15) of std_logic_vector(7 downto 0);
	signal freak : sentence := (X"10",X"10",X"10",X"46",X"72",X"65",X"61",X"6B",X"75",X"65",X"6E",X"63",X"79",X"10",X"10",X"10");
	signal tempReg : sentence;
	
begin

    process (clk, reset)
    variable enableCnt : integer;-- range 0 to 2**20 - 1;
    variable enableCnt2 : integer;-- range 0 to 2**20 - 1;
	
    variable printCnt  : integer range 0 to 31;
    begin
	
		if reset = '0' then
		
			currState <= functionSet;
			nextState <= functionSet;
			
			LCD_E  <= '0';
			LCD_RS <= '0';
			LCD_RW <= '0';
			DATA   <= X"38";
						
            enableCnt := 0;
            printCnt  := 0;
            
            led <= "0000";
    
		elsif rising_edge(clk) then
		
			case currState is
 
				when idleState =>
				
					LCD_E  <= '0';
					LCD_RS <= '0';
					LCD_RW <= '0';
							
					if write = '1' then
					
						currState <= printState;
						nextState <= printState;
						printCnt := 0;
						
					elsif init = '1' then
					
						currState <= functionSet;
						nextState <= functionSet;

                        						
					else 
					
						currState <= idleState;
						nextState <= idleState;
															
					end if; 
					
					led(0) <= '1';					
					led(1) <= '0';					
					led(2) <= '0';					
					led(3) <= '0';

				when toggleEnable => -- e minimum 300ns
				
					if enableCnt2 = 20 then
						LCD_E <= '1';
					elsif enableCnt2 = 80 then
						LCD_E <= '0';
					else
					    enableCnt2 := enableCnt2 + 1;
					end if;
					
					
					if enableCnt = 0 then
						currState <= nextState;
					else
						currState <= toggleEnable;
						enableCnt := enableCnt - 1;	
					end if;

					led(0) <= '0';					
					led(1) <= '1';					
					led(2) <= '0';					
					led(3) <= '0';
												 
				when functionSet =>  --  39 us, 7800 clk
				
					--LCD_E  <= '1';
					LCD_RS <= '0';
					LCD_RW <= '0';
					DATA   <= X"38";  --  8-bit data transfer and 5x8 font
					
					currState <= toggleEnable;
					nextState <= displayOff;
					enableCnt := 78000;
					enableCnt2 := 0;
										
				when displayOff =>  --  x ms

					--LCD_E  <= '1';
					LCD_RS <= '0';
					LCD_RW <= '0';
					DATA   <= X"08";  -- Display On, Cursor Off, Blink Off
					currState <= toggleEnable;
					nextState <= clearDisplay;
					enableCnt := 78000;					
					enableCnt2 := 0;
					
				when clearDisplay =>  --  1.53 ms, 306000 clk, 19 bits required
			
					--LCD_E  <= '1';
					LCD_RS <= '0';
					LCD_RW <= '0';
					DATA   <= X"01";
					currState <= toggleEnable;
					nextState <= displayOn;
					enableCnt := 3060000;
					enableCnt2 := 0;
                    					
				when displayOn =>  --  x ms

					--LCD_E  <= '1';
					LCD_RS <= '0';
					LCD_RW <= '0';
                                        --DATA   <= X"0C";  -- Display On, Cursor Off, Blink Off
                                        DATA   <= X"0F";  -- Display On, Cursor On, Blink On
					currState <= toggleEnable;
					nextState <= entryMode;
					enableCnt := 78000;
					enableCnt2 := 0;
					
				when entryMode =>  --  39 us
			
					--LCD_E  <= '1';
					LCD_RS <= '0';
					LCD_RW <= '0';
					DATA   <= X"06";  -- Cursor to the right, no shift
					currState <= toggleEnable;
					--nextState <= idleState;
					nextState <= printState;
					enableCnt := 78000;
												
				when printState =>
				
					--LCD_E  <= '1';
					LCD_RS <= '1';
					LCD_RW <= '0';
					--DATA   <= freak(printCnt);--"11000001";
				    DATA   <= "11110000";
				    
					if printCnt = 15 then
						nextState <= idleState;
						printCnt := 0;
						led(2) <= '1';
					else
						nextState <= printState;	
						printCnt := printCnt + 1;
					    led(2) <= '0';					
					end if;
					
					currState <= toggleEnable;
					enableCnt := 86000;
                    enableCnt2 := 0;

					led(0) <= '0';					
					led(1) <= '0';					
					led(3) <= '0';
																	
				when returnHome  =>
				
					--LCD_E  <= '1';
					LCD_RS <= '1';
					LCD_RW <= '0';
					DATA   <= X"02";	
									
--				when row1Cursor => 	

--					LCD_E  <= '1';
--					LCD_RS <= '0';
--					LCD_RW <= '0';
--					DATA   <= X"80";	--move the cursor at the beginning
--					currState <= toggleEnable;
--					nextState <= idleState;

--				when row2Cursor => 	
				
--					LCD_E  <= '1';
--					LCD_RS <= '0';
--					LCD_RW <= '0';
--					DATA   <= X"C0";	--change line move pointer to corresponding first position of second row of the screen
--					currState <= toggleEnable;
--					nextState <= idleState;
					
--				when displayOff =>  
					
--					LCD_E  <= '1';
--					LCD_RS <= '0';
--					LCD_RW <= '0';
--					DATA   <= X"08";  
--					currState <= toggleEnable;
--					nextState <= clearDisplay;
										
			end case;
		end if;
	end process;
end arch_lcd;