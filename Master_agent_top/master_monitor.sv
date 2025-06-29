class master_monitor extends uvm_monitor;

    	`uvm_component_utils(master_monitor)

    	master_agt_config m_cfg;

    	virtual axi_if.M_MON_MP vif;

	uvm_analysis_port #(axi_xtn) m_write_port,m_read_port;
	
	//uvm_analysis_port #(axi_xtn) m_read_port;

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

	extern task monitoring_master();

	extern task collect_waddr();

	extern task collect_wdata(axi_xtn xtn1);

	extern task collect_wresp(axi_xtn xtn1);

	extern task collect_raddr();

	extern task collect_rdata(axi_xtn xtn2);

endclass

    	function master_monitor::new(string name, uvm_component parent);

        	super.new(name,parent);

		m_write_port = new("m_wp",this);
		
		m_read_port = new("m_rp",this);


    	endfunction

    	function void master_monitor::build_phase(uvm_phase phase);

        	super.build_phase(phase);

        	if(!uvm_config_db #(master_agt_config)::get(this,"","master_agt_config",m_cfg))
            		`uvm_fatal("MASTER_MONITOR","M_CFG not getting in master_monitor class")

    	endfunction

    	function void master_monitor::connect_phase(uvm_phase phase);

        	super.connect_phase(phase);

		vif = m_cfg.vif;

	endfunction

	task master_monitor::run_phase(uvm_phase phase);

		forever
			monitoring_master();

	endtask

	task master_monitor::monitoring_master();
		
		fork
		
			begin
				sem_wac.get(1);
				collect_waddr();
				sem_wac.put(1);
				sem_wadc.put(1);	
			end	
	
			begin
				sem_wadc.get(1);
				sem_wdc.get(1);
				collect_wdata(q1.pop_front());
				sem_wdc.put(1);
				sem_wdrc.put(1);
			end	
	
			begin
				sem_wdrc.get(1);
				sem_wrc.get(1);
				collect_wresp(q2.pop_front());
				sem_wrc.put(1);
			end

			begin
				sem_rac.get(1);
				collect_raddr();
				sem_rac.put(1);
				sem_radc.put(1);
			end		
		
			begin
				sem_radc.get(1);
				sem_rdc.get(1);
				collect_rdata(q3.pop_front());
				sem_rdc.put(1);
			end
		join_any

	endtask

	task master_monitor::collect_waddr();

		xtn1 = axi_xtn::type_id::create("xtn1");

		while(vif.m_mon_cb.awvalid !== 1 || vif.m_mon_cb.awready !== 1)
			@(vif.m_mon_cb);

		xtn1.awid = vif.m_mon_cb.awid;
		xtn1.awaddr = vif.m_mon_cb.awaddr;
		xtn1.awlen = vif.m_mon_cb.awlen;
		xtn1.awsize = vif.m_mon_cb.awsize;
		xtn1.awburst = vif.m_mon_cb.awburst;
		xtn1.awvalid = vif.m_mon_cb.awvalid;
		xtn1.awready = vif.m_mon_cb.awready;

		q1.push_back(xtn1);
		q2.push_back(xtn1);


		@(vif.m_mon_cb);

	endtask

	task master_monitor::collect_wdata(axi_xtn xtn1);

		while(vif.m_mon_cb.wvalid !== 1 || vif.m_mon_cb.wready !== 1)
			@(vif.m_mon_cb);

		xtn1.wid = vif.m_mon_cb.wid;
		xtn1.wready = vif.m_mon_cb.wready;
		xtn1.wvalid = vif.m_mon_cb.wvalid;
		xtn1.wdata = new[xtn1.awlen+1];
		xtn1.wstrb = new[xtn1.awlen+1];

		foreach(xtn1.wdata[i])
			begin
				while(vif.m_mon_cb.wvalid !== 1 || vif.m_mon_cb.wready !== 1)
					@(vif.m_mon_cb);
				@(vif.m_mon_cb);
				xtn1.wstrb[i] = vif.m_mon_cb.wstrb;
				case(vif.m_mon_cb.wstrb)
					
						4'b0001 : xtn1.wdata[i] = vif.m_mon_cb.wdata[7:0];
						
						4'b0010 : xtn1.wdata[i] = vif.m_mon_cb.wdata[15:8];
						
						4'b0011 : xtn1.wdata[i] = vif.m_mon_cb.wdata[15:0];
						
						4'b0100 : xtn1.wdata[i] = vif.m_mon_cb.wdata[23:16];
						
						4'b0110 : xtn1.wdata[i] = vif.m_mon_cb.wdata[23:8];
						
						4'b0111 : xtn1.wdata[i] = vif.m_mon_cb.wdata[23:0];
						
						4'b1000 : xtn1.wdata[i] = vif.m_mon_cb.wdata[31:24];
						
						4'b1100 : xtn1.wdata[i] = vif.m_mon_cb.wdata[31:16];
						
						4'b1110 : xtn1.wdata[i] = vif.m_mon_cb.wdata[31:8];
						
						4'b1111 : xtn1.wdata[i] = vif.m_mon_cb.wdata[31:0];

						default : xtn1.wdata[i] = vif.m_mon_cb.wdata[31:0];
										
				endcase
				//@(vif.m_mon_cb);
			end	
	
	endtask

	task master_monitor::collect_wresp(axi_xtn xtn1);

		while(vif.m_mon_cb.bvalid !== 1 || vif.m_mon_cb.bready !== 1)
			@(vif.m_mon_cb);

		@(vif.m_mon_cb);
		xtn1.bid = vif.m_mon_cb.bid;
		xtn1.bresp = vif.m_mon_cb.bresp;
		xtn1.bready = vif.m_mon_cb.bready;
		xtn1.bvalid = vif.m_mon_cb.bvalid;

		@(vif.m_mon_cb);

		//$display("master_monitor_write_channel");
		//xtn1.print();

		m_write_port.write(xtn1);

	endtask

	task master_monitor::collect_raddr();

		xtn2 = axi_xtn::type_id::create("xtn2");

		while(vif.m_mon_cb.arvalid !== 1 || vif.m_mon_cb.arready !== 1)
			@(vif.m_mon_cb);

		xtn2.arid = vif.m_mon_cb.arid;
		xtn2.araddr = vif.m_mon_cb.araddr;
		xtn2.arlen = vif.m_mon_cb.arlen;
		xtn2.arsize = vif.m_mon_cb.arsize;
		xtn2.arburst = vif.m_mon_cb.arburst;
		xtn2.arvalid = vif.m_mon_cb.arvalid;
		xtn2.arready = vif.m_mon_cb.arready;

		q3.push_back(xtn2);

		@(vif.m_mon_cb);

	endtask

	task master_monitor::collect_rdata(axi_xtn xtn2);

		while(vif.m_mon_cb.rvalid !== 1 || vif.m_mon_cb.rready !== 1)
			@(vif.m_mon_cb);

		xtn2.rid = vif.m_mon_cb.rid;
		xtn2.rvalid = vif.m_mon_cb.rvalid;
		xtn2.rready = vif.m_mon_cb.rready;
		//$display("arlen %0d",xtn2.arlen);
		xtn2.rdata = new[xtn2.arlen+1];
		//$display("size is %0d",xtn2.rdata.size);
		xtn2.rresp = vif.m_mon_cb.rresp;
		foreach(xtn2.rdata[i])
			begin
				while(vif.m_mon_cb.rvalid !== 1 || vif.m_mon_cb.rready !== 1)
					@(vif.m_mon_cb);
					@(vif.m_mon_cb);
				xtn2.rdata[i] = vif.m_mon_cb.rdata;
				//@(vif.m_mon_cb);
			end	
		//@(vif.m_mon_cb);
		//$display("master_monitor_read_channel");
		//xtn2.print();
		
		m_read_port.write(xtn2);
	
	endtask
