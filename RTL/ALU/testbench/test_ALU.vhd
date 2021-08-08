library ieee;
library ALU;
library MipsEncode;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ALU.ALU_pkg.all;
use MipsEncode.MipsEncode_pkg.all;

entity ALU_tb is
    port (n : integer := 32);
end ALU_tb;

architecture tb of ALU_tb is
    signal ALUctrl     : std_logic_vector(14 downto 0);
    signal instr       : std_logic_vector(31 downto 0);
    signal instrR      : R_TYPE;
    signal instrI      : I_TYPE;
    signal instrJ      : J_TYPE;
    signal t           : std_logic_vector(1 downto 0);
    signal regData0    : std_logic_vector(31 downto 0);
    signal regData1    : std_logic_vector(31 downto 0);
    signal immed       : std_logic_vector(31 downto 0);
    signal shamt       : std_logic_vector(4 downto 0);
    signal result      : std_logic_vector(31 downto 0);
    signal ovf         : std_logic;
    signal less        : std_logic;
    signal zero        : std_logic;
    signal v0, v1      : integer;

    signal result_true : std_logic_vector(31 downto 0);
    signal ovf_true    : std_logic;
    signal less_true   : std_logic;
    signal zero_true   : std_logic;
    signal pass        : boolean;
    signal signExt     : std_logic;
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

