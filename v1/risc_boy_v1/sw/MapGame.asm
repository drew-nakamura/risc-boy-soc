#IMEM: 0-FFF
#WMEM(DRAM): 1000-2FFF
#VRAM: 3000-3FFF
#MMIO: 4000
    #Joy-Con/Buttons: 4000 4LSB
    #Player X: 4004
    #Player Y: 4008
    #Goal X: 400C
    #Goal Y: 4010
    #Goal X-wards size: 4014
    #Goal Y-wards size: 4018

.data
# LEVEL ONE MAP (20 words)
MAP1:
    .word 0,0,0,0
    .word 0,0,0,0
    .word 0xFF000,0xFF000,0xFF000,0xFF000
    .word 0xFF000,0xFF000,0xFF000,0xFF000
    .word 0,0,0,0
    .word 0x50000000,0x20000000,0x50000000,0

# LEVEL TWO MAP (20 words)
MAP2:
    .word 0,0,0,0
    .word 0,0,0,0
    .word 0xFFFFFFF,0,0,0
    .word 0,0,0,0
    .word 0xFFFFFFF0,0,0,0
    .word 0x50000000,0x20000000,0x50000000,0

# LEVEL THREE MAP (20 words)
MAP3:
    .word 0x00000000,0x00000000,0x00000000,0x1FFF8FF8
    .word 0x02008808,0x02008808,0xFE008808,0x00208888
    .word 0x00208880,0x0A208880,0x1F208880,0x1F2088FF
    .word 0x0E2A8808,0x04248808,0x002A8808,0x00208888
    .word 0x1FFF8888,0x10100880,0x10100880,0x10100880
    .word 0x111FFFF8,0x01000000,0x01000000,0x01000000    
            
# WIN SCREEN (20 words)
WIN:
    .word 0, 0x55555555, 0xAAAAAAAA, 0
    .word 0,0,0,0
    .word 0x2211C444,0x22308444,0x22508444,0x22508444
    .word 0x22908444,0x229082A8,0x031082A8,0x2211C110
    .word 0,0,0,0
    .word 0,0xAAAAAAAA,0x55555555,0

LEVEL: 
    .word 1
    
.text

main:
    li sp, 0x4ffc
    jal load_level_1
    j game_loop
    
# Game logic -----------------------------------
game_loop:
    li t3, 0x4000	# Joy-Con MMIO
    lw t4, 0(t3)	# Button Read
    
    li t0, 0x4000	# MMIO
    lw t1, 4(t0)	# t1 = x position
    lw t2, 8(t0)	# t2 = y position
    
    mv a0, t1
    mv a1, t2

    # Movement Checker
    andi t3, t4, 1
    bnez t3, move_up
    andi t3, t4, 2
    bnez t3, move_down
    andi t3, t4, 4
    bnez t3, move_left
    andi t3, t4, 8
    bnez t3, move_right
    j game_loop

# Movements
move_up:
    mv a2, a0
    addi a3, a1, -1
    j moved

move_down:
    mv a2, a0
    addi a3, a1, 1
    j moved

move_left:
    addi a2, a0, -1
    mv a3, a1
    j moved

move_right:
    addi a2, a0, 1
    mv a3, a1
    j moved
    
moved:
    jal check_move
    bnez a4, goal_reached
    mv a0, a2
    mv a1, a3
    jal update_player
    j game_loop
    
goal_reached:
    la t0, LEVEL
    lw t0, 0(t0)
    li t1, 1
    beq t0, t1, to_level_2
    li t1, 2
    beq t0, t1, to_level_3
    j end
    
to_level_2:
    la t0, LEVEL
    li t1, 2
    sw t1, 0(t0)
    jal load_level_2
    j game_loop
    
to_level_3:
    la t0, LEVEL
    li t1, 3
    sw t1, 0(t0)
    jal load_level_3
    j game_loop
    
# --------- Functions ------------

