library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package geometryPackage is

constant romSize : natural := 132;
type romArray is array (0 to romSize-1) of integer;
type incArray is array (0 to 2) of integer;

-- All the notes periods in integers where mod4 == 0
constant T : romArray := (12231220, 11544732, 10896776, 10285188, 9707924, 9163060, 8648780, 8163360, 7705184, 7272728, 6864540, 6479264, 6115608, 5772368, 5448388, 5142592, 4853964, 4581532, 4324388, 4081680, 3852592, 3636364, 3432268, 3239632, 3057804, 2886184, 2724192, 2571296, 2426980, 2290764, 2162192, 2040840, 1926296, 1818180, 1716136, 1619816, 1528900, 1443092, 1362096, 1285648, 1213488, 1145380, 1081096, 1020420, 963148, 909088, 858068, 809908, 764452, 721544, 681048, 642824, 606744, 572692, 540548, 510208, 481572, 454544, 429032, 404952, 382224, 360772, 340524, 321412, 303372, 286344, 270272, 255104, 240788, 227272, 214516, 202476, 191112, 180384, 170260, 160704, 151684, 143172, 135136, 127552, 120392, 113636, 107256, 101236, 95556, 90192, 85132, 80352, 75844, 71584, 67568, 63776, 60196, 56816, 53628, 50620, 47776, 45096, 42564, 40176, 37920, 35792, 33784, 31888, 30096, 28408, 26812, 25308, 23888, 22548, 21280, 20088, 18960, 17896, 16892, 15944, 15048, 14204, 13408, 12652, 11944, 11272, 10640, 10044, 9480, 8948, 8444, 7972, 7524, 7100, 6704, 6328);
-- All the periods for their respective sampling frequencies
constant F_s : romArray := (382226, 360773, 340524, 321412, 303373, 286346, 270274, 255105, 240787, 227273, 214517, 202477, 191113, 180386, 170262, 160706, 151686, 143173, 135137, 127553, 120394, 113636, 107258, 101238, 95556, 90193, 85131, 80353, 75843, 71586, 67569, 63776, 60197, 56818, 53629, 50619, 47778, 45097, 42566, 40177, 37922, 35793, 33784, 31888, 30098, 28409, 26815, 25310, 23889, 22548, 21283, 20088, 18961, 17897, 16892, 15944, 15049, 14205, 13407, 12655, 11945, 11274, 10641, 10044, 9480, 8948, 8446, 7972, 7525, 7102, 6704, 6327, 5972, 5637, 5321, 5022, 4740, 4474, 4223, 3986, 3762, 3551, 3352, 3164, 2986, 2819, 2660, 2511, 2370, 2237, 2112, 1993, 1881, 1776, 1676, 1582, 1493, 1409, 1330, 1256, 1185, 1119, 1056, 997, 941, 888, 838, 791, 747, 705, 665, 628, 593, 559, 528, 498, 470, 444, 419, 395, 373, 352, 333, 314, 296, 280, 264, 249, 235, 222, 209, 198);
-- The incrementation at every sampling point
constant inc : incArray := (18078, 8456, 16383);--9096

-- Declare functions
function getT (input : integer) return integer;
function getFs (input : integer) return integer;
function getInc (input : integer) return integer;
function getSemiT (note : integer; semi : integer) return integer;
function getSemiF (note : integer; semi : integer) return integer;
--
end geometryPackage;

package body geometryPackage is

    function getT (input : integer) return integer is
    begin
        return T(input);
    end getT;
    
    function getFs (input : integer) return integer is
    begin
        return F_s(input);
    end getFs;
    
    function getInc (input : integer) return integer is
    begin
        return inc(input);
    end getInc;

    function getSemiT (note : integer; semi : integer) return integer is
    begin

        if note = 0 and semi < 0 then           --  No return of low
        
            return T(0);
            
        elsif note = (romSize-1) and semi > 0 then   --  and no return of high...
        
            return T(romSize-1);
            
        else
            if semi < 0 and semi > -12 then     --  it is negative
                
                 return (T(note-1) - T(note)) / 12 * semi;
            
            else                                --  positive
                
                 return (T(note) - T(note+1)) / 12 * semi;
                 
            end if;
            
        end if;
    end getSemiT;


    function getSemiF (note : integer; semi : integer) return integer is
    begin

        if note = 0 and semi < 0 then                --  No return of low
        
            return F_s(0);
            
        elsif note = (romSize-1) and semi > 0 then   --  and no return of high...
        
            return F_s(romSize-1);
            
        else
        
            if semi < 0 and semi > -12 then     --  it is negative
                
                 return (F_s(note-1) - F_s(note)) / 12 * (semi);
            
            else                                --  positive
                
                 return (F_s(note) - F_s(note+1)) / 12 * semi;
                 
            end if;
            
        end if;
        
    end getSemiF;
        
end geometryPackage;