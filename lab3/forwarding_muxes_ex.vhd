library ieee;
use ieee.std_logic_1164.all;

entity forwarding_muxes_ex is
  port(
    -- original operands from ID/EX
    IDEX_A     : in  std_logic_vector(7 downto 0);
    IDEX_B     : in  std_logic_vector(7 downto 0);

    -- forward sources
    EXMEM_Val  : in  std_logic_vector(7 downto 0); -- typically EX/MEM ALUResult
    MEMWB_Val  : in  std_logic_vector(7 downto 0); -- WB writeback data

    -- controls from forwarding unit
    ForwardA   : in  std_logic_vector(1 downto 0);
    ForwardB   : in  std_logic_vector(1 downto 0);

    -- forwarded outputs (to ALU muxes / store-data path)
    A_fwd      : out std_logic_vector(7 downto 0);
    B_fwd      : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of forwarding_muxes_ex is
  signal a01, a_final : std_logic_vector(7 downto 0);
  signal b01, b_final : std_logic_vector(7 downto 0);

  signal selA_is10, selA_is01 : std_logic;
  signal selB_is10, selB_is01 : std_logic;

  signal FA1n, FA0n, FB1n, FB0n : std_logic;
begin
  -- decode ForwardA
  FA1n <= not ForwardA(1);
  FA0n <= not ForwardA(0);

  selA_is10 <= ForwardA(1) and FA0n; -- 10
  selA_is01 <= FA1n and ForwardA(0); -- 01
  -- 00 => neither asserted

  -- decode ForwardB
  FB1n <= not ForwardB(1);
  FB0n <= not ForwardB(0);

  selB_is10 <= ForwardB(1) and FB0n; -- 10
  selB_is01 <= FB1n and ForwardB(0); -- 01

  -- A: first select between IDEX_A and MEMWB_Val if sel=01, else IDEX_A
  -- Use muxes structurally:
  -- If ForwardA=01 pick MEMWB; if ForwardA=10 pick EXMEM; else IDEX.
  -- Implement as two-stage mux:
  -- stage1: choose IDEX vs MEMWB using selA_is01
  mA1: entity work.mux2 generic map(N=>8) port map(a=>IDEX_A, b=>MEMWB_Val, s=>selA_is01, y=>a01);
  -- stage2: choose stage1 vs EXMEM using selA_is10
  mA2: entity work.mux2 generic map(N=>8) port map(a=>a01,   b=>EXMEM_Val, s=>selA_is10, y=>a_final);

  -- B similarly
  mB1: entity work.mux2 generic map(N=>8) port map(a=>IDEX_B, b=>MEMWB_Val, s=>selB_is01, y=>b01);
  mB2: entity work.mux2 generic map(N=>8) port map(a=>b01,   b=>EXMEM_Val, s=>selB_is10, y=>b_final);

  A_fwd <= a_final;
  B_fwd <= b_final;
end architecture;