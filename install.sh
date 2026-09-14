#!/data/data/com.termux/files/usr/bin/bash
#VNEmuREV6
#AerA
set -euo pipefail
TERMUX_PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

VNEMU_RAW="https://raw.githubusercontent.com/LuKazuu/VNEmu/main"
HANGOVER_TAG="hangover-wine-11.17-r42"
HANGOVER_BASE="https://github.com/LuKazuu/VNEmuWine/releases/download/${HANGOVER_TAG}"

termux-setup-storage
sleep 1

SHARED_DIR=~/storage/shared/Termux
mkdir -p "${SHARED_DIR}/layers" "${SHARED_DIR}/logs" "${SHARED_DIR}/turnip/wrapper" "${SHARED_DIR}/turnip/termux" "${SHARED_DIR}/dlls/system32" "${SHARED_DIR}/dlls/syswow64"

TEMPLATE_DIR="${TERMUX_PREFIX}/var/lib/vnemu-defaults"
mkdir -p "${TEMPLATE_DIR}"

cat > "${TEMPLATE_DIR}/desktop.txt" << 'INNER_EOF'
# BASIC
WINEDEBUG=-all
HODLL=libwow64fex.dll
# libwow64fex.dll / wowbox64.dll
LC_ALL=en_US.UTF-8
WINE_DDRAW_GDI_FALLBACK=1
# 0 / 1
WINE_DO_NOT_CREATE_DXGI_DEVICE_MANAGER=1
# 0 / 1
WINEVMEMMAXSIZE=4096
TZ=Asia/Tokyo
AUDIO_BACKEND=pulse
# pulse / alsa
PULSE_LATENCY_MSEC=45
# 30 / 45 / 60
WINESERVICES=1
# 0 / 1
CPU_TASKSET=all
# all / 0,1,2,3 / 4,5,6,7

# GPU
GPU_BACKEND=wrapper
# wrapper / termux
WRAPPER_DRIVER=system
# system / turnip
OPENGL_DRIVER=llvmpipe
# llvmpipe / zink
TU_DEBUG=noconform
# noconform / sysmem / gmem / etc.
WRAPPER_BCN=0
# 0 / 1 / 2
WRAPPER_USE_BCN_CACHE=0
# 0 / 1
WRAPPER_SURFACE_FORMAT=bgra8
# bgra8 / rgba8
WRAPPER_DISABLE_PRESENT_WAIT=1
# 0 / 1
WRAPPER_VK_VERSION=1.4
WRAPPER_EXTENSION_BLACKLIST=none
WRAPPER_VMEM_MAX_SIZE=4096
WRAPPER_RESOURCE_TYPE=auto
MESA_NO_ERROR=1
MESA_GL_VERSION_OVERRIDE=4.6
MESA_GLES_VERSION_OVERRIDE=3.2
MESA_VK_WSI_PRESENT_MODE=mailbox
ZINK_DESCRIPTORS=lazy
ZINK_DEBUG=compact
GALLIUM_THREAD=1
# 0 / 1

# HUD
GALLIUM_HUD=simple,fps
DXVK_HUD=fps
INNER_EOF

cat > "${TEMPLATE_DIR}/box64.txt" << 'INNER_EOF'
BOX64_DYNAREC_SAFEFLAGS=0
# 0: no flags on CALL/RET / 1: most RETs need flags [Default] / 2: all CALL/RET need flags

BOX64_DYNAREC_STRONGMEM=0
# 0: none [Default] / 1: basic barriers / 2: +SIMD barriers / 3: +more barriers / 4: mimic x86 TSO (QEMU-like)

BOX64_DYNAREC_FASTNAN=1
# 0: precise -NaN emulation / 1: fast, no special handling [Default]

BOX64_DYNAREC_FASTROUND=1
# 0: precise x86-like rounding / 1: fast, no special handling [Default] / 2: precise rounding + fast int↔float conversion

BOX64_DYNAREC_X87DOUBLE=0
# 0: use float when possible [Default] / 1: always use double / 2: check Precision Control

BOX64_DYNAREC=1
# 0: disable DynaRec / 1: enable DynaRec

