; ═══════════════════════════════════════════════════════
; DIGITAL LOCK SYSTEM
; Passcode: 1738
; ═══════════════════════════════════════════════════════
;
; ── REGISTER ALLOCATION ─────────────────────────────────
; R0 = zero constant (0)
; R1 = increment value (1)
; R2 = temp / mask / comparison
; R3 = button input
; R4 = processed flag (0=not processed, 1=processed)
; R5 = temp output value
; R6 = blink/delay counter / attempt counter
; R7 = selected digit / delay counter
;
; ── RAM MAP ─────────────────────────────────────────────
; RAM[0x01] = real attempt counter
; RAM[0x02] = entered digit 3 (Seg7)
; RAM[0x03] = entered digit 2 (Seg6)
; RAM[0x04] = entered digit 1 (Seg5)
; RAM[0x05] = entered digit 0 (Seg4)
; RAM[0x06] = digit 3 set flag
; RAM[0x07] = digit 2 set flag
; RAM[0x08] = digit 1 set flag
; RAM[0x09] = digit 0 set flag
; RAM[0x0A] = current selected digit (0-3)
; RAM[0x0B] = blank value (128)
; RAM[0x0C] = display attempt counter
;
; ── PERIPHERAL MAP ──────────────────────────────────────
; BT_Reg  = 0x34  (buttons read)
; SW_Reg  = 0x35  (switches read)
; LED_Reg = 0x36  (LEDs write)
; RGB_Reg = 0x37  (RGB write)
; Seg7    = 0x38  (leftmost)
; Seg6    = 0x39
; Seg5    = 0x3A
; Seg4    = 0x3B
; Seg3    = 0x3C
; Seg2    = 0x3D
; Seg1    = 0x3E
; Seg0    = 0x3F  (rightmost, attempt counter)
;
; ── BUTTON MAP ──────────────────────────────────────────
; Right  = bit 0 = mask 1
; Down   = bit 1 = mask 2
; Left   = bit 2 = mask 4
; Up     = bit 3 = mask 8
; Center = bit 4 = mask 16
;
; ── SEGMENT VALUES ──────────────────────────────────────
; dash(-) = 64
; blank   = 128
; P       = 115
; A       = 10
; S       = 5
; F       = 113
; I       = 48
; L       = 56
; ════════════════════════════════════════════════════════

; ── INITIALIZATION ───────────────────────────────────────
INIT:
    MOV  R0, 0          ; zero constant
    MOV  R1, 1          ; increment value
    MOV  R5, 128        ; blank value
    STORE R5, 0x0B      ; save blank to RAM

    STORE R0, 0x01      ; clear real attempt counter
    STORE R0, 0x0C      ; clear display attempt counter
    STORE R0, 0x02      ; clear entered digit 3
    STORE R0, 0x03      ; clear entered digit 2
    STORE R0, 0x04      ; clear entered digit 1
    STORE R0, 0x05      ; clear entered digit 0
    STORE R0, 0x06      ; clear digit 3 set flag
    STORE R0, 0x07      ; clear digit 2 set flag
    STORE R0, 0x08      ; clear digit 1 set flag
    STORE R0, 0x09      ; clear digit 0 set flag
    STORE R0, 0x0A      ; clear selected digit

    MOV   R5, 128       ; blank all displays
    STORE R5, 0x38
    STORE R5, 0x39
    STORE R5, 0x3A
    STORE R5, 0x3B
    STORE R5, 0x3C
    STORE R5, 0x3D
    STORE R5, 0x3E
    STORE R5, 0x3F

    STORE R0, 0x37      ; clear RGB

; ── SYSTEM STARTUP ───────────────────────────────────────
; flash -------- 3 times
STARTUP:
    MOV  R6, 3          ; blink counter = 3
    MOV  R5, 64         ; dash encoding

STARTUP_BLINK:
    STORE R5, 0x38
    STORE R5, 0x39
    STORE R5, 0x3A
    STORE R5, 0x3B
    STORE R5, 0x3C
    STORE R5, 0x3D
    STORE R5, 0x3E
    STORE R5, 0x3F

    MOV  R7, 63
