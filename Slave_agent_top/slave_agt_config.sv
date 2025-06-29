class slave_agt_config extends uvm_object;

    `uvm_object_utils(slave_agt_config)

    uvm_active_passive_enum is_active = UVM_ACTIVE;

    virtual axi_if vif;

    extern function new(string name = "s_agt_cfg");

endclass

    function slave_agt_config::new(string name = "s_agt_cfg");

        super.new(name);
    
    endfunction