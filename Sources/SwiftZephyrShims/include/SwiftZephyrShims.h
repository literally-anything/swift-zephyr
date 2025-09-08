/*
 * BridgingHeader.h
 * include
 * 
 * Created by Hunter Baker on 9/01/2025
 * Copyright (C) 2025-2025, by Hunter Baker hunter@literallyanything.net
 */

#pragma once

#include <autoconf.h>

#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/sys/reboot.h>
#include <zephyr/sys/timeutil.h>

#include <zephyr/drivers/hwinfo.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/dt-bindings/gpio/gpio.h>
#include <zephyr/drivers/led.h>

inline k_timeout_t _sToKTimeout(int32_t s) {
    return K_SECONDS(s);
}
inline k_timeout_t _msToKTimeout(int32_t ms) {
    return K_MSEC(ms);
}
inline k_timeout_t _usToKTimeout(int32_t us) {
    return K_USEC(us);
}
inline k_timeout_t _nsToKTimeout(int32_t ns) {
    return K_NSEC(ns);
}
