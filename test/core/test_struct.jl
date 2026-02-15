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

end