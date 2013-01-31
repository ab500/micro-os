configuration HplCC2420XC {
    provides {
        interface Resource as SpiResource;
        interface FastSpiByte;
        interface GeneralIO as CCA;
        interface GeneralIO as CSN;
        interface GeneralIO as FIFO;
        interface GeneralIO as FIFOP;
        interface GeneralIO as RSTN;
        interface GeneralIO as SFD;
        interface GeneralIO as VREN;
        interface GpioCapture as SfdCapture;
        interface GpioInterrupt as FifopInterrupt;

        interface LocalTime<TRadio> as LocalTimeRadio;
        interface Init;
        interface Alarm<TRadio,uint16_t>;
    }
}
implementation {

    components HplMsp430GeneralIOC as IO, new Msp430Spi1C() as SpiC;

    // pins
    components new Msp430GpioC() as CCAM;
    components new Msp430GpioC() as CSNM;
    components new Msp430GpioC() as FIFOM;
    components new Msp430GpioC() as FIFOPM;
    components new Msp430GpioC() as RSTNM;
    components new Msp430GpioC() as SFDM;
    components new Msp430GpioC() as VRENM;
    
    CCAM -> IO.Port14;
    CSNM -> IO.Port41;
    FIFOM -> IO.Port13;
    FIFOPM -> IO.Port10;
    RSTNM -> IO.Port46;
    SFDM -> IO.Port41;
    VRENM -> IO.Port45;
    
    CCA = CCAM;
    CSN = CSNM;
    FIFO = FIFOM;
    FIFOP = FIFOPM;
    RSTN = RSTNM;
    SFD = SFDM;
    VREN = VRENM;

    // spi  
    SpiResource = SpiC.Resource;
    FastSpiByte = SpiC;

    // capture
    components Msp430TimerC as TimerC;
    components new GpioCaptureC();
    GpioCaptureC.Msp430TimerControl -> TimerC.ControlA1;
    GpioCaptureC.Msp430Capture -> TimerC.CaptureA1;
    GpioCaptureC.GeneralIO -> IO.Port41;
    SfdCapture = GpioCaptureC;

    components new Msp430InterruptC() as FifopInterruptC, HplMsp430InterruptC;
    FifopInterruptC.HplInterrupt -> HplMsp430InterruptC.Port10;
    FifopInterrupt = FifopInterruptC.Interrupt; 

    // alarm
    components new AlarmMicro16C() as AlarmC;
    Alarm = AlarmC;
    Init = AlarmC;

    // localTime
    components LocalTimeMicroC;
    LocalTimeRadio = LocalTimeMicroC.LocalTime;
}
