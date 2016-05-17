library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package ascii is
    -- 16x1 Row for LCD
    type mem_row is array(0 to 15) of std_logic_vector(7 downto 0);
    -- Row for BCD value on LCD
    type BCD_row is array(0 to 4) of std_logic_vector(7 downto 0);

    -- Double dabble binary to BCD
    function to_BCD_row ( binary : std_logic_vector(15 downto 0)) return BCD_row;

    -- Array of types for LCD
    type mem_types is array(0 to 15) of mem_row;
    constant linebreak_to_BCD : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(192+(16-BCD_row'LENGTH), 8)); -- 192 = 0xC0 which is new row
    constant types : mem_types := (
      (X"43",X"75",X"74",X"6F",X"66",X"66",X"3A",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD), -- Cutoff:
      (X"44",X"75",X"74",X"79",X"63",X"79",X"63",X"6C",X"65",X"3A",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD), -- Dutycycle:
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD),
      (X"53",X"76",X"65",X"6E",X"3A",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",linebreak_to_BCD)); -- Sven

end ascii;

package body ascii is

  -- Turns a binary value into a row of Binary Coded Decimal values.
  -- IMPORTANT NOTE: input vector value can't have more digits than BCD_row
  function to_BCD_row ( binary : std_logic_vector(15 downto 0)) return BCD_row is
    variable i : integer := 0;
    variable BCD : std_logic_vector(BCD_row'LENGTH*4-1 downto 0) := (others => '0');
    variable binary_t : std_logic_vector(binary'LENGTH-1 downto 0) := binary;
    variable BCD_row : BCD_row := (others => X"20");
  begin
    -- Doubble dabble binary to BCD algorithm
    for i in 0 to binary'LENGTH-1 loop
      BCD := BCD(18 downto 0) & binary_t(binary'LENGTH-1);
      binary_t := binary_t(binary'LENGTH-2 downto 0) & '0';

      if i < binary'LENGTH-1 then
        for n in 0 to BCD_row'LENGTH-1 loop
          if BCD(3+n*4 downto 0+n*4) > "0100" then
            BCD(3+n*4 downto 0+n*4) := std_logic_vector(unsigned(BCD(3+n*4 downto 0+n*4)) + 3);
          end if;
        end loop;
      end if;
    end loop;

    -- Insert BCD values in array and add 48 to turn intp ascii char
    for i in 0 to BCD_row'LENGTH-1 loop
      BCD_row(i) := "0000" & BCD((BCD_row'LENGTH*4-1-(i*4)) downto (BCD_row'LENGTH*4-4-(i*4)));
      BCD_row(i) := std_logic_vector(unsigned(BCD_row(i)) + 48);
    end loop;

    -- Replace leading zeroes with blankspaces
    for i in 0 to BCD_row'LENGTH-2 loop
      if BCD_row(i) = X"30" then
        BCD_row(i) := X"20";
      else
        exit;
      end if;
    end loop;

    return BCD_row;
  end to_BCD_row;
end ascii;
