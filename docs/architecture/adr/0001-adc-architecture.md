# ADR-0001: ADC architecture — TI AMC/DFSDM vs ADI ADE91xx/ADEMA (SPI)

- Status: **proposed**
- Date: TBD

## Context

V1.0 used TI **AMC3336** (voltage) and **AMC3306M25** (current) isolated sigma-delta modulators fed into the STM32H750 **DFSDM** peripheral at 78.125 kSps. For V2.0 we want a swappable measurement board and possibly a cheaper MCU without DFSDM.

## Options

### 1 phase

- **Rogowski or CT**
  - $\color{green}{\text{ADEMA124}}$
    - **Pros:** ~64 kSps, internal rogowski integrator, one chip,
    - **Cons:** no isolation, 2 channels unused
- **Shunt**
  - TI AMC
    - **Pros:** ~78 kSps,
    - **Cons:** needs DFSDM, two chips (one for current, one for voltage),
  - $\color{green}{\text{ADE9112 }}$
    - **Pros:** isolated, one chip,
    - **Cons:** ~32 kSps, problems with supply

### 3 phase

- **Rogowski or CT**
  - ADEMA124 + ADE 9113
    - **Pros:** isolated, SPI chain, internal synchronisation, internal rogowski integrator
    - **Cons:** ~32 kSps, two chips, in 9113 the third current channel would be used for voltage measurement
  - $\color{green}{\text{ADEMA127}}$
    - **Pros:** ~64 kSps, one chip, SPI chain, internal synchronisation, internal rogowski integrator, same footprint as ADEMA124.
    - **Cons:** no isolation

- **Shunt**
  - $\color{green}{\text{3x ADE9112}}$
    - **Pros:** isolated, SPI chain, internal synchronisation
    - **Cons:** ~32 kSps, problems with supply

## Consequences

- If ADI-SPI: measurement board is passive (ADC only); the control MCU can be smaller/slower.
- Isolation budget moves outside the ADC for ADEMA.
- Sample rate drops vs V1.0 (78 kSps).
- Isolation of power supply and SPI is needed