BOX64_DYNAREC_WAIT=1
# 0: don't wait, use interpreter / 1: wait for block ready [Default]

BOX64_DYNAREC_ALIGNED_ATOMICS=0
# 0: unaligned atomics handling [Default] / 1: aligned atomics only (faster, may SIGBUS)

BOX64_DYNAREC_BIGBLOCK=2
# 0: small blocks (multithread/JIT-friendly) / 1: as big as possible / 2: bigger, elf memory only [Default] / 3: bigger, all memory types (Wine)

BOX64_DYNAREC_CALLRET=1
# 0: no optimize, use jump table / 1: optimize, skip jump table / 2: optimize + handle dirty/modified block return [Default]

BOX64_DYNAREC_WEAKBARRIER=0
# 0: regular safe barrier / 1: weak barriers, more performance [Default] / 2: weak barriers + disable last write barriers

BOX64_DYNAREC_PAUSE=0
# 0: ignore PAUSE [Default] / 1: use YIELD / 2: use WFI / 3: use SEVL+WFE

BOX64_DYNAREC_DF=1
# 0: disable deferred flags / 1: enable deferred flags [Default]

BOX64_DYNAREC_DIRTY=0
# 0: don't run unprotected/dirty block [Default] / 1: allow continue running (faster, riskier) / 2: also flag hot page as NEVERCLEAN

BOX64_DYNAREC_NATIVEFLAGS=1
# 0: don't use native flags / 1: use native flags when possible [Default]

BOX64_DYNAREC_VOLATILE_METADATA=1
# 0: don't use volatile metadata / 1: use volatile metadata from PE files [Default]

BOX64_DYNAREC_DIV0=0
# 0: don't generate divide-by-zero exception [Default] / 1: generate divide-by-zero exception

BOX64_RDTSC_1GHZ=0
# 0: use hardware counter if available [Default] / 1: use hardware counter only if precision ≥1GHz

BOX64_CPUTYPE=0
# 0: emulate Intel CPU [Default] / 1: emulate AMD CPU

BOX64_AVX=0
# 0: disable AVX / 1: expose AVX, BMI1, F16C, VAES / 2: + AVX2, BMI2, FMA, ADX, VPCLMULQDQ, RDRAND

BOX64_IGNOREINT3=0
# 0: trigger TRAP signal if handler present [Default] / 1: skip INT3 opcode silently
INNER_EOF

cat > "${TEMPLATE_DIR}/fexcore.txt" << 'INNER_EOF'
FEX_TSOENABLED=0
# 0: TSO memory ordering disabled (may break multithreaded apps, faster) / 1: TSO enabled [Default]

FEX_X87REDUCEDPRECISION=1
# 0: full x87 precision emulation [Default] / 1: reduced (64-bit) x87 precision, faster but less accurate

FEX_MULTIBLOCK=1
# 0: disable multiblock compilation / 1: enable multiblock compilation (faster JIT'd code, can cause longer compile stutter) [Default]

FEX_MAXINST=5000
# 0: unlimited instructions per block / XXXX: max instructions per block [Default: 5000]

FEX_SMALLTSCSCALE=1
# 0: no TSC scaling / 1: scale cycle counter on low-frequency systems [Default]

FEX_VECTORTSOENABLED=0
# 0: vector loadstores not forced atomic [Default] / 1: vector loadstores also atomic under TSO

FEX_MEMCPYSETTSOENABLED=0
# 0: REP MOVS/STOS not forced atomic [Default] / 1: REP MOVS/STOS also atomic under TSO

FEX_HALFBARRIERTSOENABLED=0
# 0: unaligned loadstores not backpatched to half-barrier atomics / 1: backpatch unaligned loadstores to half-barrier atomics [Default]

FEX_VOLATILEMETADATA=1
# 0: don't use PE volatile metadata / 1: use PE volatile metadata to guide TSO handling [Default]

FEX_HIDEHYPERVISORBIT=0
# 0: expose hypervisor CPUID bit [Default] / 1: hide hypervisor CPUID bit

FEX_MONOHACKS=1
# 0: don't apply Mono-specific SMC hooks / 1: enable SMC hooks + smaller JIT blocks when Mono detected [Default]

