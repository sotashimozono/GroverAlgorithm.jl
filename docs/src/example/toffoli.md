```@meta
EditURL = "../../../example/toffoli.jl"
```

# Toffoli Gate Example
Here we define the Toffoli gate (CCNOT) using the GroverAlgorithm package
This is an example of how to use the package.
Toffoli gate is available in ITensorMPS.jl as a built-in gate.
Let's create a Toffoli gate and check its action on the basis states.

## Using the built-in Toffoli gate
In ITensorMPS.jl, the Toffoli gate is available as a built-in three-qubit gate. We can simply add it to our quantum circuit and execute it.

````@example toffoli
using Printf
using GroverAlgorithm
using ITensors, ITensorMPS

circuit = QuantumCircuit(3)
add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))

sites = siteinds("Qubit", 3)
psi = execute_circuit(circuit, sites)
counts = measure(psi, Sampling(100))
println("結果: ", counts)
````

Toffoli gate acts as follows for the basis states:

````@example toffoli
function test_actions(circuit)
    println("Test of Toffoli Gate")
    println("=" ^ 50)
    println("Input  |  Output")
    println("-" ^ 50)
    for a in 0:1, b in 0:1, c in 0:1
        initial = AbstractInitialState[ProductState([string(a), string(b), string(c)])]
        set_state!(circuit, initial)

        sites = siteinds("Qubit", 3)
        psi = execute_circuit(circuit, sites)

        counts = measure(psi, Sampling(1))
        output = collect(keys(counts))[1]
        @printf("|%d%d%d⟩ → |%s⟩\n", a, b, c, output)
    end
end

test_actions(circuit)
````

## Toffoli gate decomposition
Then, Lets's construct the Toffoli gate using the standard decomposition into CNOT and single-qubit gates,
and verify that it produces the same results as the built-in Toffoli gate.

````@example toffoli
function toffoli_decomposed(circuit)
    add_gate!(circuit, SingleQubitGate(3, :H))
    add_gate!(circuit, ControlledGate(2, 3, :CX))
    add_gate!(circuit, SingleQubitGate(3, :Tdag))
    add_gate!(circuit, ControlledGate(1, 3, :CX))
    add_gate!(circuit, SingleQubitGate(3, :T))
    add_gate!(circuit, ControlledGate(2, 3, :CX))
    add_gate!(circuit, SingleQubitGate(2, :Tdag))
    add_gate!(circuit, SingleQubitGate(3, :Tdag))
    add_gate!(circuit, ControlledGate(1, 3, :CX))
    add_gate!(circuit, ControlledGate(1, 2, :CX))
    add_gate!(circuit, SingleQubitGate(1, :T))
    add_gate!(circuit, SingleQubitGate(2, :Tdag))
    add_gate!(circuit, SingleQubitGate(3, :T))
    add_gate!(circuit, ControlledGate(1, 2, :CX))
    add_gate!(circuit, SingleQubitGate(2, :S))
    add_gate!(circuit, SingleQubitGate(3, :H))
    return circuit
end
circuit_decomposed = QuantumCircuit(3)
toffoli_decomposed(circuit_decomposed)

tp = to_tikz_picture(circuit_decomposed)
````

Let's test the action of the decomposed Toffoli gate on the basis states to verify that it behaves the same as the built-in Toffoli gate.

````@example toffoli
test_actions(circuit_decomposed)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

