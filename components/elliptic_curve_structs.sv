package elliptic_curve_structs;

typedef struct packed {
    logic [255:0] x;
    logic [255:0] y;
} curve_point_t;


typedef struct packed {
    logic [255:0] p;
    logic [255:0] n;
    logic [255:0] a;
    logic [255:0] b;
    curve_point_t base_point;
} secp256k1_parameters;

secp256k1_parameters params = '{p:256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F,
                                n:256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141,
                                a:256'd7,
                                b:0,
								base_point:{256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
										    256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8}};
//initial begin
//    params.n = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
//    params.a = 256'd7;
//    params.b = 256'd0;
//    params.base_point.x = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
//    params.base_point.y = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
//end



typedef struct packed {
    logic m;            // m = 1 for secp256k1
    logic k;            // k = 256 for secp256k1
} barrett_constants_t;

barrett_constants_t barrett_constants = '{m:1, k:256};

typedef struct packed {
    logic [255:0] r;
    logic [255:0] s;
} signature_t;

endpackage : elliptic_curve_structs
