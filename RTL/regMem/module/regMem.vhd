library ieee;
use ieee.std_logic_1164.all;
library flipflop;
use flipflop.ff.all;
package regMem_pkg is
  constant width : integer := 32;
  constant depth : integer := 5;

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
    generic (
      w : integer;
      d : integer
    );
    port (
      clk1  : in std_logic;
      clk2  : in std_logic;
      rst   : in std_logic;
      wen   : in std_logic;
      waddr : in std_logic_vector(d - 1 downto 0);
      raddr : in std_logic_vector(d - 1 downto 0);
      wdata : in std_logic_vector(w - 1 downto 0);
      rdata : out std_logic_vector(w - 1 downto 0));
  end component;
end package;
library ieee;
library flipflop;
use ieee.std_logic_1164.all;
use flipflop.ff.all;

entity vReg is
  generic (n : integer);
  port (
    clk : in std_logic;
    rst : in std_logic;
    en  : in std_logic;
    D   : in std_logic_vector(n - 1 downto 0);
    Q   : out std_logic_vector(n - 1 downto 0));
end vReg;

architecture vReg_rtl of vReg is
  signal vD1, vQ1 : std_logic_vector(n - 1 downto 0);
begin
  Q <= vQ1;
  dff : vDFF generic map(n) port map(clk => clk, rst => rst, D => vD1, Q => vQ1);

  process (all)
  begin
    if en then
      vD1 <= D;
    else
      vD1 <= vQ1;
    end if;
  end process;

end vReg_rtl;

library ieee;
library flipflop;
use ieee.std_logic_1164.all;
use flipflop.ff.all;

entity regMem is
  generic (
    w : integer := 32;
    d : integer := 5);
  port (
    clk1  : in std_logic;
    clk2  : in std_logic;
    rst   : in std_logic;
    wen   : in std_logic;
    waddr : in std_logic_vector(d - 1 downto 0);
    raddr : in std_logic_vector(d - 1 downto 0);
    wdata : in std_logic_vector(w - 1 downto 0);
    rdata : out std_logic_vector(w - 1 downto 0)
  );
end regMem;

