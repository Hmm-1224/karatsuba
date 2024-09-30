# 32-bit Sequential Karatsuba Multiplier

- **Project Overview**: Implements a 32-bit sequential Karatsuba multiplier using a single 16-bit multiplication module.
- **Algorithm**: Leverages the Karatsuba algorithm to efficiently multiply large numbers by breaking them into smaller parts.

## Features

- **32-bit Input**: Accepts two 32-bit numbers as input.
- **16-bit Submodules**: Utilizes 16-bit multipliers for smaller multiplication tasks.
- **Control Logic**: Implements a finite state machine (FSM) to manage the multiplication process.
- **Synchronous Design**: Designed to work with a clock signal for synchronization and reset functionality.
- **Enable Signal**: Can be enabled or disabled for operation as needed.

## Modules Overview

### 1. `iterative_karatsuba_32_16`
- **Description**: Top-level module that coordinates the multiplication process.
- **Inputs**: 
  - `clk`: Clock signal
  - `rst`: Reset signal
  - `A`: First 32-bit input
  - `B`: Second 32-bit input
  - `enable`: Enable signal for operation
- **Output**: 
  - `C`: 64-bit output representing the product of `A` and `B`

### 2. `iterative_karatsuba_datapath`
- **Description**: Performs the core multiplication operations.
- **Inputs**: 
  - `X`: First operand
  - `Y`: Second operand
  - `T`: Temporary storage
  - `Z`: Output from previous calculations
- **Outputs**: 
  - `W1`: Output for the selected multiplication result
  - `W2`: Temporary result for further processing

### 3. `iterative_karatsuba_control`
- **Description**: Manages the state transitions of the multiplier.
- **Inputs**: 
  - `clk`: Clock signal
  - `rst`: Reset signal
  - `enable`: Enable signal
- **Outputs**: 
  - `sel_x`, `sel_y`, `sel_z`, `sel_T`: Select lines for data routing
  - `en_z`, `en_T`: Enable signals for registers
  - `done`: Indicates when the multiplication is complete

### 4. `reg_with_enable`
- **Description**: Register module that captures data on the clock's rising edge if enabled, and resets on a reset signal.

### 5. `mult_16` and `mult_17`
- **Description**: Modules that perform 16-bit and 17-bit multiplications respectively.

### 6. Arithmetic Support Modules
- **Description**: Includes modules for full adders, N-bit adders, subtractors, and bit manipulation (like 2's complement).

## Usage

- **Instantiation**: To use the Karatsuba multiplier, instantiate the `iterative_karatsuba_32_16` module in your top-level design. 
- **Connections**: Connect the inputs and outputs as required, and manage the `clk`, `rst`, and `enable` signals to control the operation.

NOTE : To run this make sure your device has verilog compiler otherwise you can use online verilog compiler just copy paste my code over there along with testbench.
