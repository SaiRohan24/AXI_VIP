class slave_bsequence extends uvm_sequence #(axi_xtn);

    `uvm_object_utils(slave_bsequence)

    extern function new(string name = "s_bseq");

endclass

    function slave_bsequence::new(string name = "s_bseq");

        super.new(name);
    
    endfunction
