LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY sineWave_tb1 IS
END sineWave_tb1;
 
ARCHITECTURE behavior OF sineWave_tb1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sineWave
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         angle : IN  std_logic_vector(31 downto 0);
         Xin : IN  std_logic_vector(15 downto 0);
         Yin : IN  std_logic_vector(15 downto 0);
         Xout : OUT  std_logic_vector(16 downto 0);
         Yout : OUT  std_logic_vector(16 downto 0);
         Zout : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal angle : std_logic_vector(31 downto 0) := (others => '0');
   signal Xin : std_logic_vector(15 downto 0) := (others => '0');
   signal Yin : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal Xout : std_logic_vector(16 downto 0);
   signal Yout : std_logic_vector(16 downto 0);
   signal Zout : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 1 ns;
   
   -- Stimulus stuff
   constant VALUE : integer := 19429; -- 32000 / 1.647;
   signal alive : integer := 0;
   constant oneDegree : std_logic_vector(31 downto 0) := ("00000000101101100000101101100000");
   
 
BEGIN
            
     -- Instantiate the Unit Under Test (UUT)
    uut: sineWave PORT MAP (
           clk => clk,
           reset => reset,
           angle => angle,
           Xin => Xin,
           Yin => Yin,
           Xout => Xout,
           Yout => Yout,
           Zout => Zout
         );
    
    -- Clock process definitions
    clk_process :process
    begin
         clk <= '0';
         wait for clk_period/2;
         clk <= '1';
         wait for clk_period/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
   
       Xin <= std_logic_vector(to_signed(VALUE,16)); --  Xout = 32000*cos(angle)
       Yin <= (OTHERS => '0');                 --  Yout = 32000*sin(angle)
       angle <= (31 => '0', 30 => '1', OTHERS => '0');
       
       --BYTE<= (7 => '1', 5 downto 1 => '1', 6 => B_BIT, others => '0');
   --14606
    reset <= '0';
   
      -- hold reset state for 100 ns.
      wait for 100 ns;	

    reset <= '1';

      wait for clk_period*10;

      -- insert stimulus here
      for i in 0 to 359 loop    --  from 0 to 359 degrees in 1 degree increments
         
         alive <= alive + 1;
      
      -- "In VHDL the Integer type is defined as a 32-bit signed integer."
         --angle <= std_logic_vector(to_signed( (2**31 - 1)/360*i,32) ); -- example: 45 deg = 45/360 * 2^32 = 32'b00100000000000000000000000000000 = 45.000 degrees -> atan(2^0)
         --angle <= (others => '0');
         --angle <= "00000000101101100000101101100000";
         angle <= std_logic_vector(signed(oneDegree) + signed(angle));
         wait for clk_period*5;
         
         
         
      end loop;

      wait;
   end process;

 
END;