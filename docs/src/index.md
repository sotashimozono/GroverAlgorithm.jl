# GroverAlgorithm.jl

Integrated Julia package for quantum circuit simulation and visualization.

## Features

- **Quantum Gates**: Wide range of gates from 1-qubit to 4-qubit operations
- **Initial State Abstraction**: Support for computational basis, custom labels, and product states
- **Measurements**: Expectation values, sampling, and projective measurements
- **ITensors Integration**: Efficient simulation using Matrix Product States (MPS)
- **Quantikz Visualization**: Beautiful circuit diagrams via LaTeX/TikZ

## Quick Start

```julia
using GroverAlgorithm
using ITensors, ITensorMPS

# Create a Bell state circuit
circuit = QuantumCircuit(2, AbstractQuantumGate[])
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))

# Simulate with ITensors
sites = siteinds("Qubit", 2)
psi = execute_circuit(circuit, sites)

# Measure
counts = measure(psi, Sampling(1000))
println(counts)  # Dict("00" => ~500, "11" => ~500)

# Visualize
println(to_quantikz(circuit))
```

## Installation

```julia
using Pkg
Pkg.add("GroverAlgorithm")
```

## Documentation Structure

### Basics

- [**Getting Started**](getting_started.md) - Create your first quantum circuit and learn how it appears in ITensors and Quantikz

### Core Concepts

- [**Quantum Gates and Circuits**](structures.md) - Details of gate types and circuit structures
- [**Initial States**](initialstates.md) - Define and customize initial states
- [**Measurements**](measurements.md) - Various measurement methods

### Usage

- [**ITensor Conversion**](itensor_conversion.md) - Running simulations with ITensors
- [**Quantikz Visualization**](quantikz_visualization.md) - Generating and customizing circuit diagrams

### Examples

- [**Examples and Tutorials**](examples.md) - Practical examples including Toffoli gates and Grover's algorithm

## API Reference

```@autodocs
Modules = [GroverAlgorithm]
```

## Related Links

- [GitHub Repository](https://github.com/sotashimozono/GroverAlgorithm.jl)
- [ITensors.jl Documentation](https://itensor.github.io/ITensors.jl/)
- [Quantikz Package](https://ctan.org/pkg/quantikz)
