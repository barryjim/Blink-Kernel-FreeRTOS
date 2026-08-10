####################################################################
# Automatically-generated file. Do not edit!                       #
####################################################################

set(SDK_PATH "$ENV{SILABS_SDK_PATH}" CACHE PATH "Path to Silicon Labs SDK" FORCE)
if(NOT SDK_PATH)
  set(SDK_PATH "/home/tuya/.silabs/slt/installs/conan/p/simpl965e19baece23/p" CACHE PATH "Fallback SDK path" FORCE)
endif()
set(COPIED_SDK_PATH "simplicity_sdk_2025.12.2")
set(PKG_PATH "/home/tuya/.silabs/slt/installs")

add_library(slc OBJECT
    "${SDK_PATH}/boards/hardware/board/src/sl_board_control_gpio.c"
    "${SDK_PATH}/boards/hardware/board/src/sl_board_init.c"
    "${SDK_PATH}/cmsis/RTOS2/Source/os_systick.c"
    "${SDK_PATH}/cmsis_common/platform/common/src/sl_cmsis_os2_common.c"
    "${SDK_PATH}/devices/platform/Device/SiliconLabs/SIMG301/Source/startup_simg301.c"
    "${SDK_PATH}/devices/platform/Device/SiliconLabs/SIMG301/Source/system_simg301.c"
    "${SDK_PATH}/freertos/cmsis/Source/cmsis_os2.c"
    "${SDK_PATH}/freertos/kernel/croutine.c"
    "${SDK_PATH}/freertos/kernel/event_groups.c"
    "${SDK_PATH}/freertos/kernel/list.c"
    "${SDK_PATH}/freertos/kernel/portable/GCC/ARM_CM33_NTZ/non_secure/mpu_wrappers_v2_asm.c"
    "${SDK_PATH}/freertos/kernel/portable/GCC/ARM_CM33_NTZ/non_secure/port.c"
    "${SDK_PATH}/freertos/kernel/portable/GCC/ARM_CM33_NTZ/non_secure/portasm.c"
    "${SDK_PATH}/freertos/kernel/portable/MemMang/heap_3.c"
    "${SDK_PATH}/freertos/kernel/queue.c"
    "${SDK_PATH}/freertos/kernel/stream_buffer.c"
    "${SDK_PATH}/freertos/kernel/tasks.c"
    "${SDK_PATH}/freertos/kernel/timers.c"
    "${SDK_PATH}/platform_common/platform/common/src/sl_assert.c"
    "${SDK_PATH}/platform_common/platform/common/src/sl_syscalls.c"
    "${SDK_PATH}/platform_core/hardware/driver/configuration_over_swo/src/sl_cos.c"
    "${SDK_PATH}/platform_core/platform/common/src/sl_core_cortexm.c"
    "${SDK_PATH}/platform_core/platform/common/src/sl_tz_non_secure_execution.c"
    "${SDK_PATH}/platform_core/platform/driver/debug/src/sl_debug_swo.c"
    "${SDK_PATH}/platform_core/platform/driver/gpio/src/sl_gpio.c"
    "${SDK_PATH}/platform_core/platform/driver/leddrv/src/sl_led.c"
    "${SDK_PATH}/platform_core/platform/driver/leddrv/src/sl_simple_led.c"
    "${SDK_PATH}/platform_core/platform/peripheral/src/sl_hal_burtc.c"
    "${SDK_PATH}/platform_core/platform/peripheral/src/sl_hal_gpcrc.c"
    "${SDK_PATH}/platform_core/platform/peripheral/src/sl_hal_gpio.c"
    "${SDK_PATH}/platform_core/platform/peripheral/src/sl_hal_prs.c"
    "${SDK_PATH}/platform_core/platform/peripheral/src/sl_hal_syscfg.c"
    "${SDK_PATH}/platform_core/platform/peripheral/src/sl_hal_sysrtc.c"
    "${SDK_PATH}/platform_core/platform/peripheral/src/sl_hal_sysrtc_subsystem.c"
    "${SDK_PATH}/platform_core/platform/peripheral/src/sl_hal_system.c"
    "${SDK_PATH}/platform_core/platform/peripheral/src/sl_hal_timer.c"
    "${SDK_PATH}/platform_core/platform/service/clock_manager/src/sl_clock_manager.c"
    "${SDK_PATH}/platform_core/platform/service/clock_manager/src/sl_clock_manager_hal_s3.c"
    "${SDK_PATH}/platform_core/platform/service/clock_manager/src/sl_clock_manager_init.c"
    "${SDK_PATH}/platform_core/platform/service/clock_manager/src/sl_clock_manager_init_hal_s3.c"
    "${SDK_PATH}/platform_core/platform/service/device_manager/clocks/sl_device_clock_sixx301.c"
    "${SDK_PATH}/platform_core/platform/service/device_manager/devices/sl_device_peripheral_hal_sixx301.c"
    "${SDK_PATH}/platform_core/platform/service/device_manager/dma/sl_device_dma_s3.c"
    "${SDK_PATH}/platform_core/platform/service/device_manager/src/sl_device_clock.c"
    "${SDK_PATH}/platform_core/platform/service/device_manager/src/sl_device_dma.c"
    "${SDK_PATH}/platform_core/platform/service/device_manager/src/sl_device_gpio.c"
    "${SDK_PATH}/platform_core/platform/service/device_manager/src/sl_device_peripheral.c"
    "${SDK_PATH}/platform_core/platform/service/interrupt_manager/src/sl_interrupt_manager_cortexm.c"
    "${SDK_PATH}/platform_core/platform/service/memory_manager/src/sl_memory_manager.c"
    "${SDK_PATH}/platform_core/platform/service/memory_manager/src/sl_memory_manager_dynamic_reservation.c"
    "${SDK_PATH}/platform_core/platform/service/memory_manager/src/sl_memory_manager_pool.c"
    "${SDK_PATH}/platform_core/platform/service/memory_manager/src/sl_memory_manager_pool_common.c"
    "${SDK_PATH}/platform_core/platform/service/memory_manager/src/sl_memory_manager_region.c"
    "${SDK_PATH}/platform_core/platform/service/memory_manager/src/sl_memory_manager_retarget.c"
    "${SDK_PATH}/platform_core/platform/service/memory_manager/src/sli_memory_manager_common.c"
    "${SDK_PATH}/platform_core/platform/service/sl_main/src/rtos/main_retarget.c"
    "${SDK_PATH}/platform_core/platform/service/sl_main/src/sl_main_init.c"
    "${SDK_PATH}/platform_core/platform/service/sl_main/src/sl_main_init_memory.c"
    "${SDK_PATH}/platform_core/platform/service/sl_main/src/sl_main_kernel.c"
    "${SDK_PATH}/platform_core/platform/service/sleeptimer/src/sl_sleeptimer.c"
    "${SDK_PATH}/platform_core/platform/service/sleeptimer/src/sl_sleeptimer_hal_burtc.c"
    "${SDK_PATH}/platform_core/platform/service/sleeptimer/src/sl_sleeptimer_hal_sysrtc.c"
    "${SDK_PATH}/platform_core/platform/service/sleeptimer/src/sl_sleeptimer_hal_timer.c"
    "${SDK_PATH}/platform_core/platform/service/token_manager/src/sl_token_manager_api.c"
    "${SDK_PATH}/platform_core/platform/service/token_manager/src/sl_token_manager_lock.c"
    "${SDK_PATH}/platform_core/platform/service/token_manager/src/sli_token_manager_backend_nvm.c"
    "${SDK_PATH}/platform_core/platform/service/token_manager/src/sli_token_manager_backend_ram.c"
    "${SDK_PATH}/platform_core/platform/service/token_manager/src/sli_token_manager_format_klv.c"
    "${SDK_PATH}/platform_core/platform/service/token_manager/src/sli_token_manager_hal_crypto_se.c"
    "${SDK_PATH}/platform_core/platform/service/token_manager/src/sli_token_manager_hal_ext_flash.c"
    "${SDK_PATH}/platform_core/platform/service/token_manager/src/sli_token_manager_hal_se_mtp.c"
    "${SDK_PATH}/platform_core/platform/service/token_manager/src/sli_token_manager_internal.c"
    "${SDK_PATH}/platform_core/platform/service/token_manager/src/sli_token_manager_manufacturing.c"
    "${SDK_PATH}/security_mbedtls/platform/security/sl_component/sli_crypto/src/sli_crypto_ksu_manager.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/src/sl_se_manager.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/src/sl_se_manager_attestation.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/src/sl_se_manager_cipher.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/src/sl_se_manager_entropy.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/src/sl_se_manager_extmem.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/src/sl_se_manager_hash.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/src/sl_se_manager_key_derivation.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/src/sl_se_manager_key_handling.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/src/sl_se_manager_signature.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/src/sl_se_manager_util.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/src/sli_se_manager_device_data.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/src/sli_se_manager_mailbox.c"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/sli_psec_osal/src/sli_psec_osal_cmsis_rtos2.c"
    "${SDK_PATH}/security_sxsymcrypt/src/aead.c"
    "${SDK_PATH}/security_sxsymcrypt/src/blkcipher.c"
    "${SDK_PATH}/security_sxsymcrypt/src/channel.c"
    "${SDK_PATH}/security_sxsymcrypt/src/cmac.c"
    "${SDK_PATH}/security_sxsymcrypt/src/cmdma.c"
    "${SDK_PATH}/security_sxsymcrypt/src/cmmask.c"
    "${SDK_PATH}/security_sxsymcrypt/src/hash.c"
    "${SDK_PATH}/security_sxsymcrypt/src/hmac.c"
    "${SDK_PATH}/security_sxsymcrypt/src/interrupts.c"
    "${SDK_PATH}/security_sxsymcrypt/src/keyref.c"
    "${SDK_PATH}/security_sxsymcrypt/src/mac.c"
    "${SDK_PATH}/security_sxsymcrypt/src/platform/silicon_labs/sli_sxsymcrypt_engine_management.c"
    "${SDK_PATH}/security_sxsymcrypt/src/platform/silicon_labs/sli_sxsymcrypt_hardware_interaction.c"
    "../app.c"
    "../autogen/sl_board_default_init.c"
    "../autogen/sl_event_handler.c"
    "../autogen/sl_simple_led_instances.c"
    "../blink.c"
    "../main.c"
)

