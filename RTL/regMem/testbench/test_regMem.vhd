library ieee;
library regMem;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use regMem.tb_pkg.all;
use regMem.regMem_pkg.all;
entity regMem_tb is
    generic (n : integer := 4);
end regMem_tb;

architecture tb of regMem_tb is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal en  : std_logic := '0';
    signal sD  : std_logic_vector(0 downto 0);
    signal sQ  : std_logic_vector(0 downto 0);
    signal vD  : std_logic_vector(n - 1 downto 0);
    signal vQ  : std_logic_vector(n - 1 downto 0);
begin
    clock : basic_clk generic map(1 ns, 0.5 ns, 0 ns, 0 ns)port map(clk);
    v0    : vReg generic map(1) port map(clk => clk, rst => rst, en => en, D => sD, Q => sQ);
    v1    : vReg generic map(n) port map(clk => clk, rst => rst, en => en, D => vD, Q => vQ);

    stim : process
    begin
        rst <= '1';
        en  <= '0';
        wait for 1.5 ns;
        rst <= '0';
        wait for 0.4 ns;
        en <= '1';
        wait for 16 ns;
        en <= '0';
        wait for 16 ns;
        en <= '1';
        wait for 16 ns;
        en  <= '1';
        rst <= '1';
        wait for 16 ns;
        en  <= '0';
        rst <= '1';
        wait for 16 ns;
        std.env.stop;
    end process;

    sdata : process
    begin
        sD <= std_logic_vector(to_unsigned(0, sD'length));
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
        for j in 0 to 3 loop
            for i in 0 to 15 loop
                vD <= std_logic_vector(to_unsigned(i, vD'length));
                wait for 1 ns;
            end loop;
        end loop;
        wait;
    end process;

end tb;
