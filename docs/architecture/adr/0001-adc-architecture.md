# ADR-0001: ADC architecture — TI AMC/DFSDM vs ADI ADE91xx/ADEMA (SPI)

- Status: **proposed**
- Date: TBD

## Context

V1.0 used TI **AMC3336** (voltage) and **AMC3306M25** (current) isolated sigma-delta modulators fed into the STM32H750 **DFSDM** peripheral at 78.125 kSps. For V2.0 we want a swappable measurement board and possibly a cheaper MCU without DFSDM.

## Options

### Option A — TI AMC + DFSDM (keep V1.0 approach)

- **Pros:** proven in V1.0, ~78 kSps, high resolution, integrated isolation + DC/DC converter.
- **Cons:** requires a DFSDM-capable MCU (locks us to STM32 H7 class); two chips per channel (voltage + current).

### Option B — ADI ADE9112/3 (isolated, SPI)

- **Pros:** one chip, SPI with daisy-chain, integrated isolation, channel synchronisation.
- **Cons:** 32 kSps (lower than V1.0), limited availability.

### Option C — ADI ADEMA124/127 (non-isolated, SPI)

- **Pros:** 64 kSps, internal Rogowski integrator + high-pass filter, 4 or 7 channels, same footprint family (flexible board).
- **Cons:** no isolation — needs external signal + power isolation.

## Decision

TBD — pending evaluation. Leaning towards **ADI-SPI** (Options B/C) to free the MCU choice and enable a passive measurement board.

## Consequences

- If ADI-SPI: measurement board is passive (ADC only); the control MCU can be smaller/slower.
- Isolation budget moves outside the ADC for ADEMA.
- Sample rate drops vs V1.0 (78 kSps) — verify Class S / THD headroom.
