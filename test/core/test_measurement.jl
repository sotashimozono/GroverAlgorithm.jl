using GroverAlgorithm, Test
using ITensors, ITensorMPS

@testset "Measurement Abstractions" begin
    @testset "ExpectationValue Construction" begin
        m = ExpectationValue(:Z, [1])
        @test m isa AbstractMeasurement
        @test m.operator == :Z
        @test m.qubits == [1]

        m2 = ExpectationValue(:X, [1, 2])
        @test m2.qubits == [1, 2]
    end

    @testset "Sampling Construction" begin
        m = Sampling(100)
        @test m isa AbstractMeasurement
        @test m.shots == 100

        # Should reject non-positive shots
        @test_throws ArgumentError Sampling(0)
        @test_throws ArgumentError Sampling(-1)
    end

    @testset "ProjectiveMeasurement Construction" begin
        m = ProjectiveMeasurement(1)
        @test m isa AbstractMeasurement
        @test m.qubit == 1

        # Should reject non-positive qubit indices
        @test_throws ArgumentError ProjectiveMeasurement(0)
        @test_throws ArgumentError ProjectiveMeasurement(-1)
    end
end

@testset "Measurement Execution" begin
    @testset "ExpectationValue Measurement" begin
        n = 2
        sites = siteinds("Qubit", n)

        # Test on |0⟩ state
        psi = MPS(sites, ["0", "0"])
        result = measure(psi, ExpectationValue(:Z, [1]))
        # ⟨0|Z|0⟩ = +1 for "Qubit" site type
        @test result ≈ 1.0 atol=1e-10

        # Test on |1⟩ state
        psi1 = MPS(sites, ["1", "0"])
        result1 = measure(psi1, ExpectationValue(:Z, [1]))
        # ⟨1|Z|1⟩ = -1 for "Qubit" site type
        @test result1 ≈ -1.0 atol=1e-10

        # Test on superposition |+⟩ = (|0⟩ + |1⟩)/√2
        circuit = QuantumCircuit(n, AbstractQuantumGate[])
        add_gate!(circuit, SingleQubitGate(1, :H))
        psi_plus = execute_circuit(circuit, sites; init_state="0")
        result_plus = measure(psi_plus, ExpectationValue(:X, [1]))
        # ⟨+|X|+⟩ = +1
        @test result_plus ≈ 1.0 atol=1e-10
    end

    @testset "ExpectationValue Error Handling" begin
        n = 2
        sites = siteinds("Qubit", n)
        psi = MPS(sites, ["0", "0"])

        # Out of range qubit
        @test_throws ArgumentError measure(psi, ExpectationValue(:Z, [3]))
        @test_throws ArgumentError measure(psi, ExpectationValue(:Z, [0]))

        # Empty qubits
        @test_throws ArgumentError measure(psi, ExpectationValue(:Z, Int[]))
    end

    @testset "Sampling Measurement" begin
        n = 2
        sites = siteinds("Qubit", n)

        # Test on definite state |00⟩
        psi = MPS(sites, ["0", "0"])
        counts = measure(psi, Sampling(100))

        @test counts isa Dict{String,Int}
        @test sum(values(counts)) == 100
        # Should only measure "00" for |00⟩ state
        @test haskey(counts, "00")
        @test counts["00"] == 100

        # Test on Bell state (|00⟩ + |11⟩)/√2
        circuit = QuantumCircuit(n, AbstractQuantumGate[])
        add_gate!(circuit, SingleQubitGate(1, :H))
        add_gate!(circuit, ControlledGate(1, 2, :CNOT))
        psi_bell = execute_circuit(circuit, sites; init_state="0")

        counts_bell = measure(psi_bell, Sampling(1000))
        # Should measure roughly 50% "00" and 50% "11"
        @test haskey(counts_bell, "00") || haskey(counts_bell, "11")
        if haskey(counts_bell, "00")
            # Allow for statistical variation
            @test 400 <= counts_bell["00"] <= 600
        end
    end

    @testset "ProjectiveMeasurement" begin
        n = 2
        sites = siteinds("Qubit", n)

        # Test on |0⟩ state
        psi = MPS(sites, ["0", "0"])
        outcome, collapsed = measure(psi, ProjectiveMeasurement(1))

        @test outcome isa Int
        @test outcome == 0 || outcome == 1
        @test collapsed isa MPS

        # Test on |1⟩ state
        psi1 = MPS(sites, ["1", "0"])
        outcome1, _ = measure(psi1, ProjectiveMeasurement(1))
        @test outcome1 == 1
    end

    @testset "ProjectiveMeasurement Error Handling" begin
        n = 2
        sites = siteinds("Qubit", n)
        psi = MPS(sites, ["0", "0"])

        # Out of range qubit
        @test_throws ArgumentError measure(psi, ProjectiveMeasurement(3))
        @test_throws ArgumentError measure(psi, ProjectiveMeasurement(0))
    end
end
