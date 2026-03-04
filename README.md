# UART Implementation

**Language:** Verilog

## Overview
This repository contains a Register-Transfer Level (RTL) implementation of a Universal Asynchronous Receiver-Transmitter (UART) module. The design is highly parameterizable and provides reliable full-duplex serial communication for FPGA or ASIC projects.

## Features
* Full-duplex asynchronous communication (independent TX and RX paths).
* Parameterizable baud rate generation (e.g., 9600, 115200) based on the system clock.
* Configurable frame format:
  * Data bits (typically 8 bits).
  * Parity bit (None, Even, Odd).
  * Stop bits (1 or 2).
* Receiver oversampling (e.g., 16x) for noise filtering and robust data recovery.
* Error detection flags (Parity error, Framing error).

## Architecture
The UART module consists of three main sub-blocks:



[Image of UART block diagram]


* **Baud Rate Generator:** Divides the system clock to generate the precise timing ticks required for both transmitting and receiving data.
* **Transmitter (TX):** A Finite State Machine (FSM) that takes parallel data, adds start, parity, and stop bits, and shifts it out serially on the `tx` pin.
* **Receiver (RX):** An FSM that detects the start bit, synchronizes with the incoming serial stream on the `rx` pin, samples the data bits, verifies parity/framing, and outputs parallel data.

## Interfaces
* **Clock and Reset:** `clk`, `rst_n`
* **Serial Lines:** `tx` (Transmit Data), `rx` (Receive Data)
* **Control/Status:** `tx_start`, `tx_busy`, `rx_done`, `error_flags`
* **Data Buses:** `tx_data` (input), `rx_data` (output)