STARTUP_DLY1:
    SUB  R7, R1
    JNZ  STARTUP_DLY1

    MOV  R5, 128        ; blank all
    STORE R5, 0x38
    STORE R5, 0x39
    STORE R5, 0x3A
    STORE R5, 0x3B
    STORE R5, 0x3C
    STORE R5, 0x3D
    STORE R5, 0x3E
    STORE R5, 0x3F

    MOV  R7, 63
STARTUP_DLY2:
    SUB  R7, R1
    JNZ  STARTUP_DLY2

    SUB  R6, R1
    JNZ  STARTUP_BLINK

; ── SYSTEM READY ─────────────────────────────────────────
READY:
    MOV  R5, 64         ; dash on left 4
    STORE R5, 0x38
    STORE R5, 0x39
    STORE R5, 0x3A
    STORE R5, 0x3B

    MOV  R5, 128        ; blank right 3
    STORE R5, 0x3C
    STORE R5, 0x3D
    STORE R5, 0x3E

    LOAD  R5, 0x0C      ; load display attempt counter
    NOP
    NOP
    STORE R5, 0x3F      ; show on Seg0

    STORE R0, 0x0A      ; reset selected digit
    STORE R0, 0x02      ; reset entered digits
    STORE R0, 0x03
    STORE R0, 0x04
    STORE R0, 0x05
    STORE R0, 0x06      ; reset set flags
    STORE R0, 0x07
    STORE R0, 0x08
    STORE R0, 0x09

; wait for CENTER release first
READY_CLEAR:
    LOAD  R3, 0x34
    MOV   R2, 16
    AND   R3, R2
    CMP   R3, R0
    JNZ   READY_CLEAR

; wait for CENTER press
READY_WAIT:
    LOAD  R3, 0x34
    MOV   R2, 16
    AND   R3, R2
    CMP   R3, R0
    JZ    READY_WAIT

; wait for CENTER release
READY_REL:
    LOAD  R3, 0x34
    MOV   R2, 16
    AND   R3, R2
    CMP   R3, R0
    JNZ   READY_REL

    JMP   DISP_SEL

; ── DISPLAY SELECT ───────────────────────────────────────
DISP_SEL:
    LOAD  R7, 0x0A      ; load selected digit
    NOP
    NOP
    JMP   UPDATE_DISP

; ── UPDATE DISPLAY ───────────────────────────────────────
UPDATE_DISP:
    ; Seg7
    LOAD  R4, 0x06
    NOP
    NOP
    CMP   R4, R0
    JZ    SEG7_DASH
    LOAD  R5, 0x02
    NOP
    NOP
    JMP   SEG7_SHOW
SEG7_DASH:
    MOV   R5, 64
SEG7_SHOW:
    STORE R5, 0x38

    ; Seg6
    LOAD  R4, 0x07
    NOP
    NOP
    CMP   R4, R0
    JZ    SEG6_DASH
    LOAD  R5, 0x03
    NOP
    NOP
    JMP   SEG6_SHOW
SEG6_DASH:
    MOV   R5, 64
SEG6_SHOW:
    STORE R5, 0x39

    ; Seg5
    LOAD  R4, 0x08
    NOP
    NOP
    CMP   R4, R0
    JZ    SEG5_DASH
    LOAD  R5, 0x04
    NOP
    NOP
    JMP   SEG5_SHOW
SEG5_DASH:
    MOV   R5, 64
SEG5_SHOW:
    STORE R5, 0x3A

    ; Seg4
    LOAD  R4, 0x09
    NOP
    NOP
    CMP   R4, R0
    JZ    SEG4_DASH
    LOAD  R5, 0x05
    NOP
    NOP
    JMP   SEG4_SHOW
SEG4_DASH:
    MOV   R5, 64
SEG4_SHOW:
    STORE R5, 0x3B

    ; select which digit to blink
    LOAD  R7, 0x0A
    NOP
    NOP
    MOV   R2, 0
    CMP   R7, R2
    JZ    BLINK_SEG7
    MOV   R2, 1
    CMP   R7, R2
    JZ    BLINK_SEG6
    MOV   R2, 2
    CMP   R7, R2
    JZ    BLINK_SEG5
    MOV   R2, 3
    CMP   R7, R2
    JZ    BLINK_SEG4

