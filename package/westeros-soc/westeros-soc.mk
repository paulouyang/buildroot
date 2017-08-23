################################################################################
#
# westeros-soc
#
################################################################################

WESTEROS_SOC_VERSION = d89b9b1a26d39e073a42e8d792cbd840c4757a45
WESTEROS_SOC_SITE_METHOD = git
WESTEROS_SOC_SITE = git://github.com/rdkcmf/westeros
WESTEROS_SOC_INSTALL_STAGING = YES
WESTEROS_SOC_AUTORECONF = YES
WESTEROS_SOC_AUTORECONF_OPTS = "-Icfg"

WESTEROS_SOC_DEPENDENCIES = host-pkgconf host-autoconf wayland libegl

ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
	WESTEROS_SOC_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -I ${STAGING_DIR}/usr/include/interface/vmcs_host/linux/"
	WESTEROS_SOC_SUBDIR = rpi
else ifeq ($(BR2_PACKAGE_HAS_NEXUS),y)
	WESTEROS_SOC_MAKE_ENV += \
		$(BCM_REFSW_MAKE_ENV) \
		PKG_CONFIG_SYSROOT_DIR=$(STAGING_DIR)
	WESTEROS_SOC_CONF_OPTS += \
		CFLAGS="$(TARGET_CFLAGS) -I ${STAGING_DIR}/usr/include/refsw/" \
		CXXFLAGS="$(TARGET_CXXFLAGS) -I ${STAGING_DIR}/usr/include/refsw/"
	WESTEROS_SOC_SUBDIR = brcm
	WESTEROS_SOC_DEPENDENCIES += bcm-refsw
else ifeq ($(BR2_PACKAGE_LIBDRM),y)
	WESTEROS_SOC_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -I $(STAGING_DIR)/usr/include/libdrm -DEGL_WINSYS_GBM=1 -lEGL -lGLESv2 -lmaliwlsrv"
	WESTEROS_SOC_SUBDIR = drm
	WESTEROS_SOC_DEPENDENCIES += libdrm
endif

define WESTEROS_SOC_RUN_AUTOCONF
	mkdir -p $(@D)/$(WESTEROS_SOC_SUBDIR)/cfg
endef
WESTEROS_SOC_PRE_CONFIGURE_HOOKS += WESTEROS_SOC_RUN_AUTOCONF

define WESTEROS_SOC_INSTALL_STAGING_CMDS
	$(MAKE1) -C $(@D)/$(WESTEROS_SOC_SUBDIR) PKG_CONFIG_SYSROOT_DIR=$(STAGING_DIR) DESTDIR=$(STAGING_DIR) install
endef

define WESTEROS_SOC_INSTALL_TARGET_CMDS
	$(MAKE1) -C $(@D)/$(WESTEROS_SOC_SUBDIR) PKG_CONFIG_SYSROOT_DIR=$(STAGING_DIR) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(autotools-package))
