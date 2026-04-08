library ieee;
use ieee.std_logic_1164.all;

entity ex_mem_reg is
  port(
    clk      : in  std_logic;
    resetBar : in  std_logic;
    en       : in  std_logic; -- usually '1'

    -- ===== data from EX stage =====
    aluResult_in   : in  std_logic_vector(7 downto 0);
    writeData_in   : in  std_logic_vector(7 downto 0); -- store data after any forwarding
    writeReg_in    : in  std_logic_vector(2 downto 0);

    -- Optional: for debug / branch (not required if PC already updated)
    takeBr_in      : in  std_logic := '0';
    branchTarget_in: in  std_logic_vector(7 downto 0) := (others => '0');
    zero_in        : in  std_logic := '0';

    -- ===== control inputs (already masked/valid) =====
    MemRead_in   : in std_logic;
    MemWrite_in  : in std_logic;
    MemtoReg_in  : in std_logic;
    RegWrite_in  : in std_logic;

    -- ===== outputs to MEM stage =====
    aluResult_out   : out std_logic_vector(7 downto 0);
    writeData_out   : out std_logic_vector(7 downto 0);
    writeReg_out    : out std_logic_vector(2 downto 0);

    takeBr_out      : out std_logic;
    branchTarget_out: out std_logic_vector(7 downto 0);
    zero_out        : out std_logic;

    MemRead_out   : out std_logic;
    MemWrite_out  : out std_logic;
    MemtoReg_out  : out std_logic;
    RegWrite_out  : out std_logic
  );
end entity;

architecture structural of ex_mem_reg is
begin
  -- data regs
  r_alu : entity work.nbitRegister generic map(N => 8)
    port map(i_resetBar=>resetBar, i_enable=>en, i_clock=>clk, i_d=>aluResult_in, o_q=>aluResult_out);

  r_wd  : entity work.nbitRegister generic map(N => 8)
    port map(i_resetBar=>resetBar, i_enable=>en, i_clock=>clk, i_d=>writeData_in, o_q=>writeData_out);

  r_wr  : entity work.nbitRegister generic map(N => 3)
    port map(i_resetBar=>resetBar, i_enable=>en, i_clock=>clk, i_d=>writeReg_in, o_q=>writeReg_out);

  -- optional debug/branch regs
  r_take: entity work.bitRegister port map(clk=>clk, resetBar=>resetBar, en=>en, d=>takeBr_in, q=>takeBr_out);
  r_zero: entity work.bitRegister port map(clk=>clk, resetBar=>resetBar, en=>en, d=>zero_in,  q=>zero_out);

  r_bt  : entity work.nbitRegister generic map(N => 8)
    port map(i_resetBar=>resetBar, i_enable=>en, i_clock=>clk, i_d=>branchTarget_in, o_q=>branchTarget_out);

  -- control regs
  r_mr : entity work.bitRegister port map(clk, resetBar, en, MemRead_in,  MemRead_out);
  r_mw : entity work.bitRegister port map(clk, resetBar, en, MemWrite_in, MemWrite_out);
  r_m2r: entity work.bitRegister port map(clk, resetBar, en, MemtoReg_in, MemtoReg_out);
  r_rw : entity work.bitRegister port map(clk, resetBar, en, RegWrite_in, RegWrite_out);

end architecture;