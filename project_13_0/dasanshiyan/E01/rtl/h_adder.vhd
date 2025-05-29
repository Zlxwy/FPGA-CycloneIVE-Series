LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY h_adder IS
    PORT(
        a, b   : IN STD_LOGIC;
        so, co : OUT STD_LOGIC
    );
END h_adder;

ARCHITECTURE h_adder_arch OF h_adder IS
BEGIN
    so <= a XOR b; -- 异或
    co <= a AND b; -- 与
END h_adder_arch;
