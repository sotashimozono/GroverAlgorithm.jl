"""
    AbstractInitialState

Abstract type for quantum initial states in a quantum circuit.
Provides common interfaces for both ITensors MPS initialization and quantikz visualization.
"""
abstract type AbstractInitialState end
export AbstractInitialState

"""
    BasisState(label::String)

Represents a computational basis state for quantum circuit initialization.

# Fields
- `label::String`: The state label conforming to ITensors' op-defined state names.
  Common values include "0", "1", "+", "-", "Up", "Dn", etc.

# Example
```julia
BasisState("0")  # |0⟩ state
BasisState("+")  # |+⟩ state (equal superposition)
```
"""
struct BasisState <: AbstractInitialState
    label::String
end
export BasisState

"""
    NamedState(name::String, latex::String)

Represents a quantum state with arbitrary name and LaTeX label for visualization.

# Fields
- `name::String`: The state name for ITensors initialization (must be a valid ITensors state).
- `latex::String`: The LaTeX representation for quantikz visualization.

# Example
```julia
NamedState("0", "\\psi_0")  # Initialized as |0⟩ but displayed as |ψ₀⟩
```
"""
struct NamedState <: AbstractInitialState
    name::String
    latex::String
end
export NamedState

"""
    ProductState(labels::Vector{String})

Represents a product state where each qubit is individually specified.

# Fields
- `labels::Vector{String}`: Vector of state labels, one for each qubit.
  Each label should conform to ITensors' op-defined state names.

# Usage
ProductState is typically used as a single element in the `initial_states` vector
to specify all qubits at once. To specify different states per qubit individually,
use a vector of `BasisState` or `NamedState` instances instead.

# Examples
```julia
# Use ProductState as a single element for all qubits:
initial = AbstractInitialState[ProductState(["0", "1", "+"])]
circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)

# To specify per-qubit states individually, use BasisState:
initial = AbstractInitialState[BasisState("0"), BasisState("1"), BasisState("+")]
circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)
```
"""
struct ProductState <: AbstractInitialState
    labels::Vector{String}
end
export ProductState

"""
    to_itensor_state(state::AbstractInitialState, nqubits::Int) -> Vector{String}

Convert an initial state specification to a vector of state strings for ITensors MPS initialization.

# Arguments
- `state::AbstractInitialState`: The initial state specification.
- `nqubits::Int`: The total number of qubits in the circuit.

# Returns
- `Vector{String}`: A vector of state strings suitable for `MPS(sites, states)`.

# Throws
- `ArgumentError`: If the state specification is incompatible with the number of qubits.

# Example
```julia
to_itensor_state(BasisState("0"), 3)  # ["0", "0", "0"]
to_itensor_state(ProductState(["0", "1"]), 2)  # ["0", "1"]
```
"""
function to_itensor_state(state::BasisState, nqubits::Int)::Vector{String}
    if nqubits <= 0
        throw(ArgumentError("Number of qubits must be positive, got $nqubits"))
    end
    return fill(state.label, nqubits)
end

function to_itensor_state(state::NamedState, nqubits::Int)::Vector{String}
    if nqubits <= 0
        throw(ArgumentError("Number of qubits must be positive, got $nqubits"))
    end
    return fill(state.name, nqubits)
end

function to_itensor_state(state::ProductState, nqubits::Int)::Vector{String}
    if nqubits <= 0
        throw(ArgumentError("Number of qubits must be positive, got $nqubits"))
    end
    if length(state.labels) != nqubits
        throw(
            ArgumentError(
                "ProductState has $(length(state.labels)) labels but circuit has $nqubits qubits",
            ),
        )
    end
    return state.labels
end

export to_itensor_state

"""
    to_latex_label(state::AbstractInitialState, qubit_idx::Int) -> String

Generate a LaTeX label for the specified qubit in quantikz visualization.

# Arguments
- `state::AbstractInitialState`: The initial state specification.
- `qubit_idx::Int`: The index of the qubit (1-based).

# Returns
- `String`: A LaTeX string for use in `\\lstick{}`.

# Example
```julia
to_latex_label(BasisState("0"), 1)  # "\\ket{0}"
to_latex_label(NamedState("0", "\\psi"), 1)  # "\\ket{\\psi}"
```
"""
function to_latex_label(state::BasisState, qubit_idx::Int)::String
    if qubit_idx <= 0
        throw(ArgumentError("Qubit index must be positive, got $qubit_idx"))
    end
    return "\\ket{$(state.label)}"
end

function to_latex_label(state::NamedState, qubit_idx::Int)::String
    if qubit_idx <= 0
        throw(ArgumentError("Qubit index must be positive, got $qubit_idx"))
    end
    return "\\ket{$(state.latex)}"
end

function to_latex_label(state::ProductState, qubit_idx::Int)::String
    if qubit_idx <= 0
        throw(ArgumentError("Qubit index must be positive, got $qubit_idx"))
    end
    if qubit_idx > length(state.labels)
        throw(
            ArgumentError(
                "Qubit index $qubit_idx exceeds ProductState size $(length(state.labels))"
            ),
        )
    end
    return "\\ket{$(state.labels[qubit_idx])}"
end

export to_latex_label
