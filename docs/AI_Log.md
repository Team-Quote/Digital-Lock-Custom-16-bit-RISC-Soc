# AI Usage Log
> This log documents all AI usage throughout the project.

---

# Stage 2: First Progress Report

## Prompt 1 
Research Notes
Digital Lock with VGA status screen using a Custom 16-bit RISC SoC
Concept
FPGA implements a small 16-bit processor with the following 
•	Instruction ROM
•	Data RAM
•	Memory-mapped peripherals
•	Switch/button intputs
•	LED outputs
•	Seven segment output
•	VGA display output

CPU runs a program that behaves like a digital lock 

What is the user experience?
Enter a code using switches 
Press a button to submit
Press another button to reset/clear
Optional: 
	Select lock mode with switches or buttons

What the system does
•	Compares entered code against stored passcode
•	Shows LOCKED, ENTER CODE, ACCESS GRANTED or ACCESS DENIED on VGA
•	Turns LEDs on/off for success or failure
•	Can show number of failed attempts on the 7-segment display
•	Can lock out the user after too many wrong tries

Minimum Embedded demo
Build
•	16-bit CPU
•	ROM with lock-control program
•	RAM for state / attempts / temporary values
•	Switch input register
•	Button input register
•	LED output register
•	7-seg output register
•	VGA text / status module

Behavior
•	System boots to LOCKED
•	User enters 4-bit or 8-bit code using switches
•	Presses submit
•	CPU checks code
•	If correct
•	VGA shows ACCESS GRANTED, 
•	Green LED Pattern
•	If wrong
•	VGA shows ACCESS DENIED
•	Failed attempt counter increments
•	After 3 failures
•	VGA shows SYSTEM LOCKOUT

References so far	

Nexys A7 Board Resources
Tiny 16-bit CPU architecture
Memory Design in Vivado
VGA Fundamentals
Verification strategy

I don't even know where to begin for this project. We need to have our first progress report by next week Monday. I need your help. Consider the sources that I have called Project Instructions.pdf

## Answer 1
You do have a place to begin. Your first progress report is not asking for a finished project yet. It wants five things: an introduction, background/preliminaries, the research/resources you are using, a design diagram, obstacles, about 20%–30% implementation progress, and each group member’s contribution. Your digital lock idea fits the class project well because the instructions explicitly allow a simple processor project and also mention VGA controller work. 

Here is the easiest way to think about your project:

**Your project in one sentence**
Build a small 16-bit custom CPU on the Nexys A7 that runs a lock-control program and talks to memory-mapped I/O for switches, buttons, LEDs, seven-segment display, and VGA status output.

That is already a solid CECS 361 project direction.

## What you should focus on by next Monday

Do **not** try to finish the whole lock system first.
For the first report, aim to prove that the architecture is real and that part of it already works.

A good 20%–30% completion target would be:

* Define the CPU architecture at a high level
* Define the memory map
* Draw the block diagram
* Decide the instruction set
* Implement or partially implement a few core modules
* Show at least one simulation result

That is enough for a strong first progress report.

## Best project scope for now

Keep the first version simple.

### Recommended minimum version

* 16-bit CPU
* Instruction ROM
* Data RAM
* Memory-mapped I/O
* Switch input
* Button input
* LED output
* 7-segment output
* VGA text/status output
* Lock-control program in ROM

### Simplify the lock behavior

For version 1:

* Use a **4-bit code** instead of 8-bit
* One stored passcode in ROM or a fixed register
* One submit button
* One reset/clear button
* Three lock states:

  * ENTER CODE
  * ACCESS GRANTED
  * ACCESS DENIED
* Optional lockout after 3 failures

That is much more manageable than trying to make a fancy keypad-like system immediately.

## Suggested architecture

Think of the system in 5 blocks:

1. **CPU core**

   * PC
   * instruction decoder
   * register file
   * ALU
   * control unit

2. **Instruction memory**

   * ROM holding the lock program

3. **Data memory**

   * RAM for temporary data
   * failed attempt count
   * current state

4. **Memory-mapped peripherals**

   * switches register
   * buttons register
   * LED register
   * seven-seg register
   * VGA status register

5. **VGA display module**

   * Does not need full graphics
   * Can simply display a status word or state code
   * Example: show different messages based on a small status register

## Very important design choice

Do **not** make the CPU generate VGA timing itself.

Instead:

* Build a separate VGA controller module
* Let the CPU write a small value to a memory-mapped VGA status register
* VGA module reads that register and displays the corresponding screen

