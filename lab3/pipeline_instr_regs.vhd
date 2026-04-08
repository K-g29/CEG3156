library ieee;
use ieee.std_logic_1164.all;

-- Pipelines instruction words for display:
-- I1 is from IMEM (combinational output)
-- I2 is IF/ID (stall + flush-to-NOP)
-- I3/I4/I5 are subsequent stage registers (always enabled)
entity pipeline_instr_regs is
  port(
    clk      : in  std_logic;
    resetBar : in  std_logic;

    IFID_en    : in  std_logic; -- stall IF/ID
    IFID_flush : in  std_logic; -- taken branch/jump: write NOP into IF/ID

    I1_in      : in  std_logic_vector(31 downto 0); -- from IMEM

    I2_out     : out std_logic_vector(31 downto 0);
    I3_out     : out std_logic_vector(31 downto 0);
    I4_out     : out std_logic_vector(31 downto 0);
    I5_out     : out std_logic_vector(31 downto 0);

    I2_tap     : out std_logic_vector(31 downto 0)
  );
end entity;

architecture structural of pipeline_instr_regs is
  signal zeros32 : std_logic_vector(31 downto 0);

  signal I2_d : std_logic_vector(31 downto 0);

  -- internal copies (because Quartus does not allow reading from OUT ports)
  signal I2_q, I3_q, I4_q, I5_q : std_logic_vector(31 downto 0);
begin
  zeros32 <= (others => '0');

  -- IF/ID instruction register input: flush -> zeros else instruction
  mI2: entity work.mux2
    generic map(N=>32)
    port map(a => I1_in, b => zeros32, s => IFID_flush, y => I2_d);

  rI2: entity work.nbitRegister
    generic map(N=>32)
    port map(i_resetBar=>resetBar, i_enable=>IFID_en, i_clock=>clk, i_d=>I2_d, o_q=>I2_q);

  -- downstream instruction registers (always enabled)
  rI3: entity work.nbitRegister
    generic map(N=>32)
    port map(i_resetBar=>resetBar, i_enable=>'1', i_clock=>clk, i_d=>I2_q, o_q=>I3_q);

  rI4: entity work.nbitRegister
    generic map(N=>32)
    port map(i_resetBar=>resetBar, i_enable=>'1', i_clock=>clk, i_d=>I3_q, o_q=>I4_q);

  rI5: entity work.nbitRegister
    generic map(N=>32)
    port map(i_resetBar=>resetBar, i_enable=>'1', i_clock=>clk, i_d=>I4_q, o_q=>I5_q);

  -- drive outputs
  I2_out <= I2_q;
  I3_out <= I3_q;
  I4_out <= I4_q;
  I5_out <= I5_q;

  I2_tap <= I2_q;
end architecture;