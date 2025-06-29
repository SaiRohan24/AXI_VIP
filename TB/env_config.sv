class env_config extends uvm_object;

	`uvm_object_utils(env_config)

	bit has_scoreboard = 1;
	
	int has_master_agents = 1;

	int has_slave_agents = 1;

	master_agt_config m_cfg[];

	slave_agt_config s_cfg[];

	extern function new(string name = "env_cfg");	

endclass

	function env_config::new(string name = "env_cfg");

		super.new(name);

	endfunction
