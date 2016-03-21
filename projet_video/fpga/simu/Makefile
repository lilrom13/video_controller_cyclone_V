# Squelette de Makefile pour le projet Video
#
.PHONY: clean all simu_batch compile simu_gui info

# WORK_DIR est le répertoire de simulation
WORK_DIR = $(shell pwd)/work
# TOPDIR est le répertoire principal (le dépot git de vos travaux)
TOPDIR = $(shell pwd)/../..

# Le module top a simuler
TB_TOP = tb_fpga

#VPATH := ${TOPDIR} ${TOPDIR}/.. 


# Module sources
SRCDIR    = $(TOPDIR)/fpga/src
SRC       = $(wildcard $(SRCDIR)/*.sv)
DEP      += $(patsubst $(SRCDIR)/%.sv,$(WORK_DIR)/.%.compiled,${SRC})

# Module testbench sources
TBDIR     = $(TOPDIR)/fpga/tb_src
TBSRC     = $(wildcard $(TBDIR)/*.sv)
DEP      += $(patsubst $(TBDIR)/%.sv,$(WORK_DIR)/.%.compiled,${TBSRC})


info: 
	@echo "Les commandes possibles sont:"
	@echo "make compile    : compilation des codes (module à tester et testbenchs)"
	@echo "make simu_batch : simulation en mode terminal, avec simple affichage des résultats des tests"
	@echo "make simu_gui   : simulation en mode graphique pour faire un debug de votre code."
	@echo "make all        : équivalent à simu_gui"
	@echo "make info       : ce message"
	@echo "make clean      : nettoyage des fichiers inutiles"

all: simu_batch

simu_batch: compile
	cd $(WORK_DIR) ; vsim  -batch -t 1ps -lib work $(TB_TOP) -do "run -all ; quit"

simu_gui: compile
	cd $(WORK_DIR); vsim -t 1ps -lib work $(TB_TOP) 

compile: $(DEP) 

$(WORK_DIR)/.%.compiled: $(TBDIR)/%.sv | $(WORK_DIR)/work
	cd $(WORK_DIR) ; vlog  +acc $< 
	touch $@

$(WORK_DIR)/.%.compiled: $(SRCDIR)/%.sv | $(WORK_DIR)/work
	cd $(WORK_DIR) ; vlog  +acc $< 
	touch $@


$(WORK_DIR):
	mkdir $(WORK_DIR) 

$(WORK_DIR)/work: $(WORK_DIR)
	cd $(WORK_DIR) ; vlib work

clean:
	rm -rf $(WORK_DIR)

