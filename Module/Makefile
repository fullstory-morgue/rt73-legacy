###########################################################################
# RT2400/RT2500 SourceForge Project - http://rt2x00.serialmonkey.com      #
#                                                                         #
#   This program is free software; you can redistribute it and/or modify  #
#   it under the terms of the GNU General Public License as published by  #
#   the Free Software Foundation; either version 2 of the License, or     #
#   (at your option) any later version.                                   #
#                                                                         #
#   This program is distributed in the hope that it will be useful,       #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#   GNU General Public License for more details.                          #
#                                                                         #
#   You should have received a copy of the GNU General Public License     #
#   along with this program; if not, write to the                         #
#   Free Software Foundation, Inc.,                                       #
#   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
#                                                                         #
#   Licensed under the GNU GPL                                            #
#   Original code supplied under license from RaLink Inc, 2004.           #
###########################################################################

###########################################################################
#      Module Name: Makefile
#
#      Abstract: Makefile for rt73 kernel module
#
#      Revision History:
#      Who             When             What
#      --------        -----------      -----------------------------
#      MarkW (rt2500)  21st Jan 06      Rewrite of Makefile
#      Amir S (rt2500) 2nd  Feb 06      Update for gmake compat
#      MarkW (rt2500)  3rd  Feb 06      Fixed permissions on directory
#      MichaIL(rt2500) 13th Feb 06      Module installation fixes
#      MarkW (rt2500)  13th Feb 06      Allow install dir override
#      OlivierC        14th May 07      Install firmware file
#      OlivierC        14th May 07      Check old config
###########################################################################



MODULE_NAME := rt73
IF_NAME :=     wlan*

FIRMWARES :=   rt73.bin
FIRM_DIR :=    /lib/firmware

OLD_IF_NAME := ra0
CONFIG_DIR :=  /etc/Wireless/RT73STA
CONFIG_FILE := rt73sta.dat

ifeq ($(PATCHLEVEL),)
 PATCHLEVEL := $(shell uname -r | cut -d. -f2)
endif

$(MODULE_NAME)-objs :=  rtmp_main.o mlme.o connect.o rtusb_bulk.o rtusb_io.o \
			sync.o assoc.o auth.o auth_rsp.o rtusb_data.o \
			rtmp_init.o  sanity.o rtmp_wep.o rtmp_info.o \
			rtmp_tkip.o wpa.o md5.o rt2x00debug.o

ifdef TOPDIR
obj-m += $(MODULE_NAME).o
endif

EXTRA_CFLAGS += -I$(src)
EXTRA_CFLAGS += -DAGGREGATION_SUPPORT -DWMM_SUPPORT
#EXTRA_CFLAGS += -DRALINK_ATE
#EXTRA_CFLAGS += -DSINGLE_ADHOC_LINKUP

ifdef KERNDIR
 KERNEL_SOURCES := $(KERNDIR)
else
 KERNEL_SOURCES := /lib/modules/$(shell uname -r)/build
endif

ifdef MODDIR
 MODULE_ROOT := $(MODDIR)
else
 MODULE_ROOT := /lib/modules/$(shell uname -r)/extra
endif

ifdef KERNOUT
 KERNEL_OUTPUT := KBUILD_OUTPUT=$(KERNOUT)
else
 KERNEL_OUTPUT :=
endif

src ?= .
obj ?= .

ifeq ($(PATCHLEVEL), 4)
 MODULE_OBJECT := $(MODULE_NAME).o
 MODULE_CONF := /etc/modules.conf
else
 MODULE_OBJECT := $(MODULE_NAME).ko
 MODULE_CONF := /etc/modprobe.d/ralink
endif

all: module

ifeq ($(PATCHLEVEL), 4)
$(obj)/$(MODULE_NAME).o: $($(MODULE_NAME)-objs)
	$(LD) $(EXTRA_LDFLAGS) -r -o $@ $($(MODULE_NAME)-objs)
endif

KBUILD_PARAMS := -C $(KERNEL_SOURCES) SUBDIRS=$(CURDIR) $(KERNEL_OUTPUT)

MODULE_CHECK :=	if ! [ -f $(MODULE_OBJECT) ]; then \
			echo "$(MODULE_OBJECT) failed to build!"; \
			exit 1; \
		fi; \
		if [ `du -b $(MODULE_OBJECT) | sed -e 's/\t.*//g'` -gt 1000000 ]; then \
			echo "!!! WARNING: Module file much too big (>1MB)"; \
			echo "!!! Check your kernel settings or use 'strip'"; \
		fi; \
		echo "*** Module $(MODULE_OBJECT) built successfully"

