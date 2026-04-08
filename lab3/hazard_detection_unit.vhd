library ieee;
use ieee.std_logic_1164.all;

entity hazard_detection_unit is
  port(
    -- from ID/EX (instruction currently in EX)
    IDEX_MemRead : in  std_logic;                  -- 1 when EX is lw
    IDEX_Rt      : in  std_logic_vector(2 downto 0); -- lw destination (rt)

    -- from IF/ID (instruction currently in ID)
    IFID_Rs      : in  std_logic_vector(2 downto 0);
    IFID_Rt      : in  std_logic_vector(2 downto 0);

    -- optional: whether ID-stage instruction actually uses Rt as a source
    -- If unknown, tie to '1' (conservative stall behavior).
    IFID_UsesRt  : in  std_logic := '1';

    -- outputs
    PCWrite      : out std_logic;
    IFID_Write   : out std_logic;
    ControlFlush : out std_logic
  );
end entity;

architecture structural of hazard_detection_unit is
  -- equality flags
  signal eq_rs, eq_rt : std_logic;

  -- XNOR bits for explicit equality
  signal rs_x2, rs_x1, rs_x0 : std_logic;
  signal rt_x2, rt_x1, rt_x0 : std_logic;

  signal stall_i : std_logic;
begin
  --------------------------------------------------------------------
  -- Explicit 3-bit equality:
  -- eq_rs = (IDEX_Rt == IFID_Rs)
  -- eq_rt = (IDEX_Rt == IFID_Rt)
  --------------------------------------------------------------------
  rs_x2 <= IDEX_Rt(2) xnor IFID_Rs(2);
  rs_x1 <= IDEX_Rt(1) xnor IFID_Rs(1);
  rs_x0 <= IDEX_Rt(0) xnor IFID_Rs(0);
  eq_rs <= rs_x2 and rs_x1 and rs_x0;

  rt_x2 <= IDEX_Rt(2) xnor IFID_Rt(2);
  rt_x1 <= IDEX_Rt(1) xnor IFID_Rt(1);
  rt_x0 <= IDEX_Rt(0) xnor IFID_Rt(0);
  eq_rt <= rt_x2 and rt_x1 and rt_x0;

  -- Stall = MemReadEX & (RtEX==RsID | (UsesRt & RtEX==RtID))
  stall_i <= IDEX_MemRead and (eq_rs or (IFID_UsesRt and eq_rt));

  PCWrite      <= not stall_i;
  IFID_Write   <= not stall_i;
  ControlFlush <= stall_i;

end architecture;