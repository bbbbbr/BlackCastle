SHELL := /bin/bash

# If you move this project you can change the directory
# to match your GBDK root directory (ex: GBDK_HOME = "C:/GBDK/"
ifndef GBDK_HOME
GBDK_HOME = ../../gbdk-2020/build/gbdk/
endif
LCC = $(GBDK_HOME)bin/lcc
GBCOMP = $(GBDK_HOME)bin/gbcompress

# Set platforms to build here, spaced separated. (These are in the separate Makefile.targets)
# They can also be built/cleaned individually: "make gg" and "make gg-clean"
# Possible are: gb gbc pocket sms gg
TARGETS=nes gb megaduck gg sms pocket

# Configure platform specific LCC flags here:
LCCFLAGS_gb      = -Wl-yt0x19 -Wm-yn"$(PROJECTNAME)"
LCCFLAGS_pocket  = -Wl-yt0x19 -Wm-yn"$(PROJECTNAME)"
LCCFLAGS_duck    = -Wl-yt0x19 -Wm-yn"$(PROJECTNAME)"
LCCFLAGS_sms     = 
LCCFLAGS_gg      =
LCCFLAGS_nes     = -Wb-min=0

LCCFLAGS += $(LCCFLAGS_$(EXT)) # This adds the current platform specific LCC Flags

ifndef SM83_CART_32K
LCCFLAGS += -Wm-yoA -autobank -Wb-ext=.rel # MBC + Autobanking related flags
endif

LCCFLAGS += -Wl-j -Wl-w -Wm-yS
LCCFLAGS += -debug      # Uncomment to enable debug output
LCCFLAGS += -v -Wb-v    # Uncomment for lcc verbose output
LCCFLAGS += -Wl-u

CFLAGS = -Wf-Iinclude -Wf-MMD
CFLAGS += -debug

ifdef SM83_CART_32K
CFLAGS += -Wf-DSM83_CART_32K
# CFLAGS += -Wf--max-allocs-per-node500000

# Remove MBC from flags
LCCFLAGS_gb      =  -Wm-yn"$(PROJECTNAME)"
LCCFLAGS_pocket  =  -Wm-yn"$(PROJECTNAME)"
LCCFLAGS_duck    =  -Wm-yn"$(PROJECTNAME)"
endif

# You can set the name of the ROM file here
PROJECTNAME = blackcastle

# EXT?=gb # Only sets extension to default (game boy .gb) if not populated
SRCDIR      = src
SRCPLAT     = src/$(PORT)
OBJDIR      = obj/$(EXT)$(CARTTYPE)
RESDIR      = res
BINDIR      = build/$(EXT)$(CARTTYPE)
MKDIRS      = $(OBJDIR) $(BINDIR) # See bottom of Makefile for directory auto-creation

