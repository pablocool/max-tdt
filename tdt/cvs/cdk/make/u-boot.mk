#
# U-BOOT
#
HOST_U_BOOT := host-u-boot
HOST_U_BOOT_VERSION := sh4-1.3.1_stm24_0048-48
HOST_U_BOOT_RAWVERSION := $(HOST_U_BOOT_VERSION)
HOST_U_BOOT_DIR := u-boot/u-boot-sh4-$(word 2, $(subst -, ,$(HOST_U_BOOT_VERSION)))
HOST_U_BOOT_SPEC := stm-$(HOST_U_BOOT).spec
HOST_U_BOOT_SPEC_PATCH := uboot-1.3.1_spec_stm24.patch
HOST_U_BOOT_PATCHES := uboot-1.3.1_lzma_stm24.patch

HOST_U_BOOT_RPM := RPMS/noarch/$(STLINUX)-$(HOST_U_BOOT)-source-$(HOST_U_BOOT_VERSION).noarch.rpm

$(HOST_U_BOOT_RPM): \
		$(if $(HOST_U_BOOT_SPEC_PATCH),Patches/$(HOST_U_BOOT_SPEC_PATCH)) \
		$(if $(HOST_U_BOOT_PATCHES),$(HOST_U_BOOT_PATCHES:%=Patches/%)) \
		$(archivedir)/$(STLINUX)-$(HOST_U_BOOT)-source-$(HOST_U_BOOT_VERSION).src.rpm
	rpm $(DRPM) --nosignature -Uhv $(lastword $^) && \
	$(if $(HOST_U_BOOT_SPEC_PATCH),( cd SPECS && patch -p1 $(HOST_U_BOOT_SPEC) < $(buildprefix)/Patches/$(HOST_U_BOOT_SPEC_PATCH) ) &&) \
	$(if $(HOST_U_BOOT_PATCHES),cp $(HOST_U_BOOT_PATCHES:%=Patches/%) SOURCES/ &&) \
	export PATH=$(hostprefix)/bin:$(PATH) && \
	rpmbuild $(DRPMBUILD) -bb -v --clean --target=sh4-linux SPECS/$(HOST_U_BOOT_SPEC)

$(DEPDIR)/u-boot-utils.do_prepare: $(HOST_U_BOOT_RPM)
	@rpm $(DRPM) --ignorearch --nodeps -Uhv $< && \
	touch $@

### TO be fixed
$(DEPDIR)/u-boot-utils.do_compile: bootstrap $(DEPDIR)/u-boot-utils.do_prepare
#	cd $(HOST_U_BOOT_DIR) && \
#		$(MAKE) -C tools/env TOPDIR=$(buildprefix)/$(HOST_U_BOOT_DIR) ARCH=sh4 CROSS_COMPILE=$(target)- clean TARGETS=fw_printenv TARGETDIR=$(targetprefix) && \
#		$(MAKE) -C tools/env TOPDIR=$(buildprefix)/$(HOST_U_BOOT_DIR) ARCH=sh4 CROSS_COMPILE=$(target)- all TARGETS=fw_printenv TARGETDIR=$(targetprefix)
	touch $@

$(DEPDIR)/min-u-boot-utils $(DEPDIR)/std-u-boot-utils $(DEPDIR)/max-u-boot-utils \
$(DEPDIR)/u-boot-utils: \
$(DEPDIR)/%u-boot-utils: $(DEPDIR)/u-boot-utils.do_compile
#	$(INSTALL) -d $(prefix)/$*cdkroot/{etc,usr/sbin} && \
#	cd $(HOST_U_BOOT_DIR) && \
#		$(INSTALL) -m 755 tools/env/fw_printenv $(prefix)/$*cdkroot/usr/sbin && \
#		$(LN_SF) fw_printenv $(prefix)/$*cdkroot/usr/sbin/fw_setenv
#	$(INSTALL) -m 644 $(buildprefix)/root/etc/fw_env.config $(prefix)/$*cdkroot/etc/
	[ "x$*" = "x" ] && touch $@ || true

$(DEPDIR)/u-boot-utils: $(DEPDIR)/u-boot-utils.do_compile

#
# HOST-U-BOOT-TOOLS
#
HOST_U_BOOT_TOOLS := host-u-boot-tools
HOST_U_BOOT_TOOLS_VERSION := 1.3.1_stm24-8
HOST_U_BOOT_TOOLS_SPEC := stm-$(HOST_U_BOOT_TOOLS).spec
HOST_U_BOOT_TOOLS_SPEC_PATCH :=
HOST_U_BOOT_TOOLS_PATCHES :=

HOST_U_BOOT_TOOLS_RPM := RPMS/sh4/$(STLINUX)-$(HOST_U_BOOT_TOOLS)-$(HOST_U_BOOT_TOOLS_VERSION).sh4.rpm

$(HOST_U_BOOT_TOOLS_RPM): \
		$(if $(HOST_U_BOOT_TOOLS_SPEC_PATCH),Patches/$(HOST_U_BOOT_TOOLS_SPEC_PATCH)) \
		$(if $(HOST_U_BOOT_TOOLS_PATCHES),$(HOST_U_BOOT_TOOLS_PATCHES:%=Patches/%)) \
		$(archivedir)/$(STLINUX)-$(HOST_U_BOOT_TOOLS)-$(HOST_U_BOOT_TOOLS_VERSION).src.rpm
	rpm $(DRPM) --nosignature -Uhv $(lastword $^) && \
	rpm $(DRPM) --nosignature -Uhv $(lastword $^) && \
	$(if $(HOST_U_BOOT_TOOLS_SPEC_PATCH),( cd SPECS && patch -p1 $(HOST_U_BOOT_TOOLS_SPEC) < $(buildprefix)/Patches/$(HOST_U_BOOT_TOOLS_SPEC_PATCH) ) &&) \
	$(if $(HOST_U_BOOT_TOOLS_PATCHES),cp $(HOST_U_BOOT_TOOLS_PATCHES:%=Patches/%) SOURCES/ &&) \
	rpmbuild $(DRPMBUILD) -bb -v --clean --target=sh4-linux SPECS/$(HOST_U_BOOT_TOOLS_SPEC)

$(DEPDIR)/$(HOST_U_BOOT_TOOLS): u-boot-utils.do_prepare $(HOST_U_BOOT_TOOLS_RPM) | bootstrap-cross
	@rpm $(DRPM) --ignorearch --nodeps -Uhv $(lastword $^) && \
	touch $@