Example status codes:

* `0 = LOCKED`
* `1 = ENTER CODE`
* `2 = ACCESS GRANTED`
* `3 = ACCESS DENIED`
* `4 = SYSTEM LOCKOUT`

This makes the project much easier and cleaner.

## Suggested memory map

You can put something like this in your report:

* `0x0000–0x00FF` : Data RAM
* `0x8000` : Switch input register
* `0x8001` : Button input register
* `0x8002` : LED output register
* `0x8003` : Seven-segment output register
* `0x8004` : VGA status register

That already looks like a real SoC design.

## Suggested CPU instruction set

Keep it tiny. For example:

* `LOAD Rd, [addr]`
* `STORE Rs, [addr]`
* `ADD Rd, Rs`
* `SUB Rd, Rs`
* `AND Rd, Rs`
* `CMP Rd, Rs`
* `MOV Rd, imm`
* `JMP addr`
* `JZ addr`
* `JNZ addr`

You do not need a big ISA. You only need enough instructions to:

* read switches/buttons
* compare against passcode
* update state
* drive outputs
* branch based on success/failure

## Lock algorithm the CPU program can run

A simple software flow:

1. On boot:

   * set state = LOCKED
   * clear attempts
   * show ENTER CODE or LOCKED on VGA

2. Wait for submit button

3. Read switch value

4. Compare with stored passcode

5. If equal:

   * set VGA status = ACCESS GRANTED
   * turn on green LED pattern
   * maybe reset attempts

6. If not equal:

   * increment failed attempts
   * set VGA status = ACCESS DENIED
   * show attempts on 7-seg

7. If attempts >= 3:

   * set VGA status = SYSTEM LOCKOUT
   * ignore further submit inputs until reset

8. Reset button:

   * clear attempts
   * return to LOCKED

## What to write for the first progress report

Here is a structure you can almost directly use.

# 1. Introduction

Say what the project is and why it matters.

Example:

> This project implements a custom 16-bit RISC-style processor on the Nexys A7 FPGA board to control a digital lock system with VGA status output. The system demonstrates processor design, memory-mapped I/O, embedded control, and hardware verification. The processor executes a program stored in ROM to read user inputs, compare a passcode, update lock state, and drive peripheral outputs including LEDs, seven-segment display, and VGA.

# 2. Background and Preliminaries

Explain the concepts your design depends on.

Include:

* Custom 16-bit CPU basics
* Memory-mapped I/O
* Nexys A7 board peripherals
* VGA basics
* Verification strategy

You can divide it like this:

* **Custom CPU architecture**: PC, ALU, registers, control
* **Memory-mapped peripherals**: CPU accesses devices through addresses
* **VGA fundamentals**: VGA module generates sync/display timing, CPU only writes status codes
* **Verification**: testbench simulation for CPU, memory, and peripherals

# 3. Research and Resources Used

You already listed some. Turn them into categories:

* Nexys A7 board documentation
* Verilog/Vivado tutorials for ROM, RAM, and block design
* VGA timing references
* CPU architecture references
* Course notes on HDL design and verification
* The sources listed in the project instructions, including Pong P. Chu, computer architecture references, and verification references. 

# 4. Design Diagram

Make one system block diagram.

Use this structure:

```text
           +----------------------+
           |   Instruction ROM    |
           +----------+-----------+
                      |
                      v
+---------+    +-------------+    +-----------+
| Buttons |--> |             |--> | LED Reg   |--> LEDs
+---------+    |   16-bit    |    +-----------+
               |    CPU      |
+---------+--> |             |--> +-----------+--> 7-Seg
| Switches|    |             |    | 7-Seg Reg |
+---------+    +------+------+    +-----------+
                      |
                      v
               +-------------+
               |   Data RAM  |
               +-------------+
                      |
                      v
               +-------------+      +------------------+
               | VGA Status   |----> | VGA Controller   |--> VGA Output
               | Register     |      +------------------+
               +-------------+
```

## 5. Obstacles

Be honest here. Good obstacles for this project:

* Keeping CPU design simple enough to finish on time
* Deciding the smallest useful instruction set
* Integrating memory-mapped I/O cleanly
* Handling button debounce or edge detection
* Making VGA output manageable without overcomplicating the CPU
* Verifying hardware/software interaction between CPU and peripherals

## 6. Implementation Progress (20%–30%)

This is the part you need to show by next week.

A realistic progress statement:

