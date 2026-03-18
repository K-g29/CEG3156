library ieee;
use ieee.std_logic_1164.all;

entity muxout_select is
  port (
    ValueSelect : in  std_logic_vector(2 downto 0);
    PC          : in  std_logic_vector(7 downto 0);
    ALUResult   : in  std_logic_vector(7 downto 0);
    RD1         : in  std_logic_vector(7 downto 0);
    RD2         : in  std_logic_vector(7 downto 0);
    WD          : in  std_logic_vector(7 downto 0);
    CtrlPack    : in  std_logic_vector(7 downto 0);
    MuxOut      : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of muxout_select is
begin
  with ValueSelect select
    MuxOut <= PC        when "000",
              ALUResult when "001",
              RD1       when "010",
              RD2       when "011",
              WD        when "100",
              CtrlPack  when others;  -- "101", "110", "111"
end architecture;