# Load info for Level 1
load_level_1: 
    addi sp, sp, -4
    sw ra, 0(sp)
    li a0, 0x3000        # VRAM address
    la a1, MAP1           # pointer to MAP
    li a2, 24            # number of words in MAP
    jal copy_map
    li a0, 2
    li a1, 2
    jal update_player
    li a0, 28
    li a1, 20
    li a2, 3
    li a3, 3
    jal update_goal
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# Load info for Level 2
load_level_2: 
    addi sp, sp, -4
    sw ra, 0(sp)
    li a0, 0x3000        # VRAM address
    la a1, MAP2           # pointer to MAP
    li a2, 24            # number of words in MAP
    jal copy_map
    li a0, 2
    li a1, 2
    jal update_player
    li a0, 28
    li a1, 20
    li a2, 3
    li a3, 3
    jal update_goal
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# Load info for Level 3
load_level_3: 
    addi sp, sp, -4
    sw ra, 0(sp)
    li a0, 0x3000        # VRAM address
    la a1, MAP3           # pointer to MAP
    li a2, 24            # number of words in MAP
    jal copy_map
    li a0, 1
    li a1, 1
    jal update_player
    li a0, 17
    li a1, 12
    li a2, 3
    li a3, 3
    jal update_goal
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# Draw Map into VRAM
copy_map: # a0 = VRAM address, a1 = Map, a2 = Number of words in Map
    lw t0, 0(a1)
    sw t0, 0(a0)
    addi a1, a1, 4
    addi a0, a0, 4
    addi a2, a2, -1
    bnez a2, copy_map
    ret
    
# Send new player location to MMIO
update_player: # a0 = new x, a1 = new y
    li t0, 0x4000
    sw a0, 4(t0)
    sw a1, 8(t0)
    ret
    
# Update goal information
update_goal: # a0 = goal x, a1 = goal y, a2 = goal x size, a3 = goal y size
    li t0, 0x400C
    sw a0, 0(t0)
    sw a1, 4(t0)
    sw a2, 8(t0)
    sw a3, 12(t0)
    ret
    
    
# Check if the move is valid
check_move: # a0 = old x, a1 = old y, a2 = new x, a3 = new y, a4 = reached goal?
    
    # Check if it's in bounds
    blt a2, zero, invalid
    blt a3, zero, invalid
    li t0, 31 # x-bound
    li t1, 23 # y-bound
    bgt a2, t0, invalid
    bgt a3, t1, invalid
    
    # Check if goal reached
    li   t0, 0x400C      # base of goal info
    lw   t1, 0(t0)           # goal_x
    lw   t2, 4(t0)           # goal_y
    lw   t3, 8(t0)           # goal_x_size
    lw   t4, 12(t0)          # goal_y_size
    
    blt  a2, t1, not_goal
    add  t5, t1, t3          # goal_x + size
    bge  a2, t5, not_goal
    blt  a3, t2, not_goal
    add  t6, t2, t4          # goal_y + size
    bge  a3, t6, not_goal

    li   a4, 1               # reached goal
    ret

    not_goal:
    li a4, 0
    
    # Check if there's a wall in the way
    slli t0, a3, 2 		# this is y coordinate * 4
    li t1, 0x3000		# this is the start of VRAM
    add t0, t0, t1		# this is the address it's at
    lw t1, 0(t0)		# this is what's on that line atm
    li t2, 1			# this is just a 1
    sll t2, t2, a2		# this is a 1 at the new x bit
    and t3, t1, t2		# this clears everything except that exact bit
    bnez t3, invalid		# this invalidates the move if there's a wall there!
    
    ret

    invalid:
    mv a2, a0
    mv a3, a1
    ret

end:
    li a0, -1
    li a1, -1
    jal update_player
    li a0, 0x3000        # VRAM address
    la a1, WIN           # pointer to MAP
    li a2, 24            # number of words in MAP
    jal copy_map