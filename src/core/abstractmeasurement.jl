"""
    AbstractMeasurement

Abstract type for quantum measurements performed on MPS after circuit execution.
Encapsulates different measurement strategies for quantum states.
"""
abstract type AbstractMeasurement end
export AbstractMeasurement

"""
    ExpectationValue(operator::Symbol, qubits::Vector{Int})

Represents an expectation value measurement of a physical operator.

Computes ⟨ψ|Ô|ψ⟩ where Ô is the specified operator acting on the given qubits.

# Fields
- `operator::Symbol`: The operator symbol (e.g., `:X`, `:Y`, `:Z`, `:H`, `:Sz`).
- `qubits::Vector{Int}`: The qubit indices where the operator acts (1-based).

# Example
```julia
ExpectationValue(:Z, [1])  # Measure ⟨Z⟩ on qubit 1
ExpectationValue(:X, [1, 2])  # Measure ⟨X₁X₂⟩ on qubits 1 and 2
```
"""
struct ExpectationValue <: AbstractMeasurement
    operator::Symbol
    qubits::Vector{Int}
end
export ExpectationValue

"""
    Sampling(shots::Int)

Represents a sampling measurement in the computational basis.

Performs repeated measurements to obtain a probability distribution over basis states.

# Fields
- `shots::Int`: The number of measurement samples to collect.

# Example
```julia
Sampling(1000)  # Perform 1000 measurements
```
"""
struct Sampling <: AbstractMeasurement
    shots::Int

    function Sampling(shots::Int)
        if shots <= 0
            throw(ArgumentError("Number of shots must be positive, got $shots"))
        end
        new(shots)
    end
end
export Sampling

"""
    ProjectiveMeasurement(qubit::Int)

Represents a projective measurement on a specific qubit.

Measures a single qubit in the computational basis and collapses the state.

# Fields
- `qubit::Int`: The qubit index to measure (1-based).

# Example
```julia
ProjectiveMeasurement(1)  # Measure qubit 1
```
"""
struct ProjectiveMeasurement <: AbstractMeasurement
    qubit::Int

    function ProjectiveMeasurement(qubit::Int)
        if qubit <= 0
            throw(ArgumentError("Qubit index must be positive, got $qubit"))
        end
        new(qubit)
    end
end
export ProjectiveMeasurement