FEX_SMCCHECKS=1
# 0 (none): no code-modification checks / 1 (mtrack): page-tracking based invalidation [Default] / 2 (full): validate code before every run (slow)

FEX_HOSTFEATURES=off
# off: use default CPU features from host [Default] / comma-separated combination of: {enable,disable}sve, {enable,disable}avx, {enable,disable}afp, {enable,disable}lrcpc, {enable,disable}lrcpc2, {enable,disable}cssc, {enable,disable}pmull128, {enable,disable}rng, {enable,disable}clzero, {enable,disable}atomics, {enable,disable}fcma, {enable,disable}flagm, {enable,disable}flagm2, {enable,disable}frintts, {enable,disable}crypto, {enable,disable}rpres, {enable,disable}svebitperm, {enable,disable}preserveallabi, {enable,disable}wfxt, {enable,disable}3dnow, {enable,disable}sse4a, {enable,disable}mops — force-enable/disable specific JIT CPU features even if the host doesn't support them

FEX_DISABLEL2CACHE=1
# 0: keep JIT L2 cache lookup active (fewer stutters, more memory use) / 1: disable L2 cache lookup (less memory, may stutter more) [Default]

FEX_DYNAMICL1CACHE=1
# 0: static JIT L1 cache size / 1: dynamic JIT L1 cache size (less memory, may stutter) [Default]
INNER_EOF

cat > "${TEMPLATE_DIR}/override_dll.txt" << 'INNER_EOF'
version=n,b
nsisvclstyles=d
INNER_EOF

for cfg in desktop.txt box64.txt fexcore.txt override_dll.txt; do
    [ -f "${SHARED_DIR}/${cfg}" ] || cp -f "${TEMPLATE_DIR}/${cfg}" "${SHARED_DIR}/${cfg}"
done

WORKDIR="$(mktemp -d)"
cleanup() {
    rm -rf "${WORKDIR}" 2>/dev/null || true
    pkg clean 2>/dev/null || true
}
trap cleanup EXIT

dl() { curl -fL --retry 3 --retry-all-errors -o "$1" "$2"; }

pkg install -y x11-repo
pkg update -y && pkg upgrade -y
pkg install -y termux-x11-nightly xorg-xrandr pulseaudio alsa-lib alsa-plugins xfce4 xfce4-terminal zstd tar vulkan-loader-generic mesa mesa-vulkan-icd-freedreno

if [ ! -f "${HOME}/.asoundrc" ]; then
    cat > "${HOME}/.asoundrc" << 'ASOUNDEOF'
pcm.!default {
    type pulse
    server "127.0.0.1"
}

ctl.!default {
    type pulse
    server "127.0.0.1"
}
ASOUNDEOF
fi

TURNIP_TERMUX_DEFAULT_DIR="${TERMUX_PREFIX}/var/lib/turnip-termux"
mkdir -p "${TURNIP_TERMUX_DEFAULT_DIR}"
apt install --reinstall -y mesa-vulkan-icd-freedreno
cp -f "${TERMUX_PREFIX}/lib/libvulkan_freedreno.so" "${TURNIP_TERMUX_DEFAULT_DIR}/libvulkan_freedreno.so"

TURNIP_WRAPPER_DEFAULT_DIR="${TERMUX_PREFIX}/var/lib/turnip-wrapper"

WRAPPER_ARCHIVE="${WORKDIR}/wrapper.tzst"
EXTRA_LIBS_ARCHIVE="${WORKDIR}/extra_libs.tzst"
EXTRA_LIBS_TMPDIR="${WORKDIR}/extra_libs"
mkdir -p "${EXTRA_LIBS_TMPDIR}" "${TURNIP_WRAPPER_DEFAULT_DIR}" "${TERMUX_PREFIX}/share/vulkan/implicit_layer.d"

dl "${WRAPPER_ARCHIVE}" "${VNEMU_RAW}/wrapper/pipetto/wrapper.tzst" &
DL_PIDS=("$!")
dl "${EXTRA_LIBS_ARCHIVE}" "${VNEMU_RAW}/wrapper/extra_libs.tzst" &
DL_PIDS+=("$!")

