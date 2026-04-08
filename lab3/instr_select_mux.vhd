library ieee;
use ieee.std_logic_1164.all;

entity instr_select_mux is
  port(
    InstrSelect : in  std_logic_vector(2 downto 0);
    I1          : in  std_logic_vector(31 downto 0);
    I2          : in  std_logic_vector(31 downto 0);
    I3          : in  std_logic_vector(31 downto 0);
    I4          : in  std_logic_vector(31 downto 0);
    I5          : in  std_logic_vector(31 downto 0);
    Y           : out std_logic_vector(31 downto 0)
  );
end entity;

architecture structural of instr_select_mux is
  signal s0, s1, s2 : std_logic;
  signal ns0, ns1, ns2 : std_logic;

  signal a0,a1,a2,a3,a4 : std_logic_vector(31 downto 0); -- intermediates
begin
  s0 <= InstrSelect(0);
  s1 <= InstrSelect(1);
  s2 <= InstrSelect(2);

  ns0 <= not s0;
  ns1 <= not s1;
  ns2 <= not s2;

  -- We only care about codes:
  -- 000->I1, 001->I2, 010->I3, 011->I4, 100->I5, others->0
  -- Implement with mux tree using mux2 (structural).

  -- level 1 (select s0): choose between pairs
  m0: entity work.mux2 generic map(N=>32) port map(a=>I1, b=>I2, s=>s0, y=>a0); -- 00/01
  m1: entity work.mux2 generic map(N=>32) port map(a=>I3, b=>I4, s=>s0, y=>a1); -- 10/11

  -- for I5 vs 0 on s0 (since I5 at 100 only)
  a2 <= (others => '0');
  m2: entity work.mux2 generic map(N=>32) port map(a=>I5, b=>a2, s=>s0, y=>a3); -- if s0=0 => I5 else 0

  -- level 2 (select s1)
  m3: entity work.mux2 generic map(N=>32) port map(a=>a0, b=>a1, s=>s1, y=>a4); -- s1=0 selects I1/I2, s1=1 selects I3/I4

  -- level 3 (select s2): if s2=0 -> a4 (I1..I4), if s2=1 -> a3 (I5 or 0)
  m4: entity work.mux2 generic map(N=>32) port map(a=>a4, b=>a3, s=>s2, y=>Y);

end architecture;