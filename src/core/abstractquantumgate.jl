"""
    AbstractQuantumGate
Abstract type for quantum gates in the quantum circuit representation.
Provides common interfaces between `ITensors` calcurations and `quantikz` representations.
[Available gates in ITensor Library](https://docs.itensor.org/ITensorMPS/stable/IncludedSiteTypes.html)
"""
abstract type AbstractQuantumGate end
export AbstractQuantumGate
# ============================================
# 1量子ビットゲート
# ============================================
"""
    SingleQubitGate(qubit::Int, gate_type::Symbol)

Quantum gate acting on a single qubit without parameters.
`gate_type` specifies the type of gate. Available types include:
- `:X`, `:Y`, `:Z`: Pauli operators
- `:H`: Hadamard gate
- `:S`, `:T`: Phase shift gates (aliases: `:Phase`, `:π/8`)
- `:Proj0`, `:Proj1`: Projection operators (\$|0\\rangle\\langle0|\$ and \$|1\\rangle\\langle1|\$)
"""
struct SingleQubitGate <: AbstractQuantumGate
    qubit::Int
    gate_type::Symbol
end
export SingleQubitGate
"""
    ParametricSingleGate(qubit::Int, gate_type::Symbol, params::Vector{Float64})

Quantum gate acting on a single qubit with one or more parameters.
`params` is a vector of parameters such as rotation angles (e.g., \$\\theta, \\phi, \\lambda\$).
Available `gate_type` include:
- `:Rx`, `:Ry`, `:Rz`: Rotation gates around the x, y, and z axes (argument: `[θ]`)
- `:Rn`: Rotation about an arbitrary axis \$n=(\\theta, \\phi, \\lambda)\$ (arguments: `[θ, ϕ, λ]`)
"""
struct ParametricSingleGate <: AbstractQuantumGate
    qubit::Int
    gate_type::Symbol
    params::Vector{Float64}  # θ, ϕ, λなどのパラメータ
end
export ParametricSingleGate
# ============================================
# 2量子ビットゲート
# ============================================

"""
    ControlledGate(control::Int, target::Int, gate_type::Symbol)

Two-qubit controlled gate without parameters.
`gate_type` specifies the operation applied to the target qubit. Available types include:
- `:CNOT`: Controlled-NOT gate (alias: `:CX`)
- `:CY`, `:CZ`: Controlled-Y and Controlled-Z gates
- `:CPHASE`: Controlled-Phase gate
"""
struct ControlledGate <: AbstractQuantumGate
    control::Int
    target::Int
    gate_type::Symbol
end
export ControlledGate

"""
    ParametricControlledGate(control::Int, target::Int, gate_type::Symbol, params::Vector{Float64})

Two-qubit controlled gate with parameters.
Available `gate_type` include:
- `:CRx`, `:CRy`, `:CRz`: Controlled rotation gates (argument: `[θ]`)
- `:CRn`: Controlled rotation about an arbitrary axis (arguments: `[θ, ϕ, λ]`)
"""
struct ParametricControlledGate <: AbstractQuantumGate
    control::Int
    target::Int
    gate_type::Symbol
    params::Vector{Float64}
end
export ParametricControlledGate

"""
    TwoQubitGate(qubit1::Int, qubit2::Int, gate_type::Symbol)

Two-qubit gate without a specific control/target structure.
Available `gate_type` include:
- `:SWAP`: Swap gate
- `:iSWAP`: Imaginary Swap gate
- `:√SWAP`: Square root of Swap gate
"""
struct TwoQubitGate <: AbstractQuantumGate
    qubit1::Int
    qubit2::Int
    gate_type::Symbol  # SWAP, iSWAP, etc.
end
export TwoQubitGate

"""
    ParametricTwoQubitGate(qubit1::Int, qubit2::Int, gate_type::Symbol, params::Vector{Float64})

Two-qubit gate with parameters, typically used for coupling operations.
Available `gate_type` include:
- `:Rxx`, `:Ryy`, `:Rzz`: Ising (XX, YY, ZZ) coupling gates (argument: `[ϕ]`)
"""
struct ParametricTwoQubitGate <: AbstractQuantumGate
    qubit1::Int
    qubit2::Int
    gate_type::Symbol  # Rxx, Ryy, Rzz
    params::Vector{Float64}
end
export ParametricTwoQubitGate

# ============================================
# 3量子ビットゲート
# ============================================

"""
    ThreeQubitGate(qubit1::Int, qubit2::Int, qubit3::Int, gate_type::Symbol)

Three-qubit gate acting on the specified qubits.
Available `gate_type` include:
- `:Toffoli`: Controlled-Controlled-NOT gate (aliases: `:CCNOT`, `:CCX`)
- `:Fredkin`: Controlled-SWAP gate (alias: `:CSWAP`)
"""
struct ThreeQubitGate <: AbstractQuantumGate
    qubit1::Int
    qubit2::Int
    qubit3::Int
    gate_type::Symbol  # Toffoli, Fredkin
end
export ThreeQubitGate

# ============================================
# 4量子ビットゲート
# ============================================

"""
    FourQubitGate(qubit1::Int, qubit2::Int, qubit3::Int, qubit4::Int, gate_type::Symbol)

Four-qubit gate acting on the specified qubits.
Available `gate_type` include:
- `:CCCNOT`: Triple-controlled NOT gate
"""
struct FourQubitGate <: AbstractQuantumGate
    qubit1::Int
    qubit2::Int
    qubit3::Int
    qubit4::Int
    gate_type::Symbol  # CCCNOT
