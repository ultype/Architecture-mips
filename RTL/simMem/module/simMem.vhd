library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;

package simMem_pkg is
  constant ram_width  : integer := 8;
  constant ram_depth  : integer := 4 * 1024 * 1024;
  constant addr_width : integer := 32;
  constant data_width : integer := 32;
  type ram_type is array (0 to ram_depth - 1) of std_logic_vector(ram_width - 1 downto 0);
  component dualMem is
    port (
      clk1  : in std_logic;
      clk2  : in std_logic;
      wen   : in std_logic;
      waddr : in std_logic_vector(addr_width - 1 downto 0);
      raddr : in std_logic_vector(addr_width - 1 downto 0);
      wdata : in std_logic_vector(data_width - 1 downto 0);
      rdata : out std_logic_vector(data_width - 1 downto 0));
  end component;

  component instrMem is
    port (
      clk1  : in std_logic;
      clk2  : in std_logic;
      rst   : in std_logic;
      raddr : in std_logic_vector(addr_width - 1 downto 0);
      rdata : out std_logic_vector(data_width - 1 downto 0));
  end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.simMem_pkg.all;
entity dualMem is
  port (
    clk1  : in std_logic;
    clk2  : in std_logic;
    wen   : in std_logic;
    waddr : in std_logic_vector(addr_width - 1 downto 0);
    raddr : in std_logic_vector(addr_width - 1 downto 0);
    wdata : in std_logic_vector(data_width - 1 downto 0);
    rdata : out std_logic_vector(data_width - 1 downto 0));
end dualMem;

architecture dualMem_rtl of dualMem is
  signal RAM    : ram_type;
  signal raddr0 : std_logic_vector(addr_width - 1 downto 0);
  signal raddr1 : std_logic_vector(addr_width - 1 downto 0);
  signal raddr2 : std_logic_vector(addr_width - 1 downto 0);
  signal raddr3 : std_logic_vector(addr_width - 1 downto 0);
  signal waddr0 : std_logic_vector(addr_width - 1 downto 0);
  signal waddr1 : std_logic_vector(addr_width - 1 downto 0);
  signal waddr2 : std_logic_vector(addr_width - 1 downto 0);
  signal waddr3 : std_logic_vector(addr_width - 1 downto 0);
begin
  raddr0 <= raddr(addr_width - 1 downto 2) & 2b"00";
  raddr1 <= raddr(addr_width - 1 downto 2) & 2b"01";
  raddr2 <= raddr(addr_width - 1 downto 2) & 2b"10";
  raddr3 <= raddr(addr_width - 1 downto 2) & 2b"11";
  waddr0 <= waddr(addr_width - 1 downto 2) & 2b"00";
  waddr1 <= waddr(addr_width - 1 downto 2) & 2b"01";
  waddr2 <= waddr(addr_width - 1 downto 2) & 2b"10";
  waddr3 <= waddr(addr_width - 1 downto 2) & 2b"11";
  writer : process (all)
  begin
    if (falling_edge(clk1) and clk2 = '1') then
      if wen = '1' then
        RAM(conv_integer(waddr0)) <= wdata(7 downto 0);
        RAM(conv_integer(waddr1)) <= wdata(15 downto 8);
        RAM(conv_integer(waddr2)) <= wdata(23 downto 16);
        RAM(conv_integer(waddr3)) <= wdata(31 downto 24);
      end if;
    end if;

  end process;

  reader : process (all)
  begin
    if (falling_edge(clk2) and clk1 = '0') then
      rdata(7 downto 0)   <= RAM(conv_integer(raddr0));
      rdata(15 downto 8)  <= RAM(conv_integer(raddr1));
      rdata(23 downto 16) <= RAM(conv_integer(raddr2));
      rdata(31 downto 24) <= RAM(conv_integer(raddr3));
    end if;
  end process;
end dualMem_rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.simMem_pkg.all;

entity instrMem is
  port (
    clk1  : in std_logic;
    clk2  : in std_logic;
    rst   : in std_logic;
    raddr : in std_logic_vector(addr_width - 1 downto 0);
    rdata : out std_logic_vector(data_width - 1 downto 0));
end instrMem;

architecture instrMem_rtl of instrMem is
  signal RAM      : ram_type;
  file read_file  : text;
  file write_file : text;
  signal raddr0   : std_logic_vector(addr_width - 1 downto 0);
  signal raddr1   : std_logic_vector(addr_width - 1 downto 0);
  signal raddr2   : std_logic_vector(addr_width - 1 downto 0);
  signal raddr3   : std_logic_vector(addr_width - 1 downto 0);
begin
  file_open(read_file, "./instr.dat", read_mode);
  raddr0 <= raddr(addr_width - 1 downto 2) & 2b"00";
  raddr1 <= raddr(addr_width - 1 downto 2) & 2b"01";
  raddr2 <= raddr(addr_width - 1 downto 2) & 2b"10";
  raddr3 <= raddr(addr_width - 1 downto 2) & 2b"11";
  loadInstr : process (rst)
    variable line_v : line;
    variable word   : std_ulogic_vector(addr_width + data_width - 1 downto 0);
    variable addr   : std_logic_vector(addr_width - 1 downto 0);
    variable instr  : std_logic_vector(data_width - 1 downto 0);
    variable good   : boolean;
    variable i      : integer := 0;
  begin
    if (rst'event and rst = '1') then
      while (not endfile(read_file)) loop
        readline(read_file, line_v);
        HREAD(line_v, word, good);
        report "word :" & to_hstring(word);
        addr  := word(addr_width + data_width - 1 downto data_width);
        instr := word(data_width - 1 downto 0);
        i     := conv_integer(addr);
        RAM(i)     <= instr(7 downto 0);
        RAM(i + 1) <= instr(15 downto 8);
        RAM(i + 2) <= instr(23 downto 16);
        RAM(i + 3) <= instr(31 downto 24);
      end loop;
    end if;
  end process loadInstr;

  reader : process (all)
  begin
    if (rising_edge(clk2) and (clk1 = '1')) then
      if (rst = '1') then
        rdata <= 32b"0";
      else
        rdata(7 downto 0)   <= RAM(conv_integer(raddr0));
        rdata(15 downto 8)  <= RAM(conv_integer(raddr1));
        rdata(23 downto 16) <= RAM(conv_integer(raddr2));
        rdata(31 downto 24) <= RAM(conv_integer(raddr3));
      end if;
    end if;
  end process;

end instrMem_rtl;
