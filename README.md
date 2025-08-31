# Flip-That-Digit

## Table of Contents

1. [Project Description](#project-description)
   - [Prerequisites](#prerequisites)
   - [Installation](#installation)
2. [Getting Started](#getting-started)
3. [Usage](#usage)
4. [Contact](#contact)
5. [Acknowledgments](#acknowledgments)

## Project Description

The device is built for the interactive game “Flip That Digit.” The purpose of the game is that the user must flip the ordered switch corresponding to the number shown on the seven segment display with a streak display, which increments each correct response. The game runs continuously: a new, randomly generated target between zero and nine appears after each correct answer until the user times out or completes a streak of 10. The target number is the leftmost seven-segment position on the display, whereas the current streak count is the rightmost seven-segment position.

### Built With

![Assembly Badge](https://img.shields.io/badge/assembly-assembly?style=for-the-badge&color=darkblue)

![SystemVerilog Badge](https://img.shields.io/badge/systemverilog-systemverilog?style=for-the-badge&color=lightblue)

![RARS Badge](https://img.shields.io/badge/rars-rars?style=for-the-badge&color=orange)

![Vivado Badge](https://img.shields.io/badge/vivado-vivado?style=for-the-badge&color=white)

## Getting Started

### Prerequisites

- [Basys3 Board](https://digilent.com/shop/basys-3-amd-artix-7-fpga-trainer-board-recommended-for-introductory-users/) or any programmable device
- Computer to connect
- Micro-USB cable

### Installation

- Plug the Basys3 Board into your computer using a micro-USB cable.
- Switch the power slider (SW16 in the top left corner) to the "ON" position; the "DONE" LED will light after successful programming.
- Open Vivado, connect to the hardware server.
- Select the Basys3 device from the list or autoconnect and program the device with the project bitstream file (.bit).
- Once programmed, the device will immediately launch and run the game.

## Usage

## Contact

Brian Li - brian.li.social@gmail.com

## Acknowledgments

- Joshua Naim, co-engineer
- Digilent
