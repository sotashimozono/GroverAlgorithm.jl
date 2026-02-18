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
