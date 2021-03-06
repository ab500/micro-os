#include "Timer.h"

configuration Ds2411C {
    provides interface ReadId48;
}
implementation {
    components
        Ds2411P,
        OneWireMasterC,
        BusyWaitMicroC;

    components HplMsp430GeneralIOC as Hpl,
      new Msp430GpioC() as Gpio;
    Gpio.HplGeneralIO -> Hpl.Port24;
    
    ReadId48 = Ds2411P;
    Ds2411P.OneWire -> OneWireMasterC;
    OneWireMasterC.Pin -> Gpio;
    OneWireMasterC.BusyWait -> BusyWaitMicroC;
}
