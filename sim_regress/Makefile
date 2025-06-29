#Makefile for UVM Testbench - AXI_VIP

# SIMULATOR = Questa for Mentor's Questasim
# SIMULATOR = VCS for Synopsys's VCS

SIMULATOR = VCS

FSDB_PATH=/home/cad/eda/SYNOPSYS/VERDI_2022/verdi/T-2022.06-SP1/share/PLI/VCS/LINUX64


RTL= ../rtl/*
work= work #library name
SVTB1= ../tb/top.sv
INC =  +incdir+../tb +incdir+../test +incdir+../master_agt_top +incdir+../slave_agt_top
SVTB2 = ../test/test_pkg.sv
VSIMOPT= -vopt -voptargs=+acc 
VSIMCOV= -coverage -sva 
VSIMBATCH1= -c -do  " log -r /* ;coverage save -onexit router_cov1;run -all; exit"
VSIMBATCH2= -c -do  " log -r /* ;coverage save -onexit router_cov2;run -all; exit"
VSIMBATCH3= -c -do  " log -r /* ;coverage save -onexit router_cov3;run -all; exit"
VSIMBATCH4= -c -do  " log -r /* ;coverage save -onexit router_cov4;run -all; exit"
VSIMBATCH5= -c -do  " log -r /* ;coverage save -onexit router_cov5;run -all; exit"
VSIMBATCH6= -c -do  " log -r /* ;coverage save -onexit router_cov6;run -all; exit"
VSIMBATCH7= -c -do  " log -r /* ;coverage save -onexit router_cov7;run -all; exit"
VSIMBATCH8= -c -do  " log -r /* ;coverage save -onexit router_cov8;run -all; exit"
VSIMBATCH9= -c -do  " log -r /* ;coverage save -onexit router_cov9;run -all; exit"
VSIMBATCH10= -c -do  " log -r /* ;coverage save -onexit router_cov10;run -all; exit"



help:
	@echo =============================================================================================================
	@echo "! USAGE   	--  make target                  								!"
	@echo "! clean   	=>  clean the earlier log and intermediate files.  						!"
	@echo "! sv_cmp    	=>  Create library and compile the code.           						!"
	@echo "! run_test	=>  clean, compile & run the simulation for base_test in batch mode.		!" 
	@echo "! run_test1	=>  clean, compile & run the simulation for test_1 in batch mode.			!" 
	@echo "! run_test2	=>  clean, compile & run the simulation for router_medium_test_0 in batch mode.			!"
	@echo "! run_test3	=>  clean, compile & run the simulation for router_big_test_0 in batch mode.			!"
	@echo "! run_test4      =>  clean, compile & run the simulation for router_small_test_1 in batch mode			!"
	@echo "! run_test5	=>  clean, compile & run the simulation for router_medium_test_1 in batch mode.			!"
	@echo "! run_test6	=>  clean, compile & run the simulation for router_big_test_1 in batch mode.			!"
	@echo "! run_test7	=>  clean, compile & run the simulation for router_small_test_2 in batch mode.			!"
	@echo "! run_test8	=>  clean, compile & run the simulation for router_medium_test_2 in batch mode.			!"
	@echo "! run_test9	=>  clean, compile & run the simulation for router_big_test_2 in batch mode.			!"	
	@echo "! run_test10	=>  clean, compile & run the simulation for router_error_test in batch mode.			!"	
	@echo "! run_test11	=>  clean, compile & run the simulation for router_moretime_test in batch mode.			!"	
	@echo "! view_wave1 =>  To view the waveform of router_base_test	    						!" 
	@echo "! view_wave2 =>  To view the waveform of router_small_test_0	    						!" 
	@echo "! view_wave3 =>  To view the waveform of router_medium_test_0 	  						!" 
	@echo "! view_wave4 =>  To view the waveform of router_big_test_0    							!" 
	@echo "! view_wave5 =>  To view the waveform of router_small_test_1	    						!" 
	@echo "! view_wave6 =>  To view the waveform of router_medium_test_1 	  						!" 
	@echo "! view_wave7 =>  To view the waveform of router_big_test_1    							!" 
	@echo "! view_wave8 =>  To view the waveform of router_small_test_2	    						!" 
	@echo "! view_wave9 =>  To view the waveform of router_medium_test_2 	  						!" 
	@echo "! view_wave10 =>  To view the waveform of router_big_test_2    							!" 
	@echo "! view_wave11 =>  To view the waveform of router_error_test    							!" 
	@echo "! view_wave12 =>  To view the waveform of router_moretime_test    							!" 
	@echo "! regress    =>  clean, compile and run all testcases in batch mode.		    				!"
	@echo "! report     =>  To merge coverage reports for all testcases and  convert to html format.			!"
	@echo "! cov        =>  To open merged coverage report in html format.							!"
	@echo ====================================================================================================================

clean : clean_$(SIMULATOR)
sv_cmp : sv_cmp_$(SIMULATOR)
run_test : run_test_$(SIMULATOR)
run_test1 : run_test01_$(SIMULATOR)
run_test2 : run_test02_$(SIMULATOR)
run_test3 : run_test03_$(SIMULATOR)
run_test4 : run_test11_$(SIMULATOR)
run_test5 : run_test12_$(SIMULATOR)
run_test6 : run_test13_$(SIMULATOR)
run_test7 : run_test21_$(SIMULATOR)
run_test8 : run_test22_$(SIMULATOR)
run_test9 : run_test23_$(SIMULATOR)
run_test10 : run_test_err_$(SIMULATOR)
run_test11 : run_test_mt_$(SIMULATOR)
view_wave1 : view_wave1_$(SIMULATOR)
view_wave2 : view_wave2_$(SIMULATOR)
view_wave3 : view_wave3_$(SIMULATOR)
view_wave4 : view_wave4_$(SIMULATOR)
view_wave5 : view_wave5_$(SIMULATOR)
view_wave6 : view_wave6_$(SIMULATOR)
view_wave7 : view_wave7_$(SIMULATOR)
view_wave8 : view_wave8_$(SIMULATOR)
view_wave9 : view_wave9_$(SIMULATOR)
view_wave10 : view_wave10_$(SIMULATOR)
view_wave11 : view_wave11_$(SIMULATOR)
view_wave12 : view_wave12_$(SIMULATOR)
regress : regress_$(SIMULATOR)
report : report_$(SIMULATOR)
cov : cov_$(SIMULATOR)

# ----------------------------- Start of Definitions for Mentor's Questa Specific Targets -------------------------------#

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1) 	
	
run_test_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1)  -wlf wave_file1.wlf -l test1.log  -sv_seed random  work.top +UVM_TESTNAME=base_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov1
	
run_test01_Questa: sv_cmp_Questa
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH2)  -wlf wave_file2.wlf -l test2.log  -sv_seed random  work.top +UVM_TESTNAME=test_1
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov2
	
run_test02_Questa: sv_cmp_Questa
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH3)  -wlf wave_file3.wlf -l test3.log  -sv_seed random  work.top +UVM_TESTNAME=test_1
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov3
	
run_test3_Questa:
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4)  -wlf wave_file4.wlf -l test4.log  -sv_seed random  work.top +UVM_TESTNAME=big_pkt_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov4
	
view_wave1_Questa:
	vsim -view wave_file1.wlf
	
view_wave2_Questa:
	vsim -view wave_file2.wlf
	
view_wave3_Questa:
	vsim -view wave_file3.wlf
	
view_wave4_Questa:
	vsim -view wave_file4.wlf

report_Questa:
	#vcover merge mem_cov mem_cov2 #mem_cov2 mem_cov3 mem_cov4
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov2

regress_Questa: clean_Questa run_test_Questa run_test1_Questa run_test2_Questa run_test3_Questa report_Questa cov_Questa

cov_Questa:
	firefox covhtmlreport/index.html&
	
clean_Questa:
	rm -rf transcript* *log* fcover* covhtml* mem_cov* *.wlf modelsim.ini work
	clear

# ----------------------------- End of Definitions for Mentor's Questa Specific Targets -------------------------------#

# ----------------------------- Start of Definitions for Synopsys's VCS Specific Targets -------------------------------#

sv_cmp_VCS:
	vcs -l vcs.log -timescale=1ns/1ps -sverilog -ntb_opts uvm -debug_access+all -full64 -cm assert -kdb  -lca -P $(FSDB_PATH)/novas.tab $(FSDB_PATH)/pli.a $(RTL) $(INC) $(SVTB2) $(SVTB1)
		      
run_test_VCS:	clean  sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave1.fsdb -cm assert_enable_coverage=1 -cm_dir ./router_cov1 +ntb_random_seed_automatic +UVM_TESTNAME=base_test 
	urg -dir router_cov1.vdb -format both -report urgReport1
	
run_test01_VCS: sv_cmp_VCS	
	./simv -a vcs.log +fsdbfile+wave2.fsdb -cm assert_enable_coverage=1 -cm_dir ./router_cov2 +ntb_random_seed_automatic +UVM_TESTNAME=test_1 
	urg -dir router_cov2.vdb -format both -report urgReport2
	
run_test02_VCS:	sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave3.fsdb -cm assert_enable_coverage=1 -cm_dir ./router_cov3 +ntb_random_seed_automatic +UVM_TESTNAME=test_2 
	urg -dir router_cov3.vdb -format both -report urgReport3
	
run_test03_VCS:	sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave4.fsdb -cm assert_enable_coverage=1 -cm_dir ./router_cov4 +ntb_random_seed_automatic +UVM_TESTNAME=test_3 
	urg -dir router_cov4.vdb -format both -report urgReport4

run_test11_VCS: sv_cmp_VCS	
	./simv -a vcs.log +fsdbfile+wave5.fsdb -cm assert_enable_coverage=1 -cm_dir ./router_cov5 +ntb_random_seed_automatic +UVM_TESTNAME=small_pkt_test_1 
	urg -dir router_cov5.vdb -format both -report urgReport5
	
run_test12_VCS:	sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave6.fsdb -cm assert_enable_coverage=1 -cm_dir ./router_cov6 +ntb_random_seed_automatic +UVM_TESTNAME=medium_pkt_test_1 
	urg -dir router_cov6.vdb -format both -report urgReport6
	
run_test13_VCS:	sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave7.fsdb -cm assert_enable_coverage=1 -cm_dir ./router_cov7 +ntb_random_seed_automatic +UVM_TESTNAME=big_pkt_test_1 
	urg -dir router_cov7.vdb -format both -report urgReport7

run_test21_VCS: sv_cmp_VCS	
	./simv -a vcs.log +fsdbfile+wave8.fsdb -cm assert_enable_coverage=1 -cm_dir ./router_cov8 +ntb_random_seed_automatic +UVM_TESTNAME=small_pkt_test_2 
	urg -dir router_cov8.vdb -format both -report urgReport8
	
run_test22_VCS:	sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave9.fsdb -cm assert_enable_coverage=1 -cm_dir ./router_cov9 +ntb_random_seed_automatic +UVM_TESTNAME=medium_pkt_test_2 
	urg -dir router_cov9.vdb -format both -report urgReport9
	
run_test23_VCS:	sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave10.fsdb -cm assert_enable_coverage=1 -cm_dir ./router_cov10 +ntb_random_seed_automatic +UVM_TESTNAME=big_pkt_test_2 
	urg -dir router_cov10.vdb -format both -report urgReport10

run_test_err_VCS: sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave11.fsdb -cm assert_enable_coverage=1 -cm_dir ./router_cov11 +ntb_random_seed_automatic +UVM_TESTNAME=error_test 
	urg -dir router_cov11.vdb -format both -report urgReport11

run_test_mt_VCS: sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave12.fsdb -cm assert_enable_coverage=1 -cm_dir ./router_cov12 +ntb_random_seed_automatic +UVM_TESTNAME=moretime_pkt_test 
	urg -dir router_cov12.vdb -format both -report urgReport12

	
view_wave1_VCS: 
	verdi -ssf wave1.fsdb
	
view_wave2_VCS: 
	verdi -ssf wave2.fsdb

view_wave3_VCS: 
	verdi -ssf wave3.fsdb

view_wave4_VCS: 
	verdi -ssf wave4.fsdb	

view_wave5_VCS: 
	verdi -ssf wave5.fsdb
	
view_wave6_VCS: 
	verdi -ssf wave6.fsdb

view_wave7_VCS: 
	verdi -ssf wave7.fsdb

view_wave8_VCS: 
	verdi -ssf wave8.fsdb	

view_wave9_VCS: 
	verdi -ssf wave9.fsdb
	
view_wave10_VCS: 
	verdi -ssf wave10.fsdb

view_wave11_VCS: 
	verdi -ssf wave11.fsdb	

view_wave12_VCS: 
	verdi -ssf wave12.fsdb	
	
report_VCS:
	urg -dir router_cov1.vdb router_cov2.vdb router_cov3.vdb router_cov4.vdb router_cov5.vdb router_cov6.vdb router_cov7.vdb router_cov8.vdb router_cov9.vdb router_cov10.vdb router_cov11.vdb router_cov12.vdb -dbname merged_dir/merged_test -format both -report urgReport

regress_VCS: clean_VCS sv_cmp_VCS run_test_VCS run_test01_VCS run_test02_VCS run_test03_VCS run_test11_VCS run_test12_VCS run_test13_VCS run_test21_VCS run_test22_VCS run_test23_VCS run_test_err_VCS run_test_mt_VCS report_VCS

cov_VCS:
	verdi -cov -covdir merged_dir.vdb

clean_VCS:
	rm -rf simv* csrc* *.tmp *.vpd *.vdb *.key *.log *hdrs.h urgReport* *.fsdb novas* verdi*
	clear

# ----------------------------- END of Definitions for Synopsys's VCS Specific Targets -------------------------------
