class base_test extends uvm_test;

	`uvm_component_utils(base_test)

	env_config cfg;

	master_agt_config m_cfg[];

	slave_agt_config s_cfg[];

	env envh;

	int has_master_agents = 1;

	int has_slave_agents = 1;

	bit has_scoreboard = 1;

	extern function new(string name, uvm_component parent);

	extern function void build_phase(uvm_phase phase);
	
	extern function void start_of_simulation_phase(uvm_phase phase); 

endclass

	function base_test::new(string name, uvm_component parent);

		super.new(name,parent);

	endfunction

	function void base_test::build_phase(uvm_phase phase);

		//super.build_phase(phase);

		cfg = env_config::type_id::create("cfg");

		m_cfg = new[has_master_agents];

		s_cfg = new[has_slave_agents];

		foreach(m_cfg[i])
			begin

				m_cfg[i] =  master_agt_config::type_id::create($sformatf("m_cfg[%0d]",i));
			
				if(!uvm_config_db #(virtual axi_if)::get(this,"","axi_if",m_cfg[i].vif))
					`uvm_fatal("TEST","virtual interface not getting in test class")

				m_cfg[i].is_active = UVM_ACTIVE;		

			end

		foreach(s_cfg[i])
			begin

				s_cfg[i] = slave_agt_config::type_id::create($sformatf("s_cfg[%0d]",i));

				if(!uvm_config_db #(virtual axi_if)::get(this,"","axi_if",s_cfg[i].vif))
					`uvm_fatal("TEST","virtual interface not getting in test class")

				s_cfg[i].is_active = UVM_ACTIVE;		

			end

		cfg.m_cfg = m_cfg;

		cfg.s_cfg = s_cfg;

		cfg.has_master_agents = has_master_agents;

		cfg.has_slave_agents = has_slave_agents;

		cfg.has_scoreboard = has_scoreboard;

		uvm_config_db #(env_config)::set(this,"*","env_config",cfg);

		envh = env::type_id::create("envh",this);

	endfunction

	function void base_test::start_of_simulation_phase(uvm_phase phase);

		uvm_top.print_topology();

		//envh.m_agt_top.m_agt[0].seqrh.set_arbitration(SEQ_ARB_STRICT_FIFO);

		//endfunction

	endfunction

	class test_1 extends base_test;

		`uvm_component_utils(test_1)

		drive_sequence_0 d_seq_0;
		drive_sequence_1 d_seq_1;
		drive_sequence_2 d_seq_2;
	
		extern function new(string name, uvm_component parent);

		extern function void build_phase(uvm_phase phase);

		extern function void start_of_simulation_phase(uvm_phase phase);

		extern task run_phase(uvm_phase phase);
	
	endclass

	function test_1::new(string name, uvm_component parent);

		super.new(name,parent);

	endfunction

	function void test_1::build_phase(uvm_phase phase);

		super.build_phase(phase);

	endfunction

	function void test_1::start_of_simulation_phase(uvm_phase phase);

		//envh.m_agt_top.m_agt[0].seqrh.set_arbitration(SEQ_ARB_STRICT_FIFO);


	endfunction


	task test_1::run_phase(uvm_phase phase);

		d_seq_0 = drive_sequence_0::type_id::create("d_seq_0");
		
		d_seq_1 = drive_sequence_1::type_id::create("d_seq_1");
		
		d_seq_2 = drive_sequence_2::type_id::create("d_seq_2");

		phase.raise_objection(this);

		repeat(1)
			begin
				d_seq_0.start(envh.m_agt_top.m_agt[0].seqrh);
				d_seq_1.start(envh.m_agt_top.m_agt[0].seqrh);
				d_seq_2.start(envh.m_agt_top.m_agt[0].seqrh);
			end
		#9000;
		phase.drop_objection(this);

	endtask
