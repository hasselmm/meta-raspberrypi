HAS_X11 = "${@base_contains('DISTRO_FEATURES', 'x11', 1, 0, d)}"

PACKAGECONFIG_GL_raspberrypi = "gles2"
PACKAGECONFIG_append_raspberrypi = " tslib icu examples"

do_configure_prepend_raspberrypi() {
    platform_dir="${S}/mkspecs/linux-oe-g++"
    platform_config="${platform_dir}/qmake.conf"

    # The load() directive must be the last line of the qmake.conf.
    # Therefore we drop it for now.
    sed -i '/load(qt_config)/d' "${platform_config}"

    # Copy the Raspberry Pi's platform hooks to our platform dir
    cp "${S}/mkspecs/devices/linux-rasp-pi-g++/qeglfshooks_pi.cpp" "${platform_dir}"

    # Add some more settings to the qmake.conf
    cat >> "${platform_config}" << EOF
QMAKE_INCDIR_EGL        = \$\$[QT_SYSROOT]${includedir}/interface/vcos/pthreads \
                          \$\$[QT_SYSROOT]${includedir}/interface/vmcs_host/linux
QMAKE_INCDIR_OPENGL_ES2 = \$\${QMAKE_INCDIR_OPENGL_ES2}

EGLFS_PLATFORM_HOOKS_SOURCES = \$\$PWD/qeglfshooks_pi.cpp
EGLFS_PLATFORM_HOOKS_LIBS    = -lbcm_host


QMAKE_LIBS_EGL        += -lEGL -lGLESv2
QMAKE_LIBS_OPENGL_ES2 += -lEGL -lGLESv2
QMAKE_LIBS_OPENVG     += -lEGL -lOpenVG

load(qt_config)
EOF

}

qmake5_base_do_configure_prepend_raspberrypi() {
    # Prevent that qmodule.pri overrides our platform definition
    sed -i '/^QMAKE_\(CFLAGS\|INCDIR\|LIBDIR\)_\(EGL\|OPENGL_ES2\)\s*=/d' mkspecs/qmodule.pri
}

