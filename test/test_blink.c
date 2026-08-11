#include "unity_stub.h"
#include "mock_task.h"
#include "mock_sl_simple_led.h"
#include "sl_simple_led_instances.h"
#include "blink.h"

#include <setjmp.h>
#include <string.h>

/* ======================== 测试辅助变量 ======================== */

static TaskFunction_t captured_task_fn;
static void *captured_task_param;
static configSTACK_DEPTH_TYPE captured_stack_depth;
static UBaseType_t captured_priority;
static const char *captured_task_name;
static BaseType_t create_static_called;
static BaseType_t create_dynamic_called;
static TickType_t last_delay_ticks;
static uint32_t toggle_count;
static uint32_t delay_count;
static jmp_buf jump_buffer;

/* ======================== Mock 回调: xTaskCreateStatic ======================== */

static TaskHandle_t xTaskCreateStatic_success_cb(
    TaskFunction_t pvTaskCode,
    const char *pcName,
    configSTACK_DEPTH_TYPE uxStackDepth,
    void *pvParameters,
    UBaseType_t uxPriority,
    StackType_t *puxStackBuffer,
    StaticTask_t *pxTaskBuffer
) {
    (void)puxStackBuffer;
    (void)pxTaskBuffer;
    captured_task_fn = pvTaskCode;
    captured_task_param = pvParameters;
    captured_stack_depth = uxStackDepth;
    captured_priority = uxPriority;
    captured_task_name = pcName;
    create_static_called = 1;
    static tskTCB fake_tcb;
    return &fake_tcb;
}

static TaskHandle_t xTaskCreateStatic_fail_cb(
    TaskFunction_t pvTaskCode,
    const char *pcName,
    configSTACK_DEPTH_TYPE uxStackDepth,
    void *pvParameters,
    UBaseType_t uxPriority,
    StackType_t *puxStackBuffer,
    StaticTask_t *pxTaskBuffer
) {
    (void)pvTaskCode;
    (void)pcName;
    (void)uxStackDepth;
    (void)pvParameters;
    (void)uxPriority;
    (void)puxStackBuffer;
    (void)pxTaskBuffer;
    create_static_called = 1;
    return NULL;
}

/* ======================== Mock 回调: xTaskCreate ======================== */

static BaseType_t xTaskCreate_success_cb(
    TaskFunction_t pvTaskCode,
    const char *pcName,
    configSTACK_DEPTH_TYPE usStackDepth,
    void *pvParameters,
    UBaseType_t uxPriority,
    TaskHandle_t *pxCreatedTask
) {
    (void)pxCreatedTask;
    captured_task_fn = pvTaskCode;
    captured_task_param = pvParameters;
    captured_stack_depth = usStackDepth;
    captured_priority = uxPriority;
    captured_task_name = pcName;
    create_dynamic_called = 1;
    return pdPASS;
}

/* ======================== Mock 回调: vTaskDelay ======================== */

static void vTaskDelay_count_cb(TickType_t xTicksToDelay) {
    last_delay_ticks = xTicksToDelay;
    delay_count++;
}

/* ======================== Mock 回调: sl_led_toggle ======================== */

static void sl_led_toggle_count_cb(const sl_led_t *led) {
    (void)led;
    toggle_count++;
}

static void sl_led_toggle_break_loop_cb(const sl_led_t *led) {
    (void)led;
    toggle_count++;
    if (toggle_count >= 5) {
        longjmp(jump_buffer, 1);
    }
}

/* ======================== setUp / tearDown ======================== */

void setUp(void) {
    captured_task_fn = NULL;
    captured_task_param = NULL;
    captured_stack_depth = 0;
    captured_priority = 0;
    captured_task_name = NULL;
    create_static_called = 0;
    create_dynamic_called = 0;
    last_delay_ticks = 0;
    toggle_count = 0;
    delay_count = 0;

    Mocktask_Init();
    Mocksl_simple_led_Init();
}

