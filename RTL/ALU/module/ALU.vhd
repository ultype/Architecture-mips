
library ieee;
package ALU_pkg is
  use ieee.std_logic_1164.all;

  component barrelShifter32 is -- single-bit D flip-flop
    port (
      dir    : in std_logic;
      sp     : in std_logic;
      barrel : in std_logic;
      Din    : in std_logic_vector(31 downto 0);
      shift  : in std_logic_vector(4 downto 0);
      Dout   : out std_logic_vector(31 downto 0));
  end component;

  component biDirect is -- multi-bit D flip-fif lop
    generic (n : integer);
    port (
      dir    : in std_logic;
      shift  : in std_logic;
      barrel : in std_logic;
      DinL   : in std_logic_vector(n - 1 downto 0);
      DinO   : in std_logic_vector(n - 1 downto 0);
      DinR   : in std_logic_vector(n - 1 downto 0);
      BinL   : in std_logic_vector(n - 1 downto 0);
      BinR   : in std_logic_vector(n - 1 downto 0);
      Dout   : out std_logic_vector(n - 1 downto 0)
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
      sel                 : in std_logic_vector(2 downto 0);
      result, Cout        : out std_logic);
  end component;

  component signExtend16to32 is
    port (
      signExt : in std_logic;
      di      : in std_logic_vector(15 downto 0);
      do      : out std_logic_vector(31 downto 0)
    );
  end component;

  component ALU32 is
    port (
      ctrl               : in std_logic_vector(14 downto 0);
      rs                 : in std_logic_vector(4 downto 0);
      regData0, regData1 : in std_logic_vector(31 downto 0);
      immed              : in std_logic_vector(31 downto 0);
      shamt              : in std_logic_vector(4 downto 0);
      result             : out std_logic_vector(31 downto 0);
      zero               : out std_logic;
      ovf                : out std_logic;
      less               : out std_logic
    );
  end component;

end package;

--- ALU32
library ieee;
library MipsEncode;
library work;
use ieee.std_logic_1164.all;
use work.ALU_pkg.all;
use MipsEncode.MipsEncode_pkg.all;

entity ALU32 is
  port (
    ctrl               : in std_logic_vector(14 downto 0);
    rs                 : in std_logic_vector(4 downto 0);
    regData0, regData1 : in std_logic_vector(31 downto 0);
    immed              : in std_logic_vector(31 downto 0);
    shamt              : in std_logic_vector(4 downto 0);
    result             : out std_logic_vector(31 downto 0);
    zero               : out std_logic;
    ovf                : out std_logic;
    less               : out std_logic
  );
end entity ALU32;

architecture ALU32_impl of ALU32 is
  signal A, B       : std_logic_vector(32 downto 0);
  signal C          : std_logic_vector(33 downto 0);
  signal L          : std_logic_vector(32 downto 0);
  signal S          : std_logic_vector(32 downto 0);
  signal shift      : std_logic_vector(4 downto 0);

  signal selA       : std_logic;
  signal selB       : std_logic_vector(1 downto 0);

  signal invA, invB : std_logic;
  signal carry      : std_logic;
  signal ALUsel     : std_logic_vector(2 downto 0);
  signal ALUsign    : std_logic;

  signal selShift   : std_logic_vector(1 downto 0);
  signal signShift  : std_logic;
  signal dirShift   : std_logic;
  signal barrel     : std_logic;

  signal sovf       : std_logic; --signed ovf
  signal uovf       : std_logic; --unsigned ovf
  signal sless      : std_logic; --signed less
  signal uless      : std_logic; --unsigned less

