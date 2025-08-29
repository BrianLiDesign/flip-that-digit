# main.asm
# Author: Brian Li and Joshua Naim
# Description: Assembly translation of Flip That Digit
# Target (0–9) shown on leftmost digit of the 7-segment display
# Score (0–9) shown on rightmost hex digit
# Game ends when the score reaches 10
# Switches map left to right (SW15 to SW6) to digits 0 to 9
# Flip exactly one correct switch to Score

.eqv MMIO, 0x11000000
.eqv LEDS, 0x20
.eqv SEV_SEG, 0x40

# The initial target is for ease of testing purposes after assembling the program
.data
	initial_target: .word 5

# Saved registers usage
# s0: MMIO base
# s1: score (0... 10)
# s2: target (0... 9)
# s4: display word (packed)
# s5: raw switches snapshot
.text
.global _start
        
_start:
        # Initialize base, score, target
        li s0, MMIO
        addi s1, zero, 0		# Score = 0
        addi s2, zero, 0
        
        # Load the initial target from the data segment (again, only necessary for the optional testing case)
        la s3, initial_target
	lw s2, 0(s3)

        # Clear displays
        sw zero, SEV_SEG(s0)
        sw zero, LEDS(s0)

MAIN_LOOP:
        # Pack display: [target << 12] | (score & 0xF)
        slli s4, s2, 12
        andi t0, s1, 0xF
        or s4, s4, t0
        sw s4, SEV_SEG(s0)

        # Read switches; if none, loop
        lw s5, 0(s0)	# Read 32-bit; wrapper places switches in low 16
        li t6, 0xFFFF
        and s5, s5, t6
        beq s5, x0, MAIN_LOOP	# No press yet

        # Decode exactly-one-bit and map to digit 0..9
        # a0 returns:
        # 0..9 => valid digit pressed
        # -1   => invalid (none/multiple/out-of-range)
        mv a1, s5
        jal ra, DECODE_SWITCH

        # Invalid? Wait for release then continue
        addi t0, x0, -1
        beq a0, t0, WAIT_RELEASE
        # Compare with target
        bne a0, s2, WAIT_RELEASE		# Wrong digit; no score
        # Correct input
        addi s1, s1, 1
        # Check for win condition (score == 10)
        li t0, 10
        beq s1, t0, GAME_WIN

        # New target = (old + 3) mod 10
        addi s2, s2, 3
        li t0, 10
        blt s2, t0, AFTER_TARGET_WRAP
        addi s2, s2, -10
        
AFTER_TARGET_WRAP:
        # Blink LEDs briefly as feedback
        li t0, 0x0000FFFF
        sw t0, LEDS(s0)
        li t1, 40000	# Tiny delay (busy loop)
        
BLINK_DLY1:
        addi t1, t1, -1
        bne t1, zero, BLINK_DLY1
        sw zero, LEDS(s0)

# Must wait for release before continuing
WAIT_RELEASE:
        lw t2, 0(s0)
        li t6, 0xFFFF
        and t2, t2, t6
        bne t2, zero, WAIT_RELEASE
        # Small post-release delay
        li t3, 40000
        
REL_DLY:
        addi t3, t3, -1
        bne t3, zero, REL_DLY
        j MAIN_LOOP

GAME_WIN:
	# Display "A" (10) for the score on the rightmost digit
	# and "A" for the target on the leftmost digit -> A00A
	li t0, 0xA00A
	sw t0, SEV_SEG(s0)

	# Turn on all LEDs to signify a win
	li t0, 0xFFFF
	sw t0, LEDS(s0)

# Halt the program in an infinite loop
GAME_HALT:
	j GAME_HALT

# In : a1 = raw switches (low 16 bits used)
# Out: a0 = 0..9 if exactly one valid bit set (SW15..SW6), else -1
# Uses t0..t6 only (legal temps)
DECODE_SWITCH:
        # Mask to 16 bits
        li t6, 0xFFFF
        and t0, a1, t6

        # Reject zero
        beq t0, zero, DS_FAIL

        # Check exactly one bit set: (x & (x-1)) == 0 ?
        addi t1, t0, -1
        and t2, t0, t1
        bne t2, zero, DS_FAIL	# multiple bits => fail

        # Find index of the single '1' bit (0..15 from LSB)
        addi    t3, zero, 0		# Bit index
        
FIND_BIT:
        andi t4, t0, 1
        bne t4, zero, GOT_BIT
        srli t0, t0, 1
        addi t3, t3, 1
        j  FIND_BIT
        
GOT_BIT:
        # Map bit index (0..15) to required digit 0..9 from left (SW15... SW6)
        # Compute digit = 15 - index; then ensure 0..9
        addi t5, zero, 15
        sub t6, t5, t3	# t6 = 15 - index

        # Is index within 6... 15 ? If index < 6 => invalid
        addi t5, zero, 6
        blt t3, t5, DS_FAIL	# Index < 6 => fail

        # t6 now 0... 9 => return in a0
        addi a0, t6, 0
        jr ra

DS_FAIL:
        addi a0, zero, -1
        jr ra