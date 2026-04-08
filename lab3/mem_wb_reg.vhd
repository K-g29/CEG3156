library ieee;
use ieee.std_logic_1164.all;

entity mem_wb_reg is
  port(
    clk      : in  std_logic;
    resetBar : in  std_logic;
    en       : in  std_logic; -- usually '1'

    -- ===== data from MEM stage =====
    memReadData_in : in  std_logic_vector(7 downto 0);
    aluResult_in   : in  std_logic_vector(7 downto 0);
    writeReg_in    : in  std_logic_vector(2 downto 0);

    -- ===== control from MEM stage =====
    MemtoReg_in : in std_logic;
    RegWrite_in : in std_logic;

    -- ===== outputs to WB stage =====
    memReadData_out : out std_logic_vector(7 downto 0);
    aluResult_out   : out std_logic_vector(7 downto 0);
    writeReg_out    : out std_logic_vector(2 downto 0);

    MemtoReg_out : out std_logic;
    RegWrite_out : out std_logic
  );
end entity;

architecture structural of mem_wb_reg is
begin
  r_md : entity work.nbitRegister generic map(N => 8)
    port map(i_resetBar=>resetBar, i_enable=>en, i_clock=>clk, i_d=>memReadData_in, o_q=>memReadData_out);

  r_alu: entity work.nbitRegister generic map(N => 8)
    port map(i_resetBar=>resetBar, i_enable=>en, i_clock=>clk, i_d=>aluResult_in, o_q=>aluResult_out);

  r_wr : entity work.nbitRegister generic map(N => 3)
    port map(i_resetBar=>resetBar, i_enable=>en, i_clock=>clk, i_d=>writeReg_in, o_q=>writeReg_out);

  r_m2r: entity work.bitRegister port map(clk, resetBar, en, MemtoReg_in, MemtoReg_out);
  r_rw : entity work.bitRegister port map(clk, resetBar, en, RegWrite_in, RegWrite_out);
end architecture;