; ── BLINK SEG7 ───────────────────────────────────────────
BLINK_SEG7:
    MOV   R5, 128
    STORE R5, 0x38
    MOV   R6, 63
BLINK7_DLY1:
    SUB   R6, R1
    JNZ   BLINK7_DLY1
    LOAD  R4, 0x06
    NOP
    NOP
    CMP   R4, R0
    JZ    BLINK7_DASH
    LOAD  R5, 0x02
    NOP
    NOP
    JMP   BLINK7_RESTORE
BLINK7_DASH:
    MOV   R5, 64
BLINK7_RESTORE:
    STORE R5, 0x38
    MOV   R6, 63
BLINK7_DLY2:
    SUB   R6, R1
    JNZ   BLINK7_DLY2
    JMP   READ_BUTTONS

; ── BLINK SEG6 ───────────────────────────────────────────
BLINK_SEG6:
    MOV   R5, 128
    STORE R5, 0x39
    MOV   R6, 63
BLINK6_DLY1:
    SUB   R6, R1
    JNZ   BLINK6_DLY1
    LOAD  R4, 0x07
    NOP
    NOP
    CMP   R4, R0
    JZ    BLINK6_DASH
    LOAD  R5, 0x03
    NOP
    NOP
    JMP   BLINK6_RESTORE
BLINK6_DASH:
    MOV   R5, 64
BLINK6_RESTORE:
    STORE R5, 0x39
    MOV   R6, 63
BLINK6_DLY2:
    SUB   R6, R1
    JNZ   BLINK6_DLY2
    JMP   READ_BUTTONS

; ── BLINK SEG5 ───────────────────────────────────────────
BLINK_SEG5:
    MOV   R5, 128
    STORE R5, 0x3A
    MOV   R6, 63
BLINK5_DLY1:
    SUB   R6, R1
    JNZ   BLINK5_DLY1
    LOAD  R4, 0x08
    NOP
    NOP
    CMP   R4, R0
    JZ    BLINK5_DASH
    LOAD  R5, 0x04
    NOP
    NOP
    JMP   BLINK5_RESTORE
BLINK5_DASH:
    MOV   R5, 64
BLINK5_RESTORE:
    STORE R5, 0x3A
    MOV   R6, 63
BLINK5_DLY2:
    SUB   R6, R1
    JNZ   BLINK5_DLY2
    JMP   READ_BUTTONS

; ── BLINK SEG4 ───────────────────────────────────────────
BLINK_SEG4:
    MOV   R5, 128
    STORE R5, 0x3B
    MOV   R6, 63
BLINK4_DLY1:
    SUB   R6, R1
    JNZ   BLINK4_DLY1
    LOAD  R4, 0x09
    NOP
    NOP
    CMP   R4, R0
    JZ    BLINK4_DASH
    LOAD  R5, 0x05
    NOP
    NOP
    JMP   BLINK4_RESTORE
BLINK4_DASH:
    MOV   R5, 64
BLINK4_RESTORE:
    STORE R5, 0x3B
    MOV   R6, 63
BLINK4_DLY2:
    SUB   R6, R1
    JNZ   BLINK4_DLY2
    JMP   READ_BUTTONS

; ── READ BUTTONS ─────────────────────────────────────────
READ_BUTTONS:
    ; check RIGHT
    LOAD  R3, 0x34
    MOV   R2, 1
    AND   R3, R2
    CMP   R3, R0
    JNZ   DO_RIGHT

    ; check DOWN
    LOAD  R3, 0x34
    MOV   R2, 2
    AND   R3, R2
    CMP   R3, R0
    JNZ   DO_DOWN

    ; check LEFT
    LOAD  R3, 0x34
    MOV   R2, 4
    AND   R3, R2
    CMP   R3, R0
    JNZ   DO_LEFT

    ; check UP
    LOAD  R3, 0x34
    MOV   R2, 8
    AND   R3, R2
    CMP   R3, R0
    JNZ   DO_UP

    ; check CENTER
    LOAD  R3, 0x34
    MOV   R2, 16
    AND   R3, R2
    CMP   R3, R0
    JNZ   DO_CENTER

    JMP   DISP_SEL      ; no button pressed

