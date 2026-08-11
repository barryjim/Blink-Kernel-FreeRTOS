#ifndef UNITY_STUB_H
#define UNITY_STUB_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    const char *TestFile;
    unsigned int CurrentLineNumber;
    const char *CurrentTestName;
    unsigned char CurrentTestFailed;
    unsigned char CurrentTestIgnored;
    unsigned int NumberOfTests;
    unsigned int TestFailures;
    unsigned int TestIgnores;
    unsigned char SilenceFailures;
} UnityStruct;

extern UnityStruct Unity;

void UnityAssertEqualNumber(unsigned int expected, unsigned int actual,
                            const char *msg, unsigned int line, int size);
void UnityAssertEqualString(const char *expected, const char *actual,
                            unsigned int line);
void UnityAssertEqualPointer(const void *expected, const void *actual,
                              unsigned int line);
void UnityAssertNotNull(const void *ptr, unsigned int line);
void UnityAssertIsNull(const void *ptr, unsigned int line);
void UnityAssertGreaterThanNumber(unsigned int threshold, unsigned int actual,
                                   unsigned int line);
void UnityAssertGreaterOrEqualNumber(unsigned int threshold, unsigned int actual,
                                      unsigned int line);
void UnityAssertLessThanNumber(unsigned int threshold, unsigned int actual,
                                unsigned int line);
void UnityAssertLessOrEqualNumber(unsigned int threshold, unsigned int actual,
                                   unsigned int line);
void UnityAssertTrue(int condition, unsigned int line);
void UnityAssertFalse(int condition, unsigned int line);
void UnityTestRunnerStart(void);
void UnityTestRunnerEnd(void);
void UnityAddTest(const char *name, void (*func)(void));

int Unity_GetSelf(void);
const char *UnityMakeFormattedMessage(const char *fmt, ...);

void setUp(void);
void tearDown(void);

#define UNITY_BEGIN() UnityTestRunnerStart()
#define UNITY_END()   UnityTestRunnerEnd(), Unity.TestFailures

#define RUN_TEST(func) \
    Unity.CurrentTestName = #func; \
    Unity.CurrentTestFailed = 0; \
    Unity.CurrentTestIgnored = 0; \
    setUp(); \
    func(); \
    tearDown(); \
    Unity.NumberOfTests++; \
    if (Unity.CurrentTestFailed) { Unity.TestFailures++; } \
    printf("  %s: %s\n", Unity.CurrentTestFailed ? "FAIL" : "PASS", #func);

#define TEST_ASSERT_EQUAL(expected, actual) \
    UnityAssertEqualNumber((unsigned int)(expected), (unsigned int)(actual), NULL, __LINE__, 4)

#define TEST_ASSERT_EQUAL_STRING(expected, actual) \
    UnityAssertEqualString((const char *)(expected), (const char *)(actual), __LINE__)

#define TEST_ASSERT_EQUAL_PTR(expected, actual) \
    UnityAssertEqualPointer((const void *)(expected), (const void *)(actual), __LINE__)

#define TEST_ASSERT_NOT_NULL(ptr) \
    UnityAssertNotNull((const void *)(ptr), __LINE__)

#define TEST_ASSERT_NULL(ptr) \
    UnityAssertIsNull((const void *)(ptr), __LINE__)

#define TEST_ASSERT_GREATER_THAN(threshold, actual) \
    UnityAssertGreaterThanNumber((unsigned int)(threshold), (unsigned int)(actual), __LINE__)

#define TEST_ASSERT_GREATER_OR_EQUAL(threshold, actual) \
    UnityAssertGreaterOrEqualNumber((unsigned int)(threshold), (unsigned int)(actual), __LINE__)

#define TEST_ASSERT_LESS_THAN(threshold, actual) \
    UnityAssertLessThanNumber((unsigned int)(threshold), (unsigned int)(actual), __LINE__)

#define TEST_ASSERT_LESS_OR_EQUAL(threshold, actual) \
    UnityAssertLessOrEqualNumber((unsigned int)(threshold), (unsigned int)(actual), __LINE__)

#define TEST_ASSERT_TRUE(condition) \
    UnityAssertTrue((int)(condition), __LINE__)

#define TEST_ASSERT_FALSE(condition) \
    UnityAssertFalse((int)(condition), __LINE__)

#define TEST_ASSERT_EQUAL_FLOAT(expected, actual) \
    UnityAssertEqualNumber((unsigned int)(expected), (unsigned int)(actual), NULL, __LINE__, 4)

#define UNITY_TEST_FAIL(line, msg) \
    do { Unity.CurrentTestFailed = 1; \
         printf("    FAIL at line %u: %s\n", line, msg); \
         return; } while(0)

#ifdef __cplusplus
}
#endif

#endif /* UNITY_STUB_H */