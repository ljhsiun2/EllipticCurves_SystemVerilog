package elliptic_curve_structs;

typedef struct packed {
    logic [255:0] x;
    logic [255:0] y;
} curve_point_t;


typedef struct packed {
    logic [255:0] P;
    logic [255:0] n;
    logic [255:0] a;
    logic [255:0] b;
    curve_point_t base_point;
} secp256k1_parameters;

secp256k1_parameters params = '{P:256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141,
										  n:256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141,
                                a:256'd7,
                                b:0, 
										  base_point:{256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
														  256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8}};
										  
//params.base_point = curve_point_t'(256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
//										256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8);

typedef struct packed {
    logic [255:0] r;
    logic [255:0] s;
} signature_t;

endpackage : elliptic_curve_structs