> The project is currently in the architecture and early implementation stage. The CPU datapath, memory map, and peripheral interface have been defined. Initial Verilog modules for instruction ROM, data RAM, and selected I/O registers have been started. The lock-control program flow has been drafted, and the VGA interface approach has been simplified so that the CPU writes status codes to a dedicated register instead of directly generating video timing.

That sounds like real progress.

## 7. Work distribution

Example:

* **Member 1**: CPU datapath and control unit
* **Member 2**: memory-mapped I/O, LEDs, switches, seven-seg
* **Member 3**: VGA status module, testing, integration, documentation

If only two people:

* Person 1: CPU + ROM + program flow
* Person 2: peripherals + VGA + verification

---

## What you should physically finish this week

Here is the smartest short-term plan.

### By Day 1

* Finalize project scope
* Decide 4-bit passcode
* Decide system states
* Decide memory map
* Draw block diagram

### By Day 2

* Define instruction format
* Decide register count
* Write pseudo-assembly for lock program

### By Day 3

* Implement simple ROM and RAM modules
* Implement switch/button input registers
* Implement LED output register

### By Day 4

* Implement basic CPU skeleton or partial datapath
* Or, if CPU is not ready, simulate a simplified controller that mimics expected CPU I/O behavior

### By Day 5

* Write first progress report
* Include block diagram
* Include current module status
* Include obstacles and next steps

## Strong recommendation

For next Monday, prioritize these deliverables:

* one clean architecture diagram
* one memory map table
* one short instruction set table
* one pseudo-code or flowchart for the lock program
* one or two screenshots of Verilog modules or simulation waveforms

Even if the full CPU is not working yet, that still looks like real progress.

## A clean project title you can use

**Custom 16-bit RISC SoC for Digital Lock Control with VGA Status Display**

## A short abstract you can reuse

> This project presents the design and implementation of a custom 16-bit RISC-style system-on-chip on the Nexys A7 FPGA board. The system executes a lock-control program stored in ROM and interfaces with memory-mapped peripherals including switches, buttons, LEDs, seven-segment display, and a VGA status display. The digital lock accepts a user-entered code, verifies it against a stored passcode, indicates success or failure through visual outputs, and optionally locks out the user after repeated failed attempts. The project demonstrates processor design, embedded hardware/software interaction, peripheral integration, and HDL verification.

## My advice on where to begin tonight

Start with these three things only:

1. Draw the block diagram
2. Create the memory map
3. Write the lock algorithm as pseudo-code

Once those are done, the whole project becomes much easier to organize.

I can also draft your **entire first progress report** in a submission-ready format based on this project.

## Prompt 2
Now is this all within using Vivado? We are using the Nexys A7-100T. 

## Answer 2
Yes — this project can be done entirely in **Vivado** for the **Nexys A7-100T**.

What you would typically use in Vivado:

* **Verilog or VHDL** to design the CPU, ROM, RAM, peripherals, and VGA logic
* **Simulation** in Vivado to test modules and verify behavior
* **Synthesis and implementation** to program the FPGA
* **Constraints file (.xdc)** to connect your design to the Nexys A7 switches, buttons, LEDs, 7-segment display, and VGA pins

So your workflow is basically:

1. Write the hardware modules in Verilog
2. Simulate them in Vivado
3. Connect them together at the top level
4. Assign board pins in the XDC file
5. Generate bitstream
6. Program the Nexys A7

For your project, the whole system is still hardware design in Vivado, even though it behaves like a “processor running a program.” The “program” is usually stored in:

* a **ROM module**
* or a **COE/MEM initialization file** loaded into block memory

So the CPU fetches instructions from ROM, but the ROM itself is still part of your Vivado FPGA design.

A clean breakdown for Vivado would be:

* `cpu.v`
* `alu.v`
* `register_file.v`
* `control_unit.v`
* `instr_rom.v`
* `data_ram.v`
* `mmio.v`
* `vga_controller.v`
* `top.v`
* `nexys_a7.xdc`

One important note: for the **Nexys A7-100T**, VGA is possible, but you need the correct VGA pin constraints from the board files or reference manual. The CPU should not directly generate text pixels by itself at first. It is much easier to make a separate VGA controller module and let the CPU write a status code to a register.

So yes: **Vivado is the main tool**, and the Nexys A7-100T is a good board for this project.

A practical first implementation target in Vivado would be:

* switches in
* buttons in
* LEDs out
* simple ROM/RAM
* a tiny CPU or FSM test
* then VGA status last

