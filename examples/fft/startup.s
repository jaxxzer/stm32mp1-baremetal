.syntax unified
.cpu cortex-a7

.section .vector_table, "x"
.global _Reset
.global _start
_Reset:
    b Reset_Handler
    b . /* 0x4  Undefined Instruction */
    b . /* Software Interrupt */
    b .  /* 0xC  Prefetch Abort */
    b . /* 0x10 Data Abort */
    b . /* 0x14 Reserved */
    b . /* 0x18 IRQ */
    b . /* 0x1C FIQ */

.section .text
Reset_Handler:
        MRC p15,0,r0,c1,c0,2    // Read CP Access register
        ORR r0,r0,#0x00f00000   // Enable full access to NEON/VFP (Coprocessors 10 and 11)
        MCR p15,0,r0,c1,c0,2    // Write CP Access register
        ISB
        MOV r0,#0x40000000      // Switch on the VFP and NEON hardware
        VMSR FPEXC,r0            // Set EN bit in FPEXC


    bl main
    b .
