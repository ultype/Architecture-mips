library ieee;
library regMem;
library flipflop;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use regMem.tb_pkg.all;
use regMem.regMem_pkg.all;
use flipflop.ff.all;
entity regMem_tb1 is
    generic (n : integer := 32);
end regMem_tb1;

architecture tb1 of regMem_tb1 is
    signal clk1                  : std_logic := '0';
    signal clk2                  : std_logic := '1';
    signal rst                   : std_logic := '1';
    signal wen                   : std_logic := '0';
    signal wdata, rdata0, rdata1 : std_logic_vector(n - 1 downto 0);
    signal waddr, raddr0, raddr1 : std_logic_vector(4 downto 0);
    component regMem is
        generic (
            w : integer;
            d : integer
        );
        port (
            clk1   : in std_logic;
            clk2   : in std_logic;
            rst    : in std_logic;
            wen    : in std_logic;
            waddr  : in std_logic_vector(d - 1 downto 0);
            raddr0 : in std_logic_vector(d - 1 downto 0);
            raddr1 : in std_logic_vector(d - 1 downto 0);
            wdata  : in std_logic_vector(w - 1 downto 0);
            rdata0 : out std_logic_vector(w - 1 downto 0);
            rdata1 : out std_logic_vector(w - 1 downto 0)
        );
    end component;
begin
    clk2 <= not clk1;
    clock : basic_clk generic map(1 ns, 0.5 ns, 0 ns, 0 ns)port map(clk1);
    mem   : regMem generic map(
        32, 5) port map(
        clk1   => clk1,
        clk2   => clk2,
        rst    => rst,
        wen    => wen,
        waddr  => waddr,
        raddr0 => raddr0,
        raddr1 => raddr1,
        wdata  => wdata,
        rdata0 => rdata0,
        rdata1 => rdata1

    );

    stim : process
    begin
        rst <= '1';
        wait for 1 ns;
        rst <= '0';
        wait for 140 ns;
        std.env.stop;
    end process;

    vdata : process
    begin
        wdata  <= std_logic_vector(to_unsigned(0, wdata'length));
        raddr0 <= std_logic_vector(to_unsigned(0, raddr0'length));
        raddr1 <= std_logic_vector(to_unsigned(0, raddr1'length));
        waddr  <= std_logic_vector(to_unsigned(0, waddr'length));

        wait for 1.5 ns;
        wen <= '1';
        -- read after write
        for i in 0 to 31 loop
            waddr <= std_logic_vector(to_unsigned(i, waddr'length));
            wdata <= std_logic_vector(to_unsigned(i + 10, wdata'length));
            wait for 1 ns;
        end loop;

        for i in 0 to 31 loop
            raddr0 <= std_logic_vector(to_unsigned(i, raddr0'length));
            raddr1 <= std_logic_vector(to_unsigned(i, raddr1'length));
            wait for 1 ns;
        end loop;

        -- read while write
        for i in 0 to 31 loop
            waddr  <= std_logic_vector(to_unsigned(i, waddr'length));
            wdata  <= std_logic_vector(to_unsigned(i + 20, wdata'length));
            raddr0 <= std_logic_vector(to_unsigned(i, raddr0'length));
            raddr1 <= std_logic_vector(to_unsigned(i, raddr1'length));
            wait for 1 ns;
        end loop;

        wen <= '0';
        for i in 0 to 31 loop
            waddr  <= std_logic_vector(to_unsigned(i, waddr'length));
            wdata  <= std_logic_vector(to_unsigned(i + 30, wdata'length));
            raddr0 <= std_logic_vector(to_unsigned(i, raddr0'length));
            raddr1 <= std_logic_vector(to_unsigned(i, raddr1'length));
            wait for 1 ns;
        end loop;
        --

        wait;
        -- Load register test

    end process;

end tb1;
