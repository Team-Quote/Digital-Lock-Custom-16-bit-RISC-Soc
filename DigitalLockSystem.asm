; ═══════════════════════════════════════
; DIGITAL LOCK SYSTEM
; Passcode: 1738
; ═══════════════════════════════════════

; ── REGISTER ALLOCATION ─────────────────
; R0 = zero constant
; R1 = increment value (1)
; R2 = temp / mask
; R3 = button input
; R4 = temp comparison
; R5 = temp output value
; R6 = counter (delay/blink)
; R7 = temp

; ── INITIALIZATION ───────────────────────
INIT:
    MOV  R0, 0          ; zero constant
    MOV  R1, 1          ; increment value

    ; clear attempt counter
    STORE R0, 0x01      ; RAM[0x01] = 0

    ; clear entered digits
    STORE R0, 0x02      ; digit 3 = 0
    STORE R0, 0x03      ; digit 2 = 0
    STORE R0, 0x04      ; digit 1 = 0
    STORE R0, 0x05      ; digit 0 = 0

    ; clear set flags
    STORE R0, 0x06      ; digit 3 unset
    STORE R0, 0x07      ; digit 2 unset
    STORE R0, 0x08      ; digit 1 unset
    STORE R0, 0x09      ; digit 0 unset

    ; clear selected digit
    STORE R0, 0x0A      ; selected = digit 3 (Seg7)

    ; clear all displays
    STORE R0, 0x38      ; Seg7 off
    STORE R0, 0x39      ; Seg6 off
    STORE R0, 0x3A      ; Seg5 off
    STORE R0, 0x3B      ; Seg4 off
    STORE R0, 0x3C      ; Seg3 off
    STORE R0, 0x3D      ; Seg2 off
    STORE R0, 0x3E      ; Seg1 off
    STORE R0, 0x3F      ; Seg0 off

    ; clear RGB
    STORE R0, 0x37

; ── SYSTEM STARTUP ───────────────────────
; flash -------- 3 times
STARTUP:
    MOV  R6, 3          ; blink counter = 3
    MOV  R5, 64         ; dash encoding (middle segment G)

STARTUP_BLINK:
    ; turn ON all dashes
    STORE R5, 0x38
    STORE R5, 0x39
    STORE R5, 0x3A
    STORE R5, 0x3B
    STORE R5, 0x3C
    STORE R5, 0x3D
    STORE R5, 0x3E
    STORE R5, 0x3F

    ; delay ON
    MOV  R7, 63
STARTUP_DLY1:
    SUB  R7, R1
    JNZ  STARTUP_DLY1

    ; turn OFF all
    STORE R0, 0x38
    STORE R0, 0x39
    STORE R0, 0x3A
    STORE R0, 0x3B
    STORE R0, 0x3C
    STORE R0, 0x3D
    STORE R0, 0x3E
    STORE R0, 0x3F

    ; delay OFF
    MOV  R7, 63
STARTUP_DLY2:
    SUB  R7, R1
    JNZ  STARTUP_DLY2

    ; decrement blink counter
    SUB  R6, R1
    JNZ  STARTUP_BLINK  ; repeat 3 times

; ── SYSTEM READY ─────────────────────────
READY:
    ; show ---- on left 4
    MOV  R5, 64         ; dash encoding
    STORE R5, 0x38      ; Seg7 = -
    STORE R5, 0x39      ; Seg6 = -
    STORE R5, 0x3A      ; Seg5 = -
    STORE R5, 0x3B      ; Seg4 = -

    ; right 4 off except Seg0
    STORE R0, 0x3C      ; Seg3 off
    STORE R0, 0x3D      ; Seg2 off
    STORE R0, 0x3E      ; Seg1 off

    ; show attempt counter on Seg0
    LOAD  R5, 0x01      ; load attempt counter
    STORE R5, 0x3F      ; Seg0 = attempt count

    ; clear RGB
    STORE R0, 0x37

    ; reset selected digit to Seg7
    STORE R0, 0x0A

    ; reset entered digits and flags
    STORE R0, 0x02
    STORE R0, 0x03
    STORE R0, 0x04
    STORE R0, 0x05
    STORE R0, 0x06
    STORE R0, 0x07
    STORE R0, 0x08
    STORE R0, 0x09

