################################################################################
#   Copyright (c) 2010-2011 Bryce Lelbach
#
#   Distributed under the Boost Software License, Version 1.0.
#   Full text: http://www.boost.org/LICENSE_1_0.txt.
################################################################################

SHELL=/bin/sh

ifndef LINUXDIR
  RUNNING_REL := $(shell uname -r)

  LINUXDIR := $(shell if [ -e /lib/modules/$(RUNNING_REL)/source ]; then \
		 echo /lib/modules/$(RUNNING_REL)/source; \
		 else echo /lib/modules/$(RUNNING_REL)/build; fi)
endif

obj-m             += nvidia.o

nvidia-objs       := src/nv-acpi.o        \
                     src/nv.o             \
                     src/nv-gvi.o         \
                     src/nv-i2c.o         \
                     src/nv-vm.o          \
                     src/os-agp.o         \
                     src/os-interface.o   \
                     src/os-registry.o

EXTRA_CFLAGS      := -I$(M)/include                     \
                     -D__KERNEL__                       \
                     -DMODULE                           \
                     -DNVRM                             \
                     -DNV_VERSION_STRING=\"260.19.44\"  \
                     -mcmodel=kernel                    \
                     -mno-red-zone

ifeq ($(shell echo $(NVDEBUG)),1)
  EXTRA_CLFAGS    += -DDEBUG -g
else 
  EXTRA_CLFAGS    += -UDEBUG -U_DEBUG -DNDEBUG
endif

ifeq ($(CONFIG_X86_64),y)
  EXTRA_LDFLAGS   := $(M)/bin/nv-kernel.x86_64.bin
else
  EXTRA_LDFLAGS   := $(M)/bin/nv-kernel.x86_32.bin
endif

all:
	KBUILD_NOPEDANTIC=1 make -C $(LINUXDIR) M=`pwd` modules

clean:
	KBUILD_NOPEDANTIC=1 make -C $(LINUXDIR) M=`pwd` clean

install:
	KBUILD_NOPEDANTIC=1 make -C $(LINUXDIR) M=`pwd` modules_install

