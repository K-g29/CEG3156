library ieee;
use ieee.std_logic_1164.all;

entity if_id_reg is
  port(
    clk       : in  std_logic;
    resetBar  : in  std_logic;

    en        : in  std_logic; -- IFID_Write (stall control)
    flush     : in  std_logic; -- taken branch in EX -> insert NOP (all zeros)

    pc4_in    : in  std_logic_vector(7 downto 0);
    instr_in  : in  std_logic_vector(31 downto 0);

    pc4_out   : out std_logic_vector(7 downto 0);
    instr_out : out std_logic_vector(31 downto 0)
  );
end entity;

architecture structural of if_id_reg is
  signal pc4_d    : std_logic_vector(7 downto 0);
  signal instr_d  : std_logic_vector(31 downto 0);

  signal zeros8   : std_logic_vector(7 downto 0);
  signal zeros32  : std_logic_vector(31 downto 0);
begin
  zeros8  <= (others => '0');
  zeros32 <= (others => '0');

  -- On flush=1, load zeros (NOP). Else load real inputs.
  m_pc4: entity work.mux2
    generic map(N => 8)
    port map(a => pc4_in, b => zeros8, s => flush, y => pc4_d);

  m_instr: entity work.mux2
    generic map(N => 32)
    port map(a => instr_in, b => zeros32, s => flush, y => instr_d);

  -- Registers with enable (stall)
  r_pc4: entity work.nbitRegister
    generic map(N => 8)
    port map(
      i_resetBar => resetBar,
      i_enable   => en,
      i_clock    => clk,
      i_d        => pc4_d,
      o_q        => pc4_out
    );

  r_instr: entity work.nbitRegister
    generic map(N => 32)
    port map(
      i_resetBar => resetBar,
      i_enable   => en,
      i_clock    => clk,
      i_d        => instr_d,
      o_q        => instr_out
    );
end architecture;