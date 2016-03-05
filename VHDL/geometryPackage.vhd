library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package geometryPackage is

constant romSize : natural := 96;  --  Eight (8) octaves
type romArray is array (0 to romSize-1) of integer;
type incArray is array (0 to 1) of integer;

-- All the notes periods in integers where mod2 == 0
constant T : romArray := (12231220, 11544734, 10896778, 10285190, 9707926, 9163062, 8648780, 8163360, 7705186, 7272728, 6864540, 6479264, 6115610, 5772368, 5448390, 5142594, 4853964, 4581532, 4324390, 4081680, 3852594, 3636364, 3432270, 3239632, 3057806, 2886184, 2724194, 2571298, 2426982, 2290766, 2162194, 2040840, 1926296, 1818182, 1716136, 1619816, 1528902, 1443092, 1362098, 1285648, 1213490, 1145382, 1081098, 1020420, 963148, 909090, 858068, 809908, 764452, 721546, 681048, 642824, 606746, 572692, 540548, 510210, 481574, 454546, 429034, 404954, 382226, 360772, 340524, 321412, 303372, 286346, 270274, 255106, 240788, 227272, 214516, 202476, 191112, 180386, 170262, 160706, 151686, 143172, 135138, 127552, 120394, 113636, 107258, 101238, 95556, 90194, 85132, 80354, 75844, 71586, 67568, 63776, 60196, 56818, 53630, 50620);
-- All the periods for their respective sampling frequencies, 128x sampling frequency.
constant F_s : romArray := (68715, 64858, 61218, 57782, 54539, 51478, 48589, 45862, 43288, 40858, 38565, 36400, 34357, 32429, 30609, 28891, 27269, 25739, 24294, 22931, 21644, 20429, 19282, 18200, 17179, 16215, 15304, 14445, 13635, 12869, 12147, 11465, 10822, 10215, 9641, 9100, 8589, 8107, 7652, 7223, 6817, 6435, 6074, 5733, 5411, 5107, 4821, 4550, 4295, 4054, 3826, 3611, 3409, 3217, 3037, 2866, 2705, 2554, 2410, 2275, 2147, 2027, 1913, 1806, 1704, 1609, 1518, 1433, 1353, 1277, 1205, 1138, 1074, 1013, 957, 903, 852, 804, 759, 717, 676, 638, 603, 569, 537, 507, 478, 451, 426, 402, 380, 358, 338, 319, 301, 284);
-- The incrementation at every sampling point
constant inc : incArray := (46, 23);--16 o 32

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