begin

  -- signal attribute
  selA      <= ctrl(14);
  selB      <= ctrl(13 downto 12);
  invA      <= ctrl(11);
  invB      <= ctrl(10);
  carry     <= ctrl(9);
  ALUsel    <= ctrl(8 downto 6);
  ALUSign   <= ctrl(5);
  selShift  <= ctrl(4 downto 3);
  signShift <= ctrl(2);
  dirShift  <= ctrl(1);
  barrel    <= ctrl(0);

  -- A signal
  A_sel : process (all)
  begin
    if (selA) then
      A <= '0' & regData0;
    else
      A <= 33b"0";
    end if;
  end process;

  -- B signal
  B_sel : process (all)
  begin
    with (selB) select
    B <=
      '0' & regData1 when 2b"01",
      '0' & immed when 2b"10",
      33b"0" when others;
  end process;

  uovf  <= C(33) xor C(32);
  sovf  <= C(32) xor C(31);
  uless <= S(32) xor uovf;
  sless <= S(31) xor sovf;
  C(0)  <= carry;

  zero  <= not (((((S(0) or S(1)) or (S(2) or S(3))) or ((S(4) or S(5)) or (S(6) or S(7)))) or (((S(8) or S(9)) or (S(10) or S(11))) or ((S(12) or S(13)) or (S(14) or S(15))))) or ((((S(16) or S(17)) or (S(18) or S(19))) or ((S(20) or S(21)) or (S(22) or S(23)))) or (((S(24) or S(25)) or (S(26) or S(27))) or ((S(28) or S(29)) or (S(30) or S(31))))));

  ALU_DUT : for i in 0 to 32 generate
    ALUX : ALUunit port map(
      inA    => A(i),
      inB    => B(i),
      Cin    => C(i),
      less   => L(i),
      invA   => invA,
      invB   => invB,
      sel    => ALUsel,
      Cout   => C(i + 1),
      result => S(i)
    );
  end generate ALU_DUT;

  OVF_SEL : process (all)
  begin
    if (ALUsign) then
      ovf <= uovf;
    else
      ovf <= sovf;
    end if;
  end process;

  L(31 downto 1) <= 31b"0";
  L_SEL : process (all)
  begin
    if (ALUSign) then
      L(0) <= C(32); --unsigned
    else
      L(0) <= S(31); --signed
    end if;
  end process;

  LESS_SEL : process (all)
  begin
    if (ALUSign) then
      less <= uless;--unsign;
    else
      less <= sless;
    end if;
  end process;

  --shift select
  SHIFT_SEL : process (all)
  begin
    with selShift select
      shift <=
      rs when 2b"01",
      shamt when 2b"10",
      5b"0" when others;
  end process;

  SHIFTER : barrelShifter32 port map(
    dir    => dirShift,
    sp     => signShift,
    barrel => barrel,
    Din    => S(31 downto 0),
    shift  => shift,
    Dout   => result
  );
end ALU32_impl;

library ieee;
library work;
use ieee.std_logic_1164.all;
use work.ALU_pkg.all;

entity ALUunit is
  port (
    inA, inB, Cin, less : in std_logic;
    invA, invB          : in std_logic;
    sel                 : in std_logic_vector(2 downto 0);
    result, Cout        : out std_logic);
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
    andAB when 3b"000", -- and nor
    orAB when 3b"001",  -- or
    xorAB when 3b"010", -- xor
    less when 3b"011",  -- less
    s0 when others;     -- add sub 2b'1XX'

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
    dir    : in std_logic;
    sp     : in std_logic;
    barrel : in std_logic;
    Din    : in std_logic_vector(31 downto 0);
    shift  : in std_logic_vector(4 downto 0);
    Dout   : out std_logic_vector(31 downto 0));
end barrelShifter32;

architecture barrelShifter32_impl of barrelShifter32 is
  component biDirect is
    generic (n : integer);
    port (
      dir    : in std_logic;
      shift  : in std_logic;
      barrel : in std_logic;
      DinL   : in std_logic_vector(n - 1 downto 0);
      DinO   : in std_logic_vector(n - 1 downto 0);
      DinR   : in std_logic_vector(n - 1 downto 0);
      BinL   : in std_logic_vector(n - 1 downto 0);
      BinR   : in std_logic_vector(n - 1 downto 0);
      Dout   : out std_logic_vector(n - 1 downto 0)
    );
  end component;
  signal cp                      : std_logic;
  signal DL0, DR0, DO0, BL0, BR0 : std_logic_vector(31 downto 0);
  signal DL1, DR1, DO1, BL1, BR1 : std_logic_vector(31 downto 0);
  signal DL2, DR2, DO2, BL2, BR2 : std_logic_vector(31 downto 0);
  signal DL3, DR3, DO3, BL3, BR3 : std_logic_vector(31 downto 0);
  signal DL4, DR4, DO4, BL4, BR4 : std_logic_vector(31 downto 0);
