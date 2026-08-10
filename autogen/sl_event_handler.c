#include "sl_event_handler.h"

#include "sl_board_init.h"
#include "sl_clock_manager.h"
#include "sl_board_control.h"
#include "sl_debug_swo.h"
#include "sl_gpio.h"
#include "sl_simple_led_instances.h"
#include "sl_se_manager.h"
#include "sli_sxsymcrypt.h"
#include "sli_crypto_ksu_manager.h"
#include "cmsis_os2.h"
#include "sl_token_manager_api.h"
#include "sl_cos.h"

void sli_driver_permanent_allocation(void)
{
}

void sli_service_permanent_allocation(void)
{
}

void sli_stack_permanent_allocation(void)
{
}

void sli_internal_permanent_allocation(void)
{
}

void sl_platform_init(void)
{
  sl_board_preinit();
  sl_clock_manager_runtime_init();
  sl_board_init();
}

void sli_internal_init_early(void)
{
}

void sl_kernel_start(void)
{
  osKernelStart();
}

void sl_driver_init(void)
{
  sl_debug_swo_init();
  sl_gpio_init();
  sl_simple_led_init_instances();
  sl_cos_send_config();
}

void sl_service_init(void)
{
  sl_board_configure_vcom();
  sl_se_init();
  sli_sxsymcrypt_init_locks();
  sli_ksu_init();
  sl_token_manager_init();
}

void sl_stack_init(void)
{
}

void sl_internal_app_init(void)
{
}

