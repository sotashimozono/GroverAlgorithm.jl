@testset "Quantum Gate Types and Constructors" begin
    @testset "Type Hierarchy" begin
        # All gate types should be subtypes of AbstractQuantumGate
        @test SingleQubitGate(1, :X) isa AbstractQuantumGate
        @test ParametricSingleGate(1, :Rx, [0.5π]) isa AbstractQuantumGate
        @test ControlledGate(1, 2, :CNOT) isa AbstractQuantumGate
        @test ThreeQubitGate(1, 2, 3, :Toffoli) isa AbstractQuantumGate
    end

    @testset "Field Integrity" begin
        # field values should be correctly assigned
        g = SingleQubitGate(3, :H)
        @test g.qubit == 3
        @test g.gate_type == Symbol("H")

        # parameter vectors should be correctly stored
        params = [1.0, 2.0, 3.0]
        pg = ParametricSingleGate(1, :Rn, params)
        @test pg.params == params
        @test length(pg.params) == 3
    end

    @testset "Multi-Qubit Gates" begin
        # contrrol and target qubits should be correctly assigned
        cg = ControlledGate(1, 5, :CZ)
        @test cg.control == 1
        @test cg.target == 5
        
        # three-qubit gate fields should be correctly assigned
        tg = ThreeQubitGate(1, 2, 3, :Toffoli)
        @test tg.qubit1 == 1
        @test tg.qubit2 == 2
        @test tg.qubit3 == 3
        fg = FourQubitGate(1, 2, 3, 4, :CCCNOT)
        @test fg.qubit4 == 4
    end
    n = 5
    circuit = QuantumCircuit(n, AbstractQuantumGate[])
    @test circuit.nqubits == 5
    @test isempty(circuit.gates)

    # 2. Functional Test: add_gate!
    @testset "Adding Gates" begin
        # Add a single qubit gate
        g1 = SingleQubitGate(1, :X)
        add_gate!(circuit, g1)
        @test length(circuit.gates) == 1
        @test circuit.gates[end] === g1

        # Add a controlled gate
        g2 = ControlledGate(1, 2, :CNOT)
        add_gate!(circuit, g2)
        @test length(circuit.gates) == 2
        @test circuit.gates[2].gate_type == :CNOT

        # Check method chaining
        g3 = SingleQubitGate(3, :H)
        returned_circuit = add_gate!(circuit, g3)
        @test returned_circuit === circuit
        @test length(circuit.gates) == 3
    end

    # 3. Structural Integrity
    @testset "Type Constraints" begin
        # Ensure it only accepts subtypes of AbstractQuantumGate
        @test circuit.gates isa Vector{AbstractQuantumGate}
    end
end
#=
@testset "Invalid Inputs" begin
    # 制御ビットとターゲットビットが同じ場合はエラーにしたい（将来的な実装への布石）
    # 現状の実装でエラーを投げないなら、将来の自分へのメモとして書く
    @test_throws ArgumentError ControlledGate(1, 1, :CNOT)
    
    # 負のビット番号や 0 を禁止する
    @test_throws ArgumentError SingleQubitGate(0, :X)
    @test_throws ArgumentError SingleQubitGate(-1, :Z)
end
# ゲートに関連する量子ビットを配列で返す共通関数を想定
occupied_qubits(g::SingleQubitGate) = [g.qubit]
occupied_qubits(g::TwoQubitGate) = [g.qubit1, g.qubit2]
occupied_qubits(g::ControlledGate) = [g.control, g.target]

@testset "Common Interface" begin
    @test sort(occupied_qubits(ThreeQubitGate(3, 1, 2, :Toffoli))) == [1, 2, 3]
    @test length(occupied_qubits(FourQubitGate(1, 2, 3, 4, :CCCNOT))) == 4
end
=#