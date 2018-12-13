import elliptic_curve_structs::*;

module barrett_reduction #(parameter size=256) (
        input logic                 clk,
        input logic     [size-1:0]  in,
        output logic    [255:0]     out
);
/* with barrett's reduction, only values 0 <= x < n^2 */
logic [255:0] q, temp;

assign q = (in*barrett_constants.m) >> barrett_constants.k;

always_comb begin
    temp = in - q*params.n;
    if(params.n <= temp)
        out = temp - params.n;
    else
        out = temp + 0;
end

endmodule : barrett_reduction
