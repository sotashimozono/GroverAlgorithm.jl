# Getting Started: Your First Quantum Circuit

In this page, you will learn:

- How to construct quantum circuits on GroverAlgorithm.jl
- How quantum circuits on GroverAlgorithm.jl works in ITensors and Quantikz.

## Install

In order to use visualize functions, `LaTeX` and `Quantikz` may be needed.

```julia
using Pkg
Pkg.add(url="https://github.com/sotashimozono/GroverAlgorithm.jl")
Pkg.add("ITensors")
Pkg.add("ITensorMPS")
```

## Basics

In GroverAlgorithm.jl, use quantum circuits as follows:

1. Construct circuit - define circuit by adding desired gates.
2. Simulation on ITensors.jl - calculate quantum states.
3. Visualize circuits on Quantikz - generate circuits figure on LaTeX

## Example: Hadamard gate

Let's consider from easiest one.

### step1: Construct gate

```@example getting_started
using GroverAlgorithm
using ITensors, ITensorMPS

# 1 site qubit
circuit = QuantumCircuit(1, AbstractQuantumGate[])

# add Hadamard gate
add_gate!(circuit, SingleQubitGate(1, :H))

println("circuit information:")
println("  number of qubits: ", circuit.nqubits)
println("  number of gates: ", length(circuit.gates))
```

### step2: Simulation on ITensors.jl

```@example getting_started
using ITensors, ITensorMPS

# site index
sites = siteinds("Qubit", 1)

# execute circuit
psi = execute_circuit(circuit, sites)

# MPS info
println("\nMPS (Matrix Product State):")
println(psi)
```

structure of MPS：

```@example getting_started
println("amplitude of quantum states:")
amp_0 = inner(psi, MPS(sites, ["0"]))
amp_1 = inner(psi, MPS(sites, ["1"]))

println("  ⟨0|ψ⟩ = ", amp_0, " (probability: ", abs2(amp_0), ")")
println("  ⟨1|ψ⟩ = ", amp_1, " (probability: ", abs2(amp_1), ")")
```

this means the state $|\psi\rangle$ is superposition of $|0\rangle, |1\rangle$:  
$$\begin{aligned}
|\psi\rangle = \frac{|0\rangle+|1\rangle}{\sqrt2}
\end{aligned}$$

### step3: Visualization on Quantikz

```@example getting_started
# generate LaTeX string of quantikz
latex_code = to_quantikz(circuit)
println("Quantikz LaTeX code:")
println(latex_code)
```

This LaTeX code generates following：

```@example getting_started
to_tikz_picture(circuit)
```

## Example2: Bell state（Entanglement）

Next, we construct 2-site qubit.

### step1: construct circuits

```@example getting_started
circuit = QuantumCircuit(2, AbstractQuantumGate[])

add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))

println("Bell state circuit:")
println("  gate1: H on qubit 1")
println("  gate2: CNOT (control: 1, target: 2)")
```

### step2: Simulation on ITensors

```@example getting_started
sites = siteinds("Qubit", 2)
psi = execute_circuit(circuit, sites)

println("amplitude of Bell state:")
for s in ["00", "01", "10", "11"]
    basis = MPS(sites, [string(c) for c in s])
    amp = inner(basis, psi)
    prob = abs2(amp)
    println("  ⟨$s|ψ⟩ = ", round(amp, digits=4), " (probability: ", round(prob, digits=4), ")")
end
```

### step3: Visualize circuit on Quantikz

```@example getting_started
latex_code = to_quantikz(circuit)
println(latex_code)

to_tikz_picture(circuit)
```
