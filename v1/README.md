# RISC-Boy v1

A custom handheld-style game console built from scratch on an FPGA: a pipelined RISC-V CPU, memory-mapped I/O, a tile-based graphics pipeline, and a maze game written in RISC-V assembly.

**Status: v1 complete ✅**

---

## Overview
https://github.com/user-attachments/assets/1289a786-48ac-4d29-9451-572b3553d92e

RISC-Boy v1 is a small system-on-chip (SoC) for the Digilent Basys 3 (Artix-7). A 5-stage pipelined RISC-V CPU runs the game from instruction memory. It reads the board's buttons through memory-mapped I/O and writes the level map and player position into a dual-port Video RAM (VRAM). A Pixel Processing Unit (PPU) reads VRAM on its own port and sends pixels to a VGA controller, which drives a standard 640×480 @ 60 Hz monitor.

The goal for v1 was a complete system that works end to end: CPU, memory, I/O, graphics, and a playable game. That goal has been met.

---

## Features

- **5-stage pipelined RISC-V CPU** with forwarding and hazard detection
- **Memory-mapped I/O** through a central interconnect (DMEM, VRAM, buttons, switches)
- **Dual-port VRAM**: the CPU reads and writes on one port, the PPU reads on the other
- **Tile-based PPU** with a 32×24 grid of 20×20-pixel tiles and a hardware player sprite
- **VGA output** at 640×480 @ 60 Hz with 12-bit color
- **Button one-shot / hold logic** that turns a button press into a single movement step
- **Maze game** in RISC-V assembly with three levels, wall collision, goal detection, and a win screen

---

## System Architecture

```
                 ┌──────────────────────────────────────────────┐
  100 MHz CLK ──►│ Clock / reset generation (50 MHz, 25 MHz)    │
                 └──────────────────────────────────────────────┘

 ┌──────────┐   IOBUS    ┌──────────────┐
 │ RISC-V   │◄──────────►│ Interconnect │◄──── Buttons (via oneshot_hold)
 │ CPU      │            │ (MMIO decode)│◄──── Switches
 │ 5-stage  │            └──┬────────┬──┘
 └────┬─────┘               │        │
      │                ┌────▼──┐  ┌──▼─────────┐  Port 2  ┌─────┐  RGB  ┌────────────┐
  ┌───▼──┐             │ DMEM  │  │ VRAM       │◄────────►│ PPU │──────►│ VGA        │──► Monitor
  │ IMEM │             └───────┘  │ (dual port)│          └──▲──┘       │ Controller │
  └──────┘                        └────────────┘             └──────────┤ pos_x/pos_y│
                                                                        └────────────┘
```

### Clock Domains

| Clock  | Source                     | Used by                          |
|--------|----------------------------|----------------------------------|
| 100 MHz| Basys 3 oscillator         | Button sync / one-shot logic     |
| 50 MHz | Divided from 100 MHz       | CPU, Interconnect, DMEM, VRAM    |
| 25 MHz | Divided from 50 MHz        | VGA Controller, PPU              |

Reset (`BTNC`) is passed through a two-flop synchronizer into each clock domain.

---

## Memory Map

| Address range              | Region        | Notes                                      |
|----------------------------|---------------|--------------------------------------------|
| `0x0000_0000 – 0x0000_0FFF`| IMEM          | Program instructions                       |
| `0x0000_1000 – 0x0000_2FFF`| DMEM          | Data / stack (`sp` starts at `0x2FFC`)     |
| `0x0000_3000 – 0x0000_3FFF`| VRAM          | Tile map + sprite registers                |
| `0x0000_3000 – 0x0000_305C`| ↳ Tile map    | 24 words, one word per row, 1 bit per tile |
| `0x0000_3404`              | ↳ Player X    | Tile column (0–31)                         |
| `0x0000_3408`              | ↳ Player Y    | Tile row (0–23)                            |
| `0x0000_4000`              | Buttons       | Bits [3:0] = Up, Down, Left, Right         |
| `0x1100_0000`              | Switches      | 16 board switches                          |

