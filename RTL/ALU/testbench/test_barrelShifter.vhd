library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.ALU_pkg.all;

entity barrelShifter32_tb is
    generic (n : integer := 32);
end barrelShifter32_tb;

architecture tb of barrelShifter32_tb is
    signal dir, sp, barrel : std_logic                        := '0';
    signal Din, Dout       : std_logic_vector(n - 1 downto 0) := 32b"0";
    signal shift           : std_logic_vector(4 downto 0)     := 5b"0";
begin
    shifter : barrelShifter32 port map(
        dir    => dir,
        sp     => sp,
        barrel => barrel,
        Din    => Din,
        shift  => shift,
        Dout   => Dout
    );
    stim : process
        variable i : integer := 0;
    begin

        -- sp 0 dir 0
        wait for 1 ns;
        Din    <= 32b"1";
        sp     <= '0';
        barrel <= '0';
        dir    <= '0';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        -- sp 1 dir 0
        wait for 1 ns;
        Din    <= 32b"1";
        sp     <= '1';
        barrel <= '0';
        dir    <= '0';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        -- sp 0 dir 1
        wait for 1 ns;
        Din    <= 32b"1";
        sp     <= '0';
        barrel <= '0';
        dir    <= '1';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        -- sp 1 dir 1
        wait for 1 ns;
        Din    <= 32b"1";
        sp     <= '1';
        barrel <= '0';
        dir    <= '1';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        -- sp 0 dir 0
        wait for 1 ns;
        Din    <= 32b"0";
        sp     <= '0';
        barrel <= '0';
        dir    <= '0';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        -- sp 1  dir 0
        wait for 1 ns;
        Din    <= 32b"0";
        sp     <= '1';
        barrel <= '0';
        dir    <= '0';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        wait for 1 ns;
        Din    <= 32b"11111111111111111111111111111111";
        sp     <= '0';
        barrel <= '0';
        dir    <= '0';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        wait for 1 ns;
        Din    <= 32b"11111111111111111111111111111111";
        sp     <= '1';
        barrel <= '0';
        dir    <= '0';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        wait for 1 ns;
        Din    <= 32b"11111111111111111111111111111111";
        sp     <= '1';
        barrel <= '0';
        dir    <= '0';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        wait for 1 ns;
        Din    <= 32b"10011001100110011001100110011001";
        sp     <= '0';
        barrel <= '1';
        dir    <= '0';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        wait for 1 ns;
        Din    <= 32b"10011001100110011001100110011001";
        sp     <= '0';
        barrel <= '1';
        dir    <= '1';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        wait for 1 ns;
        Din    <= 32b"10011001100110011001100110011001";
        sp     <= '1';
        barrel <= '1';
        dir    <= '0';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        wait for 1 ns;
        Din    <= 32b"10011001100110011001100110011001";
        sp     <= '1';
        barrel <= '1';
        dir    <= '1';
        shift  <= 5b"0";
        for i in 0 to 31 loop
            wait for 1 ns;
            shift <= conv_std_logic_vector(i, 5);
        end loop;
        wait for 1 ns;

        std.env.stop;
    end process;
end tb;
