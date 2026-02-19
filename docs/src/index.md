# GroverAlgorithm.jl

Julia Module for simulating and visualizing quantum circuit.
As a backend, ITensors.jl/ITensorMPS.jl and Quantikz are required.

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
tp = to_quantikz(circuit)
```

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/sotashimozono/GroverAlgorithm.jl")
```

## Related Links

- [GitHub Repository](https://github.com/sotashimozono/GroverAlgorithm.jl)
- [ITensors.jl Documentation](https://itensor.github.io/ITensors.jl/)
- [Quantikz Package](https://ctan.org/pkg/quantikz)
