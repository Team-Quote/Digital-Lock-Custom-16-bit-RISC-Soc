# Digital Lock with Custom 16-bit RISC SoC

A FPGA-based digital lock system implemented using a custom 16-bit RISC processor on the Nexys A7-100T development board.

## Project Overview

This project implements a secure digital lock system that runs on a custom-built 16-bit RISC processor. The system allows users to enter a code using switches, submit it with a button, and receive feedback through LEDs, a seven-segment display, and a VGA status screen.

### Key Features

- **Custom 16-bit RISC CPU**: Designed specifically for this application
- **Memory-Mapped I/O**: Interfaces with peripherals through memory mapping
- **User Interface**:
  - 16 switches for code entry
  - Buttons for submit/reset operations
  - 16 LEDs for status indication
  - Four-digit seven-segment display for attempt counters
  - VGA display for detailed status messages
- **Security Features**:
  - Password verification
  - Failed attempt tracking
  - Lockout after multiple failed attempts

### System Behavior

1. **Boot State**: System starts in LOCKED mode
2. **Code Entry**: User enters 4-bit or 8-bit code using switches
3. **Submission**: Press submit button to check code
4. **Verification**:
   - **Correct Code**: VGA shows "ACCESS GRANTED", green LED pattern
   - **Incorrect Code**: VGA shows "ACCESS DENIED", failed attempt counter increments
5. **Lockout**: After 3 failed attempts, system enters lockout mode

## Project Structure

```
├── docs/                 # Documentation and reports
│   ├── AI_Log.md        # AI interaction log
│   └── Stage */         # Project stage documentation
├── evidence/            # Supporting evidence and test results
├── references/          # Reference materials and templates
├── report/              # Formal project reports
└── src/                 # Vivado project files
    ├── src.xpr          # Vivado project file
    ├── vivado.jou       # Vivado journal
    └── src.srcs/        # Source files
        ├── constrs_1/   # Constraints
        └── sources_1/   # HDL source code
```

## Hardware Requirements

- Digilent Nexys A7-100T FPGA Development Board
- Vivado Design Suite (2023.1 or later recommended)

## Software Requirements

- Xilinx Vivado 2023.1+
- Basic knowledge of Verilog HDL
- Familiarity with FPGA development workflow

## Getting Started

### 1. Clone or Download the Project

Ensure you have the complete project directory structure.

### 2. Open in Vivado

1. Launch Vivado
2. Open the project file: `src/src.xpr`
3. The project should load with all source files and constraints

### 3. Review Source Files

Key modules to examine:
- `SevenSegDisplay.v`: Seven-segment display controller (partially implemented)
- Constraint file: `src.srcs/constrs_1/imports/References/NexysA7-100t.xdc`

### 4. Synthesis and Implementation

1. In Vivado, click **Generate Bitstream**
2. Program the FPGA with the generated bitstream

## Current Implementation Status

This is a work-in-progress project. Current progress includes:

- ✅ Project setup and basic structure
- ✅ Seven-segment display module (framework)
- 🔄 CPU architecture design (in progress)
- 🔄 Memory map definition (planned)
- 🔄 VGA controller (planned)
- 🔄 Complete system integration (planned)

## Development Roadmap

1. **Complete CPU Architecture Definition**
2. **Implement Core CPU Modules**
3. **Memory System (ROM/RAM)**
4. **I/O Peripherals**
5. **VGA Text Display**
6. **System Integration and Testing**
7. **Security Features Implementation**

## Contributing

This is a class project for CECS 361. Individual contributions are tracked in progress reports.

## References

- Nexys A7-100T Reference Manual
- Vivado Design Suite Documentation
- Digital Design Fundamentals
- FPGA-based Processor Design

## License

This project is developed as part of an academic course and is not licensed for commercial use.

