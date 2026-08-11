CC = gcc
CFLAGS = -Wall -Wextra -Wno-unused-parameter -g -O0 \
         -I. \
         -I./support \
         -I../ \
         -DUNIT_TESTING=1

UNITY_SRCS = unity_stub.c

MOCK_SRCS = \
    support/mock_task.c \
    support/mock_sl_simple_led.c

SUPPORT_SRCS = \
    support/sl_simple_led_instances_stub.c

TARGET = test_blink
TARGET_DYNAMIC = test_blink_dynamic

.PHONY: all clean test test_dynamic

all: $(TARGET)

$(TARGET): test_runner.c test_blink.c ../blink.c $(MOCK_SRCS) $(SUPPORT_SRCS) $(UNITY_SRCS)
	$(CC) $(CFLAGS) -o $@ $^
	@echo "Build successful (static allocation)."

$(TARGET_DYNAMIC): test_runner.c test_blink.c ../blink.c $(MOCK_SRCS) $(SUPPORT_SRCS) $(UNITY_SRCS)
	$(CC) $(CFLAGS) -DEXAMPLE_USE_STATIC_ALLOCATION=0 -o $@ $^
	@echo "Build successful (dynamic allocation)."

test: $(TARGET)
	@echo ""
	@echo "============================================"
	@echo "  Running CMock Unit Tests (static)"
	@echo "============================================"
	@echo ""
	@./$(TARGET)

test_dynamic: $(TARGET_DYNAMIC)
	@echo ""
	@echo "============================================"
	@echo "  Running CMock Unit Tests (dynamic)"
	@echo "============================================"
	@echo ""
	@./$(TARGET_DYNAMIC)

clean:
	rm -f $(TARGET) $(TARGET_DYNAMIC)