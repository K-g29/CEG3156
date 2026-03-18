library ieee;
use ieee.std_logic_1164.all;

entity pc_next_select is
  port(
    pc_plus4      : in  std_logic_vector(7 downto 0);
    branch_target : in  std_logic_vector(7 downto 0);
    jump8         : in  std_logic_vector(7 downto 0);

    BranchEQ      : in  std_logic;
    BranchNE      : in  std_logic;
    Zero          : in  std_logic;
    Jump          : in  std_logic;

    TakeBr        : out std_logic;                 -- for observation/output
    pc_next       : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of pc_next_select is
  signal pc_after_branch : std_logic_vector(7 downto 0);
  signal takebr_i        : std_logic;
begin
  -- Option A branch decision
  bt: entity work.branch_take
    port map(
      BranchEQ => BranchEQ,
      BranchNE => BranchNE,
      Zero     => Zero,
      TakeBr   => takebr_i
    );

  -- export the internal decision to the output port
  TakeBr <= takebr_i;

  -- mux 1: choose PC+4 vs branch_target
  m_branch: entity work.mux2
    generic map(N => 8)
    port map(
      a => pc_plus4,
      b => branch_target,
      s => takebr_i,
      y => pc_after_branch
    );

  -- mux 2: choose (after branch) vs jump8
  m_jump: entity work.mux2
    generic map(N => 8)
    port map(
      a => pc_after_branch,
      b => jump8,
      s => Jump,
      y => pc_next
    );
end architecture;