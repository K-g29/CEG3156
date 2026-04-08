library ieee;
use ieee.std_logic_1164.all;


entity pipelinedProc is
  port(
    GClock    : in  std_logic;
    GResetBar : in  std_logic;

    -- Breakout of former MuxOut selections (Table 2)
    PC_Out        : out std_logic_vector(7 downto 0);
    ALUResult_Out : out std_logic_vector(7 downto 0);
    ReadData1_Out : out std_logic_vector(7 downto 0);
    ReadData2_Out : out std_logic_vector(7 downto 0);
    WriteData_Out : out std_logic_vector(7 downto 0);
    CtrlPack_Out  : out std_logic_vector(7 downto 0);

    -- Breakout of all pipelined instruction words (Table 3)
    InstructionOut1 : out std_logic_vector(31 downto 0);
    InstructionOut2 : out std_logic_vector(31 downto 0);
    InstructionOut3 : out std_logic_vector(31 downto 0);
    InstructionOut4 : out std_logic_vector(31 downto 0);
    InstructionOut5 : out std_logic_vector(31 downto 0);

    -- Lab-style status outputs
    BranchOut    : out std_logic;
    ZeroOut      : out std_logic;
    MemWriteOut  : out std_logic;
    RegWriteOut  : out std_logic;

    -- ===== DEBUG OUTPUTS =====
    Dbg_MEMWB_RegWrite    : out std_logic;
    Dbg_MEMWB_MemtoReg    : out std_logic;
    Dbg_MEMWB_ALUResult   : out std_logic_vector(7 downto 0);
    Dbg_MEMWB_MemReadData : out std_logic_vector(7 downto 0);
    Dbg_WD_WB             : out std_logic_vector(7 downto 0);

    Dbg_EXMEM_RegWrite    : out std_logic;
    Dbg_EXMEM_MemtoReg    : out std_logic;
    Dbg_EXMEM_MemWrite    : out std_logic;

    Dbg_IDEX_Flush        : out std_logic;
    Dbg_IFID_Flush        : out std_logic;
    Dbg_LoadUseFlush      : out std_logic;
    Dbg_PCWrite           : out std_logic;
    Dbg_IFID_Write        : out std_logic;

    -- ===== DEBUG COMPARE FIELDS =====
    Dbg_ID_rs3            : out std_logic_vector(2 downto 0);
    Dbg_ID_rt3            : out std_logic_vector(2 downto 0);
    Dbg_IDEX_Rt           : out std_logic_vector(2 downto 0);
    Dbg_MemRead_EX        : out std_logic;

    -- ===== EXTRA DEBUG FOR FORWARDING / ALU OPERANDS =====
    Dbg_A_fwd          : out std_logic_vector(7 downto 0);
    Dbg_B_fwd          : out std_logic_vector(7 downto 0);
    Dbg_ALUInB_EX      : out std_logic_vector(7 downto 0);
    Dbg_ForwardA       : out std_logic_vector(1 downto 0);
    Dbg_ForwardB       : out std_logic_vector(1 downto 0);
    Dbg_EXMEM_WriteReg : out std_logic_vector(2 downto 0);
    Dbg_MEMWB_WriteReg : out std_logic_vector(2 downto 0)
  );
end entity;

