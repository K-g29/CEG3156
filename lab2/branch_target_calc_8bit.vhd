library ieee;
use ieee.std_logic_1164.all;

entity branch_target_calc_8bit is
  port(
    pc_plus4     : in  std_logic_vector(7 downto 0);
    imm16        : in  std_logic_vector(15 downto 0);
    branch_target: out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of branch_target_calc_8bit is
  signal imm8      : std_logic_vector(7 downto 0);
  signal imm8_sl2  : std_logic_vector(7 downto 0);
  signal cout      : std_logic;
begin
  sx: entity work.signext16_to_8_signed
    port map(imm16 => imm16, imm8 => imm8);

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