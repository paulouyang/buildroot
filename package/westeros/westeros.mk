################################################################################
#
# westeros
#
################################################################################

WESTEROS_VERSION = d89b9b1a26d39e073a42e8d792cbd840c4757a45
WESTEROS_SITE_METHOD = git
WESTEROS_SITE = git://github.com/rdkcmf/westeros
WESTEROS_INSTALL_STAGING = YES
WESTEROS_AUTORECONF = YES
WESTEROS_AUTORECONF_OPTS = "-Icfg"

WESTEROS_DEPENDENCIES = host-pkgconf host-autoconf wayland \
	libxkbcommon westeros-simpleshell westeros-simplebuffer westeros-soc

WESTEROS_CONF_OPTS = \
	--prefix=/usr/ \
	--enable-app=yes \
	--enable-test=yes \
	--enable-rendergl=yes \
	--enable-sbprotocol=yes


ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
	WESTEROS_CONF_OPTS += \
		--enable-xdgv4=yes
	WESTEROS_CONF_ENV += CXXFLAGS="$(TARGET_CXXFLAGS) -DWESTEROS_PLATFORM_RPI -DWESTEROS_INVERTED_Y -DBUILD_WAYLAND -I${STAGING_DIR}/usr/include/interface/vmcs_host/linux"
	WESTEROS_LDFLAGS += -lEGL -lGLESv2 -lbcm_host
else ifeq ($(BR2_PACKAGE_HAS_NEXUS),y)
	WESTEROS_CONF_OPTS += \
		--enable-xdgv4=yes
	WESTEROS_CONF_ENV += CXXFLAGS="$(TARGET_CXXFLAGS) -I${STAGING_DIR}/usr/include/refsw"
else ifeq ($(BR2_PACKAGE_LIBDRM),y)
	WESTEROS_CONF_OPTS += \
		--enable-xdgv5=yes
	WESTEROS_CONF_ENV += CXXFLAGS="$(TARGET_CXXFLAGS) -DWESTEROS_PLATFORM_DRM -I${STAGING_DIR}/usr/include/interface/vmcs_host/linux"
endif # BR2_PACKAGE_WESTEROS_SOC_RPI


WESTEROS_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	ARCH=$(KERNEL_ARCH) \
	PREFIX="$(TARGET_DIR)" \
	EXTRA_LDFLAGS="$(WESTEROS_LDFLAGS)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	CONFIG_PREFIX="$(TARGET_DIR)" \


define WESTEROS_RUN_AUTOCONF
	mkdir -p $(@D)/cfg
endef
WESTEROS_PRE_CONFIGURE_HOOKS += WESTEROS_RUN_AUTOCONF


define WESTEROS_BUILD_CMDS
	SCANNER_TOOL=${HOST_DIR}/usr/bin/wayland-scanner \
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/protocol
	$(WESTEROS_MAKE_OPTS) \
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(WESTEROS_LDFLAGS)
endef

define WESTEROS_INSTALL_STAGING_CMDS
	$(MAKE1) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

define WESTEROS_INSTALL_TARGET_CMDS
	$(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(autotools-package))
