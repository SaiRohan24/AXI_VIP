class slave_agent_top extends uvm_env;

    `uvm_component_utils(slave_agent_top)

    slave_agent s_agt[];

    env_config cfg;

    extern function new(string name, uvm_component parent);

    extern function void build_phase(uvm_phase phase);

endclass

    function slave_agent_top::new(string name, uvm_component parent);

        super.new(name,parent);

    endfunction

    function void slave_agent_top::build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db #(env_config)::get(this,"","env_config",cfg))
            `uvm_fatal("SLAVE_AGENT_TOP","CFG is not getting in slave_agent_top class")

        s_agt = new[cfg.has_slave_agents];

        foreach(s_agt[i])
            begin
               
                s_agt[i] = slave_agent::type_id::create($sformatf("s_agt[%0d]",i),this);

                uvm_config_db #(slave_agt_config)::set(this,$sformatf("s_agt[%0d]*",i),"slave_agt_config",cfg.s_cfg[i]);
            
            end

    endfunction