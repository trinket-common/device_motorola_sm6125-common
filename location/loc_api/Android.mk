ifneq ($(QCPATH),)
LOCAL_PATH := $(call my-dir)
include $(call all-subdir-makefiles)
endif #QCPATH