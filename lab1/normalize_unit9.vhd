library ieee;
use ieee.std_logic_1164.all;

entity normalize_unit9 is
  port (
    mant_in   : in  std_logic_vector(8 downto 0);
    mant_out  : out std_logic_vector(8 downto 0);
    shamt_out : out std_logic_vector(3 downto 0);
    is_zero   : out std_logic
  );
end entity;

architecture structural of normalize_unit9 is
  -- Components used
  component leading_one_detector9 is
    port (
      din     : in  std_logic_vector(8 downto 0);
      shamt   : out std_logic_vector(3 downto 0);
      zero    : out std_logic
    );
  end component;

  component barrel_shifter_left9 is
    port (
      din     : in  std_logic_vector(8 downto 0);
      shamt   : in  std_logic_vector(3 downto 0);
      dout    : out std_logic_vector(8 downto 0)
    );
  end component;

  signal shamt  : std_logic_vector(3 downto 0);
  signal zero   : std_logic;
begin
  lod: leading_one_detector9
    port map (
      din   => mant_in,
      shamt => shamt,
      zero  => zero
    );

  shl: barrel_shifter_left9
    port map (
      din   => mant_in,
      shamt => shamt,
      dout  => mant_out
    );

  shamt_out <= shamt;
  is_zero   <= zero;
end architecture;