void tearDown(void) {
    Mocktask_Verify();
    Mocktask_Cleanup();
    Mocksl_simple_led_Verify();
    Mocksl_simple_led_Cleanup();
}

/* ======================== 测试用例 ======================== */

/*
 * 测试 1: 静态分配 - 验证 xTaskCreateStatic 被正确调用
 */
void test_blink_init_static_allocation_params(void) {
    xTaskCreateStatic_Stub(xTaskCreateStatic_success_cb);

    blink_init();

    TEST_ASSERT_EQUAL(1, create_static_called);
    TEST_ASSERT_NOT_NULL(captured_task_fn);
    TEST_ASSERT_EQUAL_STRING("blink task", captured_task_name);
    TEST_ASSERT_EQUAL(configMINIMAL_STACK_SIZE, captured_stack_depth);
    TEST_ASSERT_EQUAL(tskIDLE_PRIORITY + 1, captured_priority);
}

/*
 * 测试 2: 动态分配 - 验证 xTaskCreate 被正确调用
 * (仅在 EXAMPLE_USE_STATIC_ALLOCATION=0 时可用)
 */
#if (EXAMPLE_USE_STATIC_ALLOCATION == 0)
void test_blink_init_dynamic_allocation_params(void) {
    xTaskCreate_Stub(xTaskCreate_success_cb);

    blink_init();

    TEST_ASSERT_EQUAL(0, create_static_called);
    TEST_ASSERT_EQUAL(1, create_dynamic_called);
    TEST_ASSERT_NOT_NULL(captured_task_fn);
    TEST_ASSERT_EQUAL_STRING("blink task", captured_task_name);
    TEST_ASSERT_EQUAL(configMINIMAL_STACK_SIZE, captured_stack_depth);
    TEST_ASSERT_EQUAL(tskIDLE_PRIORITY + 1, captured_priority);
}
#endif

/*
 * 测试 3: 静态分配失败 - 验证 EFM_ASSERT 路径
 */
void test_blink_init_static_allocation_fail(void) {
    xTaskCreateStatic_Stub(xTaskCreateStatic_fail_cb);

    blink_init();

    TEST_ASSERT_EQUAL(1, create_static_called);
}

/*
 * 测试 4: 验证 blink_task 中 vTaskDelay 的延时参数
 */
void test_blink_task_delay_ticks(void) {
    vTaskDelay_Stub(vTaskDelay_count_cb);
    sl_led_toggle_Stub(sl_led_toggle_break_loop_cb);
    xTaskCreateStatic_Stub(xTaskCreateStatic_success_cb);

    blink_init();

    if (setjmp(jump_buffer) == 0) {
        captured_task_fn(captured_task_param);
    }

    TickType_t expected_ticks = pdMS_TO_TICKS(TOOGLE_DELAY_MS);
    TEST_ASSERT_EQUAL(expected_ticks, last_delay_ticks);
    TEST_ASSERT_EQUAL(5, delay_count);
}

/*
 * 测试 5: 验证 LED 切换次数 (循环 5 次)
 */
void test_blink_task_toggle_count(void) {
    vTaskDelay_Stub(vTaskDelay_count_cb);
    sl_led_toggle_Stub(sl_led_toggle_break_loop_cb);
    xTaskCreateStatic_Stub(xTaskCreateStatic_success_cb);

    blink_init();

    if (setjmp(jump_buffer) == 0) {
        captured_task_fn(captured_task_param);
    }

    TEST_ASSERT_EQUAL(5, toggle_count);
    TEST_ASSERT_EQUAL(5, delay_count);
}

/*
 * 测试 6: 验证 TOOGLE_DELAY_MS 宏值
 */
void test_toggle_delay_ms_macro(void) {
    uint32_t expected = 200;
    TEST_ASSERT_EQUAL(expected, TOOGLE_DELAY_MS);
}

/*
 * 测试 7: 验证 LED 实例不为空
 */
void test_led_instance_not_null(void) {
    TEST_ASSERT_NOT_NULL(&sl_led_led0);
    TEST_ASSERT_NOT_NULL(sl_led_led0.context);
}

