class env extends uvm_env;

	`uvm_component_utils(env)

	scoreboard sb;
	
	master_agent_top m_agt_top;

	slave_agent_top s_agt_top;

	env_config cfg;

	extern function new(string name, uvm_component parent);

	extern function void build_phase(uvm_phase phase);

	extern function void connect_phase(uvm_phase phase);

endclass

	function env::new(string name, uvm_component parent);

		super.new(name,parent);

	endfunction

	function void env::build_phase(uvm_phase phase);

		super.build_phase(phase);

		if(!uvm_config_db #(env_config)::get(this,"","env_config",cfg))
			`uvm_fatal("ENV","env_config not getting in env class")

		if(cfg.has_master_agents > 0)

			m_agt_top = master_agent_top::type_id::create("m_agt_top",this);

		if(cfg.has_slave_agents > 0)

			s_agt_top = slave_agent_top::type_id::create("s_agt_top",this);

		if(cfg.has_scoreboard > 0)
			sb = scoreboard::type_id::create("sb",this);

	endfunction

	function void env::connect_phase(uvm_phase phase);

		m_agt_top.m_agt[0].monh.m_write_port.connect(sb.mst_fifo[0].analysis_export);
		m_agt_top.m_agt[0].monh.m_read_port.connect(sb.mst_fifo[0].analysis_export);

		s_agt_top.s_agt[0].monh.s_write_port.connect(sb.slv_fifo[0].analysis_export);
		s_agt_top.s_agt[0].monh.s_read_port.connect(sb.slv_fifo[0].analysis_export);

	endfunction