; wait for CENTER button
READY_WAIT:
    LOAD  R3, 0x34      ; read buttons
    MOV   R2, 16        ; center mask
    AND   R3, R2        ; isolate center
    CMP   R3, R0        ; pressed?
    JZ    READY_WAIT    ; if not wait

; wait for release
READY_REL:
    LOAD  R3, 0x34
    MOV   R2, 16
    AND   R3, R2
    CMP   R3, R0
    JNZ   READY_REL

    ; go to display select
    JMP   DISP_SEL

; ── DISPLAY SELECT ───────────────────────
DISP_SEL:
    ; load current selected digit
    LOAD  R7, 0x0A      ; R7 = selected digit (0-3)

    ; update display
    ; show all digits solid then blink selected
    JMP   UPDATE_DISP

; ── UPDATE DISPLAY ───────────────────────
UPDATE_DISP:
    ; show Seg7 value or dash
    LOAD  R4, 0x06      ; digit 3 set flag
    CMP   R4, R0        ; is it set?
    JZ    SEG7_DASH     ; if not show dash
    LOAD  R5, 0x02      ; load digit 3 value
    JMP   SEG7_SHOW
SEG7_DASH:
    MOV   R5, 64        ; dash
SEG7_SHOW:
    STORE R5, 0x38      ; show on Seg7

    ; show Seg6 value or dash
    LOAD  R4, 0x07      ; digit 2 set flag
    CMP   R4, R0
    JZ    SEG6_DASH
    LOAD  R5, 0x03
    JMP   SEG6_SHOW
SEG6_DASH:
    MOV   R5, 64
SEG6_SHOW:
    STORE R5, 0x39

    ; show Seg5 value or dash
    LOAD  R4, 0x08
    CMP   R4, R0
    JZ    SEG5_DASH
    LOAD  R5, 0x04
    JMP   SEG5_SHOW
SEG5_DASH:
    MOV   R5, 64
SEG5_SHOW:
    STORE R5, 0x3A

    ; show Seg4 value or dash
    LOAD  R4, 0x09
    CMP   R4, R0
    JZ    SEG4_DASH
    LOAD  R5, 0x05
    JMP   SEG4_SHOW
SEG4_DASH:
    MOV   R5, 64
SEG4_SHOW:
    STORE R5, 0x3B

; ── BLINK SELECTED DIGIT ─────────────────
    ; which digit is selected?
    LOAD  R7, 0x0A

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

; blink Seg7
BLINK_SEG7:
    LOAD  R5, 0x38      ; get current Seg7 value
    STORE R0, 0x38      ; blank Seg7
    MOV   R6, 63
BLINK7_DLY1:
    SUB   R6, R1
    JNZ   BLINK7_DLY1
    STORE R5, 0x38      ; restore Seg7
    MOV   R6, 63
BLINK7_DLY2:
    SUB   R6, R1
    JNZ   BLINK7_DLY2
    JMP   READ_BUTTONS

; blink Seg6
BLINK_SEG6:
    LOAD  R5, 0x39
    STORE R0, 0x39
    MOV   R6, 63
BLINK6_DLY1:
    SUB   R6, R1
    JNZ   BLINK6_DLY1
    STORE R5, 0x39
    MOV   R6, 63
BLINK6_DLY2:
    SUB   R6, R1
    JNZ   BLINK6_DLY2
    JMP   READ_BUTTONS

; blink Seg5
BLINK_SEG5:
    LOAD  R5, 0x3A
    STORE R0, 0x3A
    MOV   R6, 63
BLINK5_DLY1:
    SUB   R6, R1
    JNZ   BLINK5_DLY1
    STORE R5, 0x3A
    MOV   R6, 63
BLINK5_DLY2:
    SUB   R6, R1
    JNZ   BLINK5_DLY2
    JMP   READ_BUTTONS

; blink Seg4
BLINK_SEG4:
    LOAD  R5, 0x3B
    STORE R0, 0x3B
    MOV   R6, 63
BLINK4_DLY1:
    SUB   R6, R1
    JNZ   BLINK4_DLY1
    STORE R5, 0x3B
    MOV   R6, 63
BLINK4_DLY2:
    SUB   R6, R1
    JNZ   BLINK4_DLY2
    JMP   READ_BUTTONS

; ── READ BUTTONS ─────────────────────────
READ_BUTTONS:
    LOAD  R3, 0x34      ; read all buttons

