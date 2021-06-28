


library ieee;
package ff is
  use ieee.std_logic_1164.all;
  component vDFF is           -- multi-bit D flip-fif lop
    generic (n : integer := 1); -- width
    port (
      clk : in std_logic;
      rst : in std_logic;
      D   : in std_logic_vector(n - 1 downto 0);
      Q   : out std_logic_vector(n - 1 downto 0));
  end component;

  component sDFF is -- single-bit D flip-flop
    port (
      clk, rst, D : in std_logic;
      Q           : out std_logic);
  end component;

end package;

library ieee;
use ieee.std_logic_1164.all;
entity vDFF is
  generic (n : integer := 1);

  port (
    clk : in std_logic;
    rst : in std_logic;
    D   : in std_logic_vector(n - 1 downto 0);
    Q   : out std_logic_vector(n - 1 downto 0));
end vDFF;

architecture impl of vDFF is
  constant zero : std_logic_vector(n - 1 downto 0) := ( others => '0');
begin
  process (clk, rst, D) begin
    if (rst = '1') then
      Q <= zero;
    elsif rising_edge(clk) then
      Q <= D;
    end if;
  end process;
end impl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity sDFF is
  port (
    clk, rst, D : in std_logic;
    Q           : out std_logic);
end sDFF;

architecture impl of sDFF is
begin
  process (clk, rst, D) begin
    if (rst = '1') then
      Q <= '0';
    elsif rising_edge(clk) then
      Q <= D;
    end if;
  end process;
end impl;
