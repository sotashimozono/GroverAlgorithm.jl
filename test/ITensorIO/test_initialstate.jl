using ITensors, ITensorMPS

@testset "Initial State Abstractions" begin
    @testset "BasisState Construction and Conversion" begin
        state = BasisState("0")
        @test state isa AbstractInitialState
        @test state.label == "0"

        # to_itensor_state conversion
        states = to_itensor_state(state, 3)
        @test states == ["0", "0", "0"]

        # to_latex_label conversion
        label = to_latex_label(state, 1)
        @test label == "\\ket{0}"

        # Test with different basis states
        plus_state = BasisState("+")
        @test to_itensor_state(plus_state, 2) == ["+", "+"]
        @test to_latex_label(plus_state, 1) == "\\ket{+}"
    end

    @testset "NamedState Construction and Conversion" begin
        state = NamedState("0", "\\psi")
        @test state isa AbstractInitialState
        @test state.name == "0"
        @test state.latex == "\\psi"

        # to_itensor_state uses the name field
        states = to_itensor_state(state, 2)
        @test states == ["0", "0"]

        # to_latex_label uses the latex field
        label = to_latex_label(state, 1)
        @test label == "\\ket{\\psi}"
    end

    @testset "ProductState Construction and Conversion" begin
        state = ProductState(["0", "1", "+"])
        @test state isa AbstractInitialState
        @test state.labels == ["0", "1", "+"]

        # to_itensor_state returns the labels as-is
        states = to_itensor_state(state, 3)
        @test states == ["0", "1", "+"]

        # to_latex_label for each qubit
        @test to_latex_label(state, 1) == "\\ket{0}"
        @test to_latex_label(state, 2) == "\\ket{1}"
        @test to_latex_label(state, 3) == "\\ket{+}"
    end

    @testset "Error Handling for Initial States" begin
        # Invalid number of qubits
        @test_throws ArgumentError to_itensor_state(BasisState("0"), 0)
        @test_throws ArgumentError to_itensor_state(BasisState("0"), -1)

        # ProductState with wrong size
        state = ProductState(["0", "1"])
        @test_throws ArgumentError to_itensor_state(state, 3)
        @test_throws ArgumentError to_itensor_state(state, 1)

        # Invalid qubit index for labels
        @test_throws ArgumentError to_latex_label(BasisState("0"), 0)
        @test_throws ArgumentError to_latex_label(BasisState("0"), -1)

        # ProductState with out-of-range qubit index
        @test_throws ArgumentError to_latex_label(ProductState(["0", "1"]), 3)
    end
end

@testset "Updated QuantumCircuit with Initial States" begin
    @testset "Default Constructor" begin
        circuit = QuantumCircuit(3, AbstractQuantumGate[])
        @test circuit.nqubits == 3
        @test isempty(circuit.gates)
        @test length(circuit.initial_states) == 1
        @test circuit.initial_states[1] isa BasisState
        @test circuit.initial_states[1].label == "0"
    end

    @testset "Constructor with Explicit Initial States" begin
        initial = AbstractInitialState[BasisState("0")]
        circuit = QuantumCircuit(2, AbstractQuantumGate[], initial)
        @test circuit.nqubits == 2
        @test circuit.initial_states === initial

        # Per-qubit initial states
        per_qubit = AbstractInitialState[BasisState("0"), BasisState("1")]
        circuit2 = QuantumCircuit(2, AbstractQuantumGate[], per_qubit)
        @test circuit2.initial_states === per_qubit
    end

    @testset "Backward Compatibility" begin
        # Old-style construction should still work
        circuit = QuantumCircuit(2, AbstractQuantumGate[])
        add_gate!(circuit, SingleQubitGate(1, :H))
        @test length(circuit.gates) == 1
    end
end

@testset "execute_circuit with Initial States" begin
    n = 2
    sites = siteinds("Qubit", n)

    @testset "Using Default Initial States" begin
        circuit = QuantumCircuit(n, AbstractQuantumGate[])
        add_gate!(circuit, SingleQubitGate(1, :H))

        # Execute without init_state parameter
        psi = execute_circuit(circuit, sites)

        # Check it's in superposition
        prob_0 = abs(inner(psi, MPS(sites, ["0", "0"])))^2
        prob_1 = abs(inner(psi, MPS(sites, ["1", "0"])))^2
        @test prob_0 ≈ 0.5 atol=1e-10
        @test prob_1 ≈ 0.5 atol=1e-10
    end

    @testset "Using Custom Initial States" begin
        # Create circuit with custom initial state
        initial = AbstractInitialState[BasisState("1")]
        circuit = QuantumCircuit(n, AbstractQuantumGate[], initial)
        add_gate!(circuit, SingleQubitGate(1, :X))  # Flip from |1⟩ to |0⟩

        psi = execute_circuit(circuit, sites)

        # Should be in |01⟩ state (first qubit is 0, second is 1)
        prob_01 = abs(inner(psi, MPS(sites, ["0", "1"])))^2
        @test prob_01 ≈ 1.0 atol=1e-10
    end

    @testset "Backward Compatibility with init_state Parameter" begin
        circuit = QuantumCircuit(n, AbstractQuantumGate[])
        add_gate!(circuit, SingleQubitGate(1, :H))

        # Use old-style init_state parameter
        psi = execute_circuit(circuit, sites; init_state="0")

        prob_0 = abs(inner(psi, MPS(sites, ["0", "0"])))^2
        @test prob_0 ≈ 0.5 atol=1e-10

        # Test with vector init_state
        psi2 = execute_circuit(circuit, sites; init_state=["1", "0"])
        prob_10 = abs(inner(psi2, MPS(sites, ["0", "0"])))^2
        prob_11 = abs(inner(psi2, MPS(sites, ["1", "0"])))^2
        @test prob_10 ≈ 0.5 atol=1e-10
        @test prob_11 ≈ 0.5 atol=1e-10
    end

    @testset "Override with AbstractInitialState" begin
        circuit = QuantumCircuit(n, AbstractQuantumGate[])
        add_gate!(circuit, SingleQubitGate(1, :H))

        # Override with ProductState
        psi = execute_circuit(circuit, sites; init_state=ProductState(["1", "0"]))

        prob_10 = abs(inner(psi, MPS(sites, ["0", "0"])))^2
        prob_11 = abs(inner(psi, MPS(sites, ["1", "0"])))^2
        @test prob_10 ≈ 0.5 atol=1e-10
        @test prob_11 ≈ 0.5 atol=1e-10
    end
end
