library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package ascii is
    -- 16x1 Row for LCD
    type mem_row is array(0 to 15) of std_logic_vector(7 downto 0);

    -- Double dabble binary to BCD
    function to_BCD_row ( binary : std_logic_vector(15 downto 0)) return mem_row;

    -- Array of types for LCD
    type mem_types is array(0 to 15) of mem_row;
    constant types : mem_types := (
      (X"43",X"75",X"74",X"6F",X"66",X"66",X"3A",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"), -- Cutoff:
      (X"44",X"75",X"74",X"79",X"63",X"79",X"63",X"6C",X"65",X"3A",X"20",X"20",X"20",X"20",X"20",X"C0"), -- Dutycycle:
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"),
      (X"53",X"76",X"65",X"6E",X"3A",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"C0"));

end ascii;

package body ascii is

  function to_BCD_row ( binary : std_logic_vector(15 downto 0)) return mem_row is
    variable i : integer := 0;
    variable BCD : std_logic_vector(19 downto 0) := (others => '0');
    variable binary_t : std_logic_vector(binary'LENGTH-1 downto 0) := binary;
    variable BCD_row : mem_row := (others => X"20");
  begin
    for i in 0 to binary'LENGTH-1 loop
      BCD := BCD(18 downto 0) & binary_t(binary'LENGTH-1);
      binary_t := binary_t(binary'LENGTH-2 downto 0) & '0';

      if i < binary'LENGTH-1 then
        if BCD(3 downto 0) > "0100" then
          BCD(3 downto 0) := std_logic_vector(unsigned(BCD(3 downto 0)) + 3);
        end if;
        if BCD(7 downto 4) > "0100" then
          BCD(7 downto 4) := std_logic_vector(unsigned(BCD(7 downto 4)) + 3);
        end if;
        if BCD(11 downto 8) > "0100" then
          BCD(11 downto 8) := std_logic_vector(unsigned(BCD(11 downto 8)) + 3);
        end if;
        if BCD(15 downto 12) > "0100" then
          BCD(15 downto 12) := std_logic_vector(unsigned(BCD(15 downto 12)) + 3);
        end if;
        if BCD(19 downto 16) > "0100" then
          BCD(19 downto 16) := std_logic_vector(unsigned(BCD(19 downto 16)) + 3);
        end if;
      end if;
    end loop;

    BCD_row(15) := "0000" & BCD(3 downto 0);
    BCD_row(14) := "0000" & BCD(7 downto 4);
    BCD_row(13) := "0000" & BCD(11 downto 8);
    BCD_row(12) := "0000" & BCD(15 downto 12);
    BCD_row(11) := "0000" & BCD(19 downto 16);

    if BCD_row(11) = "00000000" then
      BCD_row(11) := X"F0";
      if BCD_row(12) = "00000000" then
        BCD_row(12) := X"F0";
        if BCD_row(13) = "00000000" then
          BCD_row(13) := X"F0";
          if BCD_row(14) = "00000000" then
            BCD_row(14) := X"F0";
--            if BCD_row(15) = "00000000" then
--              BCD_row(15) := X"F0";
--            end if;
          end if;
        end if;
      end if;
    end if;

    BCD_row(15) := std_logic_vector(unsigned(BCD_row(15)) + 48);
    BCD_row(14) := std_logic_vector(unsigned(BCD_row(14)) + 48);
    BCD_row(13) := std_logic_vector(unsigned(BCD_row(13)) + 48);
    BCD_row(12) := std_logic_vector(unsigned(BCD_row(12)) + 48);
    BCD_row(11) := std_logic_vector(unsigned(BCD_row(11)) + 48);
    return BCD_row;
  end to_BCD_row;
end ascii;
