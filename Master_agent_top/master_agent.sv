class master_agent extends uvm_agent;

    `uvm_component_utils(master_agent)

    master_driver drvh;

    master_monitor monh;

    master_sequencer seqrh;

    master_agt_config m_cfg;

    extern function new(string name, uvm_component parent);

    extern function void build_phase(uvm_phase phase);

    extern function void connect_phase(uvm_phase phase);

endclass

    function master_agent::new(string name,uvm_component parent);

        super.new(name,parent);

    endfunction

    function void master_agent::build_phase(uvm_phase phase);

            super.build_phase(phase);

            if(!uvm_config_db #(master_agt_config)::get(this,"","master_agt_config",m_cfg))
                `uvm_fatal("MASTER_AGENT","M_CFG not getting in master_agent class")

            monh = master_monitor::type_id::create("monh",this);

            if(m_cfg.is_active == UVM_ACTIVE)
                begin
                        drvh = master_driver::type_id::create("drvh",this);
                        seqrh = master_sequencer::type_id::create("seqrh",this);
                end
            
    endfunction

    function void master_agent::connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        if(m_cfg.is_active == UVM_ACTIVE)
            drvh.seq_item_port.connect(seqrh.seq_item_export);
        
    endfunction
