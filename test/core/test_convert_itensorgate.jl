using ITensors, ITensorMPS

@testset "Comprehensive ITensors Operator Mapping" begin
    N = 4
    sites = siteinds("Qubit", N)

    @testset "Single-Qubit & Aliases" begin
        gates = [
            (:X, "X"), (:σx, "σx"), (:Y, "Y"), (:Z, "Z"), 
            (:H, "H"), (:T, "π/8"), (:S, "Phase"),
            (:Proj0, "Proj0"), (:Proj1, "Proj1")
        ]
        for (sym, str) in gates
            @test to_itensor_op(SingleQubitGate(1, sym), sites) ≈ op(str, sites[1])
        end
        
        # Parametric
        @test to_itensor_op(ParametricSingleGate(1, :Rx, [0.1]), sites) ≈ op("Rx", sites[1]; θ=0.1)
        @test to_itensor_op(ParametricSingleGate(1, :Rn, [0.1, 0.2, 0.3]), sites) ≈ op("Rn", sites[1]; θ=0.1, ϕ=0.2, λ=0.3)
    end

    @testset "Spin Operators" begin
        spin_ops = [:Sz, :S⁺, :S⁻, :Sx, :Sy, :S2]
        for sym in spin_ops
            @test to_itensor_op(SingleQubitGate(2, sym), sites) ≈ op(string(sym), sites[2])
        end
    end

    @testset "Two-Qubit Gates" begin
        # Standard
        @test to_itensor_op(ControlledGate(1, 2, :CNOT), sites) ≈ op("CNOT", sites[1], sites[2])
        @test to_itensor_op(ControlledGate(1, 2, :CZ), sites) ≈ op("CZ", sites[1], sites[2])
        @test to_itensor_op(TwoQubitGate(1, 2, :SWAP), sites) ≈ op("SWAP", sites[1], sites[2])
        @test to_itensor_op(TwoQubitGate(1, 2, :iSWAP), sites) ≈ op("iSWAP", sites[1], sites[2])
        
        # Parametric Controlled
        @test to_itensor_op(ParametricControlledGate(1, 2, :CRx, [0.5]), sites) ≈ op("CRx", sites[1], sites[2]; θ=0.5)
        
        # Ising Coupling
        @test to_itensor_op(ParametricTwoQubitGate(1, 2, :Rxx, [0.4]), sites) ≈ op("Rxx", sites[1], sites[2]; ϕ=0.4)
    end

    @testset "Multi-Qubit Gates" begin
        @test to_itensor_op(ThreeQubitGate(1, 2, 3, :Toffoli), sites) ≈ op("Toffoli", sites[1], sites[2], sites[3])
        @test to_itensor_op(ThreeQubitGate(1, 2, 3, :Fredkin), sites) ≈ op("Fredkin", sites[1], sites[2], sites[3])
        @test to_itensor_op(FourQubitGate(1, 2, 3, 4, :CCCNOT), sites) ≈ op("CCCNOT", sites[1], sites[2], sites[3], sites[4])
    end
end

@testset "Circuit Execution Tests" begin
    n = 2
    sites = siteinds("Qubit", n)

    @testset "Superposition Test (H gate)" begin
        # 1ビット目に H ゲートを適用
        circ = QuantumCircuit(n, AbstractQuantumGate[])
        add_gate!(circ, SingleQubitGate(1, :H))
        psi = execute_circuit(circ, sites)
        
        # 最終状態 |ψ⟩ = 1/√2 (|0⟩ + |1⟩) ⊗ |0⟩ 
        # sites[1] の確率振幅を確認
        # |<0|ψ>|^2 = 0.5, |<1|ψ>|^2 = 0.5
        up_prob = abs(inner(psi, MPS(sites, ["0", "0"])))^2
        dn_prob = abs(inner(psi, MPS(sites, ["1", "0"])))^2
        
        @test up_prob ≈ 0.5 atol=1e-10
        @test dn_prob ≈ 0.5 atol=1e-10
    end

    @testset "Entanglement Test (Bell State)" begin
        # |00⟩ -> (CNOT) (H ⊗ I) |00⟩ -> 1/√2 (|00⟩ + |11⟩)
        circ = QuantumCircuit(2, AbstractQuantumGate[])
        add_gate!(circ, SingleQubitGate(1, :H))
        add_gate!(circ, ControlledGate(1, 2, :CNOT))
        psi = execute_circuit(circ, sites)

        # |00⟩ と |11⟩ の確率がそれぞれ 0.5 であることを確認
        prob_00 = abs(inner(psi, MPS(sites, ["0", "0"])))^2
        prob_11 = abs(inner(psi, MPS(sites, ["1", "1"])))^2
        prob_01 = abs(inner(psi, MPS(sites, ["0", "1"])))^2
        @test prob_00 ≈ 0.5 atol=1e-10
        @test prob_11 ≈ 0.5 atol=1e-10
        @test prob_01 ≈ 0.0 atol=1e-10
    end

    @testset "Error Handling" begin
        circ = QuantumCircuit(3, AbstractQuantumGate[])
        @test_throws ArgumentError execute_circuit(circ, siteinds("Qubit", 2))
    end
end