HANGOVER_DEBS=(
    "hangover-wine_11.17_aarch64.deb"
    "hangover-libarm64ecfex_11.17_aarch64.deb"
    "hangover-wowbox64_11.17_aarch64.deb"
    "hangover-libwow64fex_11.17_aarch64.deb"
)
for deb in "${HANGOVER_DEBS[@]}"; do
    dl "${WORKDIR}/${deb}" "${HANGOVER_BASE}/${deb}" &
    DL_PIDS+=("$!")
done

for pid in "${DL_PIDS[@]}"; do
    wait "$pid"
done

zstd -dc "${WRAPPER_ARCHIVE}" | tar -x -C "${TERMUX_PREFIX}" --strip-components=1

zstd -dc "${EXTRA_LIBS_ARCHIVE}" | tar -x -C "${EXTRA_LIBS_TMPDIR}" \
    usr/lib/libbcn_layer.so \
    usr/lib/libvulkan_freedreno.so \
    usr/share/vulkan/implicit_layer.d/libbcn_layer.json
cp -f "${EXTRA_LIBS_TMPDIR}/usr/lib/libbcn_layer.so" "${TERMUX_PREFIX}/lib/"
cp -f "${EXTRA_LIBS_TMPDIR}/usr/lib/libvulkan_freedreno.so" "${TURNIP_WRAPPER_DEFAULT_DIR}/libvulkan_freedreno.so"
cp -f "${EXTRA_LIBS_TMPDIR}/usr/share/vulkan/implicit_layer.d/libbcn_layer.json" "${TERMUX_PREFIX}/share/vulkan/implicit_layer.d/"

ln -sfn "libandroid-shmem.so" "${TERMUX_PREFIX}/lib/libandroid-sysvshm.so"

apt install -y --reinstall --allow-downgrades --allow-change-held-packages "${HANGOVER_DEBS[@]/#/${WORKDIR}/}"

HANGOVER_PKG_NAMES=(
    "hangover-wine"
    "hangover-libarm64ecfex"
    "hangover-wowbox64"
    "hangover-libwow64fex"
)
apt-mark hold "${HANGOVER_PKG_NAMES[@]}" 2>/dev/null || true

LAYERS_DEFAULT_DIR="${TERMUX_PREFIX}/var/lib/layers-default"
WINE_DIR="${TERMUX_PREFIX}/opt/hangover-wine/lib/wine/aarch64-windows"
mkdir -p "${LAYERS_DEFAULT_DIR}"
cp -f "${WINE_DIR}/libarm64ecfex.dll" "${WINE_DIR}/wowbox64.dll" "${WINE_DIR}/libwow64fex.dll" "${LAYERS_DEFAULT_DIR}/"

for f in "${TERMUX_PREFIX}/opt/hangover-wine/bin/"*; do
    [ -e "$f" ] || continue
    [ "${f##*/}" = "wine" ] && continue
    ln -sf "$f" "${TERMUX_PREFIX}/bin/${f##*/}"
done
ln -sf "${TERMUX_PREFIX}/opt/hangover-wine/bin/wine" "${TERMUX_PREFIX}/bin/wine.real"

cat > "${TERMUX_PREFIX}/bin/wine" << 'WEOF'
#!/data/data/com.termux/files/usr/bin/bash
if [ -n "${WINE_LOGFILE:-}" ]; then
    mkdir -p "$(dirname "$WINE_LOGFILE")"
    exec wine.real "$@" >> "$WINE_LOGFILE" 2>&1
fi
exec wine.real "$@"
WEOF
chmod +x "${TERMUX_PREFIX}/bin/wine"

echo "Preparing Wine prefix..."

pkill -9 -f "termux.x11" > /dev/null 2>&1 || true
sleep 0.5

unset PULSE_SERVER
pulseaudio --kill > /dev/null 2>&1 || true
pulseaudio --start --exit-idle-time=-1 --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" > /dev/null 2>&1 || true
sleep 1
export PULSE_SERVER=127.0.0.1

termux-x11 :0 -ac > /dev/null 2>&1 &
sleep 2

export DISPLAY=:0
export WINEPREFIX=~/.wine
export WINEDEBUG=-all
export WINEDLLOVERRIDES="mscoree=d;mshtml=d"

