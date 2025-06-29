class slave_monitor extends uvm_monitor;

	`uvm_component_utils(slave_monitor)

    	slave_agt_config s_cfg;

    	virtual axi_if.S_MON_MP vif;
	
	uvm_analysis_port #(axi_xtn) s_write_port;
	
	uvm_analysis_port #(axi_xtn) s_read_port;

	axi_xtn xtn1,xtn2;

	axi_xtn q1[$], q2[$], q3[$];

	semaphore sem_wac = new(1);
	semaphore sem_wdc = new(1);
	semaphore sem_wrc = new(1);
	semaphore sem_wadc = new();
	semaphore sem_wdrc = new();

	semaphore sem_rac =new(1);
	semaphore sem_rdc = new(1);
	semaphore sem_radc = new();

    	extern function new(string name, uvm_component parent);

    	extern function void build_phase(uvm_phase phase);

    	extern function void connect_phase(uvm_phase phase);

	extern task run_phase(uvm_phase phase);

	extern task monitoring_slave();

	extern task s_collect_waddr();

	extern task s_collect_wdata(axi_xtn xtn1);

	extern task s_collect_wresp(axi_xtn xtn1);

	extern task s_collect_raddr();

	extern task s_collect_rdata(axi_xtn xtn2);

endclass

	function slave_monitor::new(string name, uvm_component parent);

        	super.new(name,parent);

		s_write_port = new("s_wp",this);
		
		s_read_port = new("s_rp",this);
    
    	endfunction

    	function void slave_monitor::build_phase(uvm_phase phase);

        	super.build_phase(phase);

        	if(!uvm_config_db #(slave_agt_config)::get(this,"","slave_agt_config",s_cfg))
            		`uvm_fatal("SLAVE_MONITOR","S_CFG is not getting in slave_monitor class")

    	endfunction

    	function void slave_monitor::connect_phase(uvm_phase phase);

        	vif = s_cfg.vif;

    	endfunction

	task slave_monitor::run_phase(uvm_phase phase);

		forever
			monitoring_slave();

	endtask

	task slave_monitor::monitoring_slave();
		
		fork
		
			begin
				sem_wac.get(1);
				s_collect_waddr();
				sem_wac.put(1);
				sem_wadc.put(1);	
			end	
	
			begin
				sem_wadc.get(1);
				sem_wdc.get(1);
				s_collect_wdata(q1.pop_front());
				sem_wdc.put(1);
				sem_wdrc.put(1);
			end	
	
			begin
				sem_wdrc.get(1);
				sem_wrc.get(1);
				s_collect_wresp(q2.pop_front());
				sem_wrc.put(1);
			end

			begin
				sem_rac.get(1);
				s_collect_raddr();
				sem_rac.put(1);
				sem_radc.put(1);
			end		
		
			begin
				sem_radc.get(1);
				sem_rdc.get(1);
				s_collect_rdata(q3.pop_front());
				sem_rdc.put(1);
			end
		join_any

	endtask

	task slave_monitor::s_collect_waddr();

		xtn1 = axi_xtn::type_id::create("xtn1");

		while(vif.s_mon_cb.awvalid !== 1 || vif.s_mon_cb.awready !== 1)
			@(vif.s_mon_cb);

		xtn1.awid = vif.s_mon_cb.awid;
		xtn1.awaddr = vif.s_mon_cb.awaddr;
		xtn1.awlen = vif.s_mon_cb.awlen;
		xtn1.awsize = vif.s_mon_cb.awsize;
		xtn1.awburst = vif.s_mon_cb.awburst;
		xtn1.awvalid = vif.s_mon_cb.awvalid;
		xtn1.awready = vif.s_mon_cb.awready;

		q1.push_back(xtn1);
		q2.push_back(xtn1);


		@(vif.s_mon_cb);

	endtask

	task slave_monitor::s_collect_wdata(axi_xtn xtn1);

		while(vif.s_mon_cb.wvalid !== 1 || vif.s_mon_cb.wready !== 1)
			@(vif.s_mon_cb);

		xtn1.wid = vif.s_mon_cb.wid;
		xtn1.wready = vif.s_mon_cb.wready;
		xtn1.wvalid = vif.s_mon_cb.wvalid;
		xtn1.wdata = new[xtn1.awlen+1];
		xtn1.wstrb = new[xtn1.awlen+1];

		foreach(xtn1.wdata[i])
			begin
				while(vif.s_mon_cb.wvalid !== 1 || vif.s_mon_cb.wready !== 1)
					@(vif.s_mon_cb);
				@(vif.s_mon_cb);
				xtn1.wstrb[i] = vif.s_mon_cb.wstrb;
				case(vif.s_mon_cb.wstrb)
					
						4'b0001 : xtn1.wdata[i] = vif.s_mon_cb.wdata[7:0];
						
						4'b0010 : xtn1.wdata[i] = vif.s_mon_cb.wdata[15:8];
						
						4'b0011 : xtn1.wdata[i] = vif.s_mon_cb.wdata[15:0];
						
						4'b0100 : xtn1.wdata[i] = vif.s_mon_cb.wdata[23:16];
						
						4'b0110 : xtn1.wdata[i] = vif.s_mon_cb.wdata[23:8];
						
						4'b0111 : xtn1.wdata[i] = vif.s_mon_cb.wdata[23:0];
						
						4'b1000 : xtn1.wdata[i] = vif.s_mon_cb.wdata[31:24];
						
						4'b1100 : xtn1.wdata[i] = vif.s_mon_cb.wdata[31:16];
						
						4'b1110 : xtn1.wdata[i] = vif.s_mon_cb.wdata[31:8];
						
						4'b1111 : xtn1.wdata[i] = vif.s_mon_cb.wdata[31:0];

						default : xtn1.wdata[i] = vif.s_mon_cb.wdata[31:0];
										
				endcase
				//@(vif.s_mon_cb);
			end	
	
	endtask

	task slave_monitor::s_collect_wresp(axi_xtn xtn1);

		while(vif.s_mon_cb.bvalid !== 1 || vif.s_mon_cb.bready !== 1)
			@(vif.s_mon_cb);
		@(vif.s_mon_cb);
		xtn1.bid = vif.s_mon_cb.bid;
		xtn1.bresp = vif.s_mon_cb.bresp;
		xtn1.bready = vif.s_mon_cb.bready;
		xtn1.bvalid = vif.s_mon_cb.bvalid;

		@(vif.s_mon_cb);

		//$display("slave_monitor_write_channel");
		//xtn1.print();

		s_write_port.write(xtn1);

	endtask

	task slave_monitor::s_collect_raddr();

		xtn2 = axi_xtn::type_id::create("xtn2");

		while(vif.s_mon_cb.arvalid !== 1 || vif.s_mon_cb.arready !== 1)
			@(vif.s_mon_cb);

		xtn2.arid = vif.s_mon_cb.arid;
		xtn2.araddr = vif.s_mon_cb.araddr;
		xtn2.arlen = vif.s_mon_cb.arlen;
		xtn2.arsize = vif.s_mon_cb.arsize;
		xtn2.arburst = vif.s_mon_cb.arburst;
		xtn2.arvalid = vif.s_mon_cb.arvalid;
		xtn2.arready = vif.s_mon_cb.arready;

		q3.push_back(xtn2);

		@(vif.s_mon_cb);

	endtask

	task slave_monitor::s_collect_rdata(axi_xtn xtn2);

		while(vif.s_mon_cb.rvalid !== 1 || vif.s_mon_cb.rready !== 1)
			@(vif.s_mon_cb);

		xtn2.rid = vif.s_mon_cb.rid;
		xtn2.rvalid = vif.s_mon_cb.rvalid;
		xtn2.rready = vif.s_mon_cb.rready;
		//$display("arlen %0d",xtn2.arlen);
		xtn2.rdata = new[xtn2.arlen+1];
		//$display("size is %0d",xtn2.rdata.size);
		xtn2.rresp = vif.s_mon_cb.rresp;
		foreach(xtn2.rdata[i])
			begin
				while(vif.s_mon_cb.rvalid !== 1 || vif.s_mon_cb.rready !== 1)
					@(vif.s_mon_cb);
					@(vif.s_mon_cb);
				xtn2.rdata[i] = vif.s_mon_cb.rdata;
				//@(vif.s_mon_cb);
			end	
		//@(vif.s_mon_cb);
		//$display("slave_monitor_read_channel");
		//xtn2.print();

		s_read_port.write(xtn2);

	endtask
