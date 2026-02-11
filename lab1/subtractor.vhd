library ieee;
use ieee.std_logic_1164.all;

--subtractor: a - b = a + (~b) + 1
entity subtractor is
  generic (N : natural := 8);
  port (
    a      : in  std_logic_vector(N-1 downto 0);
    b      : in  std_logic_vector(N-1 downto 0);
    diff   : out std_logic_vector(N-1 downto 0);
    borrow : out std_logic
  );
end entity;

architecture structural of subtractor is
  
  component ripple_adder is
    generic (N : natural := 8);
    port (
      a    : in  std_logic_vector(N-1 downto 0);
      b    : in  std_logic_vector(N-1 downto 0);
      cin  : in  std_logic;
      sum  : out std_logic_vector(N-1 downto 0);
      cout : out std_logic
    );
  end component;

  signal b_not : std_logic_vector(N-1 downto 0);
  signal cout  : std_logic;
begin
  b_not <= not b;

  add_tc: ripple_adder
    generic map (N => N)
    port map (
      a    => a,
      b    => b_not,
      cin  => '1',
      sum  => diff,
      cout => cout
    );

  borrow <= not cout;
end architecture;