interface axi_if(input bit clk);

	logic [31:0] awaddr,wdata,araddr,rdata;

	logic [3:0] awid,awlen,wid,wstrb,bid,arid,arlen,rid;

	logic [2:0] awsize,arsize;

	logic [1:0] awburst,bresp,arburst,rresp;

	logic awvalid,awready,wlast,wvalid,wready,bvalid,bready,arvalid,arready,rlast,rvalid,rready; 

	clocking m_drv_cb@(posedge clk);

		output awid,awaddr,awlen,awsize,awburst,awvalid,wid,wdata,wstrb,wlast,wvalid,bready,arid,araddr,arlen,arsize,arburst,arvalid,rready;

		input awready,wready,bid,bresp,bvalid,arready,rid,rdata,rresp,rlast,rvalid;

    	endclocking

    	clocking m_mon_cb@(posedge clk);

		input awid,awaddr,awlen,awsize,awburst,awvalid,wid,wdata,wstrb,wlast,wvalid,bready,arid,araddr,arlen,arsize,arburst,arvalid,rready;

		input awready,wready,bid,bresp,bvalid,arready,rid,rdata,rresp,rlast,rvalid;


    	endclocking

    	clocking s_drv_cb@(posedge clk);

		input awid,awaddr,awlen,awsize,awburst,awvalid,wid,wdata,wstrb,wlast,wvalid,bready,arid,araddr,arlen,arsize,arburst,arvalid,rready;

		output awready,wready,bid,bresp,bvalid,arready,rid,rdata,rresp,rlast,rvalid;


    	endclocking

    	clocking s_mon_cb@(posedge clk);

		input awid,awaddr,awlen,awsize,awburst,awvalid,wid,wdata,wstrb,wlast,wvalid,bready,arid,araddr,arlen,arsize,arburst,arvalid,rready;

		input awready,wready,bid,bresp,bvalid,arready,rid,rdata,rresp,rlast,rvalid;


    	endclocking

    	modport M_DRV_MP(clocking m_drv_cb);

    	modport M_MON_MP(clocking m_mon_cb);

    	modport S_DRV_MP(clocking s_drv_cb);

    	modport S_MON_MP(clocking s_mon_cb);


	property AWVALID;
      		@(posedge clk) $rose(awvalid) |-> $stable(awid) && $stable (awlen) && $stable (awburst) && $stable (awsize) && (awaddr) until awready[->1];
      	endproperty
      
     	property VALID;
     		@(posedge clk) $rose(wvalid) |-> $stable(wid) && $stable(wdata) && $stable (wstrb) && $stable(wlast) until wready[->1];
     	endproperty
  
 
   	property ARVALID;
   		@(posedge clk) $rose(arvalid) |-> $stable(arid) && $stable (arlen) && $stable (arburst) && $stable (arsize) && (araddr) until arready[->1];
   	endproperty


   	assert property (AWVALID);
   	assert property (VALID);
   	assert property (ARVALID);

 	property BVALID;
    		@(posedge clk) $rose(bvalid) |-> $stable(bid) && $stable (bresp) until bready[->1];
    	endproperty
 
      
   	property RVALID;
   		@(posedge clk) $rose(rvalid) |-> $stable(rid) && $stable (rdata) && $stable (rlast)  && (rresp) until rready[->1];
   	endproperty

   	assert property (BVALID);
   	assert property (RVALID);



   	property AWVALID_AWREADY;
   		@(posedge clk) awvalid && !awready |=> awvalid;
   	endproperty 
   
   	property WVALID_WREADY;
   		@(posedge clk) wvalid && !wready |=> wvalid;
   	endproperty 
   
   	property ARVALID_ARREADY;
   		@(posedge clk) arvalid && !arready |=> arvalid;
   	endproperty 


   	assert property (AWVALID_AWREADY);
   	assert property (WVALID_WREADY);
   	assert property (ARVALID_ARREADY);

   	property BVALID_BREADY;
   		@(posedge clk) !bvalid && bready |=> bready;
   	endproperty 


   	property RVALID_RREADY;
   		@(posedge clk) rvalid && !rready |=> rvalid;
   	endproperty 

   	assert property (BVALID_BREADY);
   	assert property (RVALID_RREADY);
	
	//wrapping type unaligned address not happen
	property R_wrap_type;
		@(posedge clk) (arburst==2)|->(arsize==1) |-> araddr%2==0;
	endproperty

	property R_wrap_type1;
 		@(posedge clk)  (arburst==2)|->(arsize==2) |-> araddr%4==0;
	endproperty

	property W_wrap_type;
		@(posedge clk)  (awburst==2)|->(awsize==1) |-> awaddr%2==0;
	endproperty 

	property W_wrap_type1;
 		@(posedge clk) (awburst==2)|-> (awsize==2) |-> awaddr%4==0;
	endproperty

	assert property (R_wrap_type);
	assert property (R_wrap_type1);
	assert property (W_wrap_type);
	assert property (W_wrap_type1);

	property ar_size;
		@(posedge clk) awvalid |-> (awsize<3);
	endproperty

	property aw_size;
		@(posedge clk) arvalid |-> (arsize<3);
	endproperty

	assert property (ar_size);
	assert property (aw_size);


	property W_burst_type_wrap;
 		@(posedge clk) (awburst==2)|-> ((awlen==1)||(awlen==3)||(awlen==7)||(awlen==15));
	endproperty

	property R_burst_type_wrap;
		@(posedge clk) (arburst==2)|-> ((arlen==1)||(arlen==3)||(arlen==7)||(arlen==15));
	endproperty

	//assert property (R_burst_type_wrap);
	//assert property (W_burst_type_wrap);


	property WBURST;
 		@(posedge clk) awvalid |-> (awburst!==3);
	endproperty

	property RBURST;
 		@(posedge clk) arvalid |-> (arburst!==3);
	endproperty

	assert property (WBURST);
	assert property (RBURST);

	property WLAST;
		@(posedge clk) wlast |-> (wvalid)&&(!wready) |=> wvalid;
	endproperty

	property RLAST;
		@(posedge clk) rlast |=> !rvalid;
	endproperty

	assert property (WLAST);
	assert property (RLAST);


endinterface