; check RIGHT
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

    JMP   DISP_SEL      ; no button, keep looping

; ── DO RIGHT ─────────────────────────────
DO_RIGHT:
    LOAD  R7, 0x0A      ; load selected digit
    MOV   R2, 3
    CMP   R7, R2        ; already at Seg4 (digit 3)?
    JZ    WAIT_REL_R    ; if yes dont go further

    ADD   R7, R1        ; move right
    STORE R7, 0x0A      ; save selected digit

WAIT_REL_R:
    LOAD  R3, 0x34
    MOV   R2, 1
    AND   R3, R2
    CMP   R3, R0
    JNZ   WAIT_REL_R
    JMP   DISP_SEL

; ── DO LEFT ──────────────────────────────
DO_LEFT:
    LOAD  R7, 0x0A      ; load selected digit
    CMP   R7, R0        ; already at Seg7 (digit 0)?
    JZ    WAIT_REL_L    ; if yes dont go further

    SUB   R7, R1        ; move left
    STORE R7, 0x0A      ; save selected digit

WAIT_REL_L:
    LOAD  R3, 0x34
    MOV   R2, 4
    AND   R3, R2
    CMP   R3, R0
    JNZ   WAIT_REL_L
    JMP   DISP_SEL

; ── DO UP ────────────────────────────────
DO_UP:
    LOAD  R7, 0x0A      ; load selected digit
    MOV   R2, 0
    CMP   R7, R2
    JZ    UP_DIG3       ; digit 3 = Seg7

    MOV   R2, 1
    CMP   R7, R2
    JZ    UP_DIG2

    MOV   R2, 2
    CMP   R7, R2
    JZ    UP_DIG1

    JMP   UP_DIG0

UP_DIG3:
    LOAD  R5, 0x02      ; load digit 3
    MOV   R2, 15
    CMP   R5, R2        ; at F?
    JZ    UP3_WRAP
    ADD   R5, R1        ; increment
    JMP   UP3_SAVE
UP3_WRAP:
    MOV   R5, 0         ; wrap to 0
UP3_SAVE:
    STORE R5, 0x02      ; save digit 3
    MOV   R2, 1
    STORE R2, 0x06      ; mark as set
    JMP   WAIT_REL_U

UP_DIG2:
    LOAD  R5, 0x03
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

; ── DO DOWN ──────────────────────────────
DO_DOWN:
    LOAD  R7, 0x0A
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
    CMP   R5, R0        ; at 0?
    JZ    DOWN3_WRAP
    SUB   R5, R1        ; decrement
    JMP   DOWN3_SAVE
DOWN3_WRAP:
    MOV   R5, 15        ; wrap to F
DOWN3_SAVE:
    STORE R5, 0x02
    MOV   R2, 1
    STORE R2, 0x06
    JMP   WAIT_REL_D

DOWN_DIG2:
    LOAD  R5, 0x03
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

; ── DO CENTER (SUBMIT) ────────────────────
DO_CENTER:
    ; wait for release first
WAIT_REL_C:
    LOAD  R3, 0x34
    MOV   R2, 16
    AND   R3, R2
    CMP   R3, R0
    JNZ   WAIT_REL_C

    ; compare digit 3 with passcode 1
    LOAD  R5, 0x02      ; entered digit 3
    MOV   R2, 1         ; passcode digit 3 = 1
    CMP   R5, R2
    JNZ   WRONG

    ; compare digit 2 with passcode 7
    LOAD  R5, 0x03
    MOV   R2, 7         ; passcode digit 2 = 7
    CMP   R5, R2
    JNZ   WRONG

    ; compare digit 1 with passcode 3
    LOAD  R5, 0x04
    MOV   R2, 3         ; passcode digit 1 = 3
    CMP   R5, R2
    JNZ   WRONG

    ; compare digit 0 with passcode 8
    LOAD  R5, 0x05
    MOV   R2, 8         ; passcode digit 0 = 8
    CMP   R5, R2
    JNZ   WRONG

    JMP   PASS          ; all digits match

; ── WRONG ────────────────────────────────
WRONG:
    ; increment attempt counter
    LOAD  R6, 0x01
    ADD   R6, R1
    STORE R6, 0x01

    ; check lockout
    MOV   R2, 3
    CMP   R6, R2
    JZ    LOCKOUT

    JMP   FAIL

