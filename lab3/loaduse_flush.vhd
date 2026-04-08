library ieee;
use ieee.std_logic_1164.all;

-- Computes the classic load-use bubble request:
-- Flush = IDEX_MemRead & ((IDEX_Rt == IFID_Rs) | (UsesRt & (IDEX_Rt == IFID_Rt)))
entity loaduse_flush is
  port(
    IDEX_MemRead : in  std_logic;
    IDEX_Rt      : in  std_logic_vector(2 downto 0);
    IFID_Rs      : in  std_logic_vector(2 downto 0);
    IFID_Rt      : in  std_logic_vector(2 downto 0);
    IFID_UsesRt  : in  std_logic;

    Flush        : out std_logic
  );
end entity;

architecture structural of loaduse_flush is
  signal eq_rs, eq_rt : std_logic;
  signal term_rt      : std_logic;
begin
  c1: entity work.eq3 port map(a => IDEX_Rt, b => IFID_Rs, eq => eq_rs);
  c2: entity work.eq3 port map(a => IDEX_Rt, b => IFID_Rt, eq => eq_rt);

  term_rt <= IFID_UsesRt and eq_rt;
  Flush   <= IDEX_MemRead and (eq_rs or term_rt);
end architecture;