export XDG_RUNTIME_DIR="${TERMUX_PREFIX}/tmp/xdg-runtime-$(id -u)"
mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"

wine wineboot -u > /dev/null 2>&1 || true
wineserver -w

unset WINEDLLOVERRIDES WINEDEBUG WINEPREFIX

pkill -9 -f "termux.x11" > /dev/null 2>&1 || true
pulseaudio --kill > /dev/null 2>&1 || true
unset PULSE_SERVER DISPLAY XDG_RUNTIME_DIR
sleep 0.5

cat > "${TERMUX_PREFIX}/bin/startx11" << EOF
#!${TERMUX_PREFIX}/bin/bash

TERMUX_PREFIX="${TERMUX_PREFIX}"
WINE_DIR="\${TERMUX_PREFIX}/opt/hangover-wine/lib/wine/aarch64-windows"
WINE_DIR_32="\${TERMUX_PREFIX}/opt/hangover-wine/lib/wine/i386-windows"
SHARED_DIR=~/storage/shared/Termux
TEMPLATE_DIR="\${TERMUX_PREFIX}/var/lib/vnemu-defaults"
LAYERS_DIR="\${SHARED_DIR}/layers"
WINEPREFIX=~/.wine
LOG_DIR="\${SHARED_DIR}/logs"

mkdir -p "\${LOG_DIR}"
rm -f "\${LOG_DIR}/"*.log
export WINE_LOGFILE="\${LOG_DIR}/wine.log"
DESKTOP_LOGFILE="\${LOG_DIR}/desktop.log"

WRAPPER_CACHE_DIR="\${TERMUX_PREFIX}/var/cache/vulkan-wrapper"
TURNIP_WRAPPER_DIR="\${SHARED_DIR}/turnip/wrapper"
TURNIP_TERMUX_DIR="\${SHARED_DIR}/turnip/termux"
TURNIP_WRAPPER_DEFAULT_DIR="\${TERMUX_PREFIX}/var/lib/turnip-wrapper"
TURNIP_WRAPPER_DEFAULT="\${TURNIP_WRAPPER_DEFAULT_DIR}/libvulkan_freedreno.so"
LAYERS_DEFAULT_DIR="\${TERMUX_PREFIX}/var/lib/layers-default"
DLLS_DIR="\${SHARED_DIR}/dlls"
MANIFEST_DIR="\${TERMUX_PREFIX}/var/lib/dll-manifest"
mkdir -p "\${LAYERS_DIR}" "\${WRAPPER_CACHE_DIR}" "\${TURNIP_WRAPPER_DIR}" "\${TURNIP_TERMUX_DIR}"
mkdir -p "\${DLLS_DIR}/system32" "\${DLLS_DIR}/syswow64"
mkdir -p "\${MANIFEST_DIR}"

for cfg in desktop.txt box64.txt fexcore.txt override_dll.txt; do
    [ -f "\${SHARED_DIR}/\${cfg}" ] || cp -f "\${TEMPLATE_DIR}/\${cfg}" "\${SHARED_DIR}/\${cfg}"
done

set -a
source "\${SHARED_DIR}/desktop.txt"
source "\${SHARED_DIR}/box64.txt"
source "\${SHARED_DIR}/fexcore.txt"
set +a

export XDG_DATA_DIRS="\${TERMUX_PREFIX}/share:\${XDG_DATA_DIRS:-}"
export XDG_CONFIG_DIRS="\${TERMUX_PREFIX}/etc/xdg:\${XDG_CONFIG_DIRS:-}"
export XDG_RUNTIME_DIR="\${TERMUX_PREFIX}/tmp/xdg-runtime-\$(id -u)"
mkdir -p "\${XDG_RUNTIME_DIR}"
chmod 700 "\${XDG_RUNTIME_DIR}"

case "\${OPENGL_DRIVER}" in
    zink)
        export MESA_LOADER_DRIVER_OVERRIDE=zink
        export GALLIUM_DRIVER=zink
        unset LIBGL_ALWAYS_SOFTWARE
        ;;
    llvmpipe)
        export MESA_LOADER_DRIVER_OVERRIDE=swrast
        export GALLIUM_DRIVER=llvmpipe
        export LIBGL_ALWAYS_SOFTWARE=true
        ;;
