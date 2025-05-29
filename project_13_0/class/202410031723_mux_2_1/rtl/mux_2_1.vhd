--module mux_2_1
--(
--  input   wire      in0,
--  input   wire      in1,
--  input   wire      sel,
--  output  wire      out
--);
--
--//assign out = ((~sel)&in0) | (sel&in1);
--assign out = sel?in1:in0;
--
--endmodule

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_2_1 is
    Port (
        in0    : in  STD_LOGIC;
        in1    : in  STD_LOGIC;
        sel    : in  STD_LOGIC;
        out0   : out STD_LOGIC 
    );
end mux_2_1;

architecture Behavioral of mux_2_1 is
begin
    process(in0, in1, sel)
    begin
        if (sel = '1') then
            out0 <= in1;
        else
            out0 <= in0;
        end if;
    end process;
end Behavioral;
