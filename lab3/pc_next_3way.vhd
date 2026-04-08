library ieee;
use ieee.std_logic_1164.all;

-- Priority: Jump (ID) > Branch taken (EX) > PC+4
entity pc_next_3way is
  port(
    pc_plus4        : in  std_logic_vector(7 downto 0);
    branch_target_ex: in  std_logic_vector(7 downto 0);
    takeBr_ex       : in  std_logic;
    jump8_id        : in  std_logic_vector(7 downto 0);
    jump_id         : in  std_logic;
    pc_next         : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of pc_next_3way is
  signal after_branch : std_logic_vector(7 downto 0);
begin
  -- select PC+4 vs branch target
  m1: entity work.mux2 generic map(N=>8)
    port map(a=>pc_plus4, b=>branch_target_ex, s=>takeBr_ex, y=>after_branch);

  -- select after_branch vs jump target (jump highest priority)
  m2: entity work.mux2 generic map(N=>8)
    port map(a=>after_branch, b=>jump8_id, s=>jump_id, y=>pc_next);
end architecture;