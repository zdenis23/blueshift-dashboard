// sBPF Timeout Challenge
// Validates that the current blockchain slot has not exceeded a deadline.
//
// Input: Clock account (40 bytes) as accounts[0]; u64 target slot in instruction data.
// Returns: r0 = 0 (success) if current_slot <= target_slot, r0 = 1 (error) otherwise.
//
// Input buffer memory layout (r1 = base pointer):
//   Offset 0x0060 → Clock.slot  = first 8 bytes of account[0].data
//   Offset 0x2898 → instruction_data[0..8] = u64 target slot (little-endian)
//
// Offset proofs:
//   CURRENT_SLOT:     8 + (1+1+1+1+4) + 32 + 32 + 8 + 8 = 96 = 0x0060
//   INSTRUCTION_SLOT: 0x60 + 40 (data) + 10240 (realloc reserve) + 8 (rent_epoch)
//                     + 8 (instr_len) = 10392 = 0x2898
//
// Compute units: 5 instructions × 1 CU = 5 CU (theoretical minimum for this logic)
// Binary code size: 5 × 8 bytes = 40 bytes

.equ CURRENT_SLOT,    0x0060   // Clock.slot: first u64 in Clock account data
.equ INSTRUCTION_SLOT, 0x2898  // Target slot: u64 in instruction data payload

.globl entrypoint
entrypoint:
  ldxdw r2, [r1 + INSTRUCTION_SLOT]  // r2 = target_slot  (deadline, from instruction data)
  ldxdw r1, [r1 + CURRENT_SLOT]      // r1 = current_slot (from Clock account, r1 was base ptr)
  jle r1, r2, success                // unsigned cmp: if current <= target → within deadline
  mov64 r0, 1                        // deadline exceeded: set error code 1 (8-byte form, optimal)
success:
  exit                               // return r0: 0 = success, 1 = timeout error
