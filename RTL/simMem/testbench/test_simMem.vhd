library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use work.tb_pkg.all;
use work.simMem_pkg.all;

entity simMem_tb is
    generic (n : integer := 4);
end simMem_tb;

architecture tb of simMem_tb is
    signal clk0        : std_logic := '0';
    signal clk1        : std_logic := '0';
    signal clk2        : std_logic := '1';
    signal rst         : std_logic := '0';
    signal wen         : std_logic := '0';
    signal instr_raddr : std_logic_vector(31 downto 0);
    signal instr_rdata : std_logic_vector(31 downto 0);
    signal dual_waddr  : std_logic_vector(31 downto 0);
    signal dual_raddr  : std_logic_vector(31 downto 0);
    signal dual_wdata  : std_logic_vector(31 downto 0);
    signal dual_rdata  : std_logic_vector(31 downto 0);
begin
    clock : basic_clk generic map(1 ns, 0.5 ns, 0 ns, 0 ns)port map(clk0);
    clk1 <= clk0;
    clk2 <= not clk0;

    instr : instrMem port map(
        clk   => clk0,
        rst   => rst,
        raddr => instr_raddr,
        rdata => instr_rdata);

    dual : dualMem port map(
        clk1  => clk1,
        clk2  => clk2,
        wen   => wen,
        waddr => dual_waddr,
        raddr => dual_raddr,
        wdata => dual_wdata,
        rdata => dual_rdata
    );

    stim : process
    begin
        rst <= '1';
        wait for 1 ns;
        rst <= '0';
        wen <= '1';
        wait for 1030 ns;
        std.env.stop;
    end process;

    instrp : process
    begin
        wait for 2 ns;
        instr_raddr <= 32b"0";
        wait for 1 ns;
        instr_raddr <= 32b"00000000000000000000000000000100";
        wait for 1 ns;
        instr_raddr <= 32b"00000000000000000000000000001000";
        wait for 1 ns;
        instr_raddr <= 32b"00000000000000000000000000001100";
        wait for 1 ns;
    end process;

    dual_write : process
        variable i : integer := 1;
    begin
        wait for 2 ns;
        for i in 0 to 1023 loop
            dual_waddr <= conv_std_logic_vector(i, 32);
            dual_wdata <= conv_std_logic_vector(i + 1, 32);
            wait for 0.5 ns;
            dual_raddr <= conv_std_logic_vector(i, 32);
            wait for 0.5 ns;
        end loop;
    end process;
end tb;
