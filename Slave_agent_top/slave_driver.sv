class slave_driver extends uvm_driver #(axi_xtn);

    	`uvm_component_utils(slave_driver)

    	slave_agt_config s_cfg;

    	virtual axi_if.S_DRV_MP vif;

		axi_xtn xtn1,xtn2;

	axi_xtn q1[$], q2[$], q3[$], q4[$];

	int smem[int];

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

	extern task send_transfer();

	extern task rec_waddr();

	extern task rec_wdata(axi_xtn xtn1);

	extern task send_wresp(axi_xtn xtn1);

	extern task rec_read_addr();

	extern task send_rdata(axi_xtn xtn2);

endclass

	function slave_driver::new(string name, uvm_component parent);

        	super.new(name,parent);

    	endfunction

    	function void slave_driver::build_phase(uvm_phase phase);

        	super.build_phase(phase);

        	if(!uvm_config_db #(slave_agt_config)::get(this,"","slave_agt_config",s_cfg))
        	    `uvm_fatal("SLAVE_DRIVER","S_CFG is not getting in slave_driver class")

    	endfunction

    	function void slave_driver::connect_phase(uvm_phase phase);

    	    vif = s_cfg.vif;

    	endfunction    

	task slave_driver::run_phase(uvm_phase phase);	

		forever
			begin
				send_transfer();
			end	

	endtask


	task slave_driver::send_transfer();
		
			fork
				begin
					sem_wac.get(1);
					rec_waddr();
					sem_wac.put(1);
					sem_wadc.put(1);
				end

				begin
					sem_wadc.get(1);
					sem_wdc.get(1);
					rec_wdata(q1.pop_front());
					sem_wdc.put(1);
					sem_wdrc.put(1);
				end

				begin
					sem_wdrc.get(1);
					sem_wrc.get(1);
					send_wresp(q2.pop_front());
					sem_wrc.put(1);
				end

				begin
					sem_rac.get(1);
					rec_read_addr();
					sem_rac.put(1);
					sem_radc.put(1);
				end		
		
				begin
					sem_radc.get(1);
					sem_rdc.get(1);
					send_rdata(q3.pop_front());
					sem_rdc.put(1);
				end

			join_any

	endtask

	task slave_driver::rec_waddr();

		xtn1 = axi_xtn::type_id::create("xtn1");
		
		while(vif.s_drv_cb.awvalid !== 1)
    	@(vif.s_drv_cb);
	
 
  		vif.s_drv_cb.awready <= 1;
		
		begin
			xtn1.awid 	= vif.s_drv_cb.awid;
			xtn1.awaddr 	= vif.s_drv_cb.awaddr;
			xtn1.awburst 	= vif.s_drv_cb.awburst;
			xtn1.awsize 	= vif.s_drv_cb.awsize;
			xtn1.awlen 	= vif.s_drv_cb.awlen;
				
    	end
	
		@(vif.s_drv_cb)
			vif.s_drv_cb.awready  <= 0;
  		
	q1.push_back(xtn1);
	q2.push_back(xtn1);
	
		repeat(2)
			@(vif.s_drv_cb);

	endtask

	task slave_driver::rec_wdata(axi_xtn xtn1);
	
		while(vif.s_drv_cb.wvalid !== 1)
    		@(vif.s_drv_cb);	
   	

		xtn1.addr_calc();
		xtn1.strb_calc();


		foreach(xtn1.w_addr_n[i])
			begin	
       	
				vif.s_drv_cb.wready <= 1;
				xtn1.wid = vif.s_drv_cb.wid;
				if(i == 0 )
					@(vif.s_drv_cb);
		
				@(vif.s_drv_cb);

				case(vif.s_drv_cb.wstrb)
			
					4'b0001 : smem[xtn1.w_addr_n[i]] = vif.s_drv_cb.wdata[7:0];
			
					4'b0011 : smem[xtn1.w_addr_n[i]] = vif.s_drv_cb.wdata[15:0];
			
					4'b0111 : smem[xtn1.w_addr_n[i]] = vif.s_drv_cb.wdata[23:0];
			
					4'b1111 : smem[xtn1.w_addr_n[i]] = vif.s_drv_cb.wdata[31:0];
			
					4'b0010 : smem[xtn1.w_addr_n[i]] = vif.s_drv_cb.wdata[15:8];
			
					4'b0100 : smem[xtn1.w_addr_n[i]] = vif.s_drv_cb.wdata[23:16];
			
					4'b1000 : smem[xtn1.w_addr_n[i]] = vif.s_drv_cb.wdata[31:24];
			
					4'b1100 : smem[xtn1.w_addr_n[i]] = vif.s_drv_cb.wdata[31:16];
			
					4'b0110 : smem[xtn1.w_addr_n[i]] = vif.s_drv_cb.wdata[23:8];
			
					4'b1110 : smem[xtn1.w_addr_n[i]] = vif.s_drv_cb.wdata[31:8];

					default : smem[xtn1.w_addr_n[i]] = vif.s_drv_cb.wdata[31:0];
		
				endcase

				//@(vif.s_drv_cb);

			end
	
		//@(vif.s_drv_cb);		
		vif.s_drv_cb.wready <= 0;

		
		/*foreach(smem[i]) 
			$display("smem[%0d] = %0b",i,smem[i]);*/
		
		repeat(2)
			@(vif.s_drv_cb);
			

	endtask

	task slave_driver::send_wresp(axi_xtn xtn1);
	
		while(vif.s_drv_cb.bready !==1 )
	@(vif.s_drv_cb);

	vif.s_drv_cb.bid    <= xtn1.awid;
       	vif.s_drv_cb.bresp  <= 0;
       	vif.s_drv_cb.bvalid <= 1;
		
	@(vif.s_drv_cb);
       	
       	vif.s_drv_cb.bresp  <= 2'bx;
	vif.s_drv_cb.bvalid  <= 0;
	