The only thing outside Vivado might be:

* writing your report
* maybe using a small script or text file to help initialize ROM contents

But the actual hardware project itself is absolutely a Vivado project.

## Prompt 3
This is our board manual by the way 
**Board Reference Manual.pdf**

## Answer 3
Perfect — this manual helps a lot, and yes, it confirms your project is a very good fit for the **Nexys A7-100T** and for **Vivado**.

A few key things from your board manual directly support your project:

The board is explicitly compatible with **Vivado Design Suite**, and the A7-100T has plenty of FPGA resources for a small custom processor project. The manual lists the 100T as having 63,400 LUTs, 126,800 flip-flops, and 1,188 Kb of block RAM, which is more than enough for a small 16-bit CPU, ROM, RAM, memory-mapped I/O, and a basic VGA status module. 

The Nexys A7 also already gives you exactly the peripherals your idea needs: **16 switches, 16 LEDs, pushbuttons, an eight-digit seven-segment display, and 12-bit VGA output**. Those are all built into the board, so your project can stay self-contained without extra hardware. 

For your lock project specifically, the most relevant board facts are:

* The board has a **100 MHz onboard clock** available to the FPGA. 
* The VGA port is driven by FPGA logic, and the manual says you must create a **video controller circuit in the FPGA** to generate the proper sync and color timing. 
* The VGA example timing given in the manual is **640×480 at 60 Hz using a 25 MHz pixel clock**, which is the standard simple mode most student VGA projects use. 
* The board’s basic I/O includes **16 slide switches**, **pushbuttons**, **16 LEDs**, and an **8-digit seven-segment display**. 
* The pushbuttons and switches are directly connected to the FPGA, and the manual notes that the normal pushbuttons are momentary and go high when pressed, while the red CPU reset button behaves differently. 
* The seven-segment display is **common anode** and **multiplexed**, so you need a scan controller for it rather than treating each digit as always-on. 

So your project is absolutely realistic on this board.

## What this means for your design

Your system can be built like this inside Vivado:

* **CPU core**
* **instruction ROM**
* **data RAM**
* **memory-mapped input registers**

  * switches
  * buttons
* **memory-mapped output registers**

  * LEDs
  * seven-seg data
  * VGA status/state
* **seven-seg scan driver**
* **VGA controller**
* **top-level module**
* **XDC constraints**

That is a normal FPGA/Vivado workflow.

## Important board-specific advice

The biggest thing is this:

**Do not try to make the CPU itself generate raw VGA timing.**

The manual says the VGA interface needs a controller that generates HS, VS, and pixel/color timing correctly.  That is much easier if you split the job like this:

* CPU writes a small status code such as:

  * 0 = LOCKED
  * 1 = ENTER CODE
  * 2 = ACCESS GRANTED
  * 3 = ACCESS DENIED
  * 4 = LOCKOUT
* Separate VGA module reads that code
* VGA module decides what to display

That is the cleanest architecture.

## Best scope for first version

Based on the manual and your deadline, I would strongly recommend this version first:

* use the **16 slide switches** for input, but only read the lower 4 or 8 bits for the passcode
* use **one pushbutton** as submit
* use **one pushbutton** as clear/reset
* use **LEDs** for quick success/failure indication
* use the **seven-segment display** only to show failed-attempt count
* use **VGA** only for a few simple screens or color-coded status blocks

For example, your VGA does not need full text on day one. You can start with:

* red screen = denied
* green screen = granted
* blue screen = locked
* yellow screen = enter code
* flashing red = lockout

That would still count as VGA output and keeps things manageable.

## What not to use yet

The board has DDR2, USB host, temperature sensor, accelerometer, microphone, audio, and other extras, but those would make the project much harder. The manual shows those are available, but you do not need them for this lock system. 

For your project, stick to:

* clock
* switches
* buttons
* LEDs
* seven-seg
* VGA

## Practical conclusion

Yes — this is fully a **Vivado project on the Nexys A7-100T**, and your board manual actually strengthens your proposal because it shows the board already supports every major part of your design: user I/O, seven-seg, and VGA. 

The smartest next step is to define your modules around the actual board hardware rather than around vague ideas.

A very good immediate plan is:

1. define the memory map
2. draw the block diagram
3. decide which switches/buttons you will use
4. make a simple VGA status module
5. make a simple seven-seg scan module
6. then connect them to your CPU later

I can turn this into a **board-specific implementation plan for your first progress report** next.

