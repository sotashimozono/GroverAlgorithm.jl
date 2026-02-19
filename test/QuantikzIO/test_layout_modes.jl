using LaTeXStrings, TikzPictures

@testset "Layout Modes" begin
    @testset "Helper Functions - get_involved_qubits" begin
        # SingleQubitGate
        gate = SingleQubitGate(2, :H)
        @test get_involved_qubits(gate) == (2, 2)

        # ParametricSingleGate
        gate = ParametricSingleGate(3, :Rx, [π])
        @test get_involved_qubits(gate) == (3, 3)

        # ControlledGate (control < target)
        gate = ControlledGate(1, 3, :CNOT)
        @test get_involved_qubits(gate) == (1, 3)

        # ControlledGate (control > target)
        gate = ControlledGate(3, 1, :CNOT)
        @test get_involved_qubits(gate) == (1, 3)

        # ParametricControlledGate
        gate = ParametricControlledGate(2, 4, :CRz, [π/2])
        @test get_involved_qubits(gate) == (2, 4)

        # TwoQubitGate
        gate = TwoQubitGate(1, 3, :SWAP)
        @test get_involved_qubits(gate) == (1, 3)

        # ParametricTwoQubitGate
        gate = ParametricTwoQubitGate(2, 4, :Rxx, [π/4])
        @test get_involved_qubits(gate) == (2, 4)

        # ThreeQubitGate
        gate = ThreeQubitGate(1, 3, 2, :Toffoli)
        @test get_involved_qubits(gate) == (1, 3)

        # FourQubitGate
        gate = FourQubitGate(1, 4, 2, 3, :CCCNOT)
        @test get_involved_qubits(gate) == (1, 4)
    end

    @testset "Helper Functions - get_latex_commands" begin
        n = 3

        # SingleQubitGate
        gate = SingleQubitGate(2, :H)
        commands = get_latex_commands(gate, n)
        @test length(commands) == n
        @test commands[1] == "\\qw"
        @test commands[2] == "\\gate{H}"
        @test commands[3] == "\\qw"

        # ControlledGate
        gate = ControlledGate(1, 3, :CNOT)
        commands = get_latex_commands(gate, n)
        @test commands[1] == "\\ctrl{2}"
        @test commands[2] == "\\qw"
        @test commands[3] == "\\targ{}"

        # TwoQubitGate (SWAP)
        gate = TwoQubitGate(1, 3, :SWAP)
        commands = get_latex_commands(gate, n)
        @test commands[1] == "\\swap{2}"
        @test commands[2] == "\\qw"
        @test commands[3] == "\\targX{}"
    end

    @testset "Serial Layout Mode" begin
        circ = QuantumCircuit(3, AbstractQuantumGate[])
        add_gate!(circ, SingleQubitGate(1, :H))
        add_gate!(circ, SingleQubitGate(2, :H))
        add_gate!(circ, ControlledGate(1, 3, :CNOT))

        # Serial layout should produce 3 columns (one per gate)
        latex = to_quantikz(circ; layout=:serial)
        @test occursin("\\begin{quantikz}", latex)
        @test occursin("\\gate{H}", latex)
        @test occursin("\\ctrl{2}", latex)
        @test occursin("\\targ{}", latex)

        # Also test with :horizontal alias
        latex2 = to_quantikz(circ; layout=:horizontal)
        @test latex == latex2

        # Test to_tikz_picture as well
        tp = to_tikz_picture(circ; layout=:serial)
        @test tp isa TikzPicture
    end

    @testset "Packed Layout Mode" begin
        circ = QuantumCircuit(3, AbstractQuantumGate[])
        # H on qubit 1 and H on qubit 2 don't interfere, should be in same column
        add_gate!(circ, SingleQubitGate(1, :H))
        add_gate!(circ, SingleQubitGate(2, :H))
        # CNOT(1,3) interferes with both previous gates
        add_gate!(circ, ControlledGate(1, 3, :CNOT))

        latex = to_quantikz(circ; layout=:packed)
        @test occursin("\\begin{quantikz}", latex)
        @test occursin("\\gate{H}", latex)
        @test occursin("\\ctrl{2}", latex)
        @test occursin("\\targ{}", latex)

        # Test aliases
        latex2 = to_quantikz(circ; layout=:parallel)
        @test latex == latex2

        latex3 = to_quantikz(circ; layout=:vertical)
        @test latex == latex3

        # Test to_tikz_picture
        tp = to_tikz_picture(circ; layout=:packed)
        @test tp isa TikzPicture
    end

    @testset "Packed Layout - Non-interfering gates" begin
        circ = QuantumCircuit(4, AbstractQuantumGate[])
        # Gates on qubits 1 and 3 don't interfere
        add_gate!(circ, SingleQubitGate(1, :H))
        add_gate!(circ, SingleQubitGate(3, :X))
        # Gates on qubits 2 and 4 don't interfere with each other or previous
        add_gate!(circ, SingleQubitGate(2, :Y))
        add_gate!(circ, SingleQubitGate(4, :Z))

        # All four gates should be packable into fewer columns than serial
        latex_serial = to_quantikz(circ; layout=:serial)
        latex_packed = to_quantikz(circ; layout=:packed)

        # Both should contain all gates
        @test occursin("\\gate{H}", latex_serial)
        @test occursin("\\gate{X}", latex_serial)
        @test occursin("\\gate{Y}", latex_serial)
        @test occursin("\\gate{Z}", latex_serial)

        @test occursin("\\gate{H}", latex_packed)
        @test occursin("\\gate{X}", latex_packed)
        @test occursin("\\gate{Y}", latex_packed)
        @test occursin("\\gate{Z}", latex_packed)
    end

    @testset "Packed Layout - CNOT spanning multiple qubits" begin
        circ = QuantumCircuit(4, AbstractQuantumGate[])
        # CNOT from qubit 1 to qubit 3 spans qubit 2
        add_gate!(circ, ControlledGate(1, 3, :CNOT))
        # This gate on qubit 4 doesn't interfere
        add_gate!(circ, SingleQubitGate(4, :H))
        # This gate on qubit 2 DOES interfere (qubit 2 is spanned by CNOT)
        add_gate!(circ, SingleQubitGate(2, :X))

        latex = to_quantikz(circ; layout=:packed)
        @test occursin("\\ctrl{2}", latex)
        @test occursin("\\targ{}", latex)
        @test occursin("\\gate{H}", latex)
        @test occursin("\\gate{X}", latex)
    end

    @testset "Default layout is :packed" begin
        circ = QuantumCircuit(2, AbstractQuantumGate[])
        add_gate!(circ, SingleQubitGate(1, :H))
        add_gate!(circ, SingleQubitGate(2, :H))

        # Default should be :packed
        latex_default = to_quantikz(circ)
        latex_packed = to_quantikz(circ; layout=:packed)
        @test latex_default == latex_packed

        tp_default = to_tikz_picture(circ)
        tp_packed = to_tikz_picture(circ; layout=:packed)
        @test tp_default.data == tp_packed.data
    end

    @testset "Invalid layout mode" begin
        circ = QuantumCircuit(2, AbstractQuantumGate[])
        add_gate!(circ, SingleQubitGate(1, :H))

        @test_throws ArgumentError to_quantikz(circ; layout=:invalid)
        @test_throws ArgumentError to_tikz_picture(circ; layout=:invalid)
    end
end
