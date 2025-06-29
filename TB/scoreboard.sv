class scoreboard extends uvm_scoreboard;

	`uvm_component_utils(scoreboard)

	env_config cfg;

	axi_xtn xtn1, xtn2,write_xtn,read_xtn;

	uvm_tlm_analysis_fifo #(axi_xtn) mst_fifo[];

	uvm_tlm_analysis_fifo #(axi_xtn) slv_fifo[];

	static int w_pkt_rcvd,r_pkt_rcvd, w_pkt_cmpr,r_pkt_cmpr;


	covergroup write_cg;
		option.per_instance = 1;
		awaddr_cp : coverpoint write_xtn.awaddr {bins awaddr_bin = {[0:32'hffff_ffff]};}
		awburst_cp : coverpoint write_xtn.awburst {bins awburst_bin[] = {[0:2]};} 
		awsize_cp : coverpoint write_xtn.awsize {bins awsize_bin[] = {[0:2]};}
		awlen_cp : coverpoint write_xtn.awlen {bins awlen_bin = {[0:15]};}
		bresp_cp : coverpoint write_xtn.bresp {bins bresp_bin = {0};}
		
		write_addr : cross awburst_cp,awsize_cp,awlen_cp;
	endgroup

	covergroup write_cg1 with function sample(int i);
		option.per_instance=1;
		wdata_cp  :   coverpoint write_xtn.wdata[i]{bins wdata_bin={[0:32'hffff_ffff]};}
		wstrb_cp  :   coverpoint write_xtn.wstrb[i]{bins wstrobe_bin0={4'b1111};
                                                            bins wstrobe_bin1={4'b1100};
                                                            bins wstrobe_bin2={4'b0011};
                                                            bins wstrobe_bin3={4'b1000};
                                                            bins wstrobe_bin4={4'b0100};
                                                            bins wstrobe_bin5={4'b0010};
                                                            bins wstrobe_bin6={4'b0001};
                                                            bins wstrobe_bin7={4'b1110};
                                                             }
                write_data : cross wdata_cp,wstrb_cp;
	endgroup

	covergroup read_cg;
		    option.per_instance=1;
			araddr_cp:   coverpoint  read_xtn.araddr{bins araddr_bin={[0:'hffff_ffff]};}
			arburst_cp:   coverpoint read_xtn.arburst{bins arburst_bin[]={[0:2]};}
			arsize_cp :   coverpoint read_xtn.arsize{bins arsize_bin[]={[0:2]};}
			arlen_cp  :   coverpoint read_xtn.arlen{bins arlen_bin={[0:15]};}
	
                        READ_ADDR: cross arburst_cp,arsize_cp,arlen_cp;
	endgroup
		
	covergroup read_cg1 with function sample(int i);
		   option.per_instance=1;
			rdata_cp  :   coverpoint read_xtn.rdata[i]{bins rdata_bin={[0:'hffff_ffff]};}
			rresp_cp  :   coverpoint read_xtn.rresp[i]{bins rresp_bin={0};}
	
        endgroup


	extern function new(string name, uvm_component parent);

	extern function void build_phase(uvm_phase phase);

	extern task run_phase(uvm_phase phase);

	extern task collect_data();

	extern function void report_phase(uvm_phase phase);

endclass

	function scoreboard::new(string name, uvm_component parent);

        	super.new(name,parent);

		write_cg=new();
	   	write_cg1=new();
	   	read_cg=new();
	   	read_cg1=new();


	endfunction

	function void scoreboard::build_phase(uvm_phase phase);

		if(!uvm_config_db #(env_config)::get(this,"","env_config",cfg))
			`uvm_fatal("SB","env_config not getting in scoreboard class")

		mst_fifo = new[cfg.has_master_agents];
		
		slv_fifo = new[cfg.has_slave_agents];

		foreach(mst_fifo[i])
			mst_fifo[i] = new($sformatf("mst_fifo[%0d]",i),this);
		
		foreach(slv_fifo[i])
			slv_fifo[i] = new($sformatf("slv_fifo[%0d]",i),this);

	endfunction

	task scoreboard::run_phase(uvm_phase phase);

		forever
			collect_data();

	endtask

	task scoreboard::collect_data();

		fork
		
			mst_fifo[0].get(xtn1);
			slv_fifo[0].get(xtn2);			
	
		join

		//$display("master_monitor");
		//xtn1.print();
		//$display("slave_monitor");
		//xtn2.print();

		if(xtn1.awaddr || xtn2.awaddr)
			w_pkt_rcvd++;
		if(xtn1.araddr || xtn2.araddr)
			r_pkt_rcvd++;

		if(!xtn1.compare(xtn2))
			`uvm_error("SB","Compare unsucessful")
		else
			begin
				if(xtn1.awaddr && xtn2.awaddr)
					w_pkt_cmpr++;
				if(xtn1.araddr && xtn2.araddr)
					r_pkt_cmpr++;

				write_xtn = xtn1;
				read_xtn = xtn1;
				write_cg.sample();
				read_cg.sample();

				foreach(xtn1.wdata[i])
                                	begin
						write_cg1.sample(i);
                                        end

				foreach(xtn1.rdata[i])
                                	begin
						read_cg1.sample(i);
                                        end

			end

	endtask

	function void scoreboard::report_phase(uvm_phase phase);

		`uvm_info("Scoreboard",$sformatf("Write Recieved transactions %0d",w_pkt_rcvd),UVM_LOW)
		`uvm_info("Scoreboard",$sformatf("Sucessful compared write transactions %0d",w_pkt_cmpr),UVM_LOW)
		`uvm_info("Scoreboard",$sformatf("read Recieved transactions %0d",r_pkt_rcvd),UVM_LOW)
		`uvm_info("Scoreboard",$sformatf("Sucessful compared read transactions %0d",r_pkt_cmpr),UVM_LOW)

	endfunction
