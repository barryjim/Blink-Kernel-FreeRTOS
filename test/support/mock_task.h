#ifndef MOCK_TASK_H
#define MOCK_TASK_H

#include "FreeRTOS.h"
#include "task.h"
#include "mock_support.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef TaskHandle_t (*xTaskCreateStatic_callback_t)(
    TaskFunction_t pvTaskCode,
    const char *pcName,
    configSTACK_DEPTH_TYPE uxStackDepth,
    void *pvParameters,
    UBaseType_t uxPriority,
    StackType_t *puxStackBuffer,
    StaticTask_t *pxTaskBuffer
);

void xTaskCreateStatic_Stub(xTaskCreateStatic_callback_t callback);
void xTaskCreateStatic_ExpectAnyArgs(void);
void xTaskCreateStatic_Return(TaskHandle_t retval);
void xTaskCreateStatic_ExpectAndReturn(
    TaskFunction_t pvTaskCode,
    const char *pcName,
    configSTACK_DEPTH_TYPE uxStackDepth,
    void *pvParameters,
    UBaseType_t uxPriority,
    StackType_t *puxStackBuffer,
    StaticTask_t *pxTaskBuffer,
    TaskHandle_t retval
);
int xTaskCreateStatic_call_count(void);
void xTaskCreateStatic_Verify(void);

typedef BaseType_t (*xTaskCreate_callback_t)(
    TaskFunction_t pvTaskCode,
    const char *pcName,
    configSTACK_DEPTH_TYPE usStackDepth,
    void *pvParameters,
    UBaseType_t uxPriority,
    TaskHandle_t *pxCreatedTask
);

void xTaskCreate_Stub(xTaskCreate_callback_t callback);
void xTaskCreate_ExpectAnyArgs(void);
void xTaskCreate_Return(BaseType_t retval);
int xTaskCreate_call_count(void);
void xTaskCreate_Verify(void);

typedef void (*vTaskDelay_callback_t)(TickType_t xTicksToDelay);

void vTaskDelay_Stub(vTaskDelay_callback_t callback);
void vTaskDelay_ExpectAnyArgs(void);
int vTaskDelay_call_count(void);
void vTaskDelay_Verify(void);

void Mocktask_Init(void);
void Mocktask_Cleanup(void);
void Mocktask_Verify(void);

#ifdef __cplusplus
}
#endif

#endif /* MOCK_TASK_H */