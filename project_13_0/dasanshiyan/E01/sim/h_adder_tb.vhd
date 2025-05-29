LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY h_adder_tb IS
END h_adder_tb;

ARCHITECTURE h_adder_tb_arch OF h_adder_tb IS
    COMPONENT h_adder
        PORT (
            a, b   : IN STD_LOGIC;
            so, co : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL a, b : STD_LOGIC;
    SIGNAL so, co : STD_LOGIC;

BEGIN
    inst: h_adder PORT MAP (
        a => a,
        b => b,
        so => so,
        co => co
    );

    stim_proc: PROCESS
    BEGIN
        a <= '0';
        b <= '0';
        WAIT FOR 100 ns;
        a <= '0';
        b <= '1';
        WAIT FOR 100 ns;
        a <= '1';
        b <= '0';
        WAIT FOR 100 ns;
        a <= '1';
        b <= '1';
        WAIT FOR 100 ns;
        WAIT;
    END PROCESS stim_proc;

END h_adder_tb_arch;