target_include_directories(slc PUBLIC
   "../config"
   "../autogen"
   "../."
    "${SDK_PATH}/devices/platform/Device/SiliconLabs/SIMG301/Include"
    "${SDK_PATH}/platform_common/platform/common/inc"
    "${SDK_PATH}/boards/hardware/board/inc"
    "${SDK_PATH}/platform_core/platform/service/clock_manager/inc"
    "${SDK_PATH}/platform_core/platform/service/clock_manager/src"
    "${SDK_PATH}/cmsis_common/platform/common/inc"
    "${SDK_PATH}/cmsis/Core/Include"
    "${SDK_PATH}/cmsis/RTOS2/Include"
    "${SDK_PATH}/platform_core/platform/service/token_manager/inc"
    "${SDK_PATH}/platform_core/platform/service/token_manager/src"
    "${SDK_PATH}/platform_core/platform/service/token_manager/legacy/inc"
    "${SDK_PATH}/platform_core/hardware/driver/configuration_over_swo/inc"
    "${SDK_PATH}/platform_core/platform/driver/debug/inc"
    "${SDK_PATH}/platform_core/platform/service/device_manager/inc"
    "${SDK_PATH}/platform_core/platform/common/errno_error_codes/inc"
    "${SDK_PATH}/freertos/kernel/include"
    "${SDK_PATH}/freertos/cmsis/Include"
    "${SDK_PATH}/freertos/kernel/portable/GCC/ARM_CM33_NTZ/non_secure"
    "${SDK_PATH}/platform_core/platform/driver/gpio/inc"
    "${SDK_PATH}/platform_core/platform/peripheral/inc"
    "${SDK_PATH}/platform_core/platform/service/interrupt_manager/inc"
    "${SDK_PATH}/platform_core/platform/service/interrupt_manager/src"
    "${SDK_PATH}/platform_core/platform/service/interrupt_manager/inc/arm"
    "${SDK_PATH}/platform_core/platform/driver/leddrv/inc"
    "${SDK_PATH}/platform_core/platform/service/memory_manager/inc"
    "${SDK_PATH}/platform_core/platform/service/memory_manager/src"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/se_manager/inc"
    "${SDK_PATH}/platform_core/platform/common/inc"
    "${SDK_PATH}/platform_core/platform/service/sl_main/inc"
    "${SDK_PATH}/platform_core/platform/service/sl_main/src"
    "${SDK_PATH}/platform_core/platform/service/sleeptimer/inc"
    "${SDK_PATH}/platform_core/platform/service/sleeptimer/src"
    "${SDK_PATH}/security_mbedtls/platform/security/sl_component/sli_crypto/inc"
    "${SDK_PATH}/security_se_manager/platform/security/sl_component/sli_psec_osal/inc"
    "${SDK_PATH}/security_sxsymcrypt/include"
    "${SDK_PATH}/security_sxsymcrypt/src"
    "${SDK_PATH}/security_sxsymcrypt/src/platform/silicon_labs"
)