; ── DO RIGHT ─────────────────────────────────────────────
DO_RIGHT:
    LOAD  R7, 0x0A
    NOP
    NOP
    MOV   R2, 3
    CMP   R7, R2
    JZ    WAIT_REL_R    ; already at rightmost
    ADD   R7, R1
    STORE R7, 0x0A

WAIT_REL_R:
    LOAD  R3, 0x34
    MOV   R2, 1
    AND   R3, R2
    CMP   R3, R0
    JNZ   WAIT_REL_R
    JMP   DISP_SEL

; ── DO LEFT ──────────────────────────────────────────────
DO_LEFT:
    LOAD  R7, 0x0A
    NOP
    NOP
    CMP   R7, R0
    JZ    WAIT_REL_L    ; already at leftmost
    SUB   R7, R1
    STORE R7, 0x0A

WAIT_REL_L:
    LOAD  R3, 0x34
    MOV   R2, 4
    AND   R3, R2
    CMP   R3, R0
    JNZ   WAIT_REL_L
    JMP   DISP_SEL

; ── DO UP ────────────────────────────────────────────────
DO_UP:
    LOAD  R7, 0x0A
    NOP
    NOP
    MOV   R2, 0
    CMP   R7, R2
    JZ    UP_DIG3
    MOV   R2, 1
    CMP   R7, R2
    JZ    UP_DIG2
    MOV   R2, 2
    CMP   R7, R2
    JZ    UP_DIG1
    JMP   UP_DIG0

UP_DIG3:
    LOAD  R5, 0x02
    NOP
    NOP
    MOV   R2, 15
    CMP   R5, R2
    JZ    UP3_WRAP
    ADD   R5, R1
    JMP   UP3_SAVE
UP3_WRAP:
    MOV   R5, 0
UP3_SAVE:
    STORE R5, 0x02
    MOV   R2, 1
    STORE R2, 0x06
    JMP   WAIT_REL_U

UP_DIG2:
    LOAD  R5, 0x03
    NOP
    NOP
    MOV   R2, 15
    CMP   R5, R2
    JZ    UP2_WRAP
    ADD   R5, R1
    JMP   UP2_SAVE
UP2_WRAP:
    MOV   R5, 0
UP2_SAVE:
    STORE R5, 0x03
    MOV   R2, 1
    STORE R2, 0x07
    JMP   WAIT_REL_U

UP_DIG1:
    LOAD  R5, 0x04
    NOP
    NOP
    MOV   R2, 15
    CMP   R5, R2
    JZ    UP1_WRAP
    ADD   R5, R1
    JMP   UP1_SAVE
UP1_WRAP:
    MOV   R5, 0
UP1_SAVE:
    STORE R5, 0x04
    MOV   R2, 1
    STORE R2, 0x08
    JMP   WAIT_REL_U

UP_DIG0:
    LOAD  R5, 0x05
    NOP
    NOP
    MOV   R2, 15
    CMP   R5, R2
    JZ    UP0_WRAP
    ADD   R5, R1
    JMP   UP0_SAVE
UP0_WRAP:
    MOV   R5, 0
UP0_SAVE:
    STORE R5, 0x05
    MOV   R2, 1
    STORE R2, 0x09
    JMP   WAIT_REL_U

WAIT_REL_U:
    LOAD  R3, 0x34
    MOV   R2, 8
    AND   R3, R2
    CMP   R3, R0
    JNZ   WAIT_REL_U
    JMP   DISP_SEL

; ── DO DOWN ──────────────────────────────────────────────
DO_DOWN:
    LOAD  R7, 0x0A
    NOP
    NOP
    MOV   R2, 0
    CMP   R7, R2
    JZ    DOWN_DIG3
    MOV   R2, 1
    CMP   R7, R2
    JZ    DOWN_DIG2
    MOV   R2, 2
    CMP   R7, R2
    JZ    DOWN_DIG1
    JMP   DOWN_DIG0

