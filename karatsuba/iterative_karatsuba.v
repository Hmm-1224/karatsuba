/* 32-bit Sequential Karatsuba Multiplier using a single 16-bit Module */

module iterative_karatsuba_32_16(clk, rst, enable, A, B, C);
    input clk;
    input rst;
    input [31:0] A;
    input [31:0] B;
    output [63:0] C;
    input enable;
    
    wire [1:0] sel_x;
    wire [1:0] sel_y;
    wire [1:0] sel_z;
    wire [1:0] sel_T;
    wire done;
    wire en_z;
    wire en_T;
    
    wire [32:0] h1;
    wire [32:0] h2;
    wire [63:0] g1;
    wire [63:0] g2;
    
    assign C = g2;
    reg_with_enable #(.N(64)) Z(.clk(clk), .rst(rst), .en(en_z), .X(g1), .O(g2));
    reg_with_enable #(.N(33)) T(.clk(clk), .rst(rst), .en(en_T), .X(h1), .O(h2));
    
    iterative_karatsuba_datapath dp(
        .clk(clk), .rst(rst), .X(A), .Y(B), .Z(g2), .T(h2),
        .sel_x(sel_x), .sel_y(sel_y), .sel_z(sel_z), .sel_T(sel_T),
        .en_z(en_z), .en_T(en_T), .done(done), .W1(g1), .W2(h1)
    );
    
    iterative_karatsuba_control control(
        .clk(clk), .rst(rst), .enable(enable), 
        .sel_x(sel_x), .sel_y(sel_y), .sel_z(sel_z), .sel_T(sel_T), 
        .en_z(en_z), .en_T(en_T), .done(done)
    );
endmodule

module iterative_karatsuba_datapath(clk, rst, X, Y, T, Z, sel_x, sel_y, en_z, sel_z, en_T, sel_T, done, W1, W2);
    input clk;
    input rst;
    input [31:0] X;
    input [31:0] Y;
    input [32:0] T;    
    input [63:0] Z;
    output reg [63:0] W1;
    output reg [32:0] W2; 
    
    input [1:0] sel_x; 
    input [1:0] sel_y; 
    
    input en_z;         
    input [1:0] sel_z;
    input en_T;        
    input [1:0] sel_T;
    
    input done;         // Final done signal
    
    wire [15:0] Xh = X[31:16];
    wire [15:0] Xl = X[15:0];    
    wire [15:0] Yh = Y[31:16];   
    wire [15:0] Yl = Y[15:0];

    wire [31:0] P1, P2, P3;  

    mult_16 mult1(.X(Xl), .Y(Yl), .Z(P1));
    mult_16 mult2(.X(Xh), .Y(Yh), .Z(P2));
    mult_17 mult3(.X(Xh+Xl), .Y(Yh+Yl), .Z(P3));

    always @(*) begin
        case (sel_x)
            2'b00: W1 = {32'b0, P1};
            2'b01: W1 = {32'b0, P2};
            2'b10: W1 = {32'b0, P3};
            default: W1 = Z;          
        endcase

        case (sel_y)
            2'b00: W2 = T;
            2'b01: W2 = {32'b0, P1} + {32'b0, P2} - {32'b0, P3}; 
            default: W2 = 33'b0;      
        endcase
    end
endmodule

module iterative_karatsuba_control(clk, rst, enable, sel_x, sel_y, sel_z, sel_T, en_z, en_T, done);
    input clk;
    input rst;
    input enable;
    
    output reg [1:0] sel_x;
    output reg [1:0] sel_y;
    
    output reg [1:0] sel_z;
    output reg [1:0] sel_T;    
    
    output reg en_z;
    output reg en_T;
    
    output reg done;
    
    reg [5:0] state, nxt_state;
    parameter S0 = 6'b000001;   // initial state
    parameter S1 = 6'b000010;   
    parameter S2 = 6'b000100;  
    parameter S3 = 6'b001000;
    parameter S4 = 6'b010000;   
    parameter DONE = 6'b100000; 

    always @(posedge clk) begin
        if (rst) begin
            state <= S0;
        end
        else if (enable) begin
            state <= nxt_state;
        end
    end
    
    always @(*) begin
        case (state)
            S0: begin
                sel_x = 2'b00; sel_y = 2'b00; sel_z = 2'b00; sel_T = 2'b00;
                en_z = 1'b0; en_T = 1'b0;
                done = 1'b0;
                nxt_state = S1;
            end
            S1: begin
                sel_x = 2'b00; sel_y = 2'b00; sel_z = 2'b01; sel_T = 2'b01;
                en_z = 1'b1; en_T = 1'b1;
                done = 1'b0;
                nxt_state = S2;  
            end
            S2: begin
                sel_x = 2'b01; sel_y = 2'b01; sel_z = 2'b10; sel_T = 2'b10;
                en_z = 1'b1; en_T = 1'b1;
                done = 1'b0;
                nxt_state = S3;  
            end
            S3: begin
                sel_x = 2'b10; sel_y = 2'b10; sel_z = 2'b00; sel_T = 2'b00;
                en_z = 1'b1; en_T = 1'b1;
                done = 1'b0;
                nxt_state = S4;  
                end
            S4: begin
                sel_x = 2'b00; sel_y = 2'b00; sel_z = 2'b11; sel_T = 2'b11;
                en_z = 1'b1; en_T = 1'b1;
                done = 1'b1;
                nxt_state = DONE;  
            end
            DONE: begin
                sel_x = 2'b00; sel_y = 2'b00; sel_z = 2'b00; sel_T = 2'b00;
                en_z = 1'b0; en_T = 1'b0;
                done = 1'b1;
                nxt_state = S0;  
            end
            default: begin
                sel_x = 2'b00; sel_y = 2'b00; sel_z = 2'b00; sel_T = 2'b00;
                en_z = 1'b0; en_T = 1'b0;
                done = 1'b0;
                nxt_state = S0; 
            end
        endcase
    end
