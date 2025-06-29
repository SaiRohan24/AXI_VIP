class axi_xtn extends uvm_sequence_item;
	
	`uvm_object_utils(axi_xtn)
	
	//wr_addr_channel
	rand bit [3:0] awid;
	rand bit [31:0] awaddr;
	rand bit [3:0] awlen;
	rand bit [2:0] awsize;
	rand bit [1:0] awburst;
	     bit awvalid;
	     bit awready;

	//wr_data_channel
	rand bit [3:0] wid;
	rand bit [31:0] wdata[];
	rand bit [3:0] wstrb[];
	     bit wlast;
	     bit wvalid;
	     bit wready;

	//wr_response_channel
	rand bit [3:0] bid;
	     bit [1:0] bresp;
	     bit bvalid;
	     bit bready;

	//rd_addr_channel
	rand bit [3:0] arid;
	rand bit [31:0] araddr;
	rand bit [3:0] arlen;
	rand bit [2:0] arsize;
	rand bit [1:0] arburst;
	     bit arvalid;
	     bit arready;

	//rd_data_channel
	rand bit [3:0] rid;
	     bit [31:0] rdata[];
	     bit [1:0] rresp;
	     bit rlast;
	     bit rvalid;
	     bit rready;
	
	int unsigned data_bus_bytes = 4;

	int unsigned w_start_addr;
	int unsigned w_number_bytes;
	int unsigned w_aligned_addr;
	int unsigned w_burst_length;
	int unsigned w_addr_n[];
	int unsigned w_wrap_boundary;
	int unsigned lower_byte_lane;
	int unsigned upper_byte_lane;
	
	int unsigned r_start_addr;
	int unsigned r_number_bytes;
	int unsigned r_aligned_addr;
	int unsigned r_burst_length;
	int unsigned r_addr_n[];	
	int unsigned r_wrap_boundary;
	
	int wb,rb;
		
	constraint ID_write_c{awid == wid;}
	
	constraint ID_write_c1{wid == bid;}  //ID's should be always same ------------

	constraint ID_read_c{arid == rid;}

	constraint awsize_c{awsize inside{[0:2]};} // size should not exceed more than 2
	
	constraint arsize_c{arsize inside{[0:2]};}

	constraint awburst_c{awburst != 3;} //Brust should be within 2 
	
	constraint arburst_c{arburst != 3;}	

	constraint wdata_c{wdata.size == awlen+1;}

	constraint wstrb_c{wstrb.size == awlen+1;}

	//constraint rdata_c{rdata.size == arlen+1;}

	constraint awaddr_c{awaddr inside{[1:4095]};}

	constraint araddr_c{araddr inside{[1:4095]};}

	constraint aligned_w_addr{((awburst == 2'b00) || (awburst == 2'b10) && (awsize == 1)) -> awaddr%2 == 0;
				  ((awburst == 2'b00) || (awburst == 2'b10) && (awsize == 2)) -> awaddr%4 == 0;}

	constraint aligned_r_addr{((arburst == 2'b00) || (arburst == 2'b10) && (arsize == 1)) -> araddr%2 == 0;
				  ((arburst == 2'b00) || (arburst == 2'b10) && (arsize == 2)) -> araddr%4 == 0;}

	extern function new(string name="axi_xtn");

	extern function void post_randomize();	

	extern function void addr_calc();

	extern function void strb_calc();

	extern function void do_print(uvm_printer printer);

endclass

	function axi_xtn::new(string name="axi_xtn");
		super.new(name);
	endfunction

	function void axi_xtn::post_randomize();

		data_bus_bytes = 4;

		w_start_addr = awaddr;
		w_number_bytes = 2**awsize;
		w_burst_length = awlen+1;
		w_aligned_addr = (int'(w_start_addr/w_number_bytes)) * w_number_bytes;
		
		r_start_addr = araddr;
		r_number_bytes = 2**arsize;
		r_burst_length = arlen+1;
		r_aligned_addr = (int'(r_start_addr/r_number_bytes)) * r_number_bytes;

		addr_calc();
		strb_calc();
		//$display("blen is %0d",w_burst_length);
	endfunction

	function void axi_xtn::addr_calc();


		data_bus_bytes = 4;

		w_start_addr = awaddr;
		w_number_bytes = 2**awsize;
		w_burst_length = awlen+1;
		w_aligned_addr = (int'(w_start_addr/w_number_bytes)) * w_number_bytes;
		
		r_start_addr = araddr;
		r_number_bytes = 2**arsize;
		r_burst_length = arlen+1;
		r_aligned_addr = (int'(r_start_addr/r_number_bytes)) * r_number_bytes;


		if(arburst == 0 || awburst == 0)
			begin
				if(arburst == 0)
					begin
						r_addr_n = new[r_burst_length];
						foreach(r_addr_n[i])
							r_addr_n[i] = r_aligned_addr;
					end

				if(awburst == 0)
					begin
						w_addr_n = new[w_burst_length];
						foreach(w_addr_n[i])
							w_addr_n[i] = w_aligned_addr; 
					end
			end
		
		if(arburst == 1 || awburst == 1)
			begin
				if(arburst == 1)
					begin
						r_addr_n = new[r_burst_length];
						r_addr_n[0] = r_start_addr;
						for(int i=1; i<r_burst_length; i++)
							r_addr_n[i] = r_aligned_addr + (i) * r_number_bytes;
					end

				if(awburst == 1)
					begin
						w_addr_n = new[w_burst_length];
						w_addr_n[0] = w_start_addr;
						for(int i=1; i<w_burst_length; i++)
							w_addr_n[i] = w_aligned_addr + (i) * w_number_bytes;
					end

			end

		if(arburst == 2 || awburst == 2)
			begin
				if(arburst == 2)
					begin
						r_addr_n = new[r_burst_length];
						r_wrap_boundary = int'(r_start_addr/(r_number_bytes * r_burst_length)) * (r_number_bytes * r_burst_length);
						r_addr_n[0] = r_aligned_addr;
						for(int i=1; i<r_burst_length; i++)
							begin
								if(rb==0)
									begin
										r_addr_n[i] = r_aligned_addr + (i) * r_number_bytes;
										if(r_addr_n[i] == r_wrap_boundary + (r_number_bytes * r_burst_length))
											begin	
												r_addr_n[i] = r_wrap_boundary;
												rb++;
											end
									end
								else
								r_addr_n[i]= r_aligned_addr+((i)*r_number_bytes)-(r_number_bytes*r_burst_length);	
							end
					end

				if(awburst == 2)
					begin
						w_addr_n = new[w_burst_length];
						w_wrap_boundary = int'(w_start_addr/(w_number_bytes * w_burst_length)) * (w_number_bytes * w_burst_length);
						w_addr_n[0] = w_aligned_addr;
						for(int i=1; i<w_burst_length; i++)
							begin
								if(wb==0)
									begin
										w_addr_n[i] = w_aligned_addr + (i) * w_number_bytes;
										if(w_addr_n[i] == w_wrap_boundary + (w_number_bytes * w_burst_length))
											begin	
												w_addr_n[i] = w_wrap_boundary;
												wb++;
											end
									end
								else
								w_addr_n[i]= w_aligned_addr+((i)*w_number_bytes)-(w_number_bytes * w_burst_length);	
							end
					end

			end


	endfunction

	function void axi_xtn::strb_calc();

		data_bus_bytes = 4;

		w_start_addr = awaddr;
		w_number_bytes = 2**awsize;
		w_burst_length = awlen+1;
		w_aligned_addr = (int'(w_start_addr/w_number_bytes)) * w_number_bytes;
		
		r_start_addr = araddr;
		r_number_bytes = 2**arsize;
		r_burst_length = arlen+1;
		r_aligned_addr = (int'(r_start_addr/r_number_bytes)) * r_number_bytes;

		wstrb = new[w_burst_length];
		for(int k =0; k < w_burst_length; k++)
			begin
				if(k == 0)
					begin
						lower_byte_lane = w_start_addr - (int'(w_start_addr/data_bus_bytes)) * data_bus_bytes;
						upper_byte_lane = w_aligned_addr+(w_number_bytes-1)-(int'(w_start_addr/data_bus_bytes))*data_bus_bytes;
						for(int j = lower_byte_lane; j<=upper_byte_lane; j++)
							wstrb[k][j]=1;
					end
				else
					begin
						lower_byte_lane = w_addr_n[k] - (int'(w_addr_n[k]/data_bus_bytes)) * data_bus_bytes;
						upper_byte_lane = lower_byte_lane + w_number_bytes - 1;
						for(int j = lower_byte_lane; j<=upper_byte_lane; j++)
							wstrb[k][j]=1;
					end
			end
	endfunction

	function void axi_xtn::do_print(uvm_printer printer);

		printer.print_field("AWID",   this.awid,   4, UVM_DEC);
		printer.print_field("AWADDR", this.awaddr, 32,UVM_DEC);
		printer.print_field("AWLEN",  this.awlen,  4, UVM_DEC);
		printer.print_field("AWSIZE", this.awsize, 3, UVM_DEC);
		printer.print_field("AWBURST",this.awburst,2, UVM_DEC);
		printer.print_field("AWVALID",this.awvalid,1, UVM_DEC);
		printer.print_field("AWREADY",this.awready,1, UVM_DEC);

		printer.print_field("WID",    this.wid,    4, UVM_DEC);
		foreach(wdata[i])
			begin
				printer.print_field($sformatf("WDATA[%0d]",i),this.wdata[i],32,UVM_BIN);
				printer.print_field($sformatf("WSTRB[%0d]",i),this.wstrb[i],4, UVM_BIN);
			end
		printer.print_field("WLAST",  this.wlast,  1, UVM_DEC);
		printer.print_field("WVALID", this.wvalid, 1, UVM_DEC);
		printer.print_field("WREADY", this.wready, 1, UVM_DEC);

		printer.print_field("BID",    this.bid,    4, UVM_DEC);
		printer.print_field("BRESP",  this.bresp,  2, UVM_DEC);
		printer.print_field("BVALID", this.bvalid, 1, UVM_DEC);
		printer.print_field("BREADY", this.bready, 1, UVM_DEC);

		printer.print_field("ARID",   this.arid,   4, UVM_DEC);
		printer.print_field("ARADDR", this.araddr, 32,UVM_DEC);
		printer.print_field("ARLEN",  this.arlen,  4, UVM_DEC);
		printer.print_field("ARSIZE", this.arsize, 3, UVM_DEC);
		printer.print_field("ARBURST",this.arburst,2, UVM_DEC);
		printer.print_field("ARVALID",this.arvalid,1, UVM_DEC);
		printer.print_field("ARREADY",this.arready,1, UVM_DEC);

		printer.print_field("RID",    this.rid,    4, UVM_DEC);
		for(int i = 0; i<arlen+1; i++)
			begin
				printer.print_field($sformatf("RDATA[%0d]",i),this.rdata[i],32,UVM_BIN);
				
			end
		printer.print_field("RRESP",  this.rresp,  2, UVM_DEC);
		printer.print_field("RLAST",  this.rlast,  1, UVM_DEC);
		printer.print_field("RVALID", this.rvalid, 1, UVM_DEC);
		printer.print_field("RREADY", this.rready, 1, UVM_DEC);

	endfunction
