# MAD: A Game Boy–Inspired SoC

> **Three students. One FPGA. A game console built from the ground up.**
>
> We're designing a complete system-on-chip in SystemVerilog with no vendor IP cores and no pre-built CPU. That covers the pipelined RISC-V processor, the memory system, the graphics pipeline, and the games that run on it. Every architectural choice, from the memory map to the bus design to the display pipeline, is our own engineering decision, and we verify it ourselves on real hardware.

**Mariella, Ariana, and Drew** are three Cal Poly SLO computer engineering students building a Game Boy–inspired SoC for the Digilent Basys 3 FPGA, because hardware is more fun when it plays games.

**Team & Technical Lead:** Drew Nakamura
**Graphics Lead:** Ariana Birruete
**Software & Game:** Mariella Brayton

The project grows one version at a time. Each version is a complete, playable system, and the next one builds on it with better graphics, more hardware, and new games.

---

## Versions

| Version | Status         | Highlights                                              |
|---------|----------------|---------------------------------------------------------|
| [v1](v1/) | ✅ Complete  | Pipelined RISC-V CPU, MMIO, tile PPU, VGA, Maze game    |
| v2      | 🚧 Planned     | LCD screen, more sprites and colors, Snake or Tetris    |

---

## v1: Complete ✅

- 5-stage pipelined RV32I CPU with forwarding and hazard detection
- Memory-mapped I/O through a central interconnect (DMEM, VRAM, buttons, switches)
- Dual-port VRAM, a tile-based PPU (32×24 grid of 20×20 tiles), and a 640×480 VGA output
- Maze game in RISC-V assembly with 3 levels, wall collision, and a win screen

**Known issues:** a single button press can occasionally register twice, and there are occasional single-pixel glitches on the left edge of the screen.

Full details are in the [v1 README](v1/README.md).

---

## v2: Plan 🚧

**Planned**
- Replace VGA with a small LCD screen
- More sprites
- More colors
- An input handshake (or a similar scheme) so each button press is exactly one step
- A new game: Snake or Tetris

**Possible additions**
- DMA controller
- Interrupt controller

---

## Contributions

### v1
| Contributor          | Role                       | Contributions                                                                            |
|----------------------|----------------------------|------------------------------------------------------------------------------------------|
| **Drew Nakamura**    | Team & Technical Lead      | 5-stage RISC-V CPU, memory-mapped I/O, Interconnect, `oneshot_hold`, DMEM, `MCU_WRAPPER` |
| **Ariana Birruete**  | Graphics                   | VGA Controller, VRAM, PPU                                                                |
| **Mariella Brayton** | Software                   | Game logic and all game software                                                         |

---

*Started August 2026 · Still leveling up*