```@meta
EditURL = "toffoli.jl"
```

````@example toffoli
using Printf
using GroverAlgorithm
using ITensors, ITensorMPS
````

Here we define the Toffoli gate (CCNOT) using the GroverAlgorithm package
This is an example of how to use the package.
Toffoli gate is available in ITensorMPS.jl as a built-in gate.
Let's create a Toffoli gate and check its action on the basis states.

````@example toffoli
circuit = QuantumCircuit(3)
add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))

sites = siteinds("Qubit", 3)
psi = execute_circuit(circuit, sites)
counts = measure(psi, Sampling(100))
println("結果: ", counts)

println("Test of Toffoli Gate")
println("=" ^ 50)
println("Input  |  Output")
println("-" ^ 50)

circuit = QuantumCircuit(3)
add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))
for a in 0:1, b in 0:1, c in 0:1
    initial = AbstractInitialState[ProductState([string(a), string(b), string(c)])]
    set_state!(circuit, initial)

    sites = siteinds("Qubit", 3)
    psi = execute_circuit(circuit, sites)

    counts = measure(psi, Sampling(1))
    output = collect(keys(counts))[1]
    @printf("|%d%d%d⟩ → |%s⟩\n", a, b, c, output)
end
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