esac

case "\${GPU_BACKEND}" in
    termux)
        export VK_ICD_FILENAMES="\${TERMUX_PREFIX}/share/vulkan/icd.d/freedreno_icd.aarch64.json"
        unset VK_LAYER_PATH WRAPPER_LAYER_PATH WRAPPER_CACHE_PATH WRAPPER_EMULATE_BCN ENABLE_BCN_COMPUTE BCN_COMPUTE_AUTO
        unset ADRENOTOOLS_DRIVER_PATH ADRENOTOOLS_DRIVER_NAME ADRENOTOOLS_HOOKS_PATH ADRENOTOOLS_REDIRECT_DIR
        TURNIP_TERMUX_DEFAULT="\${TERMUX_PREFIX}/var/lib/turnip-termux/libvulkan_freedreno.so"
        TURNIP_SOURCE_TERMUX="\$(ls "\${TURNIP_TERMUX_DIR}/"*.so 2>/dev/null | head -n 1 || true)"
        if [ -n "\${TURNIP_SOURCE_TERMUX}" ]; then
            cp -f "\${TURNIP_SOURCE_TERMUX}" "\${TERMUX_PREFIX}/lib/libvulkan_freedreno.so"
        elif [ -f "\${TURNIP_TERMUX_DEFAULT}" ]; then
            cp -f "\${TURNIP_TERMUX_DEFAULT}" "\${TERMUX_PREFIX}/lib/libvulkan_freedreno.so"
        fi
        ;;
    wrapper)
        export VK_ICD_FILENAMES="\${TERMUX_PREFIX}/share/vulkan/icd.d/wrapper_icd.aarch64.json"
        export VK_LAYER_PATH="\${TERMUX_PREFIX}/share/vulkan/implicit_layer.d:\${TERMUX_PREFIX}/share/vulkan/explicit_layer.d"
        export WRAPPER_LAYER_PATH="\${TERMUX_PREFIX}/lib"
        export WRAPPER_CACHE_PATH="\${WRAPPER_CACHE_DIR}"
        case "\${WRAPPER_BCN}" in
            0)
                unset WRAPPER_EMULATE_BCN ENABLE_BCN_COMPUTE BCN_COMPUTE_AUTO
                ;;
            1)
                export WRAPPER_EMULATE_BCN=3
                unset ENABLE_BCN_COMPUTE BCN_COMPUTE_AUTO
                ;;
            2)
                export WRAPPER_EMULATE_BCN=2
                export ENABLE_BCN_COMPUTE=1
                export BCN_COMPUTE_AUTO=0
                ;;
        esac
        case "\${WRAPPER_DRIVER}" in
            system)
                unset ADRENOTOOLS_DRIVER_PATH ADRENOTOOLS_DRIVER_NAME ADRENOTOOLS_HOOKS_PATH ADRENOTOOLS_REDIRECT_DIR
                ;;
            turnip)
                TURNIP_SOURCE_WRAPPER="\$(ls "\${TURNIP_WRAPPER_DIR}/"*.so 2>/dev/null | head -n 1 || true)"
                if [ -n "\${TURNIP_SOURCE_WRAPPER}" ]; then
                    TURNIP_WRAPPER_INTERNAL_DIR="\${TURNIP_WRAPPER_DEFAULT_DIR}/custom"
                    mkdir -p "\${TURNIP_WRAPPER_INTERNAL_DIR}"
                    find "\${TURNIP_WRAPPER_INTERNAL_DIR}" -maxdepth 1 -type f -name '*.so' -delete
                    TURNIP_INTERNAL_COPY="\${TURNIP_WRAPPER_INTERNAL_DIR}/\$(basename "\${TURNIP_SOURCE_WRAPPER}")"
                    cp -f "\${TURNIP_SOURCE_WRAPPER}" "\${TURNIP_INTERNAL_COPY}"
                    TURNIP_SOURCE_WRAPPER="\${TURNIP_INTERNAL_COPY}"
                elif [ -f "\${TURNIP_WRAPPER_DEFAULT}" ]; then
                    TURNIP_SOURCE_WRAPPER="\${TURNIP_WRAPPER_DEFAULT}"
                fi
                if [ -n "\${TURNIP_SOURCE_WRAPPER}" ]; then
                    export ADRENOTOOLS_DRIVER_PATH="\$(dirname "\${TURNIP_SOURCE_WRAPPER}")/"
                    export ADRENOTOOLS_DRIVER_NAME="\$(basename "\${TURNIP_SOURCE_WRAPPER}")"
                    export ADRENOTOOLS_HOOKS_PATH="\${TERMUX_PREFIX}/lib"
                else
                    unset ADRENOTOOLS_DRIVER_PATH ADRENOTOOLS_DRIVER_NAME ADRENOTOOLS_HOOKS_PATH ADRENOTOOLS_REDIRECT_DIR
                fi
                ;;
        esac
        ;;
