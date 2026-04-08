library ieee;
use ieee.std_logic_1164.all;

-- BranchTarget = pc_plus4 + (imm8 << 2), where imm8 is already sign-truncated
entity branch_target_calc_from_imm8 is
  port(
    pc_plus4      : in  std_logic_vector(7 downto 0);
    imm8          : in  std_logic_vector(7 downto 0);
    branch_target : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of branch_target_calc_from_imm8 is
  signal imm8_sl2 : std_logic_vector(7 downto 0);
  signal cout     : std_logic;
begin
  sh: entity work.shift_left2_8
    port map(x => imm8, y => imm8_sl2);

  add: entity work.ripple_adder
    generic map(N => 8)
    port map(
      a    => pc_plus4,
      b    => imm8_sl2,
      cin  => '0',
      sum  => branch_target,
      cout => cout
    );
end architecture;