DOWN_DIG3:
    LOAD  R5, 0x02
    NOP
    NOP
    CMP   R5, R0
    JZ    DOWN3_WRAP
    SUB   R5, R1
    JMP   DOWN3_SAVE
DOWN3_WRAP:
    MOV   R5, 15
DOWN3_SAVE:
    STORE R5, 0x02
    MOV   R2, 1
    STORE R2, 0x06
    JMP   WAIT_REL_D

DOWN_DIG2:
    LOAD  R5, 0x03
    NOP
    NOP
    CMP   R5, R0
    JZ    DOWN2_WRAP
    SUB   R5, R1
    JMP   DOWN2_SAVE
DOWN2_WRAP:
    MOV   R5, 15
DOWN2_SAVE:
    STORE R5, 0x03
    MOV   R2, 1
    STORE R2, 0x07
    JMP   WAIT_REL_D

DOWN_DIG1:
    LOAD  R5, 0x04
    NOP
    NOP
    CMP   R5, R0
    JZ    DOWN1_WRAP
    SUB   R5, R1
    JMP   DOWN1_SAVE
DOWN1_WRAP:
    MOV   R5, 15
DOWN1_SAVE:
    STORE R5, 0x04
    MOV   R2, 1
    STORE R2, 0x08
    JMP   WAIT_REL_D

DOWN_DIG0:
    LOAD  R5, 0x05
    NOP
    NOP
    CMP   R5, R0
    JZ    DOWN0_WRAP
    SUB   R5, R1
    JMP   DOWN0_SAVE
DOWN0_WRAP:
    MOV   R5, 15
DOWN0_SAVE:
    STORE R5, 0x05
    MOV   R2, 1
    STORE R2, 0x09
    JMP   WAIT_REL_D

WAIT_REL_D:
    LOAD  R3, 0x34
    MOV   R2, 2
    AND   R3, R2
    CMP   R3, R0
    JNZ   WAIT_REL_D
    JMP   DISP_SEL

; ── DO CENTER (SUBMIT) ────────────────────────────────────
DO_CENTER:
WAIT_REL_C:
    LOAD  R3, 0x34
    MOV   R2, 16
    AND   R3, R2
    CMP   R3, R0
    JNZ   WAIT_REL_C

    MOV   R4, 0         ; clear processed flag (in register)

    ; compare digit 3 with passcode 1
    LOAD  R5, 0x02
    NOP
    NOP
    MOV   R2, 1
    CMP   R5, R2
    JNZ   WRONG

    ; compare digit 2 with passcode 7
    LOAD  R5, 0x03
    NOP
    NOP
    MOV   R2, 7
    CMP   R5, R2
    JNZ   WRONG

    ; compare digit 1 with passcode 3
    LOAD  R5, 0x04
    NOP
    NOP
    MOV   R2, 3
    CMP   R5, R2
    JNZ   WRONG

    ; compare digit 0 with passcode 8
    LOAD  R5, 0x05
    NOP
    NOP
    MOV   R2, 8
    CMP   R5, R2
    JNZ   WRONG

    JMP   PASS

; ── WRONG ────────────────────────────────────────────────
WRONG:
    CMP   R4, R0        ; already processed this press?
    JNZ   SKIP_WRONG    ; if yes skip
    MOV   R4, 1         ; set flag instantly in register

    ; increment real counter
    LOAD  R6, 0x01
    NOP
    NOP
    ADD   R6, R1
    STORE R6, 0x01

    ; increment display counter
    LOAD  R5, 0x0C
    NOP
    NOP
    ADD   R5, R1
    STORE R5, 0x0C
    STORE R5, 0x3F      ; show on Seg0

    MOV   R2, 6         ; lockout threshold (hardware doubles)
    CMP   R6, R2
    JZ    LOCKOUT
    JMP   FAIL

SKIP_WRONG:
    JMP   FAIL