architecture structural of pipelinedProc is
  -- =====================
  -- IF stage
  -- =====================
  signal PC, PCNext, PCPlus4 : std_logic_vector(7 downto 0);
  signal IF_Instr            : std_logic_vector(31 downto 0);

  -- stall/flush controls
  signal PCWrite      : std_logic;
  signal IFID_Write   : std_logic;
  signal IFID_Flush   : std_logic;
  signal IDEX_Flush   : std_logic;
  signal LoadUseFlush : std_logic;

  -- hazard unit bubble request
  signal ControlFlushHaz : std_logic;

  -- =====================
  -- IF/ID stage regs
  -- =====================
  signal IFID_PC4    : std_logic_vector(7 downto 0);
  signal IFID_Instr  : std_logic_vector(31 downto 0);

  -- Instruction words for display pipeline
  signal Instr1, Instr2, Instr3, Instr4, Instr5 : std_logic_vector(31 downto 0);

  -- =====================
  -- ID stage decoded fields
  -- =====================
  signal ID_opcode : std_logic_vector(5 downto 0);
  signal ID_funct  : std_logic_vector(5 downto 0);
  signal ID_imm16  : std_logic_vector(15 downto 0);
  signal ID_rs3, ID_rt3, ID_rd3 : std_logic_vector(2 downto 0);

  -- ID stage control outputs
  signal RegDst_ID, Jump_ID, MemRead_ID, MemtoReg_ID : std_logic;
  signal ALUOp1_ID, ALUOp0_ID, MemWrite_ID, ALUSrc_ID, RegWrite_ID : std_logic;
  signal BranchEQ_ID, BranchNE_ID : std_logic;

  -- ID stage datapath
  signal RD1_ID, RD2_ID : std_logic_vector(7 downto 0);
  signal Imm8_ID        : std_logic_vector(7 downto 0);
  signal Jump8_ID       : std_logic_vector(7 downto 0);

  -- =====================
  -- ID/EX pipeline reg outputs (EX stage inputs)
  -- =====================
  signal IDEX_PC4   : std_logic_vector(7 downto 0);
  signal IDEX_RD1   : std_logic_vector(7 downto 0);
  signal IDEX_RD2   : std_logic_vector(7 downto 0);
  signal IDEX_Imm8  : std_logic_vector(7 downto 0);
  signal IDEX_Rs    : std_logic_vector(2 downto 0);
  signal IDEX_Rt    : std_logic_vector(2 downto 0);
  signal IDEX_Rd    : std_logic_vector(2 downto 0);
  signal IDEX_Funct : std_logic_vector(5 downto 0);

  signal RegDst_EX, Jump_EX, BranchEQ_EX, BranchNE_EX : std_logic;
  signal MemRead_EX, MemtoReg_EX, ALUOp1_EX, ALUOp0_EX : std_logic;
  signal MemWrite_EX, ALUSrc_EX, RegWrite_EX : std_logic;

  -- =====================
  -- EX stage
  -- =====================
  signal ALUCtrl_EX : std_logic_vector(2 downto 0);

  -- forwarding controls
  signal ForwardA, ForwardB : std_logic_vector(1 downto 0);
  signal A_fwd, B_fwd       : std_logic_vector(7 downto 0);

  signal ALUInB_EX    : std_logic_vector(7 downto 0);
  signal ALUResult_EX : std_logic_vector(7 downto 0);
  signal Zero_EX      : std_logic;

  signal BranchTarget_EX : std_logic_vector(7 downto 0);
  signal TakeBr_EX       : std_logic;

  signal WriteReg_EX     : std_logic_vector(2 downto 0);

  -- =====================
  -- EX/MEM pipeline reg outputs (MEM stage inputs)
  -- =====================
  signal EXMEM_ALUResult : std_logic_vector(7 downto 0);
  signal EXMEM_WriteData : std_logic_vector(7 downto 0);
  signal EXMEM_WriteReg  : std_logic_vector(2 downto 0);

  signal EXMEM_MemRead, EXMEM_MemWrite, EXMEM_MemtoReg, EXMEM_RegWrite : std_logic;

  -- =====================
  -- MEM stage
  -- =====================
  signal MemReadData_MEM : std_logic_vector(7 downto 0);

  -- =====================
  -- MEM/WB pipeline reg outputs (WB stage inputs)
  -- =====================
  signal MEMWB_MemReadData : std_logic_vector(7 downto 0);
  signal MEMWB_ALUResult   : std_logic_vector(7 downto 0);
  signal MEMWB_WriteReg    : std_logic_vector(2 downto 0);
  signal MEMWB_MemtoReg    : std_logic;
  signal MEMWB_RegWrite    : std_logic;

  signal WD_WB : std_logic_vector(7 downto 0);

  -- CtrlPack (Table 2 "Other")
  signal CtrlPack8 : std_logic_vector(7 downto 0);

