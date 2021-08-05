library ieee;
use ieee.std_logic_1164.all;
package MipsEncode_pkg is

    subtype OPCODE_TYPE is std_logic_vector(5 downto 0);
    subtype FUNC_TYPE is std_logic_vector(5 downto 0);
    subtype REG_ADDR_TYPE is std_logic_vector(4 downto 0);
    subtype SHIFT_TYPE is std_logic_vector(4 downto 0);
    subtype IMMED_TYPE is std_logic_vector(15 downto 0);
    subtype J_ADDR_TYPE is std_logic_vector(25 downto 0);

    type R_TYPE is record
        opcode : OPCODE_TYPE;
        rs     : REG_ADDR_TYPE;
        rt     : REG_ADDR_TYPE;
        rd     : REG_ADDR_TYPE;
        Shamt  : SHIFT_TYPE;
        func   : FUNC_TYPE;
    end record R_TYPE;

    type I_TYPE is record
        opcode : OPCODE_TYPE;
        rs     : REG_ADDR_TYPE;
        rt     : REG_ADDR_TYPE;
        immed  : IMMED_TYPE;
    end record I_TYPE;

    type J_TYPE is record
        opcode : OPCODE_TYPE;
        jaddr  : J_ADDR_TYPE;
    end record J_TYPE;

    constant R_OP      : OPCODE_TYPE := 6b"000000";

    -- load word I-type
    constant LW_OP     : OPCODE_TYPE := 6b"100011";
    constant SW_OP     : OPCODE_TYPE := 6b"101011";
    -- ADD R-TYPE
    constant ADD_OP    : OPCODE_TYPE := 6b"000000";
    constant ADD_FUNC  : FUNC_TYPE   := 6b"100000";

    -- ADDU R-TYPE
    constant ADDU_OP   : OPCODE_TYPE := 6b"000000";
    constant ADDU_FUNC : FUNC_TYPE   := 6b"100001";

    -- SUB R-TYPE
    constant SUB_OP    : OPCODE_TYPE := 6b"000000";
    constant SUB_FUNC  : FUNC_TYPE   := 6b"100010";

    -- SUBU R-TYPE
    constant SUBU_OP   : OPCODE_TYPE := 6b"000000";
    constant SUBU_FUNC : FUNC_TYPE   := 6b"100011";

    -- AND R-TYPE
    constant AND_OP    : OPCODE_TYPE := 6b"000000";
    constant AND_FUNC  : FUNC_TYPE   := 6b"100100";

    -- OR R-TYPE
    constant OR_OP     : OPCODE_TYPE := 6b"000000";
    constant OR_FUNC   : FUNC_TYPE   := 6b"100101";

    -- XOR R-TYPE
    constant XOR_OP    : OPCODE_TYPE := 6b"000000";
    constant XOR_FUNC  : FUNC_TYPE   := 6b"100110";

    -- NOR R-TYPE
    constant NOR_OP    : OPCODE_TYPE := 6b"000000";
    constant NOR_FUNC  : FUNC_TYPE   := 6b"100111";

    -- SLL R-TYPE
    constant SLL_OP    : OPCODE_TYPE := 6b"000000";
    constant SLL_FUNC  : FUNC_TYPE   := 6b"000000";

    -- SRL R-TYPE
    constant SRL_OP    : OPCODE_TYPE := 6b"000000";
    constant SRL_FUNC  : FUNC_TYPE   := 6b"000010";

    -- SRA R-TYPE
    constant SRA_OP    : OPCODE_TYPE := 6b"000000";
    constant SRA_FUNC  : FUNC_TYPE   := 6b"000011";

    -- ADDI I-TYPE
    constant ADDI_OP   : OPCODE_TYPE := 6b"001000";

    -- ADDIU I-TYPE
    constant ADDIU_OP  : OPCODE_TYPE := 6b"001001";

    -- ANDI I-TYPE
    constant ANDI_OP   : OPCODE_TYPE := 6b"001100";

    -- ORI I-TYPE
    constant ORI_OP    : OPCODE_TYPE := 6b"001101";

    -- XORI I-TYPE
    constant XORI_OP   : OPCODE_TYPE := 6b"001110";

    -- BEQ 
    constant BEQ_OP    : OPCODE_TYPE := 6b"000100";

    -- BGEZ 
    constant BGEZ_OP   : OPCODE_TYPE := 6b"000001";

    -- BGTZ
    constant BGTZ_OP   : OPCODE_TYPE := 6b"000111";

    -- BLEZ 
    constant BLEZ_OP   : OPCODE_TYPE := 6b"000110";

    -- BLTZ
    constant BLTZ_OP   : OPCODE_TYPE := 6b"000001";

    -- BNQ 
    constant BNQ_OP    : OPCODE_TYPE := 6b"000101";

    -- Jump 
    constant J_OP      : OPCODE_TYPE := 6b"000010";

    component mainCtrl is
        port (
            instr    : in std_logic_vector(31 downto 0);
            regDst   : out std_logic;
            branch   : out std_logic;
            memRead  : out std_logic;
            memtoReg : out std_logic;
            ALUop    : out std_logic_vector(1 downto 0);
            memWrite : out std_logic;
            ALUsrc   : out std_logic;
            regWrite : out std_logic);
    end component;

end package MipsEncode_pkg;

library ieee;
use std_logic_1164.all;

entity mainCtrl is
    instr    : in std_logic_vector(31 downto 0);
    regDst   : out std_logic;
    branch   : out std_logic;
    memRead  : out std_logic;
    memtoReg : out std_logic;
    ALUop    : out std_logic_vector(1 downto 0);
    memWrite : out std_logic;
    ALUsrc   : out std_logic;
    regWrite : out std_logic;
end mainCtrl;

architecture mainCtrl_impl of mainctrl is
    signal ctrl : std_logic_vector(8 downto 0);
begin

    regDst   <= ctrl(8);
    ALUsrc   <= ctrl(7);
    memtoReg <= ctrl(6);
    regWrite <= ctrl(5);
    memRead  <= ctrl(4);
    memWrite <= ctrl(3);
    branch   <= ctrl(2);
    ALUop    <= ctrl(1 downto 0);

    process (all)
    begin
        with instr(31 downto 26) select
        ctrl <=
            9b"100100010" when R_OP,
            9b"011110000" when LW_OP,
            9b"010001000" when SW_op,
            9b"000000101" when BEQ_OP,
            9b"000000000" when others;
    end process
end CONTROL_impl;