begin

  cp               <= sp and Din(31);
  -- shift 1 
  DO0              <= Din;
  DL0              <= Din(30 downto 0) & cp; -- left shift
  DR0              <= cp & Din(31 downto 1); -- width0
  BL0(31 downto 1) <= Din(30 downto 0);
  BL0(0)           <= Din(31);
  BR0(30 downto 0) <= Din(31 downto 1);
  BR0(31)          <= Din(0);
  mux1 : biDirect generic map(32)
  port map(
    dir    => dir,
    shift  => shift(0),
    barrel => barrel,
    DinL   => DL0,
    DinO   => DO0,
    DinR   => DR0,
    BinL   => BL0,
    BinR   => BR0,
    Dout   => DO1
  );

  -- shift 2
  DL1               <= DO1(29 downto 0) & cp & cp; -- left shift
  DR1               <= cp & cp & DO1(31 downto 2); -- right shift
  BL1(31 downto 2)  <= DO1(29 downto 0);
  BL1(1 downto 0)   <= DO1(31 downto 30);
  BR1(29 downto 0)  <= DO1(31 downto 2);
  BR1(31 downto 30) <= DO1(1 downto 0);

  mux2 : biDirect generic map(32)
  port map(
    dir    => dir,
    shift  => shift(1),
    barrel => barrel,
    DinL   => DL1,
    DinO   => DO1,
    DinR   => DR1,
    BinL   => BL1,
    BinR   => BR1,
    Dout   => DO2
  );

  DL2               <= DO2(27 downto 0) & cp & cp & cp & cp; -- left shift
  DR2               <= cp & cp & cp & cp & DO2(31 downto 4); -- right shift
  BL2(31 downto 4)  <= DO2(27 downto 0);
  BL2(3 downto 0)   <= DO2(31 downto 28);
  BR2(27 downto 0)  <= DO2(31 downto 4);
  BR2(31 downto 28) <= DO2(3 downto 0);
  mux4 : biDirect generic map(32)
  port map(
    dir    => dir,
    shift  => shift(2),
    barrel => barrel,
    DinL   => DL2,
    DinO   => DO2,
    DinR   => DR2,
    BinL   => BL2,
    BinR   => BR2,
    Dout   => DO3
  );

  DL3               <= DO3(23 downto 0) & cp & cp & cp & cp & cp & cp & cp & cp; -- left shift
  DR3               <= cp & cp & cp & cp & cp & cp & cp & cp & DO2(31 downto 8); -- right shift
  BL3(31 downto 8)  <= DO3(23 downto 0);
  BL3(7 downto 0)   <= DO3(31 downto 24);
  BR3(23 downto 0)  <= DO3(31 downto 8);
  BR3(31 downto 24) <= DO3(7 downto 0);

  mux8 : biDirect generic map(32)
  port map(
    dir    => dir,
    shift  => shift(3),
    barrel => barrel,
    DinL   => DL3,
    DinO   => DO3,
    DinR   => DR3,
    BinL   => BL3,
    BinR   => BR3,
    Dout   => DO4
  );
  DL4               <= DO4(15 downto 0) & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp;  -- left shift
  DR4               <= cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & cp & DO2(31 downto 16); -- right shift 
  BL4(31 downto 16) <= DO4(15 downto 0);
  BL4(15 downto 0)  <= DO4(31 downto 16);
  BR4(15 downto 0)  <= DO4(31 downto 16);
  BR4(31 downto 16) <= DO4(15 downto 0);
  mux16 : biDirect generic map(32)
  port map(
    dir    => dir,
    shift  => shift(4),
    barrel => barrel,
    DinL   => DL4,
    DinO   => DO4,
    DinR   => DR4,
    BinL   => BL4,
    BinR   => BR4,
    Dout   => Dout
  );

end barrelShifter32_impl;
library ieee;
use ieee.std_logic_1164.all;

entity biDirect is
  generic (n : integer);
  port (
    dir    : in std_logic;
    shift  : in std_logic;
    barrel : in std_logic;
    DinL   : in std_logic_vector(n - 1 downto 0);
    DinO   : in std_logic_vector(n - 1 downto 0);
    DinR   : in std_logic_vector(n - 1 downto 0);
    BinL   : in std_logic_vector(n - 1 downto 0);
    BinR   : in std_logic_vector(n - 1 downto 0);
    Dout   : out std_logic_vector(n - 1 downto 0)
  );
end biDirect;

architecture biDirect_impl of biDirect is
  signal sel : std_logic_vector(2 downto 0);
begin
  sel <= barrel & dir & shift;
  with sel select
    Dout <=
    DinL when 3b"001", -- left shift
    DinR when 3b"011", -- right shift
    BinL when 3b"101", -- left barrel
    BinR when 3b"111", -- right barrel
    DinO when others;
end biDirect_impl;

library ieee;
use ieee.std_logic_1164.all;

entity signExtend16to32 is
  port (
    signExt : in std_logic;
    di      : in std_logic_vector(15 downto 0);
    do      : out std_logic_vector(31 downto 0)
  );
end entity;

architecture signExtend16to32_impl of signExtend16to32 is
  signal s : std_logic;
begin
  s  <= signExt and di(15);
  do <= (15 downto 0 => di, others => s);

end signExtend16to32_impl;