; ── PASS ─────────────────────────────────
PASS:
    ; show PASS on left 4
    ; P = 0x0C, A = 0x08, S = 0x12, S = 0x12
    MOV   R5, 12        ; P
    STORE R5, 0x38
    MOV   R5, 8         ; A
    STORE R5, 0x39
    MOV   R5, 18        ; S
    STORE R5, 0x3A
    MOV   R5, 18        ; S
    STORE R5, 0x3B

    ; blink PASS 3 times with RGB green
    MOV   R6, 3

PASS_BLINK:
    ; RGB green on
    MOV   R5, 2
    STORE R5, 0x37

    ; show PASS
    MOV   R5, 12
    STORE R5, 0x38
    MOV   R5, 8
    STORE R5, 0x39
    MOV   R5, 18
    STORE R5, 0x3A
    MOV   R5, 18
    STORE R5, 0x3B

    ; delay ON
    MOV   R7, 63
PASS_DLY1:
    SUB   R7, R1
    JNZ   PASS_DLY1

    ; RGB off
    STORE R0, 0x37

    ; blank PASS
    STORE R0, 0x38
    STORE R0, 0x39
    STORE R0, 0x3A
    STORE R0, 0x3B

    ; delay OFF
    MOV   R7, 63
PASS_DLY2:
    SUB   R7, R1
    JNZ   PASS_DLY2

    SUB   R6, R1
    JNZ   PASS_BLINK    ; repeat 3 times

    ; stay on PASS forever
PASS_HOLD:
    MOV   R5, 12
    STORE R5, 0x38
    MOV   R5, 8
    STORE R5, 0x39
    MOV   R5, 18
    STORE R5, 0x3A
    MOV   R5, 18
    STORE R5, 0x3B
    JMP   PASS_HOLD     ; loop forever until reset

; ── FAIL ─────────────────────────────────
FAIL:
    ; show FAIL on left 4
    ; F=0x0E, A=0x08, I=0x79, L=0x47 (rough encodings)
    MOV   R6, 3

FAIL_BLINK:
    ; RGB red on
    MOV   R5, 1
    STORE R5, 0x37

    ; show FAIL
    MOV   R5, 14        ; F
    STORE R5, 0x38
    MOV   R5, 8         ; A
    STORE R5, 0x39
    MOV   R5, 49        ; I (rough)
    STORE R5, 0x3A
    MOV   R5, 56        ; L (rough)
    STORE R5, 0x3B

    ; delay ON
    MOV   R7, 63
FAIL_DLY1:
    SUB   R7, R1
    JNZ   FAIL_DLY1

    ; RGB off
    STORE R0, 0x37

    ; blank
    STORE R0, 0x38
    STORE R0, 0x39
    STORE R0, 0x3A
    STORE R0, 0x3B

    ; delay OFF
    MOV   R7, 63
FAIL_DLY2:
    SUB   R7, R1
    JNZ   FAIL_DLY2

    SUB   R6, R1
    JNZ   FAIL_BLINK    ; repeat 3 times

    JMP   READY         ; back to system ready

; ── LOCKOUT ──────────────────────────────
LOCKOUT:
    ; flash all segments 3 times
    MOV   R6, 3
    MOV   R5, 255       ; all segments on

LOCK_BLINK:
    ; all segments on
    STORE R5, 0x38
    STORE R5, 0x39
    STORE R5, 0x3A
    STORE R5, 0x3B
    STORE R5, 0x3C
    STORE R5, 0x3D
    STORE R5, 0x3E
    STORE R5, 0x3F

    ; delay ON
    MOV   R7, 63
LOCK_DLY1:
    SUB   R7, R1
    JNZ   LOCK_DLY1

    ; all segments off
    STORE R0, 0x38
    STORE R0, 0x39
    STORE R0, 0x3A
    STORE R0, 0x3B
    STORE R0, 0x3C
    STORE R0, 0x3D
    STORE R0, 0x3E
    STORE R0, 0x3F

    ; delay OFF
    MOV   R7, 63
LOCK_DLY2:
    SUB   R7, R1
    JNZ   LOCK_DLY2

    SUB   R6, R1
    JNZ   LOCK_BLINK    ; repeat 3 times

    ; HALT forever
    HALT