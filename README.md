# Traffic Light Controller with Pedestrian Crossing 

### RTL Design | Finite State Machine | Timer-Based Control | Functional Verification

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![FSM](https://img.shields.io/badge/Architecture-6--State%20FSM-green)
![VCS](https://img.shields.io/badge/Simulation-Synopsys%20VCS-orange)
![Verdi](https://img.shields.io/badge/Debugging-Synopsys%20Verdi-purple)
![Verification](https://img.shields.io/badge/Verification-Functional%20Testing-success)

---

## 1. Project Overview

This project presents the RTL design and functional verification of a **Traffic Light Controller with Pedestrian Crossing** using Verilog Hardware Description Language (HDL).

The design implements a two-road traffic management system that controls traffic signals for North-South (NS) and East-West (EW) directions.

A six-state Finite State Machine (FSM) is used to control the traffic light sequence. Programmable timers determine the duration of green, yellow, and all-red signal intervals.

Additionally, pedestrian request inputs are incorporated for both directions. These requests are synchronized using two-stage flip-flop synchronizers and stored using request flags.

When a pedestrian request is detected, the controller transitions from the corresponding vehicle green phase to the yellow phase, followed by the all-red interval and the next traffic phase.

The RTL design is simulated using **Synopsys VCS**, and waveform visualization and debugging are performed using **Synopsys Verdi**.

## 2. Design Specifications

| Parameter | Description |
|---|---|
| Project Name | Traffic Light Controller |
| Design Type | Sequential Digital Logic |
| Architecture | Six-State FSM |
| Traffic Directions | North-South and East-West |
| NS Traffic Light | 3-bit output |
| EW Traffic Light | 3-bit output |
| Pedestrian Inputs | ped_ns, ped_ew |
| Pedestrian Outputs | walk_ns, walk_ew |
| Clock | Positive-edge triggered |
| Reset | Active-low synchronous reset |
| Timer | 32-bit programmable counter |
| Pedestrian Synchronization | Two-stage synchronizer |
| HDL | Verilog |
| Simulator | Synopsys VCS |
| Waveform Viewer | Synopsys Verdi |
| Waveform Format | FSDB |

## 3. System Architecture

The traffic controller consists of the following functional blocks:

1. Finite State Machine (FSM)
2. Programmable Timer
3. Pedestrian Request Synchronizer
4. Pedestrian Request Detection Logic
5. Traffic Light Output Logic

### 3.1 Block-Level Architecture

```text
          Pedestrian NS Input
                  |
                  v
          Two-Stage Synchronizer
                  |
                  v
          Pedestrian Request Flag
                  |
                  v
                  |
                  v
Clock ------> Traffic Controller FSM ------> NS Traffic Light
                  ^                         |
                  |                         |
                  |                         v
                  |                    EW Traffic Light
                  |
             Timer Counter
                  ^
                  |
             Timer Control
                  |
                  |
          Pedestrian EW Input
                  |
                  v
          Two-Stage Synchronizer
                  |
                  v
          Pedestrian Request Flag
```

The FSM controls the traffic light sequence based on timer completion and pedestrian requests.

## 4. FSM Architecture

The design uses a six-state Finite State Machine to control the traffic signals.

The controller alternates between North-South and East-West traffic phases with appropriate yellow and all-red intervals.

### 4.1 State Description

| State | Encoding | Description |
|---|---|---|
| NS_GREEN | 000 | North-South traffic green |
| NS_YELLOW | 001 | North-South traffic yellow |
| ALL_RED1 | 010 | Both directions red |
| EW_GREEN | 011 | East-West traffic green |
| EW_YELLOW | 100 | East-West traffic yellow |
| ALL_RED2 | 101 | Both directions red |

### 4.2 State Transition Sequence

The normal traffic sequence follows:

```text
       NS_GREEN
           |
           v
       NS_YELLOW
           |
           v
        ALL_RED1
           |
           v
        EW_GREEN
           |
           v
       EW_YELLOW
           |
           v
        ALL_RED2
           |
           |
           +----------> NS_GREEN
```

### 4.3 State Transition Conditions

| Present State | Transition Condition | Next State |
|---|---|---|
| NS_GREEN | Timer completed OR EW pedestrian request | NS_YELLOW |
| NS_YELLOW | Timer completed | ALL_RED1 |
| ALL_RED1 | Timer completed | EW_GREEN |
| EW_GREEN | Timer completed OR NS pedestrian request | EW_YELLOW |
| EW_YELLOW | Timer completed | ALL_RED2 |
| ALL_RED2 | Timer completed | NS_GREEN |

The controller switches to the yellow phase when the corresponding pedestrian request is pending.

## 5. Traffic Light Encoding

The traffic lights are represented using 3-bit signals.

| Signal | Encoding | Description |
|---|---|---|
| RED | 100 | Stop |
| YELLOW | 010 | Prepare to stop |
| GREEN | 001 | Proceed |

### 5.1 North-South Traffic

| FSM State | NS Light |
|---|---|
| NS_GREEN | 001 |
| NS_YELLOW | 010 |
| ALL_RED1 | 100 |
| EW_GREEN | 100 |
| EW_YELLOW | 100 |
| ALL_RED2 | 100 |

### 5.2 East-West Traffic

| FSM State | EW Light |
|---|---|
| NS_GREEN | 100 |
| NS_YELLOW | 100 |
| ALL_RED1 | 100 |
| EW_GREEN | 001 |
| EW_YELLOW | 010 |
| ALL_RED2 | 100 |

The default output condition sets both traffic lights to RED.

## 6. Timer-Based Control

The design uses a 32-bit timer counter to control the duration of each traffic signal phase.

The timer increments on every positive edge of the clock.

When the timer reaches the configured timeout value, the `timer_done` signal becomes HIGH.

The counter resets when:

- The active-low reset is asserted.
- The current timer interval is completed.

### 6.1 Programmable Timer Parameters

| Parameter | Default Value | Description |
|---|---:|---|
| ns_green_time | 1000 | NS green duration |
| ew_green_time | 500 | EW green duration |
| yellow_time | 300 | Yellow duration |
| red_time | 100 | All-red duration |
| walk_time | 700 | Pedestrian walking duration |

**Note:** Timer values represent clock cycles, not direct time values. With a 10 ns clock period, 1000 cycles correspond to 10 µs.

The `walk_time` parameter is declared in the RTL but is not currently used in the pedestrian output logic.

## 7. Pedestrian Request Handling

The controller supports pedestrian requests for both North-South and East-West directions.

### 7.1 Two-Stage Synchronizer

The pedestrian inputs are asynchronous external signals.

To reduce the risk of metastability propagating into the control logic, each pedestrian input passes through a two-stage flip-flop synchronizer.

For North-South:

```verilog
ped_ns_sync1 <= ped_ns;
ped_ns_sync2 <= ped_ns_sync1;
```

For East-West:

```verilog
ped_ew_sync1 <= ped_ew;
ped_ew_sync2 <= ped_ew_sync1;
```

### 7.2 Pedestrian Request Detection

The controller detects a new pedestrian request using the synchronized input and a stored request flag.

A request is registered when the synchronized input becomes HIGH and the corresponding request flag is LOW.

```verilog
if (ped_ns_sync2 && !ped_ns_pressed)
    ped_ns_pressed <= 1'b1;
```

The same logic is implemented for the East-West pedestrian request.

### 7.3 Request Handling Conditions

- An East-West pedestrian request can terminate the NS green phase early.
- A North-South pedestrian request can terminate the EW green phase early.
- The controller transitions through the yellow phase before entering the all-red phase.
- The corresponding request flag is cleared when the request is serviced.

**Implementation note:** The current RTL declares `walk_ns` and `walk_ew` outputs but does not assert them. Pedestrian walking-phase timing and output control are potential future enhancements.

## 8. RTL Module Description

**Module Name:** `traffic_controller`

### 8.1 Input and Output Ports

| Port | Direction | Width | Description |
|---|---|---:|---|
| clk | Input | 1-bit | System clock |
| rst_n | Input | 1-bit | Active-low reset |
| ped_ns | Input | 1-bit | North-South pedestrian request |
| ped_ew | Input | 1-bit | East-West pedestrian request |
| light_ns | Output | 3-bit | North-South traffic signal |
| light_ew | Output | 3-bit | East-West traffic signal |
| walk_ns | Output | 1-bit | North-South pedestrian signal |
| walk_ew | Output | 1-bit | East-West pedestrian signal |

### 8.2 Internal Registers and Signals

| Signal | Width | Description |
|---|---:|---|
| state | 3-bit | Current FSM state |
| next_state | 3-bit | Next FSM state |
| timer_count | 32-bit | Timer counter |
| current_timeout | 32-bit | Selected timer duration |
| timer_done | 1-bit | Timer completion indicator |
| ped_ns_sync1 | 1-bit | First NS synchronizer stage |
| ped_ns_sync2 | 1-bit | Second NS synchronizer stage |
| ped_ew_sync1 | 1-bit | First EW synchronizer stage |
| ped_ew_sync2 | 1-bit | Second EW synchronizer stage |
| ped_ns_pressed | 1-bit | NS pedestrian request flag |
| ped_ew_pressed | 1-bit | EW pedestrian request flag |

## 9. Repository Structure

```text
traffic-light-controller/
│
├── traffic_controller.v
│   └── Traffic controller RTL design
│
├── traffic_controller_tb.v
│   └── Verilog testbench
│
├── screenshots/
│   └── verdi_waveform.png
│
├── README.md
│
└── .gitignore
```

## 10. Functional Verification

A Verilog testbench is developed to verify the functionality of the traffic light controller.

The testbench generates a clock signal with a 10 ns period and applies reset and pedestrian request inputs.

### 10.1 Testbench Configuration

| Parameter | Value |
|---|---|
| Clock Period | 10 ns |
| Clock Frequency | 100 MHz |
| Reset | Active-low |
| Initial State | NS_GREEN |
| NS Pedestrian Input | ped_ns |
| EW Pedestrian Input | ped_ew |
| Simulation | Functional simulation |

### 10.2 Test Scenarios

| Test Case | Input Condition | Expected Behavior |
|---|---|---|
| TC1 | Reset asserted | Controller initializes to NS_GREEN |
| TC2 | No pedestrian request | Normal timer-based traffic sequence |
| TC3 | NS pedestrian request | Request is stored and serviced during EW green phase |
| TC4 | EW pedestrian request | Request is stored and serviced during NS green phase |
| TC5 | Both pedestrian requests | Both requests are captured and handled according to the FSM sequence |

### 10.3 Testbench Input Sequence

The testbench applies the following sequence:

1. Initialize clock and pedestrian inputs.
2. Assert active-low reset.
3. Release reset after 20 ns.
4. Allow normal traffic operation.
5. Apply an NS pedestrian request.
6. Apply an EW pedestrian request.
7. Apply simultaneous NS and EW pedestrian requests.
8. Observe traffic light outputs and FSM behavior.
9. Complete simulation.

### 10.4 Expected Verification Results

The simulation is used to verify:

- Correct reset operation.
- Correct NS and EW traffic signal sequencing.
- Timer-based state transitions.
- Pedestrian input synchronization.
- Pedestrian request flag generation.
- Early termination of the green phase when a corresponding request is pending.
- Correct yellow and all-red transitions.

## 11. Simulation Using Synopsys VCS

Synopsys VCS is used to compile and simulate the Verilog RTL design and testbench.

### 11.1 Compilation

Compile the RTL and testbench files using:

```bash
vcs -full64 -debug_access+all \
traffic_controller.v \
traffic_controller_tb.v \
-o simv
```

Ensure the appropriate FSDB PLI integration is configured if FSDB waveform dumping is enabled.

### 11.2 Execute Simulation

```bash
./simv
```

The testbench displays simulation information using the `$monitor` system task.

### 11.3 FSDB Waveform Generation

The testbench uses the following commands to generate the FSDB waveform database.

```verilog
initial begin
    $fsdbDumpfile("traffic_controller.fsdb");
    $fsdbDumpvars(0, traffic_controller_tb);
end
```

Ensure that the appropriate Verdi FSDB PLI integration is enabled during VCS compilation.

### 11.4 Open Waveform in Synopsys Verdi

```bash
verdi -ssf traffic_controller.fsdb &
```

The generated waveform can be explored using the Verdi waveform viewer.

## 12. Waveform Analysis Using Synopsys Verdi

Synopsys Verdi is used to visualize and analyze the simulation waveforms.

The following signals are observed:

| Signal | Description |
|---|---|
| clk | System clock |
| rst_n | Active-low reset |
| ped_ns | NS pedestrian request |
| ped_ew | EW pedestrian request |
| light_ns | NS traffic light output |
| light_ew | EW traffic light output |
| walk_ns | NS pedestrian walking output |
| walk_ew | EW pedestrian walking output |
| state | Current FSM state |
| timer_count | Timer counter |
| timer_done | Timer completion signal |
| ped_ns_pressed | NS request flag |
| ped_ew_pressed | EW request flag |

Waveform analysis helps verify:

- Clock and reset behavior.
- FSM state transitions.
- Timer counter operation.
- Normal traffic light sequencing.
- Pedestrian request synchronization.
- Pedestrian request flag behavior.
- Traffic light output changes.

### Simulation Waveform

![Traffic Light Controller Verdi Waveform](screenshots/verdi_waveform.png)

*Synopsys Verdi waveform showing traffic signals, pedestrian requests, clock, and reset.*

## 13. Tools and Technologies

| Tool / Technology | Application |
|---|---|
| Verilog HDL | RTL design implementation |
| Synopsys VCS | RTL compilation and simulation |
| Synopsys Verdi | Waveform visualization and debugging |
| FSDB | Simulation waveform database |
| Git | Version control |
| GitHub | Project hosting and documentation |

## 14. Key Learning Outcomes

Through this project, the following concepts are explored:

- Sequential digital circuit design.
- Finite State Machine implementation.
- Six-state FSM architecture.
- Traffic signal control logic.
- Timer-based control systems.
- Programmable counter implementation.
- Asynchronous input synchronization.
- Two-stage flip-flop synchronizers.
- Pedestrian request detection and storage.
- Verilog RTL modeling.
- Testbench development.
- Functional verification.
- RTL simulation using Synopsys VCS.
- Waveform analysis using Synopsys Verdi.
- FSDB waveform generation and debugging.

## 15. Future Enhancements

Potential improvements to the current design include:

- Implementing pedestrian walking signal control.
- Integrating the declared `walk_time` parameter into the FSM.
- Adding dedicated pedestrian crossing states.
- Implementing pedestrian request prioritization.
- Adding a configurable clock divider.
- Supporting emergency vehicle priority.
- Extending the design to multiple intersections.
- Performing RTL synthesis and area analysis.
- Performing timing analysis and optimization.
- Developing a self-checking testbench with assertions.

## 16. Author

**SANTHOSH KUMAR N A**

RTL Design | Digital Electronics | VLSI Engineering

- GitHub: [Your GitHub Profile](https://github.com/your-username)
- LinkedIn: [Your LinkedIn Profile](https://linkedin.com/in/your-profile)

## 17. License

This project is intended for educational and learning purposes.

Feel free to explore, modify, and extend the implementation with appropriate attribution.

---

<p align="center">
  <b>Designed with Verilog HDL | Simulated using Synopsys VCS | Debugged using Synopsys Verdi</b>
</p>

<p align="center">
  ⭐ If you find this project useful, consider giving the repository a star!
</p>

---

### GitHub Topics

`verilog` `traffic-light-controller` `pedestrian-crossing` `fsm` `finite-state-machine` `rtl-design` `digital-design` `vlsi` `timer-based-control` `synchronizer` `synopsys-vcs` `synopsys-verdi` `fsdb` `rtl-verification`
