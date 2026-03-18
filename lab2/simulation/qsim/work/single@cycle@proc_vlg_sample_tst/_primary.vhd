library verilog;
use verilog.vl_types.all;
entity singleCycleProc_vlg_sample_tst is
    port(
        GClock          : in     vl_logic;
        GResetBar       : in     vl_logic;
        ValueSelect     : in     vl_logic_vector(2 downto 0);
        sampler_tx      : out    vl_logic
    );
end singleCycleProc_vlg_sample_tst;
