library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package aids is
    -- Filter type enumerator
    type FILTER is (LP, HP, BP);
    
    -- Enumerator for oscillator-wave types
    type WAVE is (SINE, COSINE, SQUARE, TRIANGLE, SAW1, SAW2, NOISE);
    
    -- STD_LOGIC_VECTOR to WAVE
    function to_wave (input : std_logic_vector(2 downto 0)) return WAVE;
    
    -- Table of angles 0 to 359 represented as 2^32*(i/360)
    type regAng is array (0 to 359) of std_logic_vector(31 downto 0);
    signal angles : regAng := (
        "00000000000000000000000000000000",
        "00000000101101100000101101100001",
        "00000001011011000001011011000001",
        "00000010001000100010001000100010",
        "00000010110110000010110110000011",
        "00000011100011100011100011100100",
        "00000100010001000100010001000100",
        "00000100111110100100111110100101",
        "00000101101100000101101100000110",
        "00000110011001100110011001100110",
        "00000111000111000111000111000111",
        "00000111110100100111110100101000",
        "00001000100010001000100010001001",
        "00001001001111101001001111101001",
        "00001001111101001001111101001010",
        "00001010101010101010101010101011",
        "00001011011000001011011000001011",
        "00001100000101101100000101101100",
        "00001100110011001100110011001101",
        "00001101100000101101100000101110",
        "00001110001110001110001110001110",
        "00001110111011101110111011101111",
        "00001111101001001111101001010000",
        "00010000010110110000010110110000",
        "00010001000100010001000100010001",
        "00010001110001110001110001110010",
        "00010010011111010010011111010010",
        "00010011001100110011001100110011",
        "00010011111010010011111010010100",
        "00010100100111110100100111110101",
        "00010101010101010101010101010101",
        "00010110000010110110000010110110",
        "00010110110000010110110000010111",
        "00010111011101110111011101110111",
        "00011000001011011000001011011000",
        "00011000111000111000111000111001",
        "00011001100110011001100110011010",
        "00011010010011111010010011111010",
        "00011011000001011011000001011011",
        "00011011101110111011101110111100",
        "00011100011100011100011100011100",
        "00011101001001111101001001111101",
        "00011101110111011101110111011110",
        "00011110100100111110100100111111",
        "00011111010010011111010010011111",
        "00100000000000000000000000000000",
        "00100000101101100000101101100001",
        "00100001011011000001011011000001",
        "00100010001000100010001000100010",
        "00100010110110000010110110000011",
        "00100011100011100011100011100100",
        "00100100010001000100010001000100",
        "00100100111110100100111110100101",
        "00100101101100000101101100000110",
        "00100110011001100110011001100110",
        "00100111000111000111000111000111",
        "00100111110100100111110100101000",
        "00101000100010001000100010001001",
        "00101001001111101001001111101001",
        "00101001111101001001111101001010",
        "00101010101010101010101010101011",
        "00101011011000001011011000001011",
        "00101100000101101100000101101100",
        "00101100110011001100110011001101",
        "00101101100000101101100000101110",
        "00101110001110001110001110001110",
        "00101110111011101110111011101111",
        "00101111101001001111101001010000",
        "00110000010110110000010110110000",
        "00110001000100010001000100010001",
        "00110001110001110001110001110010",
        "00110010011111010010011111010010",
        "00110011001100110011001100110011",
        "00110011111010010011111010010100",
        "00110100100111110100100111110101",
        "00110101010101010101010101010101",
        "00110110000010110110000010110110",
        "00110110110000010110110000010111",
        "00110111011101110111011101110111",
        "00111000001011011000001011011000",
        "00111000111000111000111000111001",
        "00111001100110011001100110011010",
        "00111010010011111010010011111010",
        "00111011000001011011000001011011",
        "00111011101110111011101110111100",
        "00111100011100011100011100011100",
        "00111101001001111101001001111101",
        "00111101110111011101110111011110",
        "00111110100100111110100100111111",
        "00111111010010011111010010011111",
        "01000000000000000000000000000000",
        "01000000101101100000101101100001",
        "01000001011011000001011011000001",
        "01000010001000100010001000100010",
        "01000010110110000010110110000011",
        "01000011100011100011100011100100",
        "01000100010001000100010001000100",
        "01000100111110100100111110100101",
        "01000101101100000101101100000110",
        "01000110011001100110011001100110",
        "01000111000111000111000111000111",
        "01000111110100100111110100101000",
        "01001000100010001000100010001001",
        "01001001001111101001001111101001",
        "01001001111101001001111101001010",
        "01001010101010101010101010101011",
        "01001011011000001011011000001011",
        "01001100000101101100000101101100",
        "01001100110011001100110011001101",
        "01001101100000101101100000101110",
        "01001110001110001110001110001110",
        "01001110111011101110111011101111",
        "01001111101001001111101001010000",
        "01010000010110110000010110110000",
        "01010001000100010001000100010001",
        "01010001110001110001110001110010",
        "01010010011111010010011111010010",
        "01010011001100110011001100110011",
        "01010011111010010011111010010100",
        "01010100100111110100100111110101",
        "01010101010101010101010101010101",
        "01010110000010110110000010110110",
        "01010110110000010110110000010111",
        "01010111011101110111011101110111",
        "01011000001011011000001011011000",
        "01011000111000111000111000111001",
        "01011001100110011001100110011010",
        "01011010010011111010010011111010",
        "01011011000001011011000001011011",
        "01011011101110111011101110111100",
        "01011100011100011100011100011100",
        "01011101001001111101001001111101",
        "01011101110111011101110111011110",
        "01011110100100111110100100111111",
        "01011111010010011111010010011111",
        "01100000000000000000000000000000",
        "01100000101101100000101101100001",
        "01100001011011000001011011000001",
        "01100010001000100010001000100010",
        "01100010110110000010110110000011",
        "01100011100011100011100011100100",
        "01100100010001000100010001000100",
        "01100100111110100100111110100101",
        "01100101101100000101101100000110",
        "01100110011001100110011001100110",
        "01100111000111000111000111000111",
        "01100111110100100111110100101000",
        "01101000100010001000100010001001",
        "01101001001111101001001111101001",
        "01101001111101001001111101001010",
        "01101010101010101010101010101011",
        "01101011011000001011011000001011",
        "01101100000101101100000101101100",
        "01101100110011001100110011001101",
        "01101101100000101101100000101110",
        "01101110001110001110001110001110",
        "01101110111011101110111011101111",
        "01101111101001001111101001010000",
        "01110000010110110000010110110000",
        "01110001000100010001000100010001",
        "01110001110001110001110001110010",
        "01110010011111010010011111010010",
        "01110011001100110011001100110011",
        "01110011111010010011111010010100",
        "01110100100111110100100111110101",
        "01110101010101010101010101010101",
        "01110110000010110110000010110110",
        "01110110110000010110110000010111",
        "01110111011101110111011101110111",
        "01111000001011011000001011011000",
        "01111000111000111000111000111001",
        "01111001100110011001100110011010",
        "01111010010011111010010011111010",
        "01111011000001011011000001011011",
        "01111011101110111011101110111100",
        "01111100011100011100011100011100",
        "01111101001001111101001001111101",
        "01111101110111011101110111011110",
        "01111110100100111110100100111111",
        "01111111010010011111010010011111",
        "10000000000000000000000000000000",
        "10000000101101100000101101100001",
        "10000001011011000001011011000001",
        "10000010001000100010001000100010",
        "10000010110110000010110110000011",
        "10000011100011100011100011100100",
        "10000100010001000100010001000100",
        "10000100111110100100111110100101",
        "10000101101100000101101100000110",
        "10000110011001100110011001100110",
        "10000111000111000111000111000111",
        "10000111110100100111110100101000",
        "10001000100010001000100010001001",
        "10001001001111101001001111101001",
        "10001001111101001001111101001010",
        "10001010101010101010101010101011",
        "10001011011000001011011000001011",
        "10001100000101101100000101101100",
        "10001100110011001100110011001101",
        "10001101100000101101100000101110",
        "10001110001110001110001110001110",
        "10001110111011101110111011101111",
        "10001111101001001111101001010000",
        "10010000010110110000010110110000",
        "10010001000100010001000100010001",
        "10010001110001110001110001110010",
        "10010010011111010010011111010010",
        "10010011001100110011001100110011",
        "10010011111010010011111010010100",
        "10010100100111110100100111110101",
        "10010101010101010101010101010101",
        "10010110000010110110000010110110",
        "10010110110000010110110000010111",
        "10010111011101110111011101110111",
        "10011000001011011000001011011000",
        "10011000111000111000111000111001",
        "10011001100110011001100110011010",
        "10011010010011111010010011111010",
        "10011011000001011011000001011011",
        "10011011101110111011101110111100",
        "10011100011100011100011100011100",
        "10011101001001111101001001111101",
        "10011101110111011101110111011110",
        "10011110100100111110100100111111",
        "10011111010010011111010010011111",
        "10100000000000000000000000000000",
        "10100000101101100000101101100001",
        "10100001011011000001011011000001",
        "10100010001000100010001000100010",
        "10100010110110000010110110000011",
        "10100011100011100011100011100100",
        "10100100010001000100010001000100",
        "10100100111110100100111110100101",
        "10100101101100000101101100000110",
        "10100110011001100110011001100110",
        "10100111000111000111000111000111",
        "10100111110100100111110100101000",
        "10101000100010001000100010001001",
        "10101001001111101001001111101001",
        "10101001111101001001111101001010",
        "10101010101010101010101010101011",
        "10101011011000001011011000001011",
        "10101100000101101100000101101100",
        "10101100110011001100110011001101",
        "10101101100000101101100000101110",
        "10101110001110001110001110001110",
        "10101110111011101110111011101111",
        "10101111101001001111101001010000",
        "10110000010110110000010110110000",
        "10110001000100010001000100010001",
        "10110001110001110001110001110010",
        "10110010011111010010011111010010",
        "10110011001100110011001100110011",
        "10110011111010010011111010010100",
        "10110100100111110100100111110101",
        "10110101010101010101010101010101",
        "10110110000010110110000010110110",
        "10110110110000010110110000010111",
        "10110111011101110111011101110111",
        "10111000001011011000001011011000",
        "10111000111000111000111000111001",
        "10111001100110011001100110011010",
        "10111010010011111010010011111010",
        "10111011000001011011000001011011",
        "10111011101110111011101110111100",
        "10111100011100011100011100011100",
        "10111101001001111101001001111101",
        "10111101110111011101110111011110",
        "10111110100100111110100100111111",
        "10111111010010011111010010011111",
        "11000000000000000000000000000000",
        "11000000101101100000101101100001",
        "11000001011011000001011011000001",
        "11000010001000100010001000100010",
        "11000010110110000010110110000011",
        "11000011100011100011100011100100",
        "11000100010001000100010001000100",
        "11000100111110100100111110100101",
        "11000101101100000101101100000110",
        "11000110011001100110011001100110",
        "11000111000111000111000111000111",
        "11000111110100100111110100101000",
        "11001000100010001000100010001001",
        "11001001001111101001001111101001",
        "11001001111101001001111101001010",
        "11001010101010101010101010101011",
        "11001011011000001011011000001011",
        "11001100000101101100000101101100",
        "11001100110011001100110011001101",
        "11001101100000101101100000101110",
        "11001110001110001110001110001110",
        "11001110111011101110111011101111",
        "11001111101001001111101001010000",
        "11010000010110110000010110110000",
        "11010001000100010001000100010001",
        "11010001110001110001110001110010",
        "11010010011111010010011111010010",
        "11010011001100110011001100110011",
        "11010011111010010011111010010100",
        "11010100100111110100100111110101",
        "11010101010101010101010101010101",
        "11010110000010110110000010110110",
        "11010110110000010110110000010111",
        "11010111011101110111011101110111",
        "11011000001011011000001011011000",
        "11011000111000111000111000111001",
        "11011001100110011001100110011010",
        "11011010010011111010010011111010",
        "11011011000001011011000001011011",
        "11011011101110111011101110111100",
        "11011100011100011100011100011100",
        "11011101001001111101001001111101",
        "11011101110111011101110111011110",
        "11011110100100111110100100111111",
        "11011111010010011111010010011111",
        "11100000000000000000000000000000",
        "11100000101101100000101101100001",
        "11100001011011000001011011000001",
        "11100010001000100010001000100010",
        "11100010110110000010110110000011",
        "11100011100011100011100011100100",
        "11100100010001000100010001000100",
        "11100100111110100100111110100101",
        "11100101101100000101101100000110",
        "11100110011001100110011001100110",
        "11100111000111000111000111000111",
        "11100111110100100111110100101000",
        "11101000100010001000100010001001",
        "11101001001111101001001111101001",
        "11101001111101001001111101001010",
        "11101010101010101010101010101011",
        "11101011011000001011011000001011",
        "11101100000101101100000101101100",
        "11101100110011001100110011001101",
        "11101101100000101101100000101110",
        "11101110001110001110001110001110",
        "11101110111011101110111011101111",
        "11101111101001001111101001010000",
        "11110000010110110000010110110000",
        "11110001000100010001000100010001",
        "11110001110001110001110001110010",
        "11110010011111010010011111010010",
        "11110011001100110011001100110011",
        "11110011111010010011111010010100",
        "11110100100111110100100111110101",
        "11110101010101010101010101010101",
        "11110110000010110110000010110110",
        "11110110110000010110110000010111",
        "11110111011101110111011101110111",
        "11111000001011011000001011011000",
        "11111000111000111000111000111001",
        "11111001100110011001100110011010",
        "11111010010011111010010011111010",
        "11111011000001011011000001011011",
        "11111011101110111011101110111100",
        "11111100011100011100011100011100",
        "11111101001001111101001001111101",
        "11111101110111011101110111011110",
        "11111110100100111110100100111111",
        "11111111010010011111010010011111");
end aids;

package body aids is
    function to_wave (input : std_logic_vector(2 downto 0)) return WAVE is
        variable output : WAVE;
    begin
        case input is
            when "000" =>
                output := SINE;
            when "001" =>
                output := COSINE;
            when "010" =>
                output := SQUARE;
            when "011" =>
                output := TRIANGLE;
            when "100" =>
                output := SAW1;
            when "101" =>
                output := SAW2;
            when "110" =>
                output := NOISE;
            when others =>
                output := NOISE;
        end case;
        
        return output;
    end to_wave;
end aids;
