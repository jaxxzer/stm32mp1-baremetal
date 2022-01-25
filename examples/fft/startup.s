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

    LDR r0, =(0xF << 20)
    MCR p15, 0, r0, c1, c0, 2
    MOV r3, #0x40000000 
    VMSR FPEXC, r3

    bl main
    b .
