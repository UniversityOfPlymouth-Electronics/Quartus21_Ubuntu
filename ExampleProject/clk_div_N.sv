// Simple Counter

//$clog2
module clk_div_N #(parameter int N=255) (input wire clk, output wire y);

reg [$clog2(N)-1:0] count = '0; //All bits set to 0
reg yy = 1'b0;                  //Single 0

assign y = yy;

always_ff @(posedge clk)
begin
   if (count == N)              //Check for the number of states
      begin
         count <= 0;            //Reset count
         yy <= !yy;             //Toggle output
      end
   else
      count <= count + 1;       //Increment count

end

endmodule
