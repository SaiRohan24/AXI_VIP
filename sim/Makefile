#Makefile for UVM Testbench - AXI_VIP

# SIMULATOR = Questa for Mentor's Questasim
# SIMULATOR = VCS for Synopsys's VCS

SIMULATOR = Questa

FSDB_PATH=/home/cad/eda/SYNOPSYS/VERDI_2022/verdi/T-2022.06-SP1/share/PLI/VCS/LINUX64

RTL= ../rtl/*
work= work #library name
SVTB1= ../tb/top.sv
INC = +incdir+../tb +incdir+../test +incdir+../master_agt_top +incdir+../slave_agt_top 
SVTB2 = ../test/test_pkg.sv
VSIMOPT= -vopt -voptargs=+acc 
VSIMCOV= -coverage -sva 
VSIMBATCH1= -c -do  " log -r /* ;coverage save -onexit mem_cov1;run -all; exit"
VSIMBATCH2= -c -do  " log -r /* ;coverage save -onexit mem_cov2;run -all; exit"
VSIMBATCH3= -c -do  " log -r /* ;coverage save -onexit mem_cov3;run -all; exit"
VSIMBATCH4= -c -do  " log -r /* ;coverage save -onexit mem_cov4;run -all; exit"


help:
	@echo =============================================================================================================
	@echo "! USAGE   	--  make target                             										!"
	@echo "! clean   	=>  clean the earlier log and intermediate files.       								!"
	@echo "! sv_cmp    	=>  Create library and compile the code.                   								!"
	@echo "! run_test	=>  clean, compile & run the simulation for axi_test_base in batch mode.		!" 
	@echo "! run_test1	=>  clean, compile & run the simulation for small_pkt_test in batch mode.			!" 
	@echo "! run_test2	=>  clean, compile & run the simulation for medium_pkt_test in batch mode.			!"
	@echo "! run_test3	=>  clean, compile & run the simulation for big_pkt_test in batch mode.		!" 
	@echo "! view_wave =>  To view the waveform of router_test_base                                                    !"
	@echo "! view_wave1 =>  To view the waveform of small_pkt_test                                                       !" 
	@echo "! view_wave2 =>  To view the waveform of medium_pkt_test                                                       !" 
	@echo "! view_wave3 =>  To view the waveform of big_pkt_test                                                      !" 
	@echo ====================================================================================================================

clean : clean_$(SIMULATOR)
sv_cmp : sv_cmp_$(SIMULATOR)
run_test : run_test_$(SIMULATOR)
run_test1 : run_test1_$(SIMULATOR)
run_test2 : run_test2_$(SIMULATOR)
run_test3 : run_test3_$(SIMULATOR)
view_wave : view_wave_$(SIMULATOR)
view_wave1 : view_wave1_$(SIMULATOR)
view_wave2 : view_wave2_$(SIMULATOR)
view_wave3 : view_wave3_$(SIMULATOR)

# ----------------------------- Start of Definitions for Mentor's Questa Specific Targets -------------------------------#

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1) 	
	
run_test_Questa: clean sv_cmp
	vsim  $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1)  -wlf wave.wlf -l test1.log  -sv_seed random  work.top +UVM_TESTNAME=base_test
	
run_test1_Questa: clean sv_cmp
	vsim  $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH2)  -wlf wave1.wlf -l test2.log  -sv_seed random  work.top +UVM_TESTNAME=test_1
	
run_test2_Questa: clean sv_cmp
	vsim  $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH3)  -wlf wave2.wlf -l test3.log  -sv_seed random  work.top +UVM_TESTNAME=medium_pkt_test
	
run_test3_Questa: clean sv_cmp
	vsim  $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4)  -wlf wave3.wlf -l test4.log  -sv_seed random  work.top +UVM_TESTNAME=big_pkt_test
	
clean_Questa: 
	rm -rf transcript* *log* fcover* covhtml* mem_cov* *.wlf modelsim.ini work
	clear


view_wave_Questa: 
	vsim -view wave.wlf

view_wave1_Questa: 
	vsim -view wave1.wlf

view_wave2_Questa: 
	vsim -view wave2.wlf

view_wave3_Questa: 
	vsim -view wave3.wlf






# ----------------------------- End of Definitions for Mentor's Questa Specific Targets -------------------------------#

# ----------------------------- Start of Definitions for Synopsys's VCS Specific Targets -------------------------------#

sv_cmp_VCS:
	vcs -l vcs.log -timescale=1ns/1ps -sverilog -ntb_opts uvm -debug_access+all -full64 -kdb -lca -P $(FSDB_PATH)/novas.tab $(FSDB_PATH)/pli.a $(RTL) $(INC) $(SVTB2) $(SVTB1) 
	      
run_test_VCS:	clean  sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave.fsdb -cm_dir +ntb_random_seed_automatic +UVM_TESTNAME=base_test
	
run_test1_VCS: clean  sv_cmp_VCS	
	./simv -a vcs.log +fsdbfile+wave1.fsdb -cm_dir +ntb_random_seed_automatic +UVM_TESTNAME=test_1 	
	
run_test2_VCS: clean  sv_cmp_VCS	
	./simv -a vcs.log +fsdbfile+wave2.fsdb +ntb_random_seed_automatic +UVM_TESTNAME=medium_pkt_test
	
run_test3_VCS: clean  sv_cmp_VCS	
	./simv -a vcs.log +fsdbfile+wave3.fsdb +ntb_random_seed_automatic +UVM_TESTNAME=big_pkt_test 	
	
clean_VCS:
	rm -rf simv* csrc* *.tmp *.vpd *.vdb *.key *.log *hdrs.h *.fsdb verdi* w* n*
	clear

view_wave_VCS: 
	verdi -ssf wave.fsdb
        
view_wave1_VCS: 
	verdi -ssf wave1.fsdb

view_wave2_VCS: 
	verdi -ssf wave2.fsdb

view_wave3_VCS: 
	verdi -ssf wave3.fsdb   

# ----------------------------- END of Definitions for Synopsys's VCS Specific Targets -------------------------------#
