#include "mock_task.h"

/* ======================== xTaskCreateStatic ======================== */

static mock_ctrl_t xTaskCreateStatic_ctrl;
static xTaskCreateStatic_callback_t xTaskCreateStatic_cb = NULL;
static TaskHandle_t xTaskCreateStatic_default_retval = NULL;
static int xTaskCreateStatic_expect_any_args = 0;

TaskHandle_t xTaskCreateStatic(
    TaskFunction_t pvTaskCode,
    const char *pcName,
    configSTACK_DEPTH_TYPE uxStackDepth,
    void *pvParameters,
    UBaseType_t uxPriority,
    StackType_t *puxStackBuffer,
    StaticTask_t *pxTaskBuffer
) {
    xTaskCreateStatic_ctrl.call_count++;
    if (xTaskCreateStatic_cb) {
        return xTaskCreateStatic_cb(pvTaskCode, pcName, uxStackDepth,
                                     pvParameters, uxPriority,
                                     puxStackBuffer, pxTaskBuffer);
    }
    return xTaskCreateStatic_default_retval;
}

void xTaskCreateStatic_Stub(xTaskCreateStatic_callback_t callback) {
    xTaskCreateStatic_cb = callback;
}

void xTaskCreateStatic_ExpectAnyArgs(void) {
    xTaskCreateStatic_expect_any_args = 1;
    xTaskCreateStatic_ctrl.expect_any_args_called = 1;
}

void xTaskCreateStatic_Return(TaskHandle_t retval) {
    xTaskCreateStatic_default_retval = retval;
}

void xTaskCreateStatic_ExpectAndReturn(
    TaskFunction_t pvTaskCode,
    const char *pcName,
    configSTACK_DEPTH_TYPE uxStackDepth,
    void *pvParameters,
    UBaseType_t uxPriority,
    StackType_t *puxStackBuffer,
    StaticTask_t *pxTaskBuffer,
    TaskHandle_t retval
) {
    (void)pvTaskCode;
    (void)pcName;
    (void)uxStackDepth;
    (void)pvParameters;
    (void)uxPriority;
    (void)puxStackBuffer;
    (void)pxTaskBuffer;
    xTaskCreateStatic_default_retval = retval;
    xTaskCreateStatic_ctrl.max_expected_calls = 1;
}

int xTaskCreateStatic_call_count(void) {
    return xTaskCreateStatic_ctrl.call_count;
}

void xTaskCreateStatic_Verify(void) {
    mock_ctrl_check_calls(&xTaskCreateStatic_ctrl, "xTaskCreateStatic");
}

/* ======================== xTaskCreate ======================== */

static mock_ctrl_t xTaskCreate_ctrl;
static xTaskCreate_callback_t xTaskCreate_cb = NULL;
static BaseType_t xTaskCreate_default_retval = pdPASS;

BaseType_t xTaskCreate(
    TaskFunction_t pvTaskCode,
    const char *pcName,
    configSTACK_DEPTH_TYPE usStackDepth,
    void *pvParameters,
    UBaseType_t uxPriority,
    TaskHandle_t *pxCreatedTask
) {
    xTaskCreate_ctrl.call_count++;
    if (xTaskCreate_cb) {
        return xTaskCreate_cb(pvTaskCode, pcName, usStackDepth,
                              pvParameters, uxPriority, pxCreatedTask);
    }
    return xTaskCreate_default_retval;
}

void xTaskCreate_Stub(xTaskCreate_callback_t callback) {
    xTaskCreate_cb = callback;
}

void xTaskCreate_ExpectAnyArgs(void) {
    xTaskCreate_ctrl.expect_any_args_called = 1;
}

void xTaskCreate_Return(BaseType_t retval) {
    xTaskCreate_default_retval = retval;
}

int xTaskCreate_call_count(void) {
    return xTaskCreate_ctrl.call_count;
}

void xTaskCreate_Verify(void) {
    mock_ctrl_check_calls(&xTaskCreate_ctrl, "xTaskCreate");
}

/* ======================== vTaskDelay ======================== */

static mock_ctrl_t vTaskDelay_ctrl;
static vTaskDelay_callback_t vTaskDelay_cb = NULL;

void vTaskDelay(TickType_t xTicksToDelay) {
    vTaskDelay_ctrl.call_count++;
    if (vTaskDelay_cb) {
        vTaskDelay_cb(xTicksToDelay);
    }
}

void vTaskDelay_Stub(vTaskDelay_callback_t callback) {
    vTaskDelay_cb = callback;
}

void vTaskDelay_ExpectAnyArgs(void) {
    vTaskDelay_ctrl.expect_any_args_called = 1;
}

int vTaskDelay_call_count(void) {
    return vTaskDelay_ctrl.call_count;
}

void vTaskDelay_Verify(void) {
    mock_ctrl_check_calls(&vTaskDelay_ctrl, "vTaskDelay");
}

/* ======================== Init / Cleanup ======================== */

void Mocktask_Init(void) {
    mock_ctrl_init(&xTaskCreateStatic_ctrl);
    mock_ctrl_init(&xTaskCreate_ctrl);
    mock_ctrl_init(&vTaskDelay_ctrl);

    xTaskCreateStatic_cb = NULL;
    xTaskCreate_cb = NULL;
    vTaskDelay_cb = NULL;

    xTaskCreateStatic_default_retval = NULL;
    xTaskCreate_default_retval = pdPASS;
    xTaskCreateStatic_expect_any_args = 0;
}

void Mocktask_Cleanup(void) {
    mock_ctrl_reset(&xTaskCreateStatic_ctrl);
    mock_ctrl_reset(&xTaskCreate_ctrl);
    mock_ctrl_reset(&vTaskDelay_ctrl);

    xTaskCreateStatic_cb = NULL;
    xTaskCreate_cb = NULL;
    vTaskDelay_cb = NULL;
}

void Mocktask_Verify(void) {
    xTaskCreateStatic_Verify();
    xTaskCreate_Verify();
    vTaskDelay_Verify();
}