library ieee;
use ieee.std_logic_1164.all;

entity ripple_adder is
  generic (N : natural := 8);
  port (
    a    : in  std_logic_vector(N-1 downto 0);
    b    : in  std_logic_vector(N-1 downto 0);
    cin  : in  std_logic;
    sum  : out std_logic_vector(N-1 downto 0);
    cout : out std_logic
  );
end entity;

architecture structural of ripple_adder is
  -- Component for 1-bit full adder
  component full_adder_1bit is
    port (
      a    : in  std_logic;
      b    : in  std_logic;
      cin  : in  std_logic;
      sum  : out std_logic;
      cout : out std_logic
    );
  end component;

  signal c : std_logic_vector(N downto 0);
begin
  c(0) <= cin;

  gen_add: for i in 0 to N-1 generate
    fa: full_adder_1bit
      port map (
        a    => a(i),
        b    => b(i),
        cin  => c(i),
        sum  => sum(i),
        cout => c(i+1)
      );
  end generate;

  cout <= c(N);
end architecture;