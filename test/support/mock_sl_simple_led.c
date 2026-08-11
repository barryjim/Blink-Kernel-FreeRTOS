#include "mock_sl_simple_led.h"

/* ======================== sl_led_toggle ======================== */

static mock_ctrl_t sl_led_toggle_ctrl;
static sl_led_toggle_callback_t sl_led_toggle_cb = NULL;

void sl_led_toggle(const sl_led_t *led) {
    sl_led_toggle_ctrl.call_count++;
    if (sl_led_toggle_cb) {
        sl_led_toggle_cb(led);
    }
}

void sl_led_toggle_Stub(sl_led_toggle_callback_t callback) {
    sl_led_toggle_cb = callback;
}

void sl_led_toggle_ExpectAnyArgs(void) {
    sl_led_toggle_ctrl.expect_any_args_called = 1;
}

int sl_led_toggle_call_count(void) {
    return sl_led_toggle_ctrl.call_count;
}

void sl_led_toggle_Verify(void) {
    mock_ctrl_check_calls(&sl_led_toggle_ctrl, "sl_led_toggle");
}

/* ======================== sl_led_init ======================== */

static mock_ctrl_t sl_led_init_ctrl;
static sl_led_init_callback_t sl_led_init_cb = NULL;

void sl_led_init(sl_led_t *led) {
    sl_led_init_ctrl.call_count++;
    if (sl_led_init_cb) {
        sl_led_init_cb(led);
    }
}

void sl_led_init_Stub(sl_led_init_callback_t callback) {
    sl_led_init_cb = callback;
}

/* ======================== sl_led_turn_on ======================== */

static sl_led_turn_on_callback_t sl_led_turn_on_cb = NULL;

void sl_led_turn_on(sl_led_t *led) {
    if (sl_led_turn_on_cb) {
        sl_led_turn_on_cb(led);
    }
}

void sl_led_turn_on_Stub(sl_led_turn_on_callback_t callback) {
    sl_led_turn_on_cb = callback;
}

/* ======================== sl_led_turn_off ======================== */

static sl_led_turn_off_callback_t sl_led_turn_off_cb = NULL;

void sl_led_turn_off(sl_led_t *led) {
    if (sl_led_turn_off_cb) {
        sl_led_turn_off_cb(led);
    }
}

void sl_led_turn_off_Stub(sl_led_turn_off_callback_t callback) {
    sl_led_turn_off_cb = callback;
}

/* ======================== sl_led_get_state ======================== */

static sl_led_get_state_callback_t sl_led_get_state_cb = NULL;
static bool sl_led_get_state_default_retval = false;

bool sl_led_get_state(sl_led_t *led) {
    if (sl_led_get_state_cb) {
        return sl_led_get_state_cb(led);
    }
    return sl_led_get_state_default_retval;
}

void sl_led_get_state_Stub(sl_led_get_state_callback_t callback) {
    sl_led_get_state_cb = callback;
}

void sl_led_get_state_Return(bool state) {
    sl_led_get_state_default_retval = state;
}

/* ======================== Init / Cleanup ======================== */

void Mocksl_simple_led_Init(void) {
    mock_ctrl_init(&sl_led_toggle_ctrl);
    mock_ctrl_init(&sl_led_init_ctrl);

    sl_led_toggle_cb = NULL;
    sl_led_init_cb = NULL;
    sl_led_turn_on_cb = NULL;
    sl_led_turn_off_cb = NULL;
    sl_led_get_state_cb = NULL;
    sl_led_get_state_default_retval = false;
}

void Mocksl_simple_led_Cleanup(void) {
    mock_ctrl_reset(&sl_led_toggle_ctrl);
    mock_ctrl_reset(&sl_led_init_ctrl);

    sl_led_toggle_cb = NULL;
    sl_led_init_cb = NULL;
    sl_led_turn_on_cb = NULL;
    sl_led_turn_off_cb = NULL;
    sl_led_get_state_cb = NULL;
}

void Mocksl_simple_led_Verify(void) {
    mock_ctrl_check_calls(&sl_led_toggle_ctrl, "sl_led_toggle");
    mock_ctrl_check_calls(&sl_led_init_ctrl, "sl_led_init");
}