#ifndef MOCK_SL_SIMPLE_LED_H
#define MOCK_SL_SIMPLE_LED_H

#include "sl_simple_led.h"
#include "mock_support.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*sl_led_toggle_callback_t)(const sl_led_t *led);

void sl_led_toggle_Stub(sl_led_toggle_callback_t callback);
void sl_led_toggle_ExpectAnyArgs(void);
int sl_led_toggle_call_count(void);
void sl_led_toggle_Verify(void);

typedef void (*sl_led_init_callback_t)(sl_led_t *led);
void sl_led_init_Stub(sl_led_init_callback_t callback);

typedef void (*sl_led_turn_on_callback_t)(sl_led_t *led);
void sl_led_turn_on_Stub(sl_led_turn_on_callback_t callback);

typedef void (*sl_led_turn_off_callback_t)(sl_led_turn_off_callback_t callback);
void sl_led_turn_off_Stub(sl_led_turn_off_callback_t callback);

typedef bool (*sl_led_get_state_callback_t)(sl_led_t *led);
void sl_led_get_state_Stub(sl_led_get_state_callback_t callback);
void sl_led_get_state_Return(bool state);

void Mocksl_simple_led_Init(void);
void Mocksl_simple_led_Cleanup(void);
void Mocksl_simple_led_Verify(void);

#ifdef __cplusplus
}
#endif

#endif /* MOCK_SL_SIMPLE_LED_H */