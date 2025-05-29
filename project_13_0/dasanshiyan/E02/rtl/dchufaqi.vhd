LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY dchufaqi IS
    PORT(
        d, clk : IN STD_LOGIC;
        q :      OUT STD_LOGIC
    );
END dchufaqi;

ARCHITECTURE dchufaqi_arch OF dchufaqi IS
BEGIN
    PROCESS(clk)
    BEGIN
        IF RISING_EDGE(clk) THEN
            q <= d;
        END IF;
    END PROCESS;
END dchufaqi_arch;
