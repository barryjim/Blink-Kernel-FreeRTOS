#ifndef MOCK_SUPPORT_H
#define MOCK_SUPPORT_H

#include "unity_stub.h"
#include <stdarg.h>
#include <setjmp.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*cmock_callback_function)(void);

typedef struct {
    int call_count;
    int max_expected_calls;
    int expect_any_args_called;
    int ignore_all_calls;
} mock_ctrl_t;

static inline void mock_ctrl_init(mock_ctrl_t *ctrl) {
    ctrl->call_count = 0;
    ctrl->max_expected_calls = -1;
    ctrl->expect_any_args_called = 0;
    ctrl->ignore_all_calls = 0;
}

static inline void mock_ctrl_reset(mock_ctrl_t *ctrl) {
    ctrl->call_count = 0;
    ctrl->max_expected_calls = -1;
    ctrl->expect_any_args_called = 0;
    ctrl->ignore_all_calls = 0;
}

static inline void mock_ctrl_expect_calls(mock_ctrl_t *ctrl, int count) {
    ctrl->max_expected_calls = count;
}

static inline int mock_ctrl_check_calls(mock_ctrl_t *ctrl, const char *name) {
    if (ctrl->max_expected_calls >= 0 && ctrl->call_count != ctrl->max_expected_calls) {
        Unity.CurrentTestFailed = 1;
        printf("    FAIL: %s: Expected %d calls but got %d\n",
               name, ctrl->max_expected_calls, ctrl->call_count);
        return 0;
    }
    return 1;
}

#ifdef __cplusplus
}
#endif

#endif /* MOCK_SUPPORT_H */