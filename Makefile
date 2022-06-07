# /***********************************************************************#
# * @file    Makefile                                                     #
# * @brief   mk file                                                      #
# * @history                                                              #
# * Date       Version Author    description                              #
# * ========== ======= ========= =========================================#
# * 2018-07-06 V1.0    weihui.jia   Create                                #
# *                                                                       #
# * @Copyright (C)  2018  originl.Co.Ltd all right reserved               #
#************************************************************************/#
# /*@{*/

VERSION = 1
SUBLEVEL = 0
PATCHLEVEL = 0
EXTRAVERSION = -rc1

#CROSS_COMPILE = 
ARCH = i386
AS 	= $(CROSS_COMPILE)as
LD 	= $(CROSS_COMPILE)ld
CC 	= $(CROSS_COMPILE)g++
CPP = $(CC) -E
AR 	= $(CROSS_COMPILE)ar
NM 	= $(CROSS_COMPILE)nm

STRIP 	= $(CROSS_COMPILE)strip
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

BUILD_DIR = bin
VERSION_DIR = version

TARGET := md5_calc
TARGET_PREFIX := $(shell echo $(TARGET) | tr [a-z] [A-Z])

export AS LD CC CPP AR NM
export STRIP OBJCOPY OBJDUMP


CFLAGS :=  -Wall -O2 -g -std=gnu99 -g -I $(shell pwd)/version -I $(shell pwd)/md5_calc/include

ifeq (i386,$(ARCH))
	CFLAGS += -I $(shell pwd)/3rds/i386/include/bsl 
	LDFLAGS := -lm -lbsl  -lrt -ldl -lpthread -lstdc++ 
#-lmysqlclient 
endif

ifeq (hisiv3536,$(ARCH))
	CFLAGS += -I $(shell pwd)/3rds/i386/  -I $(shell pwd)/3rds/hisi3536/bsl/include/
	LDFLAGS := -L $(shell pwd)/3rds/hisi3536/bsl/lib/
	LIB += -lm -lbsl -lrt -lpthread
endif

ifeq (hisiv3531,$(ARCH))
	CFLAGS += -I $(shell pwd)/src/include -I $(shell pwd)/3rds/hisi3531/bsl/include/
	LDFLAGS := -L $(shell pwd)/3rds/hisi3531/bsl/lib/
	LIB += -lm -lbsl -lrt -lpthread
endif

export CFLAGS LDFLAGS LIB

TOPDIR := $(shell pwd)
export TOPDIR

ifneq "$(SUBLEVEL)" ""
	$(TARGET_PREFIX)_VERSION = $(VERSION).$(SUBLEVEL).$(PATCHLEVEL).$(shell date +"%Y%m%d")  #$(shell date +"%Y%M%d %H%M%S")      #$(EXTRAVERSION)
else
	$(TARGET_PREFIX)_VERSION = $(VERSION).$(PATCHLEVEL)$(EXTRAVERSION)
endif

VERSION_FILE := version.h

obj-y += md5_check/
obj-y += md5_calc/

all: $(VERSION_FILE)
	$(shell [ -d ${BUILD_DIR} ] || mkdir -p $(BUILD_DIR))
	make -C ./  -f $(TOPDIR)/Makefile.build
	$(CC) $(LDFLAGS) -o $(shell pwd)/$(BUILD_DIR)/$(TARGET) built-in.o  $(LDFLAGS) $(LIB) 
	@echo "$(TARGET) run in $(ARCH) platform  compiled success."

.PHONY:
$(VERSION_FILE):  
	$(shell [ -d ${VERSION_DIR} ] || mkdir -p $(VERSION_DIR)) 
	@echo $(TARGET_PREFIX)  $($(TARGET_PREFIX)_VERSION)
	@echo "/***********************************************************************" > $(VERSION_DIR)/$@ 
	@echo " * @file      version.h" >> $(VERSION_DIR)/$@ 
	@echo " * @brief     h file" >> $(VERSION_DIR)/$@ 
	@echo " * @history" >> $(VERSION_DIR)/$@ 
	@echo " * Date       Version Author    description" >> $(VERSION_DIR)/$@ 
	@echo " * ========== ======= ========= =======================================" >> $(VERSION_DIR)/$@ 
	@date +' * %Y-%m-%d V$(VERSION).$(SUBLEVEL).$(PATCHLEVEL).$(EXTRAVERSION)  weihui.jia   Create' >> $(VERSION_DIR)/$@
	@echo " *" >> $(VERSION_DIR)/$@ 
	@echo " * @Copyright (C)  2020  dixin.Co.Ltd all right reserved" >>$(VERSION_DIR)/$@
	@echo "***********************************************************************/" >> $(VERSION_DIR)/$@ 
	@echo "/*@{*/" >> $(VERSION_DIR)/$@ 
	@echo "" >> $(VERSION_DIR)/$@
	@echo "" >> $(VERSION_DIR)/$@
	@echo "#ifndef __VERSION_H" >> $(VERSION_DIR)/$@
	@echo "#define __VERSION_H" >> $(VERSION_DIR)/$@
	@echo "" >> $(VERSION_DIR)/$@
	@echo "#ifdef __cplusplus" >> $(VERSION_DIR)/$@
	@echo "extern \"C\" {" >> $(VERSION_DIR)/$@
	@echo "#endif" >> $(VERSION_DIR)/$@
	@echo "" >> $(VERSION_DIR)/$@
	@(printf '#define $(TARGET_PREFIX)_VERSION "$(TARGET) %s "\n' "$($(TARGET_PREFIX)_VERSION)") >> $(VERSION_DIR)/$@
	@date +'#define $(TARGET_PREFIX)_DATE  "%b %d %C%y"' >> $(VERSION_DIR)/$@
	@date +'#define $(TARGET_PREFIX)_TIME "%T"' >> $(VERSION_DIR)/$@
	@echo \#define $(TARGET_PREFIX)_COMPILE_BY \"`whoami`\" >> $(VERSION_DIR)/$@
	@echo \#define $(TARGET_PREFIX)_COMPILE_HOST \"`hostname`\" >> $(VERSION_DIR)/$@
	@echo "" >> $(VERSION_DIR)/$@
	@echo "const char version_string[] = $(TARGET_PREFIX)_VERSION \" \" $(TARGET_PREFIX)_COMPILE_BY \"@\" $(TARGET_PREFIX)_COMPILE_HOST\" (\" $(TARGET_PREFIX)_DATE \" - \" $(TARGET_PREFIX)_TIME \")\";" >> $(VERSION_DIR)/$@
	@echo "" >> $(VERSION_DIR)/$@
	@echo "#ifdef __cplusplus" >> $(VERSION_DIR)/$@
	@echo "}" >> $(VERSION_DIR)/$@
	@echo "#endif" >> $(VERSION_DIR)/$@
	@echo "" >> $(VERSION_DIR)/$@
	@echo "#endif" >> $(VERSION_DIR)/$@
	@echo "" >> $(VERSION_DIR)/$@

.PHONY:
clean:
	rm -f $(rm shell find -name "*.o")
	rm -f $(shell pwd)/bin/$(TARGET)

distclean:
	rm -f $(shell find -name "*.o")
	rm -f $(shell find -name "*.d")
	rm -f $(shell pwd)/bin/$(TARGET)
	rm -f $(shell pwd)/bin/all
	rm -rf $(shell pwd)/$(VERSION_DIR)			
