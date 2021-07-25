
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

  component HA is
    port (
      a, b : in std_logic;
      s, c : out std_logic);
  end component;

  component FA is
    port (
      inA, inB, Cin : in std_logic;
      s, Cout       : out std_logic);
  end component;

  component Adder32 is
    port (
      inA, inB : in std_logic_vector(31 downto 0);
      result   : out std_logic_vector(31 downto 0)
    );
  end component;

  component ALUUnit is
    port (
      inA, inB, Cin, less : in std_logic;
      invA, invB          : in std_logic;
      sel                 : in std_logic_vector(1 downto 0);
      result, Cout        : out std_logic);
  end component;
end package;
--library ieee;
--library work;
--use ieee.std_logic_1164.all;
--use work.ALU_pkg.all;

--entity ALU32 is
--  port (
--    A, B       : in std_logic_vector(31 downto 0);
--    invA, invB : in std_logic;
--    opcode     : in std_logic_vector(5 downto 0);
--
--    result     : in std_logic_vector(2 downto 0);
--  );
--end ALU32;

--architecture ALU32_impl of ALU32 is
--  signal Bsrc : std_logic_vector(31 downto 0)
--  signal ctrl : std_logic_vector(5 downto 0);
--  signal C    : std_logic_vector(32 downto 0);
--  signal S    : std_logic_vector(31 downto 0);
--begin

--  GEN_ADD : for I in 0 to 31 generate
--    U0 : ALUunit port map(
--      inA    => A(I),
--      inB    => Bsrc(I),
--      Cin    => C(I),
--      invA   => ctrl(3),
--      invB   => ctrl(2),
--      sel    => ctrl(1 downto 0)
--      result => S(I),
--      Cout   => C(I + 1)
--    );

--    ALU_CTRL : process (all)
--    begin

--    end process;

--    ALU_RESULT : process (all)
--    beginingl
--      with ctrl(4) select
--      result <= S when '0',
--        result <= 31b"0" & C(32);
--    end process;

--  end generate GEN_ADD;
--end ALU32_impl;

library ieee;
library work;
use ieee.std_logic_1164.all;
use work.ALU_pkg.all;

entity ALUunit is
  port (
    inA, inB, Cin : in std_logic;
    invA, invB    : in std_logic;
    sel           : in std_logic_vector(1 downto 0);
    result, Cout  : out std_logic);
end ALUunit;

architecture ALUunit_impl of ALUunit is
  signal A0, B0, s0, c0, andAB, orAB, xorAB : std_logic;
begin
  HA1 : HA port map(a => xorAB, b => Cin, s => s0, c => c0);

  -- inverse
  A0    <= invA xor inA;
  B0    <= invB xor inB;

  -- logic and HA operation  
  andAB <= A0 and B0; --HA0 cout
  xorAB <= A0 xor B0; --HA0 s
  orAB  <= A0 or B0;
  Cout  <= c0 xor andAB;

  with sel select
    result <=
    andAB when 2b"00", -- and nor
    orAB when 2b"01",  -- or
    xorAB when 2b"10", -- xor
    s0 when others;    -- add sub 2b'11'

end ALUunit_impl;

library ieee;
library work;
use ieee.std_logic_1164.all;
use work.ALU_pkg.all;

entity Adder32 is
  port (
    inA, inB : in std_logic_vector(31 downto 0);
    result   : out std_logic_vector(31 downto 0)
  );
end Adder32;

architecture Adder32_impl of Adder32 is

  component FA is
    port (
      inA, inB, Cin : in std_logic;
      s, Cout       : out std_logic);
  end component;

  signal C : std_logic_vector(32 downto 0);

begin
  C(0) <= '0';
  GEN_ADD : for I in 0 to 31 generate
    U0 : FA port map(
      inA  => inA(I),
      inB  => inB(I),
      Cin  => C(I),
      s    => result(I),
      Cout => C(I + 1)
    );
  end generate GEN_ADD;

end Adder32_impl;

library ieee;
library work;
use ieee.std_logic_1164.all;
use work.ALU_pkg.all;
entity FA is
  port (
    inA, inB, Cin : in std_logic;
    s, Cout       : out std_logic);
end FA;

architecture FA_impl of FA is
  signal c0, c1, s0 : std_logic;
  component HA is
    port (
      a, b : in std_logic;
      s, c : out std_logic);
  end component;
begin
  HA0 : HA port map(a => inA, b => inB, c => c0, s => s0);
  HA1 : HA port map(a => s0, b => Cin, c => c1, s => s);
  Cout <= c1 xor c0;
end FA_impl;

library ieee;
use ieee.std_logic_1164.all;

entity HA is
  port (
    a, b : in std_logic;
    s, c : out std_logic);
end HA;

architecture HA_impl of HA is
begin
  s <= a xor b;
  c <= a and b;
end HA_impl;

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
