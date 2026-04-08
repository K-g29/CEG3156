library ieee;
use ieee.std_logic_1164.all;

entity forwarding_unit is
  port(
    -- sources in EX stage (from ID/EX)
    IDEX_Rs        : in  std_logic_vector(2 downto 0);
    IDEX_Rt        : in  std_logic_vector(2 downto 0);

    -- destination in MEM stage (from EX/MEM)
    EXMEM_Rd       : in  std_logic_vector(2 downto 0);
    EXMEM_RegWrite : in  std_logic;

    -- destination in WB stage (from MEM/WB)
    MEMWB_Rd       : in  std_logic_vector(2 downto 0);
    MEMWB_RegWrite : in  std_logic;

    -- forwarding controls to ALU input muxes
    ForwardA       : out std_logic_vector(1 downto 0);
    ForwardB       : out std_logic_vector(1 downto 0)
  );
end entity;

architecture structural of forwarding_unit is
  -- equality flags
  signal ex_eq_rs, ex_eq_rt : std_logic;
  signal wb_eq_rs, wb_eq_rt : std_logic;

  -- nonzero destination flags (ignore $0)
  signal ex_rd_nz, wb_rd_nz : std_logic;

  -- match terms
  signal EX_A, EX_B : std_logic;
  signal WB_A, WB_B : std_logic;

  -- internal XNOR bits for explicit equality (EXMEM vs Rs/Rt)
  signal ex_rs_x2, ex_rs_x1, ex_rs_x0 : std_logic;
  signal ex_rt_x2, ex_rt_x1, ex_rt_x0 : std_logic;

  -- internal XNOR bits for explicit equality (MEMWB vs Rs/Rt)
  signal wb_rs_x2, wb_rs_x1, wb_rs_x0 : std_logic;
  signal wb_rt_x2, wb_rt_x1, wb_rt_x0 : std_logic;

begin
  -- rd != 000 detection (OR-reduction)
  ex_rd_nz <= EXMEM_Rd(2) or EXMEM_Rd(1) or EXMEM_Rd(0);
  wb_rd_nz <= MEMWB_Rd(2) or MEMWB_Rd(1) or MEMWB_Rd(0);

  --------------------------------------------------------------------
  -- Explicit 3-bit equality: ex_eq_rs = (EXMEM_Rd == IDEX_Rs)
  --------------------------------------------------------------------
  ex_rs_x2 <= EXMEM_Rd(2) xnor IDEX_Rs(2);
  ex_rs_x1 <= EXMEM_Rd(1) xnor IDEX_Rs(1);
  ex_rs_x0 <= EXMEM_Rd(0) xnor IDEX_Rs(0);
  ex_eq_rs <= ex_rs_x2 and ex_rs_x1 and ex_rs_x0;

  -- Explicit 3-bit equality: ex_eq_rt = (EXMEM_Rd == IDEX_Rt)
  ex_rt_x2 <= EXMEM_Rd(2) xnor IDEX_Rt(2);
  ex_rt_x1 <= EXMEM_Rd(1) xnor IDEX_Rt(1);
  ex_rt_x0 <= EXMEM_Rd(0) xnor IDEX_Rt(0);
  ex_eq_rt <= ex_rt_x2 and ex_rt_x1 and ex_rt_x0;

  -- Explicit 3-bit equality: wb_eq_rs = (MEMWB_Rd == IDEX_Rs)
  wb_rs_x2 <= MEMWB_Rd(2) xnor IDEX_Rs(2);
  wb_rs_x1 <= MEMWB_Rd(1) xnor IDEX_Rs(1);
  wb_rs_x0 <= MEMWB_Rd(0) xnor IDEX_Rs(0);
  wb_eq_rs <= wb_rs_x2 and wb_rs_x1 and wb_rs_x0;

  -- Explicit 3-bit equality: wb_eq_rt = (MEMWB_Rd == IDEX_Rt)
  wb_rt_x2 <= MEMWB_Rd(2) xnor IDEX_Rt(2);
  wb_rt_x1 <= MEMWB_Rd(1) xnor IDEX_Rt(1);
  wb_rt_x0 <= MEMWB_Rd(0) xnor IDEX_Rt(0);
  wb_eq_rt <= wb_rt_x2 and wb_rt_x1 and wb_rt_x0;

  --------------------------------------------------------------------
  -- Forwarding decisions (priority: EX/MEM over MEM/WB)
  --------------------------------------------------------------------
  EX_A <= EXMEM_RegWrite and ex_rd_nz and ex_eq_rs;
  EX_B <= EXMEM_RegWrite and ex_rd_nz and ex_eq_rt;

  WB_A <= MEMWB_RegWrite and wb_rd_nz and wb_eq_rs;
  WB_B <= MEMWB_RegWrite and wb_rd_nz and wb_eq_rt;

  -- Encoding: 00 none, 10 EX/MEM, 01 MEM/WB
  ForwardA(1) <= EX_A;
  ForwardA(0) <= WB_A and (not EX_A);

  ForwardB(1) <= EX_B;
  ForwardB(0) <= WB_B and (not EX_B);

end architecture;