target_compile_definitions(slc PUBLIC
    "DEBUG_EFM=1"
    "SIMG301M104LIL=1"
    "SL_CODE_COMPONENT_SYSTEM=system"
    "SL_BOARD_NAME=\"BRD4407A\""
    "SL_BOARD_REV=\"A07\""
    "HARDWARE_BOARD_DEFAULT_RF_BAND_2400=1"
    "HARDWARE_BOARD_SUPPORTS_1_RF_BAND=1"
    "HARDWARE_BOARD_SUPPORTS_RF_BAND_2400=1"
    "HFXO_FREQ=38400000"
    "SL_CODE_COMPONENT_CLOCK_MANAGER=clock_manager"
    "CUSTOM_TOKEN_HEADER=\"sl_token_manager_af_token_header.h\""
    "SL_TOKEN_MANAGER_BACKEND_EXT_FLASH=1"
    "SL_TOKEN_MANAGER_SECURITY=1"
    "SL_COMMON_TOKEN_MANAGER_ENABLE_STATIC_TOKENS=1"
    "SL_COMPONENT_CATALOG_PRESENT=1"
    "SL_CODE_COMPONENT_DEVICE_PERIPHERAL=device_peripheral"
    "SL_CODE_COMPONENT_FREERTOS_KERNEL=freertos_kernel"
    "SL_CODE_COMPONENT_GPIO=gpio"
    "SL_CODE_COMPONENT_HAL_COMMON=hal_common"
    "SL_CODE_COMPONENT_HAL_GPIO=hal_gpio"
    "SL_CODE_COMPONENT_HAL_SYSRTC=hal_sysrtc"
    "SL_CODE_COMPONENT_INTERRUPT_MANAGER=interrupt_manager"
    "CMSIS_NVIC_VIRTUAL=1"
    "CMSIS_NVIC_VIRTUAL_HEADER_FILE=\"cmsis_nvic_virtual.h\""
    "SL_CODE_COMPONENT_MEMORY_MANAGER=memory_manager"
    "SL_CODE_COMPONENT_SE_MANAGER=se_manager"
    "SL_CODE_COMPONENT_CORE=core"
    "SL_CODE_COMPONENT_SLEEPTIMER=sleeptimer"
    "SL_CODE_COMPONENT_PSEC_OSAL=psec_osal"
    "SL_CODE_COMPONENT_SXSYMCRYPT=sxsymcrypt"
    "SX_HASH_BLOCKSZ_MAX=0"
    "SX_HASH_DIGESTSZ_MAX=0"
    "SX_KEYREF_MAX_ID=32"
    "SL_TZ_NON_SECURE_EXECUTION=1"
    "configENABLE_TRUSTZONE=0"
    "configRUN_FREERTOS_SECURE_ONLY=0"
)

