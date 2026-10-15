# Requirements (V2.0)

Status: **draft**. Working requirements for the V2.0 redesign, distilled from the V1.0 master's thesis and project notes.

## Goals

- Rebuild the V1.0 single-phase power quality meter as a modular, open-source platform.
- Fix the V1.0 limitations: 128 kB flash ceiling, shunt thermal drift, MII/RMII pin conflict, no HMI, no storage.
- Informational, best-effort alignment with **IEC 61000-4-30 Class S** (the less strict of the two classes) — not a formal certification target.

## Non-functional requirements

- Open source under strong copyleft (GPL-3.0 / CERN-OHL-S-2.0 / CC-BY-SA-4.0).
- Public documentation in English.
- Reproducible: everything needed to build is in this repository.

## Functional requirements

### Hardware architecture

- **REQ-HW-01** Two-board split (exact KiCad split TBD):
  - **Control board** — MCU, power, Ethernet/Modbus, HMI, SD, external flash + EEPROM.
  - **Measurement board** — swappable: 1-phase or 3-phase; series (shunt) or non-invasive (CT / Rogowski).
- **REQ-HW-02** Isolated, high-rate sigma-delta acquisition.
- **REQ-HW-03** External Flash (QSPI) (if needed) + dedicated EEPROM (fixes the V1.0 flash limit).
- **REQ-HW-04** Power (split across boards, exact placement TBD): 24 V DC on the control board; USB-C for configuration/initial bring-up; optional transformer-fed supply from the measured phase.
- **REQ-HW-05** DIN-rail enclosure with normalized mounting.

### Peripherals / HMI

- **REQ-HMI-01** OLED + buttons menu (restores the V1.0 plan).
- **REQ-HMI-02** SD-card slot for measurement logging (feasibility TBD).

### Measurement

- **REQ-M-01** Measure: Urms, Irms, U1/I1 (fundamental), P, P1, Q1, S, S1, N, PF, DPF, DF, THD_U, THD_I, frequency, peak.
- **REQ-M-02** SOGI-PLL grid synchronisation + FFT; 10-cycle aggregation window (IEC 61000-4-7).
- **REQ-M-03** Additional power-quality parameters: voltage dips/swells, flicker.
- **REQ-M-04** Best-effort Class S behaviour (IEC 61000-4-30) — informational, not certified.

### Communication

- **REQ-C-01** Modbus TCP (configuration + readout).
- **REQ-C-02** Modbus RTU / RS485 (hardware).
- **REQ-C-03** PQDIF export (IEEE 1159.3).
- **REQ-C-04** WiFi on a separate board variant with an ESP (instead of the STM32), sharing a maximally portable firmware core.

### Firmware

- **REQ-FW-01** Maximally portable firmware: a shared, hardware-independent core with a thin hardware-abstraction layer, so the STM32 and ESP variants differ only in hardware-specific code.

### Host software

- **REQ-SW-01** Desktop configuration app speaking Modbus (stack TBD).

## Open decisions (see ADRs)

- ADC architecture: ADI ADE9112/ADEMA (SPI) vs TI AMC (DFSDM) — see `docs/architecture/adr/0001-adc-architecture.md`.
- Which MCU(s) to use
- Host app language/stack.
