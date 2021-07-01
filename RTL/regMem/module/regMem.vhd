
/*
SRC : https://www.intel.com/content/www/us/en/programmable/quartushelp/13.0/mergedProjects/hdl/vhdl/vhdl_pro_ram_inferred.htm
Big Endian
*/

library ieee;
use ieee.std_logic_1164.all;
library flipflop;
use flipflop.ff.all;
package regMem_pkg is
  constant width : integer := 32;
  constant depth : integer := 32;

  component vReg is
    generic (n : integer);
    port (
      clk : in std_logic;
      rst : in std_logic;
      en  : in std_logic;
      D   : in std_logic_vector(n - 1 downto 0);
      Q   : out std_logic_vector(n - 1 downto 0));
  end component;

  component regMem is
    port (
      clk   : in std_logic;
      rst   : in std_logic;
      wdata : in std_logic_vector(width - 1 downto 0);
      waddr : in std_logic_vector(4 downto 0);
      raddr : in std_logic_vector(4 downto 0);
      we    : in std_logic;
      rdata : out std_logic_vector(width - 1 downto 0)
    );
  end component;

end package;
library ieee;
use ieee.std_logic_1164.all;
entity regMem is
  port (
    port (
      clk   : in std_logic;
      rst   : in std_logic;
      wdata : in std_logic_vector(width - 1 downto 0);
      waddr : in std_logic_vector(4 downto 0);
      raddr : in std_logic_vector(4 downto 0);
      we    : in std_logic;
      rdata : out std_logic_vector(width - 1 downto 0)
    );
  );
end regMem;

library ieee;
library flipflop;
use ieee.std_logic_1164.all;
use flipflop.ff.all;

entity vReg is
  generic (n : integer := 1);
  port (
    clk : in std_logic;
    rst : in std_logic;
    en  : in std_logic;
    D   : in std_logic_vector(n - 1 downto 0);
    Q   : out std_logic_vector(n - 1 downto 0));
end vReg;

architecture reg_rtl of vReg is
  signal sel    : std_logic_vector(1 downto 0);
  signal vD, vQ : std_logic_vector(n - 1 downto 0);
  constant zero : std_logic_vector(n - 1 downto 0) := (others => '0');
begin
  vddf : vDFF generic map(n) port map(clk => clk, rst => rst, D => vD, Q => vQ);
  sel <= rst & en;
  Q   <= vQ;
  process (clk, sel, D)
  begin
    with sel select
      vD <= vQ when 2b"00",
      D when 2b"01",
      zero when others;
  end process;
end reg_rtl;

architecture regMem_rtl of ram_dual is
  signal sel : std_logic_vector(1 to 0);
begin
  sel <= rst & en;

end rtl;
