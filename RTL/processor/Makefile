MODULE_NAME :=  singleCycle

VFLAG := +acc -2008
SFLAG := 


MODULE_PATH     := ./module
TEST_PATH 	    := ./testbench

LIB_PATH 	    := ../../lib/module_lib
TOOL_PATH		:= ../../lib/tb_tool

# Compiler
VCC  := vcom
VLIB := vlib
VMAP := vmap
VSIM := vsim


# 
MODULE    = $(wildcard $(MODULE_PATH)/*.vhd)
TEST      = $(wildcard $(TEST_PATH)/*.vhd)
TOOL 	  = $(wildcard $(TOOL_PATH)/*.vhd) 
TOP       = $(strip $(patsubst %.vhd, %, $(notdir $(TEST))))  # For simulation
OBJ 	  = $(patsubst %.vhd, %.o, $(MODULE))	
SIMMODULE = $(addprefix $(MODULE_NAME), $(patsubst %.vhd, %,  $(notdir $(MODULE))))

### TODO
INCLUDE_LIB 	+= -c flipflop $(LIB_PATH)/flipflop_lib \
				   -c simMem $(LIB_PATH)/simMem_lib \
				   -c regMem $(LIB_PATH)/regMem_lib

SIM_LIB         += $(INCLUDE_LIB) $(LIB_PATH)/$(MODULE_NAME)_lib
###




#$(info $(MODULE))
#$(info $(TEST))
#$(info $(TOP))
#$(info $(OBJ))
#$(info $(SIMMODULE))
$(info $(TOOL))


#VLIB = ./work

all: 	compile

#test:
#	vsim -c -do "run -All" $(TOP)

sim:
	$(VSIM) $(SFLAG) $(TOP) $(SIMMODULE) 
	

clean:
	rm -f *~ Avlog.dmp transcript *.ini
	rm -rf work
	rm -rf $(LIB_PATH)/$(MODULE_NAME)_lib ./$(MODULE_NAME)_lib 


compile:
	$(VMAP) flipflop $(LIB_PATH)/flipflop_lib
	$(VMAP)	simMem $(LIB_PATH)/simMem_lib
	$(VMAP) regMem $(LIB_PATH)/regMem_lib
	$(VMAP) ALU $(LIB_PATH)/ALU_lib
	$(VMAP) MipsEncode $(LIB_PATH)/MipsEncode_lib

	$(VCC) $(VFLAG) $(MODULE) $(TOOL) -work work
	$(VLIB) $(LIB_PATH)/$(MODULE_NAME)_lib
	$(VMAP) $(LIB_PATH)/$(MODULE_NAME)_lib work
	$(VCC) $(VFLAG) $(TEST) $(TOOL) -nocreatelib