architecture regMem_rtl of regMem is
  signal waddrQ           : std_logic_vector(d - 1 downto 0);
  signal raddrQ0, raddrQ1 : std_logic_vector(d - 1 downto 0);
  signal wenQ             : std_logic;
  signal wdataQ           : std_logic_vector(w - 1 downto 0);
  signal read_en          : std_logic_vector(5 downto 0);

  signal en               : std_logic_vector(31 downto 0);
  signal rdata01          : std_logic_vector(w - 1 downto 0);
  signal rdata02          : std_logic_vector(w - 1 downto 0);
  signal rdata03          : std_logic_vector(w - 1 downto 0);
  signal rdata04          : std_logic_vector(w - 1 downto 0);
  signal rdata05          : std_logic_vector(w - 1 downto 0);
  signal rdata06          : std_logic_vector(w - 1 downto 0);
  signal rdata07          : std_logic_vector(w - 1 downto 0);
  signal rdata08          : std_logic_vector(w - 1 downto 0);
  signal rdata09          : std_logic_vector(w - 1 downto 0);
  signal rdata10          : std_logic_vector(w - 1 downto 0);
  signal rdata11          : std_logic_vector(w - 1 downto 0);
  signal rdata12          : std_logic_vector(w - 1 downto 0);
  signal rdata13          : std_logic_vector(w - 1 downto 0);
  signal rdata14          : std_logic_vector(w - 1 downto 0);
  signal rdata15          : std_logic_vector(w - 1 downto 0);
  signal rdata16          : std_logic_vector(w - 1 downto 0);
  signal rdata17          : std_logic_vector(w - 1 downto 0);
  signal rdata18          : std_logic_vector(w - 1 downto 0);
  signal rdata19          : std_logic_vector(w - 1 downto 0);
  signal rdata20          : std_logic_vector(w - 1 downto 0);
  signal rdata21          : std_logic_vector(w - 1 downto 0);
  signal rdata22          : std_logic_vector(w - 1 downto 0);
  signal rdata23          : std_logic_vector(w - 1 downto 0);
  signal rdata24          : std_logic_vector(w - 1 downto 0);
  signal rdata25          : std_logic_vector(w - 1 downto 0);
  signal rdata26          : std_logic_vector(w - 1 downto 0);
  signal rdata27          : std_logic_vector(w - 1 downto 0);
  signal rdata28          : std_logic_vector(w - 1 downto 0);
  signal rdata29          : std_logic_vector(w - 1 downto 0);
  signal rdata30          : std_logic_vector(w - 1 downto 0);
  signal rdata31          : std_logic_vector(w - 1 downto 0);
  component vReg is
    generic (n : integer := 1);
    port (
      clk : in std_logic;
      rst : in std_logic;
      en  : in std_logic;
      D   : in std_logic_vector(n - 1 downto 0);
      Q   : out std_logic_vector(n - 1 downto 0));
  end component;

  component vDFF is
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
begin

  wdata_reg  : vDFF generic map(w) port map(clk => clk1, rst => rst, D => wdata, Q => wdataQ);
  waddr_reg  : vDFF generic map(d) port map(clk => clk1, rst => rst, D => waddr, Q => waddrQ);
  raddr_reg0 : vDFF generic map(d) port map(clk => clk1, rst => rst, D => raddr, Q => raddrQ0);
  raddr_reg1 : vDFF generic map(d) port map(clk => clk2, rst => rst, D => raddrQ0, Q => raddrQ1);
  wen_reg    : sDFF port map(clk => clk1, rst => rst, D => wen, Q => wenQ);

  r01        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(1), D => wdataQ, Q => rdata01);
  r02        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(2), D => wdataQ, Q => rdata02);
  r03        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(3), D => wdataQ, Q => rdata03);
  r04        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(4), D => wdataQ, Q => rdata04);
  r05        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(5), D => wdataQ, Q => rdata05);
  r06        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(6), D => wdataQ, Q => rdata06);
  r07        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(7), D => wdataQ, Q => rdata07);
  r08        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(8), D => wdataQ, Q => rdata08);
  r09        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(9), D => wdataQ, Q => rdata09);
  r10        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(10), D => wdataQ, Q => rdata10);
  r11        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(11), D => wdataQ, Q => rdata11);
  r12        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(12), D => wdataQ, Q => rdata12);
  r13        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(13), D => wdataQ, Q => rdata13);
  r14        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(14), D => wdataQ, Q => rdata14);
  r15        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(15), D => wdataQ, Q => rdata15);
  r16        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(16), D => wdataQ, Q => rdata16);
  r17        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(17), D => wdataQ, Q => rdata17);
  r18        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(18), D => wdataQ, Q => rdata18);
  r19        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(19), D => wdataQ, Q => rdata19);
  r20        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(20), D => wdataQ, Q => rdata20);
  r21        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(21), D => wdataQ, Q => rdata21);
  r22        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(22), D => wdataQ, Q => rdata22);
  r23        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(23), D => wdataQ, Q => rdata23);
  r24        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(24), D => wdataQ, Q => rdata24);
  r25        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(25), D => wdataQ, Q => rdata25);
  r26        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(26), D => wdataQ, Q => rdata26);
  r27        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(27), D => wdataQ, Q => rdata27);
  r28        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(28), D => wdataQ, Q => rdata28);
  r29        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(29), D => wdataQ, Q => rdata29);
  r30        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(30), D => wdataQ, Q => rdata30);
  r31        : vReg generic map(w) port map(clk => clk2, rst => rst, en => en(31), D => wdataQ, Q => rdata31);

  read_en <= (wenQ & waddrQ);
  process (all)
  begin
    with (wenQ & waddrQ) select
    en <= 32b"00000000000000000000000000000010" when 6b"100001",
      32b"00000000000000000000000000000100" when 6b"100010",
      32b"00000000000000000000000000001000" when 6b"100011",
      32b"00000000000000000000000000010000" when 6b"100100",
      32b"00000000000000000000000000100000" when 6b"100101",
      32b"00000000000000000000000001000000" when 6b"100110",
      32b"00000000000000000000000010000000" when 6b"100111",
      32b"00000000000000000000000100000000" when 6b"101000",
      32b"00000000000000000000001000000000" when 6b"101001",
      32b"00000000000000000000010000000000" when 6b"101010",
      32b"00000000000000000000100000000000" when 6b"101011",
      32b"00000000000000000001000000000000" when 6b"101100",
      32b"00000000000000000010000000000000" when 6b"101101",
      32b"00000000000000000100000000000000" when 6b"101110",
      32b"00000000000000001000000000000000" when 6b"101111",
      32b"00000000000000010000000000000000" when 6b"110000",
      32b"00000000000000100000000000000000" when 6b"110001",
      32b"00000000000001000000000000000000" when 6b"110010",
      32b"00000000000010000000000000000000" when 6b"110011",
      32b"00000000000100000000000000000000" when 6b"110100",
      32b"00000000001000000000000000000000" when 6b"110101",
      32b"00000000010000000000000000000000" when 6b"110110",
      32b"00000000100000000000000000000000" when 6b"110111",
      32b"00000001000000000000000000000000" when 6b"111000",
      32b"00000010000000000000000000000000" when 6b"111001",
      32b"00000100000000000000000000000000" when 6b"111010",
      32b"00001000000000000000000000000000" when 6b"111011",
      32b"00010000000000000000000000000000" when 6b"111100",
      32b"00100000000000000000000000000000" when 6b"111101",
      32b"01000000000000000000000000000000" when 6b"111110",
      32b"10000000000000000000000000000000" when 6b"111111",
      32b"00000000000000000000000000000000" when others;
  end process;

  process (all)
  begin
    with raddrQ1 select
      rdata <= rdata01 when 5b"00001",
      rdata02 when 5b"00010",
      rdata03 when 5b"00011",
      rdata04 when 5b"00100",
      rdata05 when 5b"00101",
      rdata06 when 5b"00110",
      rdata07 when 5b"00111",
      rdata08 when 5b"01000",
      rdata09 when 5b"01001",
      rdata10 when 5b"01010",
      rdata11 when 5b"01011",
      rdata12 when 5b"01100",
      rdata13 when 5b"01101",
      rdata14 when 5b"01110",
      rdata15 when 5b"01111",
      rdata16 when 5b"10000",
      rdata17 when 5b"10001",
      rdata18 when 5b"10010",
      rdata19 when 5b"10011",
      rdata20 when 5b"10100",
      rdata21 when 5b"10101",
      rdata22 when 5b"10110",
      rdata23 when 5b"10111",
      rdata24 when 5b"11000",
      rdata25 when 5b"11001",
      rdata26 when 5b"11010",
      rdata27 when 5b"11011",
      rdata28 when 5b"11100",
      rdata29 when 5b"11101",
      rdata30 when 5b"11110",
      rdata31 when 5b"11111",
      32b"0" when others;
  end process;
end regMem_rtl;
