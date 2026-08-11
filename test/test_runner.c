#include "unity_stub.h"
#include "blink.h"

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_blink_init_static_allocation_params);
#if (EXAMPLE_USE_STATIC_ALLOCATION == 0)
    RUN_TEST(test_blink_init_dynamic_allocation_params);
#endif
    RUN_TEST(test_blink_init_static_allocation_fail);
    RUN_TEST(test_blink_task_delay_ticks);
    RUN_TEST(test_blink_task_toggle_count);
    RUN_TEST(test_toggle_delay_ms_macro);
    RUN_TEST(test_led_instance_not_null);
    RUN_TEST(test_led_function_pointers_valid);
    RUN_TEST(test_blink_init_multiple_calls);
    RUN_TEST(test_blink_task_priority_above_idle);
    RUN_TEST(test_blink_stack_size_valid);
#if (EXAMPLE_USE_STATIC_ALLOCATION == 0)
    RUN_TEST(test_blink_task_dynamic_mode);
#endif
    RUN_TEST(test_blink_task_delay_consistency);
    RUN_TEST(test_led_context_fields);
    RUN_TEST(test_static_allocation_buffers_valid);
    return UNITY_END();
}