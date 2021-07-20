
library ieee;
package ALU_pkg is
  use ieee.std_logic_1164.all;

  component barrelShifter32 is -- single-bit D flip-flop
    port (
      dir   : in std_logic;
      cp    : in std_logic;
      Din   : in std_logic_vector(31 downto 0);
      shift : in std_logic_vector(4 downto 0);
      Dout  : out std_logic_vector(31 downto 0));
  end component;

  component biDirect is -- multi-bit D flip-fif lop
    generic (n : integer);
    port (
      dir   : in std_logic;
      shift : in std_logic;
      DinL  : in std_logic_vector(n - 1 downto 0);
      DinO  : in std_logic_vector(n - 1 downto 0);
      DinR  : in std_logic_vector(n - 1 downto 0);
      Dout  : out std_logic_vector(n - 1 downto 0)
    );
  end component;

  component FA is

  end component;

end package;

library ieee;
use ieee.std_logic_1164.all;

entity HA is
  A, B : in std_logic;
  S, C : out std_logic;
end HA;

library ieee;
use ieee.std_logic_1164.all;
entity barrelShifter32 is
  port (
    dir   : in std_logic;
    cp    : in std_logic;
    Din   : in std_logic_vector(31 downto 0);
    shift : in std_logic_vector(4 downto 0);
    Dout  : out std_logic_vector(31 downto 0));
end barrelShifter32;

architecture barrelShifter32_impl of barrelShifter32 is
  component biDirect is
    generic (n : integer);
    port (
      dir   : in std_logic;
      shift : in std_logic;
      DinL  : in std_logic_vector(n - 1 downto 0);
      DinO  : in std_logic_vector(n - 1 downto 0);
      DinR  : in std_logic_vector(n - 1 downto 0);
      Dout  : out std_logic_vector(n - 1 downto 0)
    );
  end component;

  signal DL0, DR0, DO0 : std_logic_vector(31 downto 0);
  signal DL1, DR1, DO1 : std_logic_vector(31 downto 0);
  signal DL2, DR2, DO2 : std_logic_vector(31 downto 0);
  signal DL3, DR3, DO3 : std_logic_vector(31 downto 0);
  signal DL4, DR4, DO4 : std_logic_vector(31 downto 0);

begin
  DO0 <= Din;
  DL0 <= Din(30 downto 0) & cp; -- left shift
  DR0 <= cp & Din(31 downto 1); -- width0

  mux1 : biDirect generic map(32)
  port map(
    dir   => dir,
    shift => shift(0),
    DinL  => DL0,
    DinO  => DO0,
    DinR  => DR0,
    Dout  => DO1
  );

  DL1 <= DO1(29 downto 0) & cp & cp; -- left shift
  DR1 <= cp & cp & DO1(31 downto 2); -- right shift

  mux2 : biDirect generic map(32)
  port map(
    dir   => dir,
    shift => shift(1),
    DinL  => DL1,
    DinO  => DO1,
    DinR  => DR1,
    Dout  => DO2
  );

  DL2 <= DO2(27 downto 0) & cp & cp & cp & cp; -- left shift
  DR2 <= cp & cp & cp & cp & DO2(31 downto 4); -- right shift

  mux4 : biDirect generic map(32)
  port map(
    dir   => dir,
    shift => shift(2),
    DinL  => DL2,
    DinO  => DO2,
    DinR  => DR2,
    Dout  => DO3
  );

  DL3 <= DO3(23 downto 0) & cp & cp & cp & cp & cp & cp & cp & cp; -- left shift
  DR3 <= cp & cp & cp & cp & cp & cp & cp & cp & DO2(31 downto 8); -- right shift
  mux8 : biDirect generic map(32)
  port map(
    dir   => dir,
    shift => shift(3),
    DinL  => DL3,
    DinO  => DO3,
    DinR  => DR3,
    Dout  => DO4
  );
  DL4 <= DO4(15 downto 0) & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp;  -- left shift
  DR4 <= cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & DO2(31 downto 16); -- right shift  
  mux16 : biDirect generic map(32)
  port map(
    dir   => dir,
    shift => shift(4),
    DinL  => DL4,
    DinO  => DO4,
    DinR  => DR4,
    Dout  => Dout
  );

end barrelShifter32_impl;

library ieee;
use ieee.std_logic_1164.all;

entity biDirect is
  generic (n : integer);
  port (
    dir   : in std_logic;
    shift : in std_logic;
    DinL  : in std_logic_vector(n - 1 downto 0);
    DinO  : in std_logic_vector(n - 1 downto 0);
    DinR  : in std_logic_vector(n - 1 downto 0);
    Dout  : out std_logic_vector(n - 1 downto 0)
  );
end biDirect;

architecture biDirect_impl of biDirect is
  signal sel : std_logic_vector(1 downto 0);
begin
  sel <= dir & shift;
  with sel select
    Dout <= DinL when 2b"01", -- left shift data
    DinR when 2b"11",         -- right shift data 
    DinO when others;
end biDirect_impl;
