library ieee;
use ieee.std_logic_1164.all;

entity id_ex_reg is
  port(
    clk      : in  std_logic;
    resetBar : in  std_logic;

    en       : in  std_logic; -- typically '1'
    flush    : in  std_logic; -- bubble insert (load-use OR taken branch)

    -- ===== data signals =====
    pc4_in   : in  std_logic_vector(7 downto 0);
    rd1_in   : in  std_logic_vector(7 downto 0);
    rd2_in   : in  std_logic_vector(7 downto 0);
    imm8_in  : in  std_logic_vector(7 downto 0);
    rs_in    : in  std_logic_vector(2 downto 0);
    rt_in    : in  std_logic_vector(2 downto 0);
    rd_in    : in  std_logic_vector(2 downto 0);
    funct_in : in  std_logic_vector(5 downto 0);

    -- ===== control signals (from ID decode) =====
    RegDst_in   : in std_logic;
    Jump_in     : in std_logic;
    BranchEQ_in : in std_logic;
    BranchNE_in : in std_logic;
    MemRead_in  : in std_logic;
    MemtoReg_in : in std_logic;
    ALUOp1_in   : in std_logic;
    ALUOp0_in   : in std_logic;
    MemWrite_in : in std_logic;
    ALUSrc_in   : in std_logic;
    RegWrite_in : in std_logic;

    -- ===== outputs =====
    pc4_out   : out std_logic_vector(7 downto 0);
    rd1_out   : out std_logic_vector(7 downto 0);
    rd2_out   : out std_logic_vector(7 downto 0);
    imm8_out  : out std_logic_vector(7 downto 0);
    rs_out    : out std_logic_vector(2 downto 0);
    rt_out    : out std_logic_vector(2 downto 0);
    rd_out    : out std_logic_vector(2 downto 0);
    funct_out : out std_logic_vector(5 downto 0);

    RegDst_out   : out std_logic;
    Jump_out     : out std_logic;
    BranchEQ_out : out std_logic;
    BranchNE_out : out std_logic;
    MemRead_out  : out std_logic;
    MemtoReg_out : out std_logic;
    ALUOp1_out   : out std_logic;
    ALUOp0_out   : out std_logic;
    MemWrite_out : out std_logic;
    ALUSrc_out   : out std_logic;
    RegWrite_out : out std_logic
  );
end entity;

architecture structural of id_ex_reg is
  signal nflush : std_logic;

  -- masked controls (ctrl & ~flush)
  signal RegDst_m, Jump_m, BranchEQ_m, BranchNE_m : std_logic;
  signal MemRead_m, MemtoReg_m, ALUOp1_m, ALUOp0_m : std_logic;
  signal MemWrite_m, ALUSrc_m, RegWrite_m : std_logic;
begin
  nflush <= not flush;

  RegDst_m   <= RegDst_in   and nflush;
  Jump_m     <= Jump_in     and nflush;
  BranchEQ_m <= BranchEQ_in and nflush;
  BranchNE_m <= BranchNE_in and nflush;
  MemRead_m  <= MemRead_in  and nflush;
  MemtoReg_m <= MemtoReg_in and nflush;
  ALUOp1_m   <= ALUOp1_in   and nflush;
  ALUOp0_m   <= ALUOp0_in   and nflush;
  MemWrite_m <= MemWrite_in and nflush;
  ALUSrc_m   <= ALUSrc_in   and nflush;
  RegWrite_m <= RegWrite_in and nflush;

  -- data regs
  r_pc4   : entity work.nbitRegister generic map(N => 8) port map(resetBar, en, clk, pc4_in,   pc4_out);
  r_rd1   : entity work.nbitRegister generic map(N => 8) port map(resetBar, en, clk, rd1_in,   rd1_out);
  r_rd2   : entity work.nbitRegister generic map(N => 8) port map(resetBar, en, clk, rd2_in,   rd2_out);
  r_imm8  : entity work.nbitRegister generic map(N => 8) port map(resetBar, en, clk, imm8_in,  imm8_out);
  r_rs    : entity work.nbitRegister generic map(N => 3) port map(resetBar, en, clk, rs_in,    rs_out);
  r_rt    : entity work.nbitRegister generic map(N => 3) port map(resetBar, en, clk, rt_in,    rt_out);
  r_rd    : entity work.nbitRegister generic map(N => 3) port map(resetBar, en, clk, rd_in,    rd_out);
  r_funct : entity work.nbitRegister generic map(N => 6) port map(resetBar, en, clk, funct_in, funct_out);

  -- control regs (1-bit)
  r_RegDst   : entity work.bitRegister port map(clk, resetBar, en, RegDst_m,   RegDst_out);
  r_Jump     : entity work.bitRegister port map(clk, resetBar, en, Jump_m,     Jump_out);
  r_BrEQ     : entity work.bitRegister port map(clk, resetBar, en, BranchEQ_m, BranchEQ_out);
  r_BrNE     : entity work.bitRegister port map(clk, resetBar, en, BranchNE_m, BranchNE_out);
  r_MemRead  : entity work.bitRegister port map(clk, resetBar, en, MemRead_m,  MemRead_out);
  r_MemtoReg : entity work.bitRegister port map(clk, resetBar, en, MemtoReg_m, MemtoReg_out);
  r_ALUOp1   : entity work.bitRegister port map(clk, resetBar, en, ALUOp1_m,   ALUOp1_out);
  r_ALUOp0   : entity work.bitRegister port map(clk, resetBar, en, ALUOp0_m,   ALUOp0_out);
  r_MemWrite : entity work.bitRegister port map(clk, resetBar, en, MemWrite_m, MemWrite_out);
  r_ALUSrc   : entity work.bitRegister port map(clk, resetBar, en, ALUSrc_m,   ALUSrc_out);
  r_RegWrite : entity work.bitRegister port map(clk, resetBar, en, RegWrite_m, RegWrite_out);

end architecture;