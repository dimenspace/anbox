PRODUCT_MAKEFILES := \
   $(LOCAL_DIR)/anbox_x86_64.mk \
   $(LOCAL_DIR)/anbox_armv7a_neon.mk \
   $(LOCAL_DIR)/anbox_arm64.mk \


COMMON_LUNCH_CHOICES := \
   anbox_x86_64-userdebug \
   anbox_x86_64-user \
   anbox_armv7a_neon-userdebug \
   anbox_armv7a_neon-user \
   anbox_arm64-userdebug \
   anbox_arm64-user
