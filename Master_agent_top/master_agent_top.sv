class master_agent_top extends uvm_env;

    `uvm_component_utils(master_agent_top)

    master_agent m_agt[];

    env_config cfg;

    extern function new(string name, uvm_component parent);

    extern function void build_phase(uvm_phase phase);

endclass

    function master_agent_top::new(string name, uvm_component parent);

        super.new(name,parent);
    
    endfunction

    function void master_agent_top::build_phase(uvm_phase phase);

        super.build_phase(phase);
        
        if(!uvm_config_db #(env_config)::get(this,"","env_config",cfg))
			`uvm_fatal("ENV","env_config not getting in env class")
        
        m_agt = new[cfg.has_master_agents];

        foreach(m_agt[i])
            begin
        
                m_agt[i] = master_agent::type_id::create($sformatf("m_agt[%0d]",i),this);

                uvm_config_db #(master_agt_config)::set(this,$sformatf("m_agt[%0d]*",i),"master_agt_config",cfg.m_cfg[i]);

            end

    endfunction
