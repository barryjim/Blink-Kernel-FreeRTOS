#ifndef SL_SIMPLE_LED_H
#define SL_SIMPLE_LED_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    uint16_t port;
    uint16_t pin;
    uint8_t polarity;
} sl_simple_led_context_t;

typedef struct sl_led_s {
    sl_simple_led_context_t *context;
    void (*init)(struct sl_led_s *led);
    void (*turn_on)(struct sl_led_s *led);
    void (*turn_off)(struct sl_led_s *led);
    void (*toggle)(struct sl_led_s *led);
    bool (*get_state)(struct sl_led_s *led);
} sl_led_t;

void sl_led_init(sl_led_t *led);
void sl_led_turn_on(sl_led_t *led);
void sl_led_turn_off(sl_led_t *led);
void sl_led_toggle(const sl_led_t *led);
bool sl_led_get_state(sl_led_t *led);

void sl_simple_led_init(sl_led_t *led);
void sl_simple_led_turn_on(sl_led_t *led);
void sl_simple_led_turn_off(sl_led_t *led);
void sl_simple_led_toggle(sl_led_t *led);
bool sl_simple_led_get_state(sl_led_t *led);

#ifdef __cplusplus
}
#endif

#endif /* SL_SIMPLE_LED_H */