#ifndef FREERTOS_H
#define FREERTOS_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef uint32_t TickType_t;
typedef uint32_t StackType_t;
typedef int BaseType_t;
typedef unsigned int UBaseType_t;
typedef uint32_t configSTACK_DEPTH_TYPE;

#define pdTRUE          ((BaseType_t) 1)
#define pdFALSE         ((BaseType_t) 0)
#define pdPASS          (pdTRUE)
#define pdFAIL          (pdFALSE)
#define pdWAIT          ((BaseType_t) 2)

#define tskIDLE_PRIORITY ((UBaseType_t) 0)

#define configTICK_RATE_HZ    ((TickType_t) 1000)
#define configMINIMAL_STACK_SIZE ((uint16_t) 160)

#define portMAX_DELAY        ((TickType_t) 0xFFFFFFFF)
#define portTICK_PERIOD_MS   ((TickType_t) (1000 / configTICK_RATE_HZ))

#define configMAX_TASK_NAME_LEN 16

typedef void (*TaskFunction_t)(void *);

typedef struct tskTaskControlBlock {
    volatile StackType_t *pxTopOfStack;
    StackType_t *pxStack;
    configSTACK_DEPTH_TYPE uxPriority;
    UBaseType_t uxCurrentPriority;
    char pcTaskName[configMAX_TASK_NAME_LEN];
    void *pvDummy1[8];
    UBaseType_t uxDummy2;
    struct tskTaskControlBlock *pxDummy1;
    struct tskTaskControlBlock *pxDummy2;
    void *pvDummy3[4];
    TickType_t xDummy1;
} tskTCB;

typedef tskTCB StaticTask_t;

#define EFM_ASSERT(x) ((void)0)

#ifndef INCLUDE_vTaskDelay
#define INCLUDE_vTaskDelay 1
#endif

#ifdef __cplusplus
}
#endif

#endif /* FREERTOS_H */