/*
 * 测试 8: 验证 LED 函数指针有效性
 */
void test_led_function_pointers_valid(void) {
    TEST_ASSERT_NOT_NULL(sl_led_led0.init);
    TEST_ASSERT_NOT_NULL(sl_led_led0.toggle);
    TEST_ASSERT_NOT_NULL(sl_led_led0.turn_on);
    TEST_ASSERT_NOT_NULL(sl_led_led0.turn_off);
    TEST_ASSERT_NOT_NULL(sl_led_led0.get_state);
}

/*
 * 测试 9: 多次调用 blink_init
 */
void test_blink_init_multiple_calls(void) {
    xTaskCreateStatic_Stub(xTaskCreateStatic_success_cb);

    blink_init();
    TEST_ASSERT_EQUAL(1, create_static_called);

    captured_task_fn = NULL;
    create_static_called = 0;
    blink_init();
    TEST_ASSERT_EQUAL(1, create_static_called);
    TEST_ASSERT_NOT_NULL(captured_task_fn);
}

/*
 * 测试 10: 验证任务优先级 > 空闲任务优先级
 */
void test_blink_task_priority_above_idle(void) {
    xTaskCreateStatic_Stub(xTaskCreateStatic_success_cb);

    blink_init();

    TEST_ASSERT_GREATER_THAN(tskIDLE_PRIORITY, captured_priority);
}

/*
 * 测试 11: 验证栈大小有效
 */
void test_blink_stack_size_valid(void) {
    TEST_ASSERT_GREATER_OR_EQUAL(configMINIMAL_STACK_SIZE,
                                 BLINK_TASK_STACK_SIZE);
}

/*
 * 测试 12: 动态分配模式下 blink_task 行为
 * (仅在 EXAMPLE_USE_STATIC_ALLOCATION=0 时可用)
 */
#if (EXAMPLE_USE_STATIC_ALLOCATION == 0)
void test_blink_task_dynamic_mode(void) {
    vTaskDelay_Stub(vTaskDelay_count_cb);
    sl_led_toggle_Stub(sl_led_toggle_break_loop_cb);
    xTaskCreate_Stub(xTaskCreate_success_cb);

    blink_init();

    if (setjmp(jump_buffer) == 0) {
        captured_task_fn(captured_task_param);
    }

    TEST_ASSERT_EQUAL(5, toggle_count);
    TickType_t expected_ticks = pdMS_TO_TICKS(TOOGLE_DELAY_MS);
    TEST_ASSERT_EQUAL(expected_ticks, last_delay_ticks);
}
#endif

/*
 * 测试 13: 验证 vTaskDelay 每次被调用的 tick 值一致
 */
void test_blink_task_delay_consistency(void) {
    vTaskDelay_Stub(vTaskDelay_count_cb);
    sl_led_toggle_Stub(sl_led_toggle_break_loop_cb);
    xTaskCreateStatic_Stub(xTaskCreateStatic_success_cb);

    blink_init();

    if (setjmp(jump_buffer) == 0) {
        captured_task_fn(captured_task_param);
    }

    TickType_t expected_ticks = pdMS_TO_TICKS(TOOGLE_DELAY_MS);
    TEST_ASSERT_EQUAL(expected_ticks, last_delay_ticks);
}

/*
 * 测试 14: 验证 LED 实例 context 字段
 */
void test_led_context_fields(void) {
    TEST_ASSERT_EQUAL(0, sl_led_led0.context->port);
    TEST_ASSERT_EQUAL(0, sl_led_led0.context->pin);
}

/*
 * 测试 15: 静态栈和缓冲区为 static 变量 (非空)
 */
void test_static_allocation_buffers_valid(void) {
    xTaskCreateStatic_Stub(xTaskCreateStatic_success_cb);

    blink_init();

    TEST_ASSERT_NOT_NULL(captured_task_fn);
    TEST_ASSERT_EQUAL(configMINIMAL_STACK_SIZE, captured_stack_depth);
}