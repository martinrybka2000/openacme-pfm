# Hardware

Two-board design (KiCad 9):

- `control-board/` — MCU, power, Ethernet/Modbus, HMI, SD, external flash + EEPROM.
- WiFi variant — separate board with an ESP instead of the STM32 (location TBD; the KiCad split is still open).
- `measurement-board/` — swappable analogue front-end (1-phase / 3-phase; shunt / CT / Rogowski).
- `lib/` — shared KiCad symbols/footprints.
- `enclosure/` — DIN-rail enclosure (STEP/FreeCAD).

Licence: **CERN-OHL-S-2.0** (see `LICENSE` in this folder).

See `docs/architecture/` for the system design and ADRs.