BINS	    = $(OBJDIR)/$(PROJECTNAME).$(EXT)
CSOURCES    = $(foreach dir,$(SRCDIR),$(notdir $(wildcard $(dir)/*.c))) $(foreach dir,$(SRCPLAT),$(notdir $(wildcard $(dir)/*.c))) $(foreach dir,$(RESDIR),$(notdir $(wildcard $(dir)/*.c)))
ASMSOURCES  = $(foreach dir,$(SRCDIR),$(notdir $(wildcard $(dir)/*.s))) $(foreach dir,$(SRCPLAT),$(notdir $(wildcard $(dir)/*.s)))
OBJS        = $(CSOURCES:%.c=$(OBJDIR)/%.o) $(ASMSOURCES:%.s=$(OBJDIR)/%.o)

# Dependencies
DEPS = $(OBJS:%.o=%.d)

-include $(DEPS)

# Builds all targets sequentially
all: $(TARGETS)

32k:
	${MAKE} build-target PORT=sm83 PLAT=duck EXT=duck SM83_CART_32K=yes CARTTYPE=_32k
	${MAKE} build-target PORT=sm83 PLAT=gb   EXT=gb   SM83_CART_32K=yes CARTTYPE=_32k

clean32k:
	${MAKE} clean-target PORT=sm83 PLAT=duck EXT=duck SM83_CART_32K=yes CARTTYPE=_32k
	${MAKE} clean-target PORT=sm83 PLAT=gb   EXT=gb   SM83_CART_32K=yes CARTTYPE=_32k

compressassets:
	$(GBCOMP) -v $(RESDIR)/title_map.bin           $(RESDIR)/title_map.bin.gbcomp
	$(GBCOMP) -v $(RESDIR)/title_bg.chr            $(RESDIR)/title_bg.chr.gbcomp
	$(GBCOMP) -v $(RESDIR)/font_tiles.chr          $(RESDIR)/font_tiles.chr.gbcomp
	$(GBCOMP) -v $(RESDIR)/level1_tiles.chr        $(RESDIR)/level1_tiles.chr.gbcomp
	$(GBCOMP) -v $(RESDIR)/level_1_4_map_meta.bin  $(RESDIR)/level_1_4_map_meta.bin.gbcomp
	$(GBCOMP) -v $(RESDIR)/level_1_3_map_meta.bin  $(RESDIR)/level_1_3_map_meta.bin.gbcomp
	$(GBCOMP) -v $(RESDIR)/level_1_2_map_meta.bin  $(RESDIR)/level_1_2_map_meta.bin.gbcomp
	$(GBCOMP) -v $(RESDIR)/level_1_1_map_meta.bin  $(RESDIR)/level_1_1_map_meta.bin.gbcomp
	$(GBCOMP) -v $(RESDIR)/level1_tiles.chr        $(RESDIR)/level1_tiles.chr.gbcomp
	$(GBCOMP) -v $(RESDIR)/sprite_tiles_noflip.chr $(RESDIR)/sprite_tiles_noflip.chr.gbcomp
	$(GBCOMP) -v $(RESDIR)/sprite_tiles_flip.chr   $(RESDIR)/sprite_tiles_flip.chr.gbcomp
	$(GBCOMP) -v $(RESDIR)/sprite_tiles_bosses.chr $(RESDIR)/sprite_tiles_bosses.chr.gbcomp
	$(GBCOMP) -v $(RESDIR)/hud_tiles_nofont.chr    $(RESDIR)/hud_tiles_nofont.chr.gbcomp
	# mark files that include these assets for rebuild
	touch $(SRCDIR)/data.c
	touch $(SRCDIR)/title_data.c
	touch $(SRCDIR)/data_level1.c


# Compile .c files in "src/" to .o object files
$(OBJDIR)/%.o:	$(SRCDIR)/%.c
	$(LCC) $(CFLAGS) -c -o $@ $<

# Compile .c files in "src/<target>/" to .o object files
$(OBJDIR)/%.o:	$(SRCPLAT)/%.c
	$(LCC) $(CFLAGS) -c -o $@ $<

# Compile .c files in "res/" to .o object files
$(OBJDIR)/%.o:	$(RESDIR)/%.c
	$(LCC) $(CFLAGS) -c -o $@ $<

# Compile .s assembly files in "src/<target>/" to .o object files
$(OBJDIR)/%.o:	$(SRCPLAT)/%.s
	$(LCC) $(CFLAGS) -c -o $@ $<

# Compile .s assembly files in "src/" to .o object files
$(OBJDIR)/%.o:	$(SRCDIR)/%.s
	$(LCC) $(CFLAGS) -c -o $@ $<

# If needed, compile .c files i n"src/" to .s assembly files
# (not required if .c is compiled directly to .o)
$(OBJDIR)/%.s:	$(SRCDIR)/%.c
	$(LCC) $(CFLAGS) -S -o $@ $<

# Link the compiled object files into a .gb ROM file
$(BINS):	$(OBJS)
	$(LCC) $(LCCFLAGS) $(CFLAGS) -o $(BINDIR)/$(PROJECTNAME).$(EXT) $(OBJS)

clean:
	@echo Cleaning
	@for target in $(TARGETS); do \
		$(MAKE) $$target-clean; \
	done

# Include available build targets
include Makefile.targets


# create necessary directories after Makefile is parsed but before build
# info prevents the command from being pasted into the makefile
ifneq ($(strip $(EXT)),)           # Only make the directories if EXT has been set by a target
$(info $(shell mkdir -p $(MKDIRS)))
endif
