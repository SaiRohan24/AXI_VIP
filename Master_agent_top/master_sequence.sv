class master_bsequence extends uvm_sequence #(axi_xtn);

	`uvm_object_utils(master_bsequence)

    	extern function new(string name = "m_bseq");

endclass

    	function master_bsequence::new(string name = "m_bseq");

		super.new(name);

	endfunction

class drive_sequence_0 extends master_bsequence;

	`uvm_object_utils(drive_sequence_0)

    	extern function new(string name = "d_seq_0");

	extern task body();

endclass

    	function drive_sequence_0::new(string name = "d_seq_0");

		super.new(name);

	endfunction

	task drive_sequence_0::body();
	
		//req = axi_xtn::type_id::create("req");
		repeat(20)
		begin
			//$display("seq");
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {awburst == 0; arburst == 0;});
			finish_item(req);
		end	
	endtask


class drive_sequence_1 extends master_bsequence;

	`uvm_object_utils(drive_sequence_1)

    	extern function new(string name = "d_seq_1");

	extern task body();

endclass

    	function drive_sequence_1::new(string name = "d_seq_1");

		super.new(name);

	endfunction

	task drive_sequence_1::body();
	
		//req = axi_xtn::type_id::create("req");
		repeat(20)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {awburst == 1; arburst == 1;});
			finish_item(req);
		end	
	endtask


class drive_sequence_2 extends master_bsequence;

	`uvm_object_utils(drive_sequence_2)

    	extern function new(string name = "d_seq_2");

	extern task body();

endclass

    	function drive_sequence_2::new(string name = "d_seq_2");

		super.new(name);

	endfunction

	task drive_sequence_2::body();
	
		//req = axi_xtn::type_id::create("req");
		repeat(20)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {awburst == 2; arburst == 2;});
			finish_item(req);
		end	
	endtask