end
export FourQubitGate

# ============================================
# N-Qubit Gates (General Multi-Qubit Gates)
# ============================================

"""
    MultiQubitGate(qubits::Vector{Int}, gate_type::Symbol)

General n-qubit gate acting on an arbitrary number of qubits.
This allows for gates acting on more than 4 qubits or custom multi-qubit operations.

# Fields
- `qubits::Vector{Int}`: Vector of qubit indices (1-based) that the gate acts on.
- `gate_type::Symbol`: The type of gate to apply.

# Examples
```julia
# 5-qubit controlled gate
gate = MultiQubitGate([1, 2, 3, 4, 5], :C4NOT)

# Custom multi-qubit gate
gate = MultiQubitGate([1, 3, 5, 7], :CustomGate)
```

# Notes
- The interpretation of `gate_type` depends on the number of qubits and the specific gate.
- For standard gates with 1-4 qubits, prefer using the specific gate types for clarity.
- This is useful for gates with 5 or more qubits, or for custom multi-qubit operations.
"""
struct MultiQubitGate <: AbstractQuantumGate
    qubits::Vector{Int}
    gate_type::Symbol

    function MultiQubitGate(qubits::Vector{Int}, gate_type::Symbol)
        if isempty(qubits)
            throw(ArgumentError("MultiQubitGate requires at least one qubit"))
        end
        if length(unique(qubits)) != length(qubits)
            throw(
                ArgumentError(
                    "Qubit indices must be unique, got duplicate qubits in $qubits"
                ),
            )
        end
        if any(q -> q <= 0, qubits)
            throw(ArgumentError("All qubit indices must be positive, got $qubits"))
        end
        new(qubits, gate_type)
    end
end
export MultiQubitGate

"""
    ParametricMultiQubitGate(qubits::Vector{Int}, gate_type::Symbol, params::Vector{Float64})

General n-qubit parametric gate acting on an arbitrary number of qubits with parameters.

# Fields
- `qubits::Vector{Int}`: Vector of qubit indices (1-based) that the gate acts on.
- `gate_type::Symbol`: The type of gate to apply.
- `params::Vector{Float64}`: Parameters for the gate (e.g., rotation angles).

# Examples
```julia
# Multi-qubit rotation gate
gate = ParametricMultiQubitGate([1, 2, 3], :MultiRz, [π/4])

# Custom parametric gate
gate = ParametricMultiQubitGate([1, 3, 5], :CustomRotation, [π/2, π/4, π/8])
```
"""
struct ParametricMultiQubitGate <: AbstractQuantumGate
    qubits::Vector{Int}
    gate_type::Symbol
    params::Vector{Float64}

    function ParametricMultiQubitGate(
        qubits::Vector{Int}, gate_type::Symbol, params::Vector{Float64}
    )
        if isempty(qubits)
            throw(ArgumentError("ParametricMultiQubitGate requires at least one qubit"))
        end
        if length(unique(qubits)) != length(qubits)
            throw(
                ArgumentError(
                    "Qubit indices must be unique, got duplicate qubits in $qubits"
                ),
            )
        end
        if any(q -> q <= 0, qubits)
            throw(ArgumentError("All qubit indices must be positive, got $qubits"))
        end
        new(qubits, gate_type, params)
    end
end
export ParametricMultiQubitGate

# ============================================
# QuantumCircuitStructure
# ============================================
"""
    QuantumCircuit

Represents a quantum circuit consisting of a fixed number of qubits and a sequence of gates.

Fields
- `nqubits::Int`: The total number of qubits in the circuit.
- `gates::Vector{AbstractQuantumGate}`: A list of quantum gates to be applied sequentially.
- `initial_states::Vector{AbstractInitialState}`: Initial state specification for each qubit.
  Defaults to `[BasisState("0")]` for all qubits if not specified.

# Initial States Usage
The `initial_states` field can be specified in two ways:
1. **Single state for all qubits**: Use a vector with one element
   ```julia
   initial = AbstractInitialState[BasisState("0")]  # All qubits in |0⟩
   initial = AbstractInitialState[ProductState(["0", "1", "+"])]  # Qubits in |0⟩, |1⟩, |+⟩
   ```
2. **Per-qubit states**: Use a vector with one element per qubit
   ```julia
   initial = AbstractInitialState[BasisState("0"), BasisState("1")]  # First qubit |0⟩, second |1⟩
   ```

Note: ProductState should be used as a single element, not within a multi-element vector.
"""
struct QuantumCircuit
    nqubits::Int
    gates::Vector{AbstractQuantumGate}
    initial_states::Vector{AbstractInitialState}

    # Constructor with default initial states
    function QuantumCircuit(nqubits::Int, gates::Vector{AbstractQuantumGate})
        initial_states = [BasisState("0")]
        new(nqubits, gates, initial_states)
    end

    # Constructor with explicit initial states
    function QuantumCircuit(
        nqubits::Int,
        gates::Vector{AbstractQuantumGate},
        initial_states::Vector{AbstractInitialState},
    )
        new(nqubits, gates, initial_states)
    end
end
export QuantumCircuit

"""
    add_gate!(circuit::QuantumCircuit, gate::AbstractQuantumGate)

Appends a quantum gate to the end of the circuit's gate sequence.
Returns the modified `QuantumCircuit` object to allow for method chaining.
"""
function add_gate!(circuit::QuantumCircuit, gate::AbstractQuantumGate)
    push!(circuit.gates, gate)
    return circuit
end
export add_gate!
