# CYCLE 64

A robot-programming puzzle game for an unexpanded PAL Commodore 64, created by
MacTee. Write a program, explore the facility and work within a 64-cycle loop.
The facility resets, while your program, discovered records, codes and firmware
survive between attempts.

The game builds into one standalone PRG containing the code, graphics and
three-voice SID music. It performs no additional file loads and needs no memory
expansion. See [AI_USAGE.md](AI_USAGE.md) for development attribution.

## Requirements

To build:

- **Java**, tested with Java 18.0.2.
- **Kick Assembler 5.25** (`KickAss.jar`), obtained separately from
  [the official Kick Assembler site](https://www.theweb.dk/KickAssembler/).
- **Windows PowerShell 5.1 or later** for the supplied scripts. A direct Java
  command is also provided below for other environments.

To play in an emulator, use **VICE `x64sc` in PAL mode**, tested with VICE 3.8.
Java, Kick Assembler, VICE and Commodore ROMs are not included in this repository.
No Python, Node.js or asset-generation step is needed to rebuild the game.

## Get the source

```powershell
git clone https://github.com/MacTee/C64-Games-CYCLE64.git
cd C64-Games-CYCLE64
```

## Build on Windows

Run this from the repository directory, replacing the two tool paths with your
installed locations:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1 `
  -Java 'C:\Tools\Java\bin\java.exe' `
  -KickAss 'C:\Tools\KickAssembler\KickAss.jar'
```

The script creates `build/`, assembles `src/main.asm`, checks the memory-layout
assertions and prints the output's SHA256. The playable result is:

```text
build/cycle64.prg
```

Assembler symbols (`main.sym`, `main.vs`) and `assembly.log` are also generated
inside `build/`. These files are ignored by Git.

The scripts have defaults for the original development machine under
`D:\Projects\Emulator.C64\_programs`. Other machines should pass the explicit
paths shown above; the repository itself can be located anywhere.

## Build directly with Java

From the repository root, create the `build` directory and run:

```text
java -jar /path/to/KickAss.jar src/main.asm -o build/cycle64.prg -showmem
```

All assembly includes and artwork imports are relative to the source files.
The music's note data is already included in assembly form. The original music
demo, design documents and local playtest folders are not build dependencies.

## Run

Using the Windows launcher:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1 `
  -Vice 'C:\Tools\VICE\bin\x64sc.exe'
```

Or launch VICE directly:

```text
x64sc -default -pal -autostart-handle-tde -autostartprgmode 0 -autostart build/cycle64.prg
```

For a real C64, transfer the PRG to suitable media, load it with secondary
address 1 and enter `RUN`. Real-hardware operation has not been verified.

The game uses the keyboard:

| Key | Action |
| --- | --- |
| Space | Start/advance pages; step one cycle in the game |
| F1 | Run or continue a paused program |
| F3 | Step one cycle |
| F5 | Music on/off; sound effects remain enabled |
| F7 | Reset the loop, keeping the program and knowledge |
| H | Help and command reference |
| V | Mission log and collected records |

The in-game help explains the editor and robot commands. Contact with an active
laser destroys the robot and resets the facility; other failed commands pause
for correction.

## Project layout

| Path | Contents |
| --- | --- |
| `src/main.asm` | Main assembly entry point and memory layout |
| `src/` | Game engine, editor, renderer, sound and music player |
| `src/data/` | Rooms, dialogue, hints, graphics and music tables |
| `src/data/title/` | Seven required binary title-art assets and their notes |
| `build.ps1` | Assemble the release or optional engine-test build |
| `run.ps1` | Launch the built PRG in PAL VICE |
| `tests/` | Directed engine-regression assembly |
| `test.ps1` | Optional external `c64ctl` regression runner |

The title `.bin` files are source assets and must be retained. Build output,
local design/handoff packages, agent state, backups and playtest reports are
excluded through `.gitignore`.

The optional test runner requires a separately installed `c64ctl` emulator CLI
and uses the build script's development-machine defaults. It is not needed to
produce or play the release PRG. An engine-test PRG can be assembled explicitly
by adding `-EngineTests` to the Windows build command above.
