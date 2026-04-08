library ieee;
use ieee.std_logic_1164.all;

entity alu8 is
  port(
    a      : in  std_logic_vector(7 downto 0);
    b      : in  std_logic_vector(7 downto 0);
    ctrl   : in  std_logic_vector(2 downto 0);
    y      : out std_logic_vector(7 downto 0);
    zero   : out std_logic
  );
end entity;

architecture structural of alu8 is
  signal andy, ory : std_logic_vector(7 downto 0);
  signal addy, suby: std_logic_vector(7 downto 0);
  signal slty      : std_logic_vector(7 downto 0);
  signal cout_add, cout_sub : std_logic;

  signal sel_sub : std_logic;
  signal y_pre   : std_logic_vector(7 downto 0);

  -- mux intermediates
  signal m_and_or  : std_logic_vector(7 downto 0);
  signal m_add_sub : std_logic_vector(7 downto 0);
  signal m_logic_arith : std_logic_vector(7 downto 0);
begin
  lg: entity work.logic8 port map(a=>a, b=>b, andy=>andy, ory=>ory);

  addU: entity work.addsub8 port map(a=>a, b=>b, sub=>'0', y=>addy, cout=>cout_add);
  subU: entity work.addsub8 port map(a=>a, b=>b, sub=>'1', y=>suby, cout=>cout_sub);

  sltU: entity work.slt8_simple port map(diff=>suby, y=>slty);

  -- Select between AND/OR based on ctrl(0) when ctrl=000/001
  mux_and_or: entity work.mux2 generic map(N=>8)
    port map(a=>andy, b=>ory, s=>ctrl(0), y=>m_and_or);

  -- Select between ADD/SUB based on ctrl(2) when ctrl=010/110
  -- (ADD=010, SUB=110 differ in ctrl(2))
  mux_add_sub: entity work.mux2 generic map(N=>8)
    port map(a=>addy, b=>suby, s=>ctrl(2), y=>m_add_sub);

  -- Now choose logic vs arith based on ctrl(1)
  -- logic ops have ctrl(1)=0; add/sub have ctrl(1)=1
  mux_logic_arith: entity work.mux2 generic map(N=>8)
    port map(a=>m_and_or, b=>m_add_sub, s=>ctrl(1), y=>m_logic_arith);

  -- Finally, if ctrl=111 (slt), override selection:
  -- detect SLT: ctrl2&ctrl1&ctrl0
  -- structural detect:
  y_pre <= slty when (ctrl(2)='1' and ctrl(1)='1' and ctrl(0)='1') else m_logic_arith;

  y <= y_pre;

  -- Zero flag
  zero <= '1' when y_pre = x"00" else '0';
end architecture;