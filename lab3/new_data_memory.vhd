library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity new_data_memory is
  port(
    clock     : in  std_logic;
    data      : in  std_logic_vector(7 downto 0);
    rdaddress : in  std_logic_vector(7 downto 0);
    wraddress : in  std_logic_vector(7 downto 0);
    wren      : in  std_logic;
    q         : out std_logic_vector(7 downto 0)
  );
end new_data_memory;

architecture rtl of new_data_memory is
  type ram_array is array (0 to 255) of std_logic_vector(7 downto 0);

  signal RAM : ram_array := (
    0      => x"55",
    1      => x"AA",
    others => x"00"
  );
begin
  -- synchronous write
  process(clock)
  begin
    if rising_edge(clock) then
      if wren = '1' then
        RAM(to_integer(unsigned(wraddress))) <= data;
      end if;
    end if;
  end process;

  -- asynchronous read
  q <= RAM(to_integer(unsigned(rdaddress)));

end rtl;