# Elaborate the v1 RTL. Run this from risc_boy_v1 in WSL:
#   make

TOP := MCU_WRAPPER
PKG := rtl/CPU/CPU_pkg.sv

# Package first. Verilator resolves imports in command-line order.
RTL := $(PKG) \
       $(filter-out $(PKG), \
         $(wildcard rtl/*.sv) $(wildcard rtl/*.v) \
         $(wildcard rtl/CPU/*.sv) $(wildcard rtl/CPU/*.v))

.PHONY: elaborate

elaborate:
	verilator --lint-only -Wall \
		--top-module $(TOP) \
		--language 1800-2017 \
		-Irtl -Irtl/CPU \
		$(RTL)
