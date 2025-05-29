LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY half_adder IS
  PORT
  (
    a,b   : IN STD_LOGIC;
    so,co : OUT STD_LOGIC
  );
END ENTITY half_adder;

ARCHITECTURE fh1 OF half_adder IS
  BEGIN
    so <= a XOR b;
	 co <= a and b;
END ARCHITECTURE fh1;