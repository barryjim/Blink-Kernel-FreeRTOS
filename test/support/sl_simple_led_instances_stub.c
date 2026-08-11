#include "sl_simple_led_instances.h"

void sl_simple_led_init(sl_led_t *led) {
    (void)led;
}

void sl_simple_led_turn_on(sl_led_t *led) {
    (void)led;
}

void sl_simple_led_turn_off(sl_led_t *led) {
    (void)led;
}

bool sl_simple_led_get_state(sl_led_t *led) {
    (void)led;
    return false;
}

static sl_simple_led_context_t test_led_context = {
    .port = 0,
    .pin = 0,
    .polarity = 0,
};

const sl_led_t sl_led_led0 = {
    .context = &test_led_context,
    .init = sl_simple_led_init,
    .turn_on = sl_simple_led_turn_on,
    .turn_off = sl_simple_led_turn_off,
    .toggle = sl_simple_led_toggle,
    .get_state = sl_simple_led_get_state,
};