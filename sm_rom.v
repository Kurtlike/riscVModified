module sm_rom
#(
    parameter SIZE = 64
)
(
    input  [31:0] a,
    output [31:0] rd
);
    reg [31:0] rom [SIZE - 1:0];
    assign rd = rom [a];

    initial begin
        $readmemh ("/home/kurtlike/german_4/new_lab4/lab4_g_2/lab4_g_2.srcs/sources_1/new/program.hex", rom);
    end

endmodule