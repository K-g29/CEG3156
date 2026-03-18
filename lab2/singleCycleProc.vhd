library ieee;
use ieee.std_logic_1164.all;

entity singleCycleProc is
  port(
    GClock         : in  std_logic;
    GResetBar      : in  std_logic; -- active-low reset
    ValueSelect    : in  std_logic_vector(2 downto 0);

    MuxOut         : out std_logic_vector(7 downto 0);
    InstructionOut : out std_logic_vector(31 downto 0);
    BranchOut      : out std_logic;
    ZeroOut        : out std_logic;
    MemWriteOut    : out std_logic;
    RegWriteOut    : out std_logic;

    -- ===== DEBUG OUTPUTS (temporary) =====
    DbgPC          : out std_logic_vector(7 downto 0);
    DbgPCNext      : out std_logic_vector(7 downto 0);
    DbgPCPlus4     : out std_logic_vector(7 downto 0);

    DbgRD1         : out std_logic_vector(7 downto 0);
    DbgRD2         : out std_logic_vector(7 downto 0);
    DbgWD          : out std_logic_vector(7 downto 0);
    DbgWriteReg    : out std_logic_vector(2 downto 0);

    DbgALUInB      : out std_logic_vector(7 downto 0);
    DbgALUResult   : out std_logic_vector(7 downto 0);

    DbgMemAddr     : out std_logic_vector(7 downto 0);
    DbgMemReadData : out std_logic_vector(7 downto 0);
	 
	 DbgRS3         : out std_logic_vector(2 downto 0);
    DbgRT3         : out std_logic_vector(2 downto 0);
    DbgRD3         : out std_logic_vector(2 downto 0);

    DbgCtrlPack    : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of singleCycleProc is
  -- ===== PC / Instruction =====
  signal PC, PCNext, PCPlus4 : std_logic_vector(7 downto 0);
  signal Instr               : std_logic_vector(31 downto 0);

  -- ===== Fields =====
  signal opcode : std_logic_vector(5 downto 0);
  signal funct  : std_logic_vector(5 downto 0);
  signal imm16  : std_logic_vector(15 downto 0);

  signal rs3, rt3, rd3 : std_logic_vector(2 downto 0);
     

  -- ===== Control signals =====
  signal RegDst   : std_logic;
  signal Jump     : std_logic;
  signal MemRead  : std_logic;
  signal MemtoReg : std_logic;
  signal ALUOp1   : std_logic;
  signal ALUOp0   : std_logic;
  signal MemWrite : std_logic;
  signal ALUSrc   : std_logic;
  signal RegWrite : std_logic;
  signal BranchEQ : std_logic;
  signal BranchNE : std_logic;

  -- ===== Register file =====
  signal WriteReg : std_logic_vector(2 downto 0);
  signal RD1, RD2 : std_logic_vector(7 downto 0);
  signal WD       : std_logic_vector(7 downto 0);

  -- ===== ALU path =====
  signal ALUCtrl    : std_logic_vector(2 downto 0);
  signal ALUImm8    : std_logic_vector(7 downto 0);
  signal ALUInB     : std_logic_vector(7 downto 0);
  signal ALUResult  : std_logic_vector(7 downto 0);
  signal Zero       : std_logic;

  -- ===== Data memory =====
  signal MemAddr     : std_logic_vector(7 downto 0);
  signal MemReadData : std_logic_vector(7 downto 0);

  -- ===== Branch/jump =====
  signal BranchTarget : std_logic_vector(7 downto 0);
  signal Jump8        : std_logic_vector(7 downto 0);
  signal TakeBr       : std_logic;

  -- ===== MuxOut "Other" packing (Table 2) =====
  signal CtrlPack : std_logic_vector(7 downto 0);

begin
  -- ========= Instruction fields =========
  opcode <= Instr(31 downto 26);
  funct  <= Instr(5 downto 0);
  imm16  <= Instr(15 downto 0);

  -- map 5-bit regs to 3-bit regs (use low 3 bits)
  rs3 <= Instr(23 downto 21); -- rs(25:21) low 3
  rt3 <= Instr(18 downto 16); -- rt(20:16) low 3
  rd3 <= Instr(13 downto 11); -- rd(15:11) low 3

  InstructionOut <= Instr;

  -- ========= PC register =========
  PCREG: entity work.pc8
    port map(
      clk      => GClock,
      resetBar => GResetBar,
      d        => PCNext,
      q        => PC
    );

  -- ========= PC + 4 =========
  PC4: entity work.pc_plus4
    port map(
      pc      => PC,
      pc_plus => PCPlus4
    );

  -- ========= Instruction memory =========
  IMEM: entity work.Instruction_Memory
    port map(
      address => PC,
      clock   => GClock,
      q       => Instr
    );

  -- ========= Main control logic =========
  CTRL: entity work.control_logic_unit
    port map(
      opcode   => opcode,
      RegDst   => RegDst,
      Jump     => Jump,
      BranchEQ => BranchEQ,
      BranchNE => BranchNE,
      MemRead  => MemRead,
      MemtoReg => MemtoReg,
      ALUOp1   => ALUOp1,
      ALUOp0   => ALUOp0,
      MemWrite => MemWrite,
      ALUSrc   => ALUSrc,
      RegWrite => RegWrite
    );

  MemWriteOut <= MemWrite;
  RegWriteOut <= RegWrite;

  -- ========= ALU control =========
  UALUCTRL: entity work.alu_control_unit
    port map(
      ALUOp1    => ALUOp1,
      ALUOp0    => ALUOp0,
      funct     => funct,
      Operation => ALUCtrl
    );

  -- ========= RegDst mux: rt vs rd =========
  WRMUX: entity work.mux2
    generic map(N => 3)
    port map(
      a => rt3,
      b => rd3,
      s => RegDst,
      y => WriteReg
    );

  -- ========= Register file =========
  RF: entity work.regfile8x8
    port map(
      clk      => GClock,
      resetBar => GResetBar,
      ra1      => rs3,
      ra2      => rt3,
      wa       => WriteReg,
      wd       => WD,
      we       => RegWrite,
      rd1      => RD1,
      rd2      => RD2
    );

  -- ========= ALU immediate for lw/sw (signed truncate) =========
  ALUImm8(6 downto 0) <= imm16(6 downto 0);
  ALUImm8(7)          <= imm16(15);

  -- ========= ALUSrc mux (B input) =========
  ALUSBMUX: entity work.mux2
    generic map(N => 8)
    port map(
      a => RD2,
      b => ALUImm8,
      s => ALUSrc,
      y => ALUInB
    );

  -- ========= ALU =========
  ALU0: entity work.alu8
    port map(
      a    => RD1,
      b    => ALUInB,
      ctrl => ALUCtrl,
      y    => ALUResult,
      zero => Zero
    );

  ZeroOut <= Zero;

  -- ========= Branch target calc (signed) =========
  BTC: entity work.branch_target_calc_8bit
    port map(
      pc_plus4      => PCPlus4,
      imm16         => imm16,
      branch_target => BranchTarget
    );

  -- ========= Jump target =========
  JMP: entity work.jump_addr8
    port map(
      instr_index => Instr(25 downto 0),
      jump8       => Jump8
    );

  -- ========= PC next select =========
  PCSEL: entity work.pc_next_select
    port map(
      pc_plus4      => PCPlus4,
      branch_target => BranchTarget,
      jump8         => Jump8,
      BranchEQ      => BranchEQ,
      BranchNE      => BranchNE,
      Zero          => Zero,
      Jump          => Jump,
      TakeBr        => TakeBr,
      pc_next       => PCNext
    );

  BranchOut <= TakeBr;

  -- ========= Data memory =========
  MemAddr <= ALUResult;

  DMEM: entity work.Data_memory
    port map(
      address => MemAddr,
      clock   => not GClock,
      data    => RD2,
      wren    => MemWrite,
      q       => MemReadData
    );

  -- ========= MemtoReg mux =========
  WDMUX: entity work.mux2
    generic map(N => 8)
    port map(
      a => ALUResult,
      b => MemReadData,
      s => MemtoReg,
      y => WD
    );

  -- ========= MuxOut debug (Table 2 complete) =========
  CtrlPack <= '0' & RegDst & Jump & MemRead & MemtoReg & ALUOp1 & ALUOp0 & ALUSrc;

  MuxOut <= PC        when ValueSelect = "000" else
            ALUResult when ValueSelect = "001" else
            RD1       when ValueSelect = "010" else
            RD2       when ValueSelect = "011" else
            WD        when ValueSelect = "100" else
            CtrlPack;

  -- ========= DEBUG OUTPUT ASSIGNMENTS =========
  DbgPC          <= PC;
  DbgPCNext      <= PCNext;
  DbgPCPlus4     <= PCPlus4;

  DbgRD1         <= RD1;
  DbgRD2         <= RD2;
  DbgWD          <= WD;
  DbgWriteReg    <= WriteReg;

  DbgALUInB      <= ALUInB;
  DbgALUResult   <= ALUResult;

  DbgMemAddr     <= MemAddr;
  DbgMemReadData <= MemReadData;

  DbgCtrlPack    <= CtrlPack;
  DbgRS3 <= rs3;
  DbgRT3 <= rt3;
  DbgRD3 <= rd3;

end architecture;