---

## Graphics

- **Resolution:** 640×480 @ 60 Hz (800×525 total timing, 25 MHz pixel clock)
- **Tile grid:** 32 columns × 24 rows, each tile 20×20 pixels
- **Background:** each VRAM row word encodes 32 tiles, where bit *n* is column *n*
  - `0` → white (empty)
  - `1` → blue (wall)
- **Player sprite:** a red tile drawn at (Player X, Player Y)
- **Sprite fetch:** during the blanking interval, the PPU reads the sprite X and Y registers from VRAM so the position stays stable for the whole visible frame

---

## Game: Maze

The player moves a red block through each maze to the goal area.

- **Controls:** the four directional buttons on the Basys 3; `BTNC` resets the system
- **Rules:** a move is rejected if it leaves the screen or runs into a wall. Collision is checked in software by reading the target row from VRAM and testing the tile bit
- **Levels:** three levels, then a win screen
- **Source:** `sw/MapGame.asm`

---

## Repository Layout

```
risc_boy_v1/
├── Makefile                 # Verilator lint / elaboration
├── rtl/
│   ├── MCU_WRAPPER.sv       # Top level: clocks, reset, module wiring
│   ├── Interconnect.sv      # Address decode + MMIO read path
│   ├── DMEM.sv              # Data memory
│   ├── VRAM.sv              # Dual-port video RAM
│   ├── PPU.v                # Pixel Processing Unit
│   ├── VGA_Controller.v     # VGA timing + RGB output
│   ├── oneshot_hold.sv      # Button synchronizer / one-shot
│   └── CPU/                 # 5-stage pipelined RISC-V core
├── sw/
│   ├── MapGame.asm          # Maze game source
│   ├── MapGameText.mem      # Game instruction image
│   ├── MapGameData.mem      # Game data image
│   └── Test_All_*.mem       # CPU test program images
└── tb/
    └── tb_MCU_WRAPPER.sv    # Top-level testbench
```

---

## Building

### Lint / Elaborate (Verilator)

From `risc_boy_v1` in WSL or Linux:

```bash
make
```

This runs `verilator --lint-only -Wall` on the full design with `MCU_WRAPPER` as the top module.

### FPGA (Vivado)

1. Create a Vivado project for the Basys 3 (`xc7a35tcpg236-1`).
2. Add every file under `rtl/` and `rtl/CPU/`, and set `MCU_WRAPPER` as the top module.
3. Point IMEM and DMEM at the game's `.mem` images.
4. Add the Basys 3 constraints for `CLK`, `BTNC`, `BTNS`, `SWITCHES`, `HSYNC`, `VSYNC`, and `RGB_pins`.
5. Synthesize, implement, generate the bitstream, and program the board.

---

## Known Issues

- **Button double-catching:** one press can sometimes register as two moves. The fix is to add a proper handshake between the input hardware and the CPU (for example, software acknowledges a button event before the next one is accepted) or a similar edge or event-latching scheme.
- **Single-pixel glitches on the left edge:** small one-pixel artifacts sometimes appear along the left side of the screen. This is likely a timing or alignment issue between the VGA position counters and the PPU's VRAM fetch.

---

## Roadmap: v2

**Planned**
- [ ] Replace the VGA controller with a **small LCD screen**
- [ ] **More sprites**
- [ ] **More colors**
- [ ] **Input handshake** (or an equivalent design) so each button press is exactly one step
- [ ] A new game: **Snake** or **Tetris**

**Possible additions**
- [ ] DMA controller
- [ ] Interrupt controller

---

## Credits

| Contributor            | Contributions                                                                 |
|------------------------|-------------------------------------------------------------------------------|
| **Ariana Birruete**    | Graphics: VGA Controller, VRAM, PPU                                           |
| **Mariella Brayton**   | Game logic and all game software                                              |
| **Drew Nakamura**      | 5-stage RISC-V CPU, memory-mapped I/O, Interconnect, `oneshot_hold`, DMEM, `MCU_WRAPPER` |

---

*RISC-Boy v1, built by students.*