; ── PASS ─────────────────────────────────────────────────
PASS:
    STORE R0, 0x37      ; clear RGB red

    ; show PASS on left 4
    MOV   R5, 115       ; P = 0111 0011
    STORE R5, 0x38
    MOV   R5, 10        ; A
    STORE R5, 0x39
    MOV   R5, 5         ; S
    STORE R5, 0x3A
    MOV   R5, 5         ; S
    STORE R5, 0x3B

    ; blank right 4
    MOV   R5, 128
    STORE R5, 0x3C
    STORE R5, 0x3D
    STORE R5, 0x3E
    STORE R5, 0x3F

    MOV   R6, 3         ; blink 3 times

PASS_BLINK:
    MOV   R5, 2
    STORE R5, 0x37      ; RGB green on

    MOV   R5, 115       ; show PASS
    STORE R5, 0x38
    MOV   R5, 10
    STORE R5, 0x39
    MOV   R5, 5
    STORE R5, 0x3A
    MOV   R5, 5
    STORE R5, 0x3B

    MOV   R7, 63
PASS_DLY1:
    SUB   R7, R1
    JNZ   PASS_DLY1

    STORE R0, 0x37      ; RGB green off

    MOV   R5, 128       ; blank PASS
    STORE R5, 0x38
    STORE R5, 0x39
    STORE R5, 0x3A
    STORE R5, 0x3B

    MOV   R7, 63
PASS_DLY2:
    SUB   R7, R1
    JNZ   PASS_DLY2

    SUB   R6, R1
    JNZ   PASS_BLINK

; stay on PASS forever with RGB green on
PASS_HOLD:
    MOV   R5, 2
    STORE R5, 0x37      ; RGB green stays on

    MOV   R5, 115       ; show PASS solid
    STORE R5, 0x38
    MOV   R5, 10
    STORE R5, 0x39
    MOV   R5, 5
    STORE R5, 0x3A
    MOV   R5, 5
    STORE R5, 0x3B
    JMP   PASS_HOLD

; ── FAIL ─────────────────────────────────────────────────
FAIL:
    MOV   R5, 1
    STORE R5, 0x37      ; RGB red on (stays solid)
    MOV   R6, 3         ; blink 3 times

FAIL_BLINK:
    MOV   R5, 113       ; F = 0111 0001
    STORE R5, 0x38
    MOV   R5, 10        ; A
    STORE R5, 0x39
    MOV   R5, 48        ; I = 0011 0000
    STORE R5, 0x3A
    MOV   R5, 56        ; L = 0011 1000
    STORE R5, 0x3B

    MOV   R7, 63
FAIL_DLY1:
    SUB   R7, R1
    JNZ   FAIL_DLY1

    MOV   R5, 128       ; blank FAIL
    STORE R5, 0x38
    STORE R5, 0x39
    STORE R5, 0x3A
    STORE R5, 0x3B

    MOV   R7, 63
FAIL_DLY2:
    SUB   R7, R1
    JNZ   FAIL_DLY2

    SUB   R6, R1
    JNZ   FAIL_BLINK

    JMP   READY         ; back to system ready (RGB stays red)

; ── LOCKOUT ──────────────────────────────────────────────
LOCKOUT:
    MOV   R5, 1
    STORE R5, 0x37      ; RGB red on

    MOV   R6, 3         ; flash all segments 3 times
    MOV   R5, 255       ; all segments on

LOCK_BLINK:
    STORE R5, 0x38
    STORE R5, 0x39
    STORE R5, 0x3A
    STORE R5, 0x3B
    STORE R5, 0x3C
    STORE R5, 0x3D
    STORE R5, 0x3E
    STORE R5, 0x3F

    MOV   R7, 63
LOCK_DLY1:
    SUB   R7, R1
    JNZ   LOCK_DLY1

    MOV   R5, 128       ; blank all
    STORE R5, 0x38
    STORE R5, 0x39
    STORE R5, 0x3A
    STORE R5, 0x3B
    STORE R5, 0x3C
    STORE R5, 0x3D
    STORE R5, 0x3E
    STORE R5, 0x3F

    MOV   R7, 63
LOCK_DLY2:
    SUB   R7, R1
    JNZ   LOCK_DLY2

    SUB   R6, R1
    JNZ   LOCK_BLINK

    HALT                ; stop forever until reset