begin
  -- ==========================================================
  -- IF stage
  -- ==========================================================
  PCREG: entity work.pc8_en
    port map(
      clk      => GClock,
      resetBar => GResetBar,
      en       => PCWrite,
      d        => PCNext,
      q        => PC
    );

  PC4: entity work.pc_plus4
    port map(pc => PC, pc_plus => PCPlus4);

  IMEM: entity work.Instruction_Memory
    port map(address => PC, clock => GClock, q => IF_Instr);

  Instr1 <= IF_Instr;

  -- ==========================================================
  -- Instruction display pipeline + IF/ID instruction tap
  -- ==========================================================
  IP: entity work.pipeline_instr_regs
    port map(
      clk        => GClock,
      resetBar   => GResetBar,
      IFID_en    => IFID_Write,
      IFID_flush => IFID_Flush,
      I1_in      => IF_Instr,
      I2_out     => Instr2,
      I3_out     => Instr3,
      I4_out     => Instr4,
      I5_out     => Instr5,
      I2_tap     => IFID_Instr
    );

  -- expose instruction words
  InstructionOut1 <= Instr1;
  InstructionOut2 <= Instr2;
  InstructionOut3 <= Instr3;
  InstructionOut4 <= Instr4;
  InstructionOut5 <= Instr5;

  -- IF/ID PC+4 register (stall with IFID_Write)
  IFID_PC4_REG: entity work.nbitRegister
    generic map(N => 8)
    port map(
      i_resetBar => GResetBar,
      i_enable   => IFID_Write,
      i_clock    => GClock,
      i_d        => PCPlus4,
      o_q        => IFID_PC4
    );

  -- ==========================================================
  -- ID stage: decode fields
  -- ==========================================================
  ID_opcode <= IFID_Instr(31 downto 26);
  ID_funct  <= IFID_Instr(5 downto 0);
  ID_imm16  <= IFID_Instr(15 downto 0);

  ID_rs3 <= IFID_Instr(23 downto 21);
  ID_rt3 <= IFID_Instr(18 downto 16);
  ID_rd3 <= IFID_Instr(13 downto 11);

  CTRL: entity work.control_logic_unit
    port map(
      opcode   => ID_opcode,
      RegDst   => RegDst_ID,
      Jump     => Jump_ID,
      BranchEQ => BranchEQ_ID,
      BranchNE => BranchNE_ID,
      MemRead  => MemRead_ID,
      MemtoReg => MemtoReg_ID,
      ALUOp1   => ALUOp1_ID,
      ALUOp0   => ALUOp0_ID,
      MemWrite => MemWrite_ID,
      ALUSrc   => ALUSrc_ID,
      RegWrite => RegWrite_ID
    );

  JMP: entity work.jump_addr8
    port map(
      instr_index => IFID_Instr(25 downto 0),
      jump8       => Jump8_ID
    );

  -- WB writeback mux
  WDMUX: entity work.mux2
    generic map(N => 8)
    port map(
      a => MEMWB_ALUResult,
      b => MEMWB_MemReadData,
      s => MEMWB_MemtoReg,
      y => WD_WB
    );

  RF: entity work.regfile8x8
    port map(
      clk      => GClock,
      resetBar => GResetBar,
      ra1      => ID_rs3,
      ra2      => ID_rt3,
      wa       => MEMWB_WriteReg,
      wd       => WD_WB,
      we       => MEMWB_RegWrite,
      rd1      => RD1_ID,
      rd2      => RD2_ID
    );

  -- imm8 truncation (signed)
  Imm8_ID(6 downto 0) <= ID_imm16(6 downto 0);
  Imm8_ID(7)          <= ID_imm16(15);

  -- ==========================================================
  -- Hazard detection + load-use flush request
  -- ==========================================================
  HAZ: entity work.hazard_detection_unit
    port map(
      IDEX_MemRead => MemRead_EX,
      IDEX_Rt      => IDEX_Rt,
      IFID_Rs      => ID_rs3,
      IFID_Rt      => ID_rt3,
      IFID_UsesRt  => '1',
      PCWrite      => PCWrite,
      IFID_Write   => IFID_Write,
      ControlFlush => ControlFlushHaz
    );

  LUF: entity work.loaduse_flush
    port map(
      IDEX_MemRead => MemRead_EX,
      IDEX_Rt      => IDEX_Rt,
      IFID_Rs      => ID_rs3,
      IFID_Rt      => ID_rt3,
      IFID_UsesRt  => '1',
      Flush        => LoadUseFlush
    );

  IFID_Flush <= (TakeBr_EX or Jump_ID) and IFID_Write;
  IDEX_Flush <= LoadUseFlush or ControlFlushHaz or TakeBr_EX or Jump_ID;

  -- ==========================================================
  -- ID/EX pipeline reg
  -- ==========================================================
  IDEX: entity work.id_ex_reg
    port map(
      clk      => GClock,
      resetBar => GResetBar,
      en       => '1',
      flush    => IDEX_Flush,

      pc4_in   => IFID_PC4,
      rd1_in   => RD1_ID,
      rd2_in   => RD2_ID,
      imm8_in  => Imm8_ID,
      rs_in    => ID_rs3,
      rt_in    => ID_rt3,
      rd_in    => ID_rd3,
      funct_in => ID_funct,

      RegDst_in   => RegDst_ID,
      Jump_in     => Jump_ID,
      BranchEQ_in => BranchEQ_ID,
      BranchNE_in => BranchNE_ID,
      MemRead_in  => MemRead_ID,
      MemtoReg_in => MemtoReg_ID,
      ALUOp1_in   => ALUOp1_ID,
      ALUOp0_in   => ALUOp0_ID,
      MemWrite_in => MemWrite_ID,
      ALUSrc_in   => ALUSrc_ID,
      RegWrite_in => RegWrite_ID,

      pc4_out   => IDEX_PC4,
      rd1_out   => IDEX_RD1,
      rd2_out   => IDEX_RD2,
      imm8_out  => IDEX_Imm8,
      rs_out    => IDEX_Rs,
      rt_out    => IDEX_Rt,
      rd_out    => IDEX_Rd,
      funct_out => IDEX_Funct,

      RegDst_out   => RegDst_EX,
      Jump_out     => Jump_EX,
      BranchEQ_out => BranchEQ_EX,
      BranchNE_out => BranchNE_EX,
      MemRead_out  => MemRead_EX,
      MemtoReg_out => MemtoReg_EX,
      ALUOp1_out   => ALUOp1_EX,
      ALUOp0_out   => ALUOp0_EX,
      MemWrite_out => MemWrite_EX,
      ALUSrc_out   => ALUSrc_EX,
      RegWrite_out => RegWrite_EX
    );

  -- ==========================================================
  -- EX stage
  -- ==========================================================
  ALUCTRL: entity work.alu_control_unit
    port map(
      ALUOp1    => ALUOp1_EX,
      ALUOp0    => ALUOp0_EX,
      funct     => IDEX_Funct,
      Operation => ALUCtrl_EX
    );

  FWD: entity work.forwarding_unit
    port map(
      IDEX_Rs        => IDEX_Rs,
      IDEX_Rt        => IDEX_Rt,
      EXMEM_Rd       => EXMEM_WriteReg,
      EXMEM_RegWrite => EXMEM_RegWrite,
      MEMWB_Rd       => MEMWB_WriteReg,
      MEMWB_RegWrite => MEMWB_RegWrite,
      ForwardA       => ForwardA,
      ForwardB       => ForwardB
    );

  FWD_MUX: entity work.forwarding_muxes_ex
    port map(
      IDEX_A    => IDEX_RD1,
      IDEX_B    => IDEX_RD2,
      EXMEM_Val => EXMEM_ALUResult,
      MEMWB_Val => WD_WB,
      ForwardA  => ForwardA,
      ForwardB  => ForwardB,
      A_fwd     => A_fwd,
      B_fwd     => B_fwd
    );

  ALUSRC_MUX: entity work.mux2
    generic map(N => 8)
    port map(
      a => B_fwd,
      b => IDEX_Imm8,
      s => ALUSrc_EX,
      y => ALUInB_EX
    );

  ALU0: entity work.alu8
    port map(
      a    => A_fwd,
      b    => ALUInB_EX,
      ctrl => ALUCtrl_EX,
      y    => ALUResult_EX,
      zero => Zero_EX
    );

  WRMUX: entity work.mux2
    generic map(N => 3)
    port map(
      a => IDEX_Rt,
      b => IDEX_Rd,
      s => RegDst_EX,
      y => WriteReg_EX
    );

  BTC8: entity work.branch_target_calc_from_imm8
    port map(
      pc_plus4      => IDEX_PC4,
      imm8          => IDEX_Imm8,
      branch_target => BranchTarget_EX
    );

  BT: entity work.branch_take
    port map(
      BranchEQ => BranchEQ_EX,
      BranchNE => BranchNE_EX,
      Zero     => Zero_EX,
      TakeBr   => TakeBr_EX
    );

  PCSEL3: entity work.pc_next_3way
    port map(
      pc_plus4         => PCPlus4,
      branch_target_ex => BranchTarget_EX,
      takeBr_ex        => TakeBr_EX,
      jump8_id         => Jump8_ID,
      jump_id          => Jump_ID,
      pc_next          => PCNext
    );

  -- ==========================================================
  -- EX/MEM pipeline reg
  -- ==========================================================
  EXMEM: entity work.ex_mem_reg
    port map(
      clk      => GClock,
      resetBar => GResetBar,
      en       => '1',

      aluResult_in => ALUResult_EX,
      writeData_in => B_fwd,
      writeReg_in  => WriteReg_EX,

      takeBr_in       => TakeBr_EX,
      branchTarget_in => BranchTarget_EX,
      zero_in         => Zero_EX,

      MemRead_in  => MemRead_EX,
      MemWrite_in => MemWrite_EX,
      MemtoReg_in => MemtoReg_EX,
      RegWrite_in => RegWrite_EX,

      aluResult_out => EXMEM_ALUResult,
      writeData_out => EXMEM_WriteData,
      writeReg_out  => EXMEM_WriteReg,

      takeBr_out       => open,
      branchTarget_out => open,
      zero_out         => open,

      MemRead_out  => EXMEM_MemRead,
      MemWrite_out => EXMEM_MemWrite,
      MemtoReg_out => EXMEM_MemtoReg,
      RegWrite_out => EXMEM_RegWrite
    );

  -- ==========================================================
  -- MEM stage
  -- ==========================================================
  DMEM: entity work.new_data_memory
    port map(
      clock     => GClock,
      data      => EXMEM_WriteData,
      rdaddress => EXMEM_ALUResult,
      wraddress => EXMEM_ALUResult,
      wren      => EXMEM_MemWrite,
      q         => MemReadData_MEM
    );

  -- ==========================================================
  -- MEM/WB pipeline reg
  -- ==========================================================
  MEMWB: entity work.mem_wb_reg
    port map(
      clk      => GClock,
      resetBar => GResetBar,
      en       => '1',

      memReadData_in => MemReadData_MEM,
      aluResult_in   => EXMEM_ALUResult,
      writeReg_in    => EXMEM_WriteReg,

      MemtoReg_in => EXMEM_MemtoReg,
      RegWrite_in => EXMEM_RegWrite,

      memReadData_out => MEMWB_MemReadData,
      aluResult_out   => MEMWB_ALUResult,
      writeReg_out    => MEMWB_WriteReg,

      MemtoReg_out => MEMWB_MemtoReg,
      RegWrite_out => MEMWB_RegWrite
    );

  -- ==========================================================
  -- CtrlPack (Table 2 "Other")
  -- ==========================================================
  CtrlPack8(7) <= '0';
  CtrlPack8(6) <= RegDst_ID;
  CtrlPack8(5) <= Jump_ID;
  CtrlPack8(4) <= MemRead_ID;
  CtrlPack8(3) <= MemtoReg_ID;
  CtrlPack8(2) <= ALUOp1_ID;
  CtrlPack8(1) <= ALUOp0_ID;
  CtrlPack8(0) <= ALUSrc_ID;

  -- ==========================================================
  -- Breakout outputs (instead of MuxOut)
  -- ==========================================================
  PC_Out        <= PC;
  ALUResult_Out <= ALUResult_EX;
  ReadData1_Out <= RD1_ID;
  ReadData2_Out <= RD2_ID;
  WriteData_Out <= WD_WB;
  CtrlPack_Out  <= CtrlPack8;

  -- ==========================================================
  -- Status outputs
  -- ==========================================================
  BranchOut   <= TakeBr_EX;
  ZeroOut     <= Zero_EX;
  MemWriteOut <= EXMEM_MemWrite;
  RegWriteOut <= MEMWB_RegWrite;

  -- ==========================================================
  -- DEBUG outputs (existing set)
  -- ==========================================================
  Dbg_MEMWB_RegWrite    <= MEMWB_RegWrite;
  Dbg_MEMWB_MemtoReg    <= MEMWB_MemtoReg;
  Dbg_MEMWB_ALUResult   <= MEMWB_ALUResult;
  Dbg_MEMWB_MemReadData <= MEMWB_MemReadData;
  Dbg_WD_WB             <= WD_WB;

  Dbg_EXMEM_RegWrite <= EXMEM_RegWrite;
  Dbg_EXMEM_MemtoReg <= EXMEM_MemtoReg;
  Dbg_EXMEM_MemWrite <= EXMEM_MemWrite;

  Dbg_IDEX_Flush   <= IDEX_Flush;
  Dbg_IFID_Flush   <= IFID_Flush;
  Dbg_LoadUseFlush <= LoadUseFlush;
  Dbg_PCWrite      <= PCWrite;
  Dbg_IFID_Write   <= IFID_Write;

  Dbg_ID_rs3     <= ID_rs3;
  Dbg_ID_rt3     <= ID_rt3;
  Dbg_IDEX_Rt    <= IDEX_Rt;
  Dbg_MemRead_EX <= MemRead_EX;

  -- ==========================================================
  -- EXTRA DEBUG FOR FORWARDING / ALU OPERANDS
  -- ==========================================================
  Dbg_A_fwd     <= A_fwd;
  Dbg_B_fwd     <= B_fwd;
  Dbg_ALUInB_EX <= ALUInB_EX;

  Dbg_ForwardA  <= ForwardA;
  Dbg_ForwardB  <= ForwardB;

  Dbg_EXMEM_WriteReg <= EXMEM_WriteReg;
  Dbg_MEMWB_WriteReg <= MEMWB_WriteReg;

end architecture;