//	$display("the array[i] collected in the slave drive ");
//	foreach(array[i]) $display("slave driver array[%0d] %b",i,array[i]);
		repeat(2)
			@(vif.s_drv_cb);

		//$display("slave_driver write channels");
		//xtn1.print();
		//foreach(smem[i])
		//	$display("smem[%0d] = %0b",i,smem[i]);
	endtask

	task slave_driver::rec_read_addr();
	
		xtn2 = axi_xtn::type_id::create("xtn2");

		while(vif.s_drv_cb.arvalid !== 1)
    	@(vif.s_drv_cb);
	
 
  		vif.s_drv_cb.arready <= 1;
		
  	//	while ( vif.s_drv_cb.ARREADY !== 1  && vif.s_drv_cb.ARVALID !== 1)
 	//	@(vif.s_drv_cb);
    		
		begin
			xtn2.arid 	= vif.s_drv_cb.arid;
			xtn2.araddr 	= vif.s_drv_cb.araddr;
			xtn2.arburst 	= vif.s_drv_cb.arburst;
			xtn2.arsize 	= vif.s_drv_cb.arsize;
			xtn2.arlen 	= vif.s_drv_cb.arlen;
				
    	
		end
	
	
	
		@(vif.s_drv_cb)
			vif.s_drv_cb.arready  <= 0;
  		
	q3.push_back(xtn2);
	
		repeat(2)
			@(vif.s_drv_cb);		

	endtask

	task slave_driver::send_rdata(axi_xtn xtn2);

		xtn2.rid = xtn2.arid;
	@(vif.s_drv_cb);
	vif.s_drv_cb.rid <= xtn2.rid;

//	$display("this is xtn4");	
//	xtn4.print();

	for(int i =0; i<xtn2.arlen+1; i++)
	begin
		begin
			vif.s_drv_cb.rdata  <= $random;
			vif.s_drv_cb.rvalid <= 1;
			vif.s_drv_cb.rresp  <= 0;
		//	$display("                                 enter the slave rdata i %0d  == %0d ",i,vif.s_drv_cb.RDATA);
			while(vif.s_drv_cb.rready !==1 )
				@(vif.s_drv_cb);
	
			if(i == xtn2.arlen)
				vif.s_drv_cb.rlast <= 1;
			
		end
			@(vif.s_drv_cb);		
	end


	vif.s_drv_cb.rvalid <= 0;
	vif.s_drv_cb.rlast  <= 0;
	vif.s_drv_cb.rresp  <= 'bx;
	
	repeat(2)
		@(vif.s_drv_cb);

		//foreach(smem[i])
		//	$display("smem[%0d] = %0b",i,smem[i]);

		//$display("Printing from slave_driver");
		//xtn1.print();
		//xtn2.print();

	endtask