begin

    TYPE_SEL : process (all)
    begin
        with t select
            instr <=
            (
            31 downto 26 => instrR.opcode,
            25 downto 21 => instrR.rs,
            20 downto 16 => instrR.rt,
            15 downto 11 => instrR.rd,
            10 downto 6  => instrR.shamt,
            5 downto 0   => instrR.func
            ) when 2b"01", --Rtype
            (
            31 downto 26 => instrI.opcode,
            25 downto 21 => instrI.rs,
            20 downto 16 => instrI.rt,
            15 downto 0  => instrI.immed
            ) when 2b"10", --Itype
            (
            31 downto 26 => instrJ.opcode,
            25 downto 0  => instrJ.jaddr
            ) when 2b"11", --Rtype
            32b"0" when others;
    end process;

    ALU_CTRL : process (all)
    begin
        if (t = 2b"01") then
            case instr(5 downto 0) is
                when (ADD_FUNC)  => ALUctrl  <= 15b"101000100000000"; -- R type
                when (ADDU_FUNC) => ALUctrl <= 15b"101000100100000";

                when (SUB_FUNC)  => ALUctrl  <= 15b"101011100000000";
                when (SUBU_FUNC) => ALUctrl <= 15b"101011100100000";

                when (AND_FUNC)  => ALUctrl  <= 15b"101000000000000";
                when (OR_FUNC)   => ALUctrl   <= 15b"101000001000000";
                when (XOR_FUNC)  => ALUctrl  <= 15b"101000010000000";
                when (NOR_FUNC)  => ALUctrl  <= 15b"101110000000000";

                when (SLL_FUNC)  => ALUctrl  <= 15b"001000100100000";
                when (SRL_FUNC)  => ALUctrl  <= 15b"001000100100100";
                when (SRA_FUNC)  => ALUctrl  <= 15b"001000100101100";
                when (SLLV_FUNC) => ALUctrl <= 15b"001000100010000";
                when (SRLV_FUNC) => ALUctrl <= 15b"001000100010100";
                when (SRAV_FUNC) => ALUctrl <= 15b"001000100011100";

                when (SLT_FUNC)  => ALUctrl  <= 15b"101011011000000";
                when (SLTU_FUNC) => ALUctrl <= 15b"101011011000001";
                when others      => ALUctrl      <= 15b"000000000000000";
            end case;
        elsif (t = 2b"10") then
            case instr(31 downto 26) is
                when ADDI_OP  => ALUctrl  <= 15b"110000100000000";
                when ADDIU_OP => ALUctrl <= 15b"110000100100000";
                when ANDI_OP  => ALUctrl  <= 15b"110000000000000";
                when ORI_OP   => ALUctrl   <= 15b"110000001000000";
                when XOR_OP   => ALUctrl   <= 15b"110000010000000";
                when SLTI_OP  => ALUctrl  <= 15b"110011011000000";
                when SLTIU_OP => ALUctrl <= 15b"110011011000001";

                when LW_OP    => ALUctrl    <= 15b"110000100000000";
                when SW_OP    => ALUctrl    <= 15b"110000100000000";

                when BEQ_OP   => ALUctrl   <= 15b"101011100000000";
                when BNE_OP   => ALUctrl   <= 15b"101011100000000";

                when BGEZ_OP  => ALUctrl  <= 15b"100011100000000";
                when BGTZ_OP  => ALUctrl  <= 15b"100011100000000";
                when BLEZ_OP  => ALUctrl  <= 15b"100011100000000";
                when others   => ALUctrl   <= 15b"000000000000000";
            end case;
        end if;
    end process;

    ALU_TEST : ALU32
    port map(
        ctrl     => ALUctrl,
        rs       => instr(25 downto 21),
        regData0 => regData0,
        regData1 => regData1,
        immed    => immed,
        shamt    => instr(10 downto 6),
        result   => result,
        ovf      => ovf,
        less     => less,
        zero     => zero
    );

    signExt <= not ALUctrl(5);
    SignExtend16to32_TEST : signExtend16to32
    port map(
        signExt => signExt,
        di      => instrI.immed,
        do      => immed
    );
    pass <= (ovf_true = ovf) and (zero_true = zero) and (result_true = result);

    TEST : process
    begin
        wait for 1 ns;
        -- R_ADD     1+1
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADD_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"0001";
        regData1      <= 32b"0001";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"0010";
        wait for 1 ns;

        -- R_ADD   2+1
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADD_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"0010";
        regData1      <= 32b"0001";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"0011";
        wait for 1 ns;

        -- R_ADD   1 + -1
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADD_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"0001";
        regData1      <= 32b"11111111111111111111111111111111";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '1';
        result_true   <= 32b"00000000000000000000000000000000";

        wait for 1 ns;

        -- R_ADD       -1 + 1
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADD_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"11111111111111111111111111111111";
        regData1      <= 32b"00000000000000000000000000000001";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '1';
        result_true   <= 32b"00000000000000000000000000000000";
        wait for 1 ns;

        -- R_ADD      3 + -1
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADD_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"0011";
        regData1      <= 32b"11111111111111111111111111111111";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"00000000000000000000000000000010";
        wait for 1 ns;

        -- R_ADD   ovf  P P ovf
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADD_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"01111111111111111111111111111111";
        regData1      <= 32b"01111111111111111111111111111111";
        ovf_true      <= '1';
        less_true     <= '1';
        zero_true     <= '0';
        result_true   <= 32b"11111111111111111111111111111110";
        wait for 1 ns;

        -- R_ADD   ovf  P P ovf
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADD_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"01000000000000000000000000000000";
        regData1      <= 32b"01000000000000000000000000000000";
        ovf_true      <= '1';
        less_true     <= '1';
        zero_true     <= '0';
        result_true   <= 32b"10000000000000000000000000000000";
        wait for 1 ns;

        -- R_ADD   ovf  P P ovf
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADD_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"11000000000000000000000000000000";
        regData1      <= 32b"11000000000000000000000000000000";
        ovf_true      <= '0';
        less_true     <= '1';
        zero_true     <= '0';
        result_true   <= 32b"10000000000000000000000000000000";
        wait for 1 ns;

        -- R_ADD   ovf  P P ovf
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADD_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"10000000000000000000000000000000";
        regData1      <= 32b"10000000000000000000000000000000";
        ovf_true      <= '1';
        less_true     <= '0';
        zero_true     <= '1';
        result_true   <= 32b"00000000000000000000000000000000";
        wait for 1 ns;

        -- R_ADD   ovf 
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADD_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"01000000000000000000000000000000";
        regData1      <= 32b"11000000000000000000000000000000";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '1';
        result_true   <= 32b"00000000000000000000000000000000";
        wait for 1 ns;

        -- R_ADDU
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADDU_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"00000000000000000000000000000000";
        regData1      <= 32b"11111111111111111111111111111111";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"11111111111111111111111111111111";
        wait for 1 ns;

        -- R_ADDU
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADDU_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"11111111111111111111111111111111";
        ovf_true      <= '1';
        less_true     <= '0';
        zero_true     <= '1';
        result_true   <= 32b"00000000000000000000000000000000";
        wait for 1 ns;

        -- R_ADDU
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= ADDU_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"01111111111111111111111111111111";
        regData1      <= 32b"11111111111111111111111111111111";
        ovf_true      <= '1';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"01111111111111111111111111111110";
        wait for 1 ns;

        -- R_SUB 1 - 0
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= SUB_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"00000000000000000000000000000000";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"00000000000000000000000000000001";
        wait for 1 ns;

        -- R_SUB -1 - 0
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= SUB_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"11111111111111111111111111111111";
        regData1      <= 32b"00000000000000000000000000000000";
        ovf_true      <= '0';
        less_true     <= '1';
        zero_true     <= '0';
        result_true   <= 32b"11111111111111111111111111111111";
        wait for 1 ns;

        -- R_SUB 0 - 1
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= SUB_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"00000000000000000000000000000000";
        regData1      <= 32b"00000000000000000000000000000001";
        ovf_true      <= '0';
        less_true     <= '1';
        zero_true     <= '0';
        result_true   <= 32b"11111111111111111111111111111111";
        wait for 1 ns;

        -- R_SUB 1 - 1
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= SUB_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"00000000000000000000000000000001";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '1';
        result_true   <= 32b"00000000000000000000000000000000";
        wait for 1 ns;

        -- R_SUB 2 - 1
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= SUB_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"00000000000000000000000000000010";
        regData1      <= 32b"00000000000000000000000000000001";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"00000000000000000000000000000001";
        wait for 1 ns;

        -- R_SUB 1 - 2
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= SUB_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"00000000000000000000000000000010";
        ovf_true      <= '0';
        less_true     <= '1';
        zero_true     <= '0';
        result_true   <= 32b"11111111111111111111111111111111";
        wait for 1 ns;

        -- R_SUB 3 - 1
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= SUB_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"00000000000000000000000000000011";
        regData1      <= 32b"00000000000000000000000000000001";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"00000000000000000000000000000010";
        wait for 1 ns;

        -- R_SUB 1 - 3
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= SUB_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"00000000000000000000000000000011";
        ovf_true      <= '0';
        less_true     <= '1';
        zero_true     <= '0';
        result_true   <= 32b"11111111111111111111111111111110";
        wait for 1 ns;

        -- R_SUB -1 - -1
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= SUB_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"11111111111111111111111111111111";
        regData1      <= 32b"11111111111111111111111111111111";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '1';
        result_true   <= 32b"00000000000000000000000000000000";
        wait for 1 ns;

        -- R_SUB +P - -1
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= SUB_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"01111111111111111111111111111111";
        regData1      <= 32b"11111111111111111111111111111111";
        ovf_true      <= '1';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"10000000000000000000000000000000";
        wait for 1 ns;

        -- R_SUBU +P - -1
        t             <= 2b"01";
        instrR.opcode <= R_OP;
        instrR.func   <= SUBU_FUNC;
        instrR.shamt  <= 5b"00000";
        regData0      <= 32b"01111111111111111111111111111111";
        regData1      <= 32b"11111111111111111111111111111111";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"10000000000000000000000000000000";
        wait for 1 ns;
        -- I_ADDI  1+1
        t             <= 2b"10";
        instrI.opcode <= ADDI_OP;
        instrI.immed  <= 16b"0000000000000001";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"00000000000000000000000000000010";
        wait for 1 ns;

        -- I_ADDI  1 + -1
        t             <= 2b"10";
        instrI.opcode <= ADDI_OP;
        instrI.immed  <= 16b"1111111111111111";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '1';
        result_true   <= 32b"00000000000000000000000000000000";
        wait for 1 ns;

        -- I_ADDIU 1 + 1
        t             <= 2b"10";
        instrI.opcode <= ADDIU_OP;
        instrI.immed  <= 16b"0000000000000001";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"00000000000000000000000000000010";
        wait for 1 ns;

        -- I_ADDIU 1 + P
        t             <= 2b"10";
        instrI.opcode <= ADDIU_OP;
        instrI.immed  <= 16b"0111111111111111";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"00000000000000001000000000000000";
        wait for 1 ns;

        -- I_ADDIU P + P
        t             <= 2b"10";
        instrI.opcode <= ADDIU_OP;
        instrI.immed  <= 16b"1111111111111111";
        regData0      <= 32b"01111111111111111111111111111111";
        regData1      <= 32b"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"10000000000000001111111111111110";
        wait for 1 ns;

        -- I_ADDI  1 + -1
        t             <= 2b"10";
        instrI.opcode <= ADDIU_OP;
        instrI.immed  <= 16b"1111111111111111";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"10000000000000000";
        wait for 1 ns;

        -- I_ADDI  1 + -1
        t             <= 2b"10";
        instrI.opcode <= ADDIU_OP;
        instrI.immed  <= 16b"1111111111111111";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"10000000000000000";
        wait for 1 ns;

        -- BEQ
        t             <= 2b"10";
        instrI.opcode <= BEQ_OP;
        instrI.immed  <= 16b"0001";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"00000000000000000000000000000001";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '1';
        result_true   <= 32b"0";

        -- BEQ
        t             <= 2b"10";
        instrI.opcode <= BEQ_OP;
        instrI.immed  <= 16b"0001";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"00000000000000000000000000000011";
        ovf_true      <= '0';
        less_true     <= '1';
        zero_true     <= '0';
        result_true   <= 32b"11111111111111111111111111111110";
        wait for 1 ns;

        -- LW
        t             <= 2b"10";
        instrI.opcode <= LW_OP;
        instrI.immed  <= 16b"0001";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
        ovf_true      <= '0';
        less_true     <= '1';
        zero_true     <= '0';
        result_true   <= 32b"0010";
        wait for 1 ns;

        -- SW
        t             <= 2b"10";
        instrI.opcode <= SW_OP;
        instrI.immed  <= 16b"0001";
        regData0      <= 32b"00000000000000000000000000000001";
        regData1      <= 32b"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
        ovf_true      <= '0';
        less_true     <= '0';
        zero_true     <= '0';
        result_true   <= 32b"0010";
        wait for 1 ns;

        std.env.stop;
    end process;
end tb;
