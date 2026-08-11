#ifndef TASK_H
#define TASK_H

#include "FreeRTOS.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct tskTaskControlBlock *TaskHandle_t;

BaseType_t xTaskCreate(
    TaskFunction_t pvTaskCode,
    const char *pcName,
    configSTACK_DEPTH_TYPE usStackDepth,
    void *pvParameters,
    UBaseType_t uxPriority,
    TaskHandle_t *pxCreatedTask
);

TaskHandle_t xTaskCreateStatic(
    TaskFunction_t pvTaskCode,
    const char *pcName,
    configSTACK_DEPTH_TYPE uxStackDepth,
    void *pvParameters,
    UBaseType_t uxPriority,
    StackType_t *puxStackBuffer,
    StaticTask_t *pxTaskBuffer
);

void vTaskDelay(TickType_t xTicksToDelay);

#define pdMS_TO_TICKS(xTimeInMs) \
    ((TickType_t)((xTimeInMs) * (TickType_t)configTICK_RATE_HZ / (TickType_t)1000))

#ifdef __cplusplus
}
#endif

#endif /* TASK_H */