library verilog;
use verilog.vl_types.all;
entity pipelinedProc_vlg_sample_tst is
    port(
        GClock          : in     vl_logic;
        GResetBar       : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end pipelinedProc_vlg_sample_tst;