esac

if ls "\${LAYERS_DIR}/"*.dll > /dev/null 2>&1; then
    cp -f "\${LAYERS_DIR}/"*.dll "\${WINE_DIR}/" > /dev/null 2>&1
else
    cp -f "\${LAYERS_DEFAULT_DIR}/"*.dll "\${WINE_DIR}/" > /dev/null 2>&1
fi

pkill -9 -f "termux.x11" > /dev/null 2>&1
pkill -9 xfce4-session > /dev/null 2>&1
pkill -9 -f "dbus-daemon" > /dev/null 2>&1
sleep 0.5

if [ ! -d "\${WINEPREFIX}/drive_c/windows/system32" ]; then
    echo "Preparing Wine prefix..."

    unset PULSE_SERVER
    pulseaudio --kill > /dev/null 2>&1
    pulseaudio --start --exit-idle-time=-1 --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" > /dev/null 2>&1
    sleep 1
    export PULSE_SERVER=127.0.0.1

    termux-x11 :0 -ac > /dev/null 2>&1 &
    sleep 2
    export DISPLAY=:0

    export WINEDLLOVERRIDES="mscoree=d;mshtml=d"
    wine wineboot -u
    wineserver -w
    unset WINEDLLOVERRIDES

    pkill -9 -f "termux.x11" > /dev/null 2>&1
    pulseaudio --kill > /dev/null 2>&1
    unset PULSE_SERVER DISPLAY
    sleep 0.5
fi

unset PULSE_SERVER
pulseaudio --kill > /dev/null 2>&1
pulseaudio --start --exit-idle-time=-1 --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" > /dev/null 2>&1
sleep 1
export PULSE_SERVER=127.0.0.1

termux-x11 :0 -ac >> "\${DESKTOP_LOGFILE}" 2>&1 &
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
sleep 2
export DISPLAY=:0

wine reg add "HKCU\Software\Wine\Drivers" /v Audio /d "\${AUDIO_BACKEND}" /f > /dev/null 2>&1

declare -A DLL_OVERRIDES_MAP
declare -A DLL_USER_NAMES

if [ -f "\${SHARED_DIR}/override_dll.txt" ]; then
    while IFS='=' read -r name mode || [ -n "\$name" ]; do
        name="\${name%%#*}"
        name="\${name// /}"
        mode="\${mode// /}"
        [ -n "\$name" ] && [ -n "\$mode" ] && {
            DLL_OVERRIDES_MAP["\$mode"]+="\${name},"
            DLL_USER_NAMES["\$name"]=1
        }
    done < "\${SHARED_DIR}/override_dll.txt"
fi

