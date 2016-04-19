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

type LFOromArray is array (0 to 199-1) of integer;
constant LFO : LFOromArray := (2000000000, 1000000000, 666666666, 500000000, 400000000, 333333334, 285714286, 250000000, 222222222, 200000000, 181818182, 166666666, 153846154, 142857142, 133333334, 125000000, 117647058, 111111112, 105263158, 100000000, 95238096, 90909090, 86956522, 83333334, 80000000, 76923076, 74074074, 71428572, 68965518, 66666666, 64516130, 62500000, 60606060, 58823530, 57142858, 55555556, 54054054, 52631578, 51282052, 50000000, 48780488, 47619048, 46511628, 45454546, 44444444, 43478260, 42553192, 41666666, 40816326, 40000000, 39215686, 38461538, 37735850, 37037038, 36363636, 35714286, 35087720, 34482758, 33898306, 33333334, 32786886, 32258064, 31746032, 31250000, 30769230, 30303030, 29850746, 29411764, 28985508, 28571428, 28169014, 27777778, 27397260, 27027028, 26666666, 26315790, 25974026, 25641026, 25316456, 25000000, 24691358, 24390244, 24096386, 23809524, 23529412, 23255814, 22988506, 22727272, 22471910, 22222222, 21978022, 21739130, 21505376, 21276596, 21052632, 20833334, 20618556, 20408164, 20202020, 20000000, 19801980, 19607844, 19417476, 19230770, 19047620, 18867924, 18691588, 18518518, 18348624, 18181818, 18018018, 17857142, 17699116, 17543860, 17391304, 17241380, 17094018, 16949152, 16806722, 16666666, 16528926, 16393442, 16260162, 16129032, 16000000, 15873016, 15748032, 15625000, 15503876, 15384616, 15267176, 15151516, 15037594, 14925374, 14814814, 14705882, 14598540, 14492754, 14388490, 14285714, 14184398, 14084508, 13986014, 13888888, 13793104, 13698630, 13605442, 13513514, 13422818, 13333334, 13245034, 13157894, 13071896, 12987012, 12903226, 12820512, 12738854, 12658228, 12578616, 12500000, 12422360, 12345680, 12269938, 12195122, 12121212, 12048192, 11976048, 11904762, 11834320, 11764706, 11695906, 11627906, 11560694, 11494252, 11428572, 11363636, 11299436, 11235956, 11173184, 11111112, 11049724, 10989010, 10928962, 10869566, 10810810, 10752688, 10695188, 10638298, 10582010, 10526316, 10471204, 10416666, 10362694, 10309278, 10256410, 10204082, 10152284, 10101010, 10050252);

-- Declare functions
function getT (input : integer) return integer;
function getFs (input : integer) return integer;
function getInc (input : integer) return integer;
function getSemiT (note : integer; semi : integer) return integer;
function getSemiF (note : integer; semi : integer) return integer;
function getSemiD (note : integer; semi : integer; duty : integer) return integer;
function getLFO_T (rate : integer) return integer;
function getLFOFs_Tri (rate : integer; depth : integer) return integer;
function getLFOFs_Saw (rate : integer; depth : integer) return integer;
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
        if (semi > 0 and semi < 12) and note /= 95 then
            return  (T(note) + (T(note) + T(note+1))/11*semi);
        elsif (semi < 0 and semi > -12) and note /= 0 then
            return  (T(note) - (T(note-1) + T(note))/11*semi);
        else
            return T(note);
        end if;
    end getSemiT;

    function getSemiF (note : integer; semi : integer) return integer is
    begin
        if (semi > 0 and semi < 12) and note /= 95 then
            return  (F_s(note) + (F_s(note) + F_s(note+1))/11*semi);
        elsif (semi < 0 and semi > -12) and note /= 0 then
            return  (F_s(note) - (F_s(note-1) + F_s(note))/11*semi);
        else
            return F_s(note);
        end if;
    end getSemiF;

    function getSemiD (note : integer; semi : integer; duty : integer) return integer is
    begin
        if (duty > 0 and duty < 100) then
            if (semi > 0 and semi < 12) and note /= 95 then
                return (T(note) + (T(note) + T(note+1))/11*semi*100/duty);
            elsif (semi < 0 and semi > -12) and note /= 0 then
                return (T(note) - (T(note-1) + T(note))/11*semi*100/duty);
            else
                return T(note)/2;
            end if;
        else
            return T(note)/2;
        end if;
    end getSemiD;
                        
    function getLFO_T (rate : integer) return integer is
    begin
        
        return LFO(rate);
        
    end getLFO_T;
                        
    function getLFOFs_Tri (rate : integer; depth : integer) return integer is
    begin
        
        return LFO(rate)/2/depth;
        
    end getLFOFs_Tri;
                
    function getLFOFs_Saw (rate : integer; depth : integer) return integer is
    begin
        
        return LFO(rate)/depth;
        
    end getLFOFs_Saw;
    
    
            
end geometryPackage;
