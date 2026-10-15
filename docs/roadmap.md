# Roadmap

Checkboxes reflect the current plan; see also the GitHub issues and `docs/architecture/adr/`.

## Measurement (primary)

- [x] Research ADCs for 1-/3-phase, series and clamp (see ADR-0001)
  - [ ] Research isolation for SPI and ADCs power supply
- [x] Research Rogowski coils and CTs
- [ ] AC Measurement signal filtering

## Power

- [ ] 24 V → 3.3 V converters (control board)
- [ ] USB-C supply for configuration / initial bring-up
- [ ] Transformer-fed supply from the measured phase (option)
- [ ] Power filtering / protection

## MCU

- [ ] Decide: smaller/slower MCU (drop DFSDM?) — see ADR-0001
- [ ] External flash requirement
- [ ] Interfaces: I2C, UART, SPI (fast), RMII, USB-C?, SD?

## Peripherals

- [ ] USB-C configuration / initial bring-up
- [ ] SD-card feasibility

## Software

- [ ] Informational Class S alignment (IEC 61000-4-30) — not a certification target
- [ ] Modbus map + PQDIF format
- [ ] Portable firmware core shared by the STM32 and ESP variants
