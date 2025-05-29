LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY dchufaqi_tb IS
END dchufaqi_tb;

ARCHITECTURE dchufaqi_tb_arch OF dchufaqi_tb IS
    COMPONENT dchufaqi
        PORT (
            d, clk : IN STD_LOGIC;
            q      : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL d, clk : STD_LOGIC;
    SIGNAL q      : STD_LOGIC;

BEGIN
    inst: dchufaqi PORT MAP (
        d => d,
        clk => clk,
        q => q
    );

    stim_proc: PROCESS
    BEGIN
        d <= '0';
        -- d为低电平时，clk产生一个脉冲信号
        clk <= '0';
        WAIT FOR 100 ns;
        clk <= '1';
        WAIT FOR 20 ns;
        clk <= '0';
        WAIT FOR 100 ns;

        d <= '1';
        -- d为高电平时，clk产生一个脉冲信号
        clk <= '0';
        WAIT FOR 100 ns;
        clk <= '1';
        WAIT FOR 20 ns;
        clk <= '0';
        WAIT;
    END PROCESS stim_proc;

END dchufaqi_tb_arch;