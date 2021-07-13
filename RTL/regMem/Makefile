MODULE_NAME :=  regMem

VFLAG := +acc -2008
SFLAG := 

MODULE_PATH     := ./module
TEST_PATH 	    := ./testbench

LIB_PATH 	    := ../../lib/module_lib
TOOL_PATH		:= ../../lib/tb_tool

LIB_NAME += flipflop

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
INC_LIB 	+= $(LIB_PATH)/flipflop_lib

SIM_LIB     += $(INCLUDE_LIB) $(LIB_PATH)/$(MODULE_NAME)_lib
###




#$(info $(MODULE))
#$(info $(TEST))
#$(info $(TOP))
#$(info $(OBJ))
#$(info $(SIMMODULE))
#$(info $(TOOL))
$(info $(INC_LIB))

#VLIB = ./work
.PHONY : clean

all: 	compile

#test:
#	vsim -c -do "run -All" $(TOP)

sim:
	$(VSIM) $(SFLAG) $(TOP) $(SIMMODULE) -L  $(INC_LIB)
	

clean:
	rm -f *~ Avlog.dmp transcript *.ini
	rm -rf work
	rm -rf $(LIB_PATH)/$(MODULE_NAME)_lib ./$(MODULE_NAME)_lib 


compile :
	$(VMAP) flipflop $(INC_LIB) 
	$(VCC) $(VFLAG) $(MODULE) $(TOOL) -work $(LIB_PATH)/$(MODULE_NAME)_lib
	$(VMAP) $(MODULE_NAME) $(LIB_PATH)/$(MODULE_NAME)_lib
	$(VCC) $(VFLAG) $(TEST) $(TOOL)
 
 