sync_dll_arch() {
    local arch="\$1" source_dir="\$2" dll_path dll_name base_name target manifest prev
    declare -A found=()

    for dll_path in "\${DLLS_DIR}/\${arch}/"*.dll; do
        [ -f "\$dll_path" ] && found["\$(basename "\$dll_path")"]="\$dll_path"
    done

    manifest="\${MANIFEST_DIR}/\${arch}.list"
    prev=""
    [ -f "\$manifest" ] && prev="\$(cat "\$manifest")"

    for dll_name in "\${!found[@]}"; do
        base_name="\${dll_name%.*}"
        target="\${WINEPREFIX}/drive_c/windows/\${arch}/\${dll_name}"
        cp -f "\${found[\$dll_name]}" "\$target" 2>/dev/null
        [ -z "\${DLL_USER_NAMES[\$base_name]:-}" ] && DLL_OVERRIDES_MAP["n,b"]+="\${base_name},"
    done

    while IFS= read -r dll_name; do
        [ -n "\$dll_name" ] && [ -z "\${found[\$dll_name]:-}" ] || continue
        target="\${WINEPREFIX}/drive_c/windows/\${arch}/\${dll_name}"
        if [ -f "\${source_dir}/\${dll_name}" ]; then
            cp -f "\${source_dir}/\${dll_name}" "\$target" 2>/dev/null
        else
            rm -f "\$target" 2>/dev/null
        fi
    done <<< "\$prev"

    printf '%s\n' "\${!found[@]}" > "\$manifest"
}

sync_dll_arch system32 "\${WINE_DIR}"
sync_dll_arch syswow64 "\${WINE_DIR_32}"

WINEDLLOVERRIDES=""
for mode in "\${!DLL_OVERRIDES_MAP[@]}"; do
    names="\${DLL_OVERRIDES_MAP[\$mode]%,}"
    [ -z "\$names" ] && continue
    WINEDLLOVERRIDES+="\${names}=\${mode};"
done
export WINEDLLOVERRIDES="\${WINEDLLOVERRIDES%;}"

if [ "\${WINESERVICES:-0}" = "0" ]; then
    if [ -n "\${WINEDLLOVERRIDES}" ]; then
        export WINEDLLOVERRIDES="\${WINEDLLOVERRIDES};services.exe=d"
    else
        export WINEDLLOVERRIDES="services.exe=d"
    fi
    wineserver -k > /dev/null 2>&1 || true
fi

if [ "\${CPU_TASKSET:-all}" = "all" ]; then
    exec startxfce4 >> "\${DESKTOP_LOGFILE}" 2>&1
else
    exec taskset -c "\${CPU_TASKSET}" startxfce4 >> "\${DESKTOP_LOGFILE}" 2>&1
fi
EOF
chmod +x "${TERMUX_PREFIX}/bin/startx11"

cat > "${TERMUX_PREFIX}/bin/winlaunch" << 'WEOF'
#!/data/data/com.termux/files/usr/bin/bash
wine start /Unix "$1"
WEOF
chmod +x "${TERMUX_PREFIX}/bin/winlaunch"

mkdir -p ~/Desktop ~/.local/share/applications ~/.config ~/.config/gtk-3.0

cat > ~/.config/gtk-3.0/bookmarks << EOF
file://${HOME}/.wine/drive_c Windows
file://${HOME}/storage/shared Android
EOF

cat > ~/.local/share/applications/wine.desktop << EOF
[Desktop Entry]
Type=Application
Name=Wine
Exec=winlaunch %f
MimeType=application/x-ms-dos-executable;application/x-msi;application/x-bat;application/x-cmd;
NoDisplay=true
EOF

cat > ~/.config/mimeapps.list << EOF
[Default Applications]
application/x-ms-dos-executable=wine.desktop;
application/x-msi=wine.desktop;
application/x-bat=wine.desktop;
application/x-cmd=wine.desktop;
EOF

cat > ~/Desktop/winecfg.desktop << EOF
[Desktop Entry]
Type=Application
Name=Wine Config
Exec=wine winecfg
Icon=xfwm4-default
Categories=System;
EOF
chmod +x ~/Desktop/winecfg.desktop

cat > ~/Desktop/winetaskmgr.desktop << EOF
[Desktop Entry]
Type=Application
Name=Wine Task Manager
Exec=wine taskmgr
Icon=xfwm4-default
Categories=System;
EOF
chmod +x ~/Desktop/winetaskmgr.desktop

cat > ~/Desktop/winecontrol.desktop << EOF
[Desktop Entry]
Type=Application
Name=Wine Control Panel
Exec=wine control
Icon=xfwm4-default
Categories=System;
EOF
chmod +x ~/Desktop/winecontrol.desktop

clear
echo "Type This Command to Start Desktop and Wine:"
echo "startx11"