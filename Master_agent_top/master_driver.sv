class master_driver extends uvm_driver #(axi_xtn);

    	`uvm_component_utils(master_driver)

    	master_agt_config m_cfg;
	
    	virtual axi_if.M_DRV_MP vif;

	axi_xtn q1[$], q2[$], q3[$], q4[$], q5[$];

	int mem[int];

	semaphore sem_wac = new(1);
	semaphore sem_wdc = new(1);
	semaphore sem_wrc = new(1);
	semaphore sem_wadc = new();
	semaphore sem_wdrc = new();

	semaphore sem_rac = new(1);
	semaphore sem_rdc = new(1);
	semaphore sem_radc = new();

    	extern function new(string name, uvm_component parent);

    	extern function void build_phase(uvm_phase phase);

    	extern function void connect_phase(uvm_phase phase);

	extern task run_phase(uvm_phase phase);
	
	extern task send_to_ip(axi_xtn xtn);

	extern task send_write_addr(axi_xtn xtn1);

	extern task send_write_data(axi_xtn xtn2);
	
	extern task rec_wresp(axi_xtn xtn3);

	extern task send_read_addr(axi_xtn xtn4);

	extern task rec_rdata(axi_xtn xtn5);

endclass

    	function master_driver::new(string name, uvm_component parent);

        	super.new(name,parent);

    	endfunction

    	function void master_driver::build_phase(uvm_phase phase);

		super.build_phase(phase);

        	if(!uvm_config_db #(master_agt_config)::get(this,"","master_agt_config",m_cfg))
            		`uvm_fatal("MASTER_DRIVER","M_CFG not getting master_driver class")

    	endfunction

    	function void master_driver::connect_phase(uvm_phase phase);

		super.connect_phase(phase);

        	vif = m_cfg.vif;

	endfunction

	task master_driver::run_phase(uvm_phase phase);
		forever
			begin
				seq_item_port.get_next_item(req);

				send_to_ip(req);
		
				seq_item_port.item_done();
			end

	endtask

	task master_driver::send_to_ip(axi_xtn xtn);
		
		q1.push_back(xtn);
		q2.push_back(xtn);
		q3.push_back(xtn);
		q4.push_back(xtn);
		q5.push_back(xtn);
		
		fork
		
				begin
					sem_wac.get(1);
					send_write_addr(q1.pop_front());
					sem_wac.put(1);
					sem_wadc.put(1);	
				end	
	
				begin
					sem_wadc.get(1);
					sem_wdc.get(1);
					send_write_data(q2.pop_front());
					sem_wdc.put(1);
					sem_wdrc.put(1);
				end	
	
				begin
					sem_wdrc.get(1);
					sem_wrc.get(1);
					rec_wresp(q3.pop_front());
					sem_wrc.put(1);
				end

				begin
					sem_rac.get(1);
					send_read_addr(q4.pop_front());
					sem_rac.put(1);
					sem_radc.put(1);
				end		
		
				begin
					sem_radc.get(1);
					sem_rdc.get(1);
					rec_rdata(q5.pop_front());
					sem_rdc.put(1);
				end
		join_any

	endtask

	task master_driver::send_write_addr(axi_xtn xtn1);
		//$display("master_driver");
		//xtn1.print();	

	//@(vif.m_drv_cb);
	@(vif.m_drv_cb)
	begin
  		 
		vif.m_drv_cb.awid 	<= xtn1.awid;
		vif.m_drv_cb.awaddr 	<= xtn1.awaddr;
		vif.m_drv_cb.awlen 	<= xtn1.awlen;
		vif.m_drv_cb.awsize 	<= xtn1.awsize;
		vif.m_drv_cb.awburst 	<= xtn1.awburst;
		vif.m_drv_cb.awvalid 	<= 1;
	end

	
	while(vif.m_drv_cb.awready !== 1 )
		@(vif.m_drv_cb);
	
	vif.m_drv_cb.awvalid <= 1'b0;

	repeat(2)
	@(vif.m_drv_cb);
			
	endtask

	task master_driver::send_write_data(axi_xtn xtn2);

	@(vif.m_drv_cb);
	vif.m_drv_cb.wid <= xtn2.wid;

	foreach(xtn2.wdata[i])
		begin
			//@(vif.m_drv_cb);
			vif.m_drv_cb.wdata  <= xtn2.wdata[i];
			vif.m_drv_cb.wstrb  <= xtn2.wstrb[i];
			vif.m_drv_cb.wvalid <= 1;	
			
			if(i == xtn2.awlen)
				vif.m_drv_cb.wlast <= 1;

			while(vif.m_drv_cb.wready !==1 )
				@(vif.m_drv_cb);
			
			@(vif.m_drv_cb); 
		
		end
	
		vif.m_drv_cb.wlast <= 0;
		vif.m_drv_cb.wvalid <= 0;
	
	repeat(2)
		@(vif.m_drv_cb);	

	endtask

	task master_driver::rec_wresp(axi_xtn xtn3);

		vif.m_drv_cb.bready <= 1'b1;

	xtn3.bid =  vif.m_drv_cb.bid;	

	while(vif.m_drv_cb.bvalid !== 1 )
		@(vif.m_drv_cb);
		
	xtn3.bresp =  vif.m_drv_cb.bresp;
	
	vif.m_drv_cb.bready <= 1'b0;
	
	
	repeat(2)
		@(vif.m_drv_cb);

	endtask

	task master_driver::send_read_addr(axi_xtn xtn4);
		//xtn4.print();
		//@(vif.m_drv_cb);
	@(vif.m_drv_cb)
	begin
  	
		vif.m_drv_cb.arid 	<= xtn4.arid;
		vif.m_drv_cb.araddr 	<= xtn4.araddr;
		vif.m_drv_cb.arlen 	<= xtn4.arlen;
		vif.m_drv_cb.arsize 	<= xtn4.arsize;
		vif.m_drv_cb.arburst 	<= xtn4.arburst;
		vif.m_drv_cb.arvalid 	<= 1;
	end


	while(vif.m_drv_cb.arready !== 1 )
		@(vif.m_drv_cb);
	
	vif.m_drv_cb.arvalid <= 1'b0;

	repeat(2)
	@(vif.m_drv_cb);

	endtask

	task master_driver::rec_rdata(axi_xtn xtn5);

		while(vif.m_drv_cb.rvalid !== 1)
    	@(vif.m_drv_cb);	
   	

	xtn5.addr_calc();

	@(vif.m_drv_cb);
       		vif.m_drv_cb.rready <= 1;

	foreach(xtn5.r_addr_n[i])
	begin	
		
	if(i == 0 )
		@(vif.m_drv_cb);
    	
		@(vif.m_drv_cb);	

		mem[xtn5.r_addr_n[i]] = vif.m_drv_cb.rdata;
		vif.m_drv_cb.rready <= 1;
			
	end	
	vif.m_drv_cb.rready <= 0;

	

	repeat(2)
		@(vif.m_drv_cb);

		//$display("mem size %0d",mem.size);
		
		//foreach(mem[i])
		//	$display("mem[%0d] = %0b",i,mem[i]);

		//$display("Printing from master_driver read");
		//xtn5.print();

	endtask