endmodule

module reg_with_enable #(parameter N = 32) (clk, rst, en, X, O );
    input [N:0] X;
    input clk;
    input rst;
    input en;
    output [N:0] O;
    
    reg [N:0] R;
    
    always@(posedge clk) begin
        if (rst) begin
            R <= {N{1'b0}};
        end
        if (en) begin
            R <= X;
        end
    end
    assign O = R;
endmodule

module mult_16(X, Y, Z);
    input [15:0] X;
    input [15:0] Y;
    output [31:0] Z;
    assign Z = X * Y;
endmodule

module mult_17(X, Y, Z);
    input [16:0] X;
    input [16:0] Y;
    output [33:0] Z;
    assign Z = X * Y;
endmodule

module full_adder(a, b, cin, S, cout);
    input a;
    input b;
    input cin;
    output S;
    output cout;
    assign S = a ^ b ^ cin;
    assign cout = (a&b) ^ (b&cin) ^ (a&cin);
endmodule

module check_subtract (A, B, C);
    input [7:0] A;
    input [7:0] B;
    output [8:0] C;
    assign C = A - B; 
endmodule

module adder_Nbit #(parameter N = 32) (a, b, cin, S, cout);
    input [N-1:0] a;
    input [N-1:0] b;
    input cin;
    output [N-1:0] S;
    output cout;

    wire [N:0] cr;  
    assign cr[0] = cin;

    generate
        genvar i;
        for (i = 0; i < N; i = i + 1) begin
            full_adder addi (.a(a[i]), .b(b[i]), .cin(cr[i]), .S(S[i]), .cout(cr[i+1]));
        end
    endgenerate    

    assign cout = cr[N];
endmodule

module Not_Nbit #(parameter N = 32) (a, c);
    input [N-1:0] a;
    output [N-1:0] c;
    generate
        genvar i;
        for (i = 0; i < N; i = i+1) begin
            assign c[i] = ~a[i];
        end
    endgenerate 
endmodule

module Complement2_Nbit #(parameter N = 32) (a, c, cout_comp);
    input [N-1:0] a;
    output [N-1:0] c;
    output cout_comp;

    wire [N-1:0] b;
    wire ccomp;

    Not_Nbit #(.N(N)) compl(.a(a),.c(b));
    adder_Nbit #(.N(N)) addc(.a(b), .b({ {N-1{1'b0}} ,1'b1 }), .cin(1'b0), .S(c), .cout(ccomp));

    assign cout_comp = ccomp;
endmodule

module subtract_Nbit #(parameter N = 32) (a, b, cin, S, ov, cout_sub);
    input [N-1:0] a;
    input [N-1:0] b;
    input cin;
    output [N-1:0] S;
    output ov;
    output cout_sub;

    wire [N-1:0] minusb;
    wire cout;
    wire ccomp;

    Complement2_Nbit #(.N(N)) compl(.a(b),.c(minusb), .cout_comp(ccomp));
    adder_Nbit #(.N(N)) addc(.a(a), .b(minusb), .cin(1'b0), .S(S), .cout(cout));

    assign ov = (~(a[N-1] ^ minusb[N-1])) & (a[N-1] ^ S[N-1]);
    assign cout_sub = cout | ccomp;
endmodule

module Left_barrel_Nbit #(parameter N = 32)(a, n, c);
    input [N-1:0] a;
    input [$clog2(N)-1:0] n;
    output [N-1:0] c;

    assign c = a << n;
endmodule