module:
	@$(MAKE) $(KBUILD_PARAMS) 'EXTRA_CFLAGS=$(EXTRA_CFLAGS)' modules; \
	$(MODULE_CHECK)

arm:
	@$(MAKE) $(KBUILD_PARAMS) 'EXTRA_CFLAGS=-DRTMP_EMBEDDED \
					-I$(src)' modules; \
	$(MODULE_CHECK)

armdebug:
	@$(MAKE) $(KBUILD_PARAMS) 'EXTRA_CFLAGS=-DRTMP_EMBEDDED \
					-I$(src) -DDBG' modules; \
	$(MODULE_CHECK)


debug:
	@$(MAKE) $(KBUILD_PARAMS) 'EXTRA_CFLAGS=$(EXTRA_CFLAGS) \
					-DDBG' modules; \
	$(MODULE_CHECK)

debugfs:
	@$(MAKE) $(KBUILD_PARAMS) 'EXTRA_CFLAGS=$(EXTRA_CFLAGS) \
					-DDBG -DRT2X00DEBUGFS' modules; \
	$(MODULE_CHECK)

clean:
	@rm -f *.o .*.{cmd,flags}
	@rm -f $(MODULE_NAME).{o,ko,mod.{o,c}} built-in.o $(VERSION_HEADER) *~
	@rm -fr .tmp_versions Module.symvers

modules_install:
	@if ! [ -f $(MODULE_OBJECT) ]; then \
		echo "!!! $(MODULE_OBJECT) does not exist: run 'make'"; \
		exit 1; \
	fi
	@echo "*** Install module in $(MODULE_ROOT) ..."
ifeq ($(PATCHLEVEL),4)
	install -m 755 -o 0 -g 0 -d $(MODULE_ROOT)
	install -m 644 -o 0 -g 0 $(MODULE_OBJECT) $(MODULE_ROOT)
else
	@$(MAKE) $(KBUILD_PARAMS) modules_install
endif
	/sbin/depmod -a

install: modules_install
	@echo "*** Update $(MODULE_CONF) alias for $(IF_NAME)"; \
	if [ -d `dirname $(MODULE_CONF)` ]; then \
		if [ -s $(MODULE_CONF) ]; then \
			if ! grep -q '$(IF_NAME)' $(MODULE_CONF) ; then \
				echo "alias $(IF_NAME) $(MODULE_NAME)" >> $(MODULE_CONF) ; \
			fi; \
		else \
			echo "alias $(IF_NAME) $(MODULE_NAME)" >> $(MODULE_CONF) ; \
		fi; \
		if grep -q '$(OLD_IF_NAME)' $(MODULE_CONF) ; then \
			echo "!!! -> $(OLD_IF_NAME) interface name is deprecated:" \
						"remove old $(MODULE_CONF) alias"; \
		fi; \
	else \
		echo "*** Config dir `dirname $(MODULE_CONF)` not found" >&2; \
	fi
	@echo "*** Install firmware in $(FIRM_DIR) ..."; \
	if ! [ -d $(FIRM_DIR) ]; then \
		mkdir $(FIRM_DIR); \
	fi; \
	cp -f $(FIRMWARES) $(FIRM_DIR)
	@echo "*** Check old config ..."; \
	if [ -d $(CONFIG_DIR) ]; then \
		echo "!!!"; \
		echo "!!! WARNING: DEPRECATED CONFIG FOUND !"; \
		echo "!!!"; \
		echo "!!! -> Update your config and remove $(CONFIG_DIR)"; \
		if [ -f $(CONFIG_DIR)/$(CONFIG_FILE) ]; then \
			echo "!!! -> $(CONFIG_FILE) file is deprecated:" \
					"use iwconfig/iwpriv instead"; \
		fi; \
		if [ -f $(CONFIG_DIR)/$(FIRMWARES) ]; then \
			echo "!!! -> $(FIRMWARES) firmware has moved to $(FIRM_DIR)"; \
		fi; \
	fi

ifeq ($(PATCHLEVEL), 4)
include $(KERNEL_SOURCES)/Rules.make
endif
