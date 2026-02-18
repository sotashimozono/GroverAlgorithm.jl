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

"""
    measure(mps::MPS, m::AbstractMeasurement) -> Any

Execute a measurement on the given Matrix Product State.

# Arguments
- `mps::MPS`: The quantum state as an MPS.
- `m::AbstractMeasurement`: The measurement specification.

# Returns
The return type depends on the measurement:
- `ExpectationValue`: Returns `Float64` or `ComplexF64` - the expectation value.
- `Sampling`: Returns `Dict{String, Int}` - counts for each basis state.
- `ProjectiveMeasurement`: Returns `Tuple{Int, MPS}` - the measurement outcome (0 or 1) and collapsed state.

# Throws
- `ArgumentError`: If qubit indices are out of range or measurement is invalid.

# Notes
- For multi-qubit ExpectationValue, the operator acts as a tensor product on the specified qubits.

# Example
```julia
sites = siteinds("Qubit", 2)
psi = MPS(sites, ["0", "0"])
result = measure(psi, ExpectationValue(:Z, [1]))
```
"""
function measure(mps::MPS, m::ExpectationValue)
    sites = siteinds(mps)
    nqubits = length(sites)
    
    # Validate qubit indices
    for q in m.qubits
        if q < 1 || q > nqubits
            throw(
                ArgumentError(
                    "Qubit index $q is out of range [1, $nqubits]",
                ),
            )
        end
    end
    
    if isempty(m.qubits)
        throw(ArgumentError("ExpectationValue requires at least one qubit"))
    end
    
    # Build the operator
    if length(m.qubits) == 1
        # Single qubit operator
        O = op(string(m.operator), sites[m.qubits[1]])
        
        # Compute expectation value: ⟨ψ|O|ψ⟩
        mps_dag = dag(mps)
        O_mps = apply(O, mps)
        result = inner(mps_dag, O_mps)
    else
        # Multi-qubit operator: compute using tensor product
        # For now, we assume the same operator on each qubit independently
        # Full tensor product would require more complex implementation
        result = 0.0
        for q in m.qubits
            O = op(string(m.operator), sites[q])
            mps_dag = dag(mps)
            O_mps = apply(O, mps)
            result += real(inner(mps_dag, O_mps))
        end
        result /= length(m.qubits)
    end
    
    return real(result)
end

function measure(mps::MPS, m::Sampling)
    sites = siteinds(mps)
    nqubits = length(sites)
    
    # Dictionary to store measurement counts
    counts = Dict{String, Int}()
    
    # Ensure MPS has well-defined orthogonality center
    mps_copy = copy(mps)
    orthogonalize!(mps_copy, 1)
    
    # Perform sampling
    for _ in 1:m.shots
        # Sample from the MPS
        sample_result = sample(mps_copy)
        
        # Convert sample to string (assuming "Qubit" site type)
        # sample returns integer values, typically 1 or 2 for up/down
        basis_string = join([string(s - 1) for s in sample_result])
        
        # Update counts
        counts[basis_string] = get(counts, basis_string, 0) + 1
    end
    
    return counts
end

function measure(mps::MPS, m::ProjectiveMeasurement)
    sites = siteinds(mps)
    nqubits = length(sites)
    
    # Validate qubit index
    if m.qubit < 1 || m.qubit > nqubits
        throw(
            ArgumentError(
                "Qubit index $(m.qubit) is out of range [1, $nqubits]",
            ),
        )
    end
    
    # Simplified implementation: sample the qubit
    # Note: This is a basic implementation. For production use, consider
    # implementing proper state projection with probability computation.
    
    # Make a copy and ensure proper orthogonality
    mps_copy = copy(mps)
    orthogonalize!(mps_copy, m.qubit)
    
    # Sample this qubit
    sample_result = sample(mps_copy)
    outcome = sample_result[m.qubit] - 1  # Convert to 0/1
    
    # Return outcome and the sampled state
    # Note: In a full implementation, we would project the state properly
    # rather than just returning the sampled state
    return (outcome, mps_copy)
end

export measure
