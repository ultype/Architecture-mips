library ieee;
library flipflop;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

use flipflop.ff.all;
use flipflop.tb_pkg.all;

entity DFF_tb is
    generic (n : integer := 4);
end DFF_tb;

architecture tb of DFF_tb is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal sD  : std_logic;
    signal sQ  : std_logic;
    signal vD  : std_logic_vector(n - 1 downto 0);
    signal vQ  : std_logic_vector(n - 1 downto 0);
begin
    clock : basic_clk generic map(1 ns, 0.5 ns, 0 ns, 0 ns)port map(clk);
    sReg  : sDFF port map(clk => clk, rst => rst, D => sD, Q => sQ);
    vReg  : vDFF generic map(n) port map(clk => clk, RST => RST, D => vD, Q => vQ);

    stim : process
    begin
        rst <= '1';
        wait for 1.5 ns;
        rst <= '0';
        wait for 20 ns;
        rst <= '1';
        wait for 2 ns;
        std.env.stop;
    end process;

    sdata : process
    begin
        sD <= '0';
        wait for 1.5 ns;
        while true loop
            sD <= not sD;
            wait for 1 ns;
        end loop;
        wait;
    end process;

    vdata : process
    begin
        vD <= std_logic_vector(to_unsigned(0, vD'length));
        wait for 1.5 ns;
        for i in 0 to 15 loop
            vD <= std_logic_vector(to_unsigned(i, vD'length)); --integer to std_logic_vector
            wait for 1 ns;
        end loop;
        wait;
    end process;

end tb;
