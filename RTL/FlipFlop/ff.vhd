/*
  Editor : Tsai Chih-shian
  Reference :VHDL page 319
*/

library ieee;
package ff is
  use ieee.std_logic_ll64.all;
  component vDFF is --multi-bit D flip-flop
    generic(n : integer := 1);
    port(clk: in std_logic;
         D : in std_logic_vector(n-1 downto 0);
         Q : out std_logic_vector(n-1 downto 0));
  end component;
