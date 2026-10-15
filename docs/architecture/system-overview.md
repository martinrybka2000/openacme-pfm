# System overview

OpenACME-PFM is split into two boards so one reusable digital core can pair with different measurement front-ends.

```
+---------------------+       digital data        +----------------------+
|   Measurement board | <------------------------> |      Control board   |
|   (shunt / CT /     |   sigma-delta or SPI       |  MCU, power,         |
|    Rogowski, 1ph/3ph)|                            |  Ethernet/Modbus/    |
+---------------------+                            |  HMI, SD, flash      |
                                                    +----------------------+
```

## Control board

- MCU (STM32 family, TBD — see ADR-0001)
- Power: 24 V DC; USB-C for configuration/initial bring-up
- Ethernet PHY, Modbus RTU/RS485
- OLED + buttons, SD card
- External QSPI flash + EEPROM

## Measurement board

- The analogue front-end: input conditioning, isolation, sigma-delta ADC(s).
- Optional transformer-fed supply from the measured phase.
- Swappable variants: 1-phase or 3-phase; series shunt or non-invasive CT/Rogowski.
- Candidate ADCs are compared in `docs/architecture/adr/0001-adc-architecture.md`.

## WiFi variant

A separate board variant with an ESP instead of the STM32. Firmware is written to be maximally portable — only the hardware-specific layer differs.

> The exact split of boards in KiCad is still TBD.

See `docs/requirements/requirements.md` for the full requirement set.