target_link_libraries(slc PUBLIC
    "-Wl,--start-group"
    "gcc"
    "c"
    "m"
    "nosys"
    "-Wl,--end-group"
)
target_compile_options(slc PUBLIC
    $<$<COMPILE_LANGUAGE:C>:-mcpu=cortex-m33>
    $<$<COMPILE_LANGUAGE:C>:-mthumb>
    $<$<COMPILE_LANGUAGE:C>:-mfpu=fpv5-sp-d16>
    $<$<COMPILE_LANGUAGE:C>:-mfloat-abi=hard>
    $<$<COMPILE_LANGUAGE:C>:-mcmse>
    $<$<COMPILE_LANGUAGE:C>:-Wall>
    $<$<COMPILE_LANGUAGE:C>:-Wextra>
    $<$<COMPILE_LANGUAGE:C>:-Os>
    $<$<COMPILE_LANGUAGE:C>:-fdata-sections>
    $<$<COMPILE_LANGUAGE:C>:-ffunction-sections>
    $<$<COMPILE_LANGUAGE:C>:-fomit-frame-pointer>
    $<$<COMPILE_LANGUAGE:C>:-g>
    $<$<COMPILE_LANGUAGE:C>:--specs=nano.specs>
    $<$<COMPILE_LANGUAGE:C>:-fno-lto>
    $<$<COMPILE_LANGUAGE:CXX>:-mcpu=cortex-m33>
    $<$<COMPILE_LANGUAGE:CXX>:-mthumb>
    $<$<COMPILE_LANGUAGE:CXX>:-mfpu=fpv5-sp-d16>
    $<$<COMPILE_LANGUAGE:CXX>:-mfloat-abi=hard>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions>
    $<$<COMPILE_LANGUAGE:CXX>:-mcmse>
    $<$<COMPILE_LANGUAGE:CXX>:-Wall>
    $<$<COMPILE_LANGUAGE:CXX>:-Wextra>
    $<$<COMPILE_LANGUAGE:CXX>:-Os>
    $<$<COMPILE_LANGUAGE:CXX>:-fdata-sections>
    $<$<COMPILE_LANGUAGE:CXX>:-ffunction-sections>
    $<$<COMPILE_LANGUAGE:CXX>:-fomit-frame-pointer>
    $<$<COMPILE_LANGUAGE:CXX>:-g>
    $<$<COMPILE_LANGUAGE:CXX>:--specs=nano.specs>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-lto>
    $<$<COMPILE_LANGUAGE:ASM>:-mcpu=cortex-m33>
    $<$<COMPILE_LANGUAGE:ASM>:-mthumb>
    $<$<COMPILE_LANGUAGE:ASM>:-mfpu=fpv5-sp-d16>
    $<$<COMPILE_LANGUAGE:ASM>:-mfloat-abi=hard>
    "$<$<COMPILE_LANGUAGE:ASM>:SHELL:-x assembler-with-cpp>"
)

set(post_build_command )
set_property(TARGET slc PROPERTY C_STANDARD 17)
set_property(TARGET slc PROPERTY CXX_STANDARD 17)
set_property(TARGET slc PROPERTY CXX_EXTENSIONS OFF)

target_link_options(slc INTERFACE
    -mcpu=cortex-m33
    -mthumb
    -mfpu=fpv5-sp-d16
    -mfloat-abi=hard
    -T${CMAKE_CURRENT_LIST_DIR}/../autogen/linkerfile.ld
    --specs=nano.specs
    "SHELL:-Xlinker -Map=$<TARGET_FILE_DIR:blink_kernel_freertos_s3>/blink_kernel_freertos_s3.map"
    "SHELL:-Wl,--wrap=_free_r -Wl,--wrap=_malloc_r -Wl,--wrap=_calloc_r -Wl,--wrap=_realloc_r"
    -Wl,--wrap=main
    -fno-lto
    -Wl,--gc-sections
)

# BEGIN_SIMPLICITY_STUDIO_METADATA=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END_SIMPLICITY_STUDIO_METADATA