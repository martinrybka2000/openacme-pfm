# OpenACME‑PFM

**Open** **AC** **M**ains **E**nergy — **PFM** (Power Factor Meter).

An open-source **power quality meter** for AC installations. It measures voltage, current, power (active / reactive / apparent), frequency, power factors and THD, and exposes the results over Ethernet and Modbus, with PQDIF export for professional analysis tools.

> ⚠️ **DANGER — MAINS VOLTAGE.**
> This project connects directly to 230 V AC mains. Building, flashing, testing or using it can **injure or kill you** and can **start a fire**. Read [`docs/user-guide/safety.md`](docs/user-guide/safety.md) before touching any hardware. You build and use everything here **entirely at your own risk**.

---

## Status

🚧 **V2.0 — under development.**

The V1.0 single-board prototype (the basis of my master's thesis) is preserved **as-is** in [`v1.0/`](v1.0/) for reference only — no cleanup, no support.

## What it measures

- RMS voltage and current (total and fundamental)
- Active `P`, reactive `Q`, non-active `N` and apparent `S` power
- Fundamental components `P1`, `Q1`, `S1`
- Power factors: `PF` (true), `DPF` (displacement), `DF` (distortion)
- `THD` of voltage and current
- Frequency and phase angle (SOGI-PLL grid synchronisation)
- 10-cycle aggregation window (IEC 61000-4-7), loosely aligned with IEC 61000-4-30 Class S (best-effort, not a certification target)

## Planned architecture (V2.0)

- **Two boards:** a reusable _control board_ (MCU, power, Ethernet/Modbus, HMI, SD) + swappable _measurement board_ (1-phase or 3-phase; shunt, CT or Rogowski). Exact KiCad split is TBD.
- **Isolated sigma-delta** acquisition at high sample rates.
- **Comms:** Modbus TCP, Modbus RTU/RS485, PQDIF (IEEE 1159.3). WiFi is a separate board variant with an ESP instead of the STM32.
- **Power:** 24 V DC on the control board, USB-C for configuration, or transformer-fed from the measured phase (option).
- **Mechanical:** DIN-rail enclosure.
- **Measurements:** FFT and other power-quality parameters (voltage dips/swells, flicker).

## Repository layout

```
docs/          Requirements, architecture (ADRs), protocol specs, user guide
hardware/      KiCad projects (control-board, measurement-board) + enclosure
firmware/      Embedded C (STM32 via CubeMX/CMake; ESP32 WiFi variant)
software/      Desktop configuration app (Modbus)
tools/         Calibration and data-processing scripts
v1.0/          Legacy V1.0 prototype + master's thesis (reference dump)
```

## Getting started

See [`docs/user-guide/building.md`](docs/user-guide/building.md) for build/flash instructions and [`docs/requirements/requirements.md`](docs/requirements/requirements.md) for the current feature set.

## Documentation

- [Requirements](docs/requirements/requirements.md)
- [Roadmap](docs/roadmap.md)
- [System overview](docs/architecture/system-overview.md)
- [Architecture Decision Records](docs/architecture/adr/)
- [Protocol / Modbus map](docs/protocol/modbus-map.md)

## License

This project uses **strong copyleft** licences — if you use it, you must keep your derivatives open:

| Component                            | Licence                            | File               |
| ------------------------------------ | ---------------------------------- | ------------------ |
| Firmware & software                  | [GPL-3.0](LICENSE)                 | `LICENSE`          |
| Hardware (KiCad, Gerbers, enclosure) | [CERN-OHL-S-2.0](hardware/LICENSE) | `hardware/LICENSE` |
| Documentation                        | [CC-BY-SA-4.0](docs/LICENSE)       | `docs/LICENSE`     |

See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md).
