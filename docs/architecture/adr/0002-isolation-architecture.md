# ADR-0002: Measurement-side isolation (SPI signals + power) for ADEMA124/127

- Status: **proposed**
- Date: TBD

## Context

The chosen measurement ADCs — ADI **ADEMA124/127** — are *non-isolated*. For a
mains-connected meter, both the digital interface and the ADC supply must be
galvanically isolated from the control board.

## Requirements (from ADEMA124/127 datasheet)

- **Signals to isolate:** SCLK, MOSI, CS, STDBY, RESET (forward, MCU→ADC) +
  MISO (reverse, ADC→MCU) = **5 forward / 1 reverse = 6 channels**.
  (Synchronisation is done via the `SYNC_SNAP` SPI register, not a dedicated pin.)
- **SPI clock:** ≤ 22 MHz (fSCLK max), ~12 Mbps actually needed
  (64 kSps × 24-bit × 7 ch + CRC).
- **Supply:** ~4–13 mA at 3.3 V depending on mode (≈ 15–45 mW).
- **Isolation:** mains-rated (230 V AC), reinforced preferred, high CMTI

## Options

### Option A — ADI ADuM4151 + ADuM6028

- **ADuM4151** — 5 kV, 7-channel SPIsolator: **4 high-speed SPI channels**
  (CLK, MO/SI, MI/SO, SS = 3 fwd / 1 rev) + **3 low-speed 250 kbps channels**
  (STDBY, RESET, spare). 17 MHz SPI clock, 14 ns prop delay, 1 ns jitter.
  **CMTI >25 kV/µs**, 8.3 mm creepage, VIORM 645 Vpk.
- **ADuM6028** — isoPower isolated DC-DC, up to ~500 mW (IISO 60 mA @ 5 V out),
  8-lead SOIC_IC. **33% efficiency, 180 MHz switching (needs ferrites), 75 mV
  ripple / 200 mV noise.**
- Total: **2 ICs**.

### Option B — TI ISOW774x + ISO6731

- **ISOW7740** (4 fwd / 0 rev) — 100 Mbps, 5 kVrms, **integrated 550 mW
  low-emissions DC-DC** (25 MHz converter, 24 mV ripple, CISPR 32 Class B),
  CMTI 85–100 kV/µs.
- **ISO6731** (2 fwd / 1 rev) — 50 Mbps, reinforced 5 kVrms, 8 mm creepage,
  CMTI 100–150 kV/µs.
- Combined: **6 fwd / 1 rev** — exact match.
- Total: **2 ICs** (or **1 IC** — `ISOW7741` — for a minimal 4-wire SPI without
  STDBY/RESET isolation).

## Comparison

| | Option A (ADI) | Option B (TI) |
|---|---|---|
| Channels (fwd/rev) | 7 (4 fast 3/1 + 3 slow) | 6/1 — exact |
| SPI rate | 17 MHz | 100 / 50 Mbps |
| Isolated power | 300 mW (33% eff.) | 550 mW (46% eff.) |
| Output ripple / noise | 75 mV / 200 mV | 24 mV |
| Switching / EMI | 180 MHz → ferrites | 25 MHz → low-emissions |
| CMTI | >25 kV/µs | 85–150 kV/µs |
| Isolation | 5 kV, 8.3 mm creepage | 5 kV reinforced, 8 mm creepage |
| IC count (full) | 2 | 2 (1 for minimal SPI) |

## Decision

**Proposed: Option B (TI ISOW774x + ISO6731).** Both deliver comparable isolated
power, but TI wins on the points that matter for a metrology front-end: cleaner
supply (24 mV vs 75/200 mV), far lower emissions (25 MHz vs 180 MHz — no ferrites),
much higher CMTI (85–150 vs 25 kV/µs),
and higher SPI headroom. Cost is also expected to be lower.

## Consequences

- Measurement board stays passive (ADC + isolation), no MCU — consistent with ADR-0001.
- The isolated 3.3 V should still be followed by a low-noise LDO before AVDD/IOVDD
  for best 24-bit accuracy.
- Proposed pin mapping:
  - `ISOW7740` (fwd): SCLK, MOSI, CS, STDBY
  - `ISO6731` (fwd): RESET; (rev): MISO
- If only the minimal 4-wire SPI is isolated (STDBY/RESET tied locally),
  drop ISO6731 and use `ISOW7741` alone.

## References

- ADuM4151/4152/4153 datasheet: https://www.analog.com/media/en/technical-documentation/data-sheets/ADuM4151_4152_4153.pdf
- ADuM6020/6028 datasheet: https://www.analog.com/media/en/technical-documentation/data-sheets/adum6020-6028.pdf
- ISOW774x: https://www.ti.com/product/ISOW7741
- ISO6731: https://www.ti.com/product/ISO6731
