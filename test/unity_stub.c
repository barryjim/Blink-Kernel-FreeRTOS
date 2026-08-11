#include "unity_stub.h"
#include <stdarg.h>

UnityStruct Unity;

static char formatted_msg[256];

int Unity_GetSelf(void) { return 0; }

const char *UnityMakeFormattedMessage(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vsnprintf(formatted_msg, sizeof(formatted_msg), fmt, args);
    va_end(args);
    return formatted_msg;
}

void UnityAssertEqualNumber(unsigned int expected, unsigned int actual,
                            const char *msg, unsigned int line, int size) {
    (void)size;
    if (expected != actual) {
        Unity.CurrentTestFailed = 1;
        printf("    FAIL at line %u: Expected %u but got %u", line, expected, actual);
        if (msg) printf(" (%s)", msg);
        printf("\n");
    }
}

void UnityAssertEqualString(const char *expected, const char *actual,
                            unsigned int line) {
    if (expected == NULL && actual == NULL) return;
    if (expected == NULL || actual == NULL || strcmp(expected, actual) != 0) {
        Unity.CurrentTestFailed = 1;
        printf("    FAIL at line %u: Expected \"%s\" but got \"%s\"\n",
               line, expected ? expected : "(null)", actual ? actual : "(null)");
    }
}

void UnityAssertEqualPointer(const void *expected, const void *actual,
                              unsigned int line) {
    if (expected != actual) {
        Unity.CurrentTestFailed = 1;
        printf("    FAIL at line %u: Expected %p but got %p\n",
               line, expected, actual);
    }
}

void UnityAssertNotNull(const void *ptr, unsigned int line) {
    if (ptr == NULL) {
        Unity.CurrentTestFailed = 1;
        printf("    FAIL at line %u: Pointer is NULL\n", line);
    }
}

void UnityAssertIsNull(const void *ptr, unsigned int line) {
    if (ptr != NULL) {
        Unity.CurrentTestFailed = 1;
        printf("    FAIL at line %u: Pointer is not NULL (%p)\n", line, ptr);
    }
}

void UnityAssertGreaterThanNumber(unsigned int threshold, unsigned int actual,
                                   unsigned int line) {
    if (!(actual > threshold)) {
        Unity.CurrentTestFailed = 1;
        printf("    FAIL at line %u: Expected %u > %u\n", line, actual, threshold);
    }
}

void UnityAssertGreaterOrEqualNumber(unsigned int threshold, unsigned int actual,
                                      unsigned int line) {
    if (!(actual >= threshold)) {
        Unity.CurrentTestFailed = 1;
        printf("    FAIL at line %u: Expected %u >= %u\n", line, actual, threshold);
    }
}

void UnityAssertLessThanNumber(unsigned int threshold, unsigned int actual,
                                unsigned int line) {
    if (!(actual < threshold)) {
        Unity.CurrentTestFailed = 1;
        printf("    FAIL at line %u: Expected %u < %u\n", line, actual, threshold);
    }
}

void UnityAssertLessOrEqualNumber(unsigned int threshold, unsigned int actual,
                                   unsigned int line) {
    if (!(actual <= threshold)) {
        Unity.CurrentTestFailed = 1;
        printf("    FAIL at line %u: Expected %u <= %u\n", line, actual, threshold);
    }
}

void UnityAssertTrue(int condition, unsigned int line) {
    if (!condition) {
        Unity.CurrentTestFailed = 1;
        printf("    FAIL at line %u: Expected TRUE\n", line);
    }
}

void UnityAssertFalse(int condition, unsigned int line) {
    if (condition) {
        Unity.CurrentTestFailed = 1;
        printf("    FAIL at line %u: Expected FALSE\n", line);
    }
}

void UnityTestRunnerStart(void) {
    memset(&Unity, 0, sizeof(Unity));
    printf("Unity test start\n");
}

void UnityTestRunnerEnd(void) {
    printf("\nUnity test结束: %d 测试, %d 失败, %d 忽略\n",
           Unity.NumberOfTests, Unity.TestFailures, Unity.TestIgnores);
    if (Unity.TestFailures == 0) {
        printf("ALL TESTS PASSED\n");
    } else {
        printf("SOME TESTS FAILED\n");
    }
}