# Shadow Torch

A torch timer application built for Shadowdark RPG sessions in Godot 4.x.

## Overview
ShadowTorch is a helpful tool to track torch and light resources; specifically created for the Shadowdark TTRPG. 

## Features

- **Configurable Torch Duration**: Set default torch burn time (default: 6 turns/60 minutes)
- **Multiple Time Units**: Display time in Minutes (MM:SS), Turns, or Hours
- **Visual Status Indicators**: Color-coded torch status (Green=lit, Yellow=low, Red=extinguished, Gray=out)
- **Real-time Countdown**: Live timer updates for all active torches
- **Easy Torch Management**: Add, remove, and track multiple torches simultaneously

## How to Use

1. **Add Torches**: Click "Add Torch" to create a new torch with the default duration
2. **Configure Settings**: Click the gear icon to adjust default duration and time units
3. **Monitor Status**: Watch the color-coded backgrounds and countdown timers
4. **Remove Torches**: Click the "X" button on individual torches when no longer needed

## Color Coding

- **Green**: Torch is burning bright (>50% remaining)
- **Yellow**: Torch is burning low (25-50% remaining) 
- **Red**: Torch is almost out (<25% remaining)
- **Gray**: Torch has been extinguished

## Requirements

- Godot 4.x engine to run the project
- Designed for tabletop RPG sessions

## Installation

1. Clone this repository
2. Open the project in Godot 4.x
3. Run the scene `scenes/main.tscn`

## Contributing

This project is open for improvements and feature additions. See `todo.md` for planned features.

## License

Open source - feel free to modify and distribute for your gaming sessions.