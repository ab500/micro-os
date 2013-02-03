#include "PlatformIeeeEui64.h"

module DallasId48ToIeeeEui64C {
  provides interface LocalIeeeEui64;
  uses interface ReadId48;
} implementation {
  command ieee_eui64_t LocalIeeeEui64.getId() {
    uint8_t id[6];
    ieee_eui64_t eui;
    if (call ReadId48.read(id) != SUCCESS) {
      memset(eui.data, 0, 8);
      goto done;
    }

    eui.data[0] = IEEE_EUI64_COMPANY_ID_0;
    eui.data[1] = IEEE_EUI64_COMPANY_ID_1;
    eui.data[2] = IEEE_EUI64_COMPANY_ID_2;

    // 16 bits of the ID is generated by software
    // could be used for hardware model id and revision, for example
    eui.data[3] = IEEE_EUI64_SERIAL_ID_0;
    eui.data[4] = IEEE_EUI64_SERIAL_ID_1;

    // 24 least significant bits of the serial ID read from the DS2401
    eui.data[5] = id[2];
    eui.data[6] = id[1];
    eui.data[7] = id[0];

  done:
    return eui;
  }
}
