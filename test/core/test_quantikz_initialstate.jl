using GroverAlgorithm, Test
using LaTeXStrings, TikzPictures

@testset "Quantikz Visualization with Initial States" begin
    @testset "Default Initial State Labels" begin
        circuit = QuantumCircuit(2, AbstractQuantumGate[])
        add_gate!(circuit, SingleQubitGate(1, :H))

        latex = to_quantikz(circuit)

        # Should have default |0⟩ labels
        @test occursin("\\lstick{\\ket{0}}", latex)
        @test occursin("\\gate{H}", latex)
    end

    @testset "Custom BasisState Labels" begin
        initial = AbstractInitialState[BasisState("+")]
        circuit = QuantumCircuit(2, AbstractQuantumGate[], initial)
        add_gate!(circuit, SingleQubitGate(1, :X))

        latex = to_quantikz(circuit)

        # Should have |+⟩ labels
        @test occursin("\\lstick{\\ket{+}}", latex)
        @test occursin("\\gate{X}", latex)
    end

    @testset "NamedState Labels" begin
        initial = AbstractInitialState[NamedState("0", "\\psi")]
        circuit = QuantumCircuit(2, AbstractQuantumGate[], initial)
        add_gate!(circuit, SingleQubitGate(1, :H))

        latex = to_quantikz(circuit)

        # Should use custom LaTeX label
        @test occursin("\\lstick{\\ket{\\psi}}", latex)
    end

    @testset "ProductState Labels" begin
        initial = AbstractInitialState[ProductState(["0", "1", "+"])]
        circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)
        add_gate!(circuit, SingleQubitGate(1, :H))

        latex = to_quantikz(circuit)

        # Should have different labels for each qubit
        @test occursin("\\lstick{\\ket{0}}", latex)
        @test occursin("\\lstick{\\ket{1}}", latex)
        @test occursin("\\lstick{\\ket{+}}", latex)
    end

    @testset "Per-Qubit Initial States" begin
        initial = AbstractInitialState[BasisState("0"), BasisState("1")]
        circuit = QuantumCircuit(2, AbstractQuantumGate[], initial)
        add_gate!(circuit, ControlledGate(1, 2, :CNOT))

        latex = to_quantikz(circuit)

        # First qubit should be |0⟩, second should be |1⟩
        lines = split(latex, "\n")
        # Find the lines with lstick
        lstick_lines = filter(l -> occursin("\\lstick", l), lines)
        @test length(lstick_lines) >= 2
        @test occursin("\\ket{0}", lstick_lines[1])
        @test occursin("\\ket{1}", lstick_lines[2])
    end

    @testset "TikzPicture with Initial States" begin
        initial = AbstractInitialState[BasisState("+")]
        circuit = QuantumCircuit(2, AbstractQuantumGate[], initial)
        add_gate!(circuit, SingleQubitGate(1, :H))
        add_gate!(circuit, ControlledGate(1, 2, :CNOT))

        tp = to_tikz_picture(circuit)

        @test tp isa TikzPicture
        @test tp.options == "ampersand replacement=\\&"
        @test tp.environment == "quantikz"

        # Check that custom labels are in the data
        @test occursin("\\ket{+}", tp.data)
    end

    @testset "Backward Compatibility - No Breaking Changes" begin
        # Old-style circuit should still work with default labels
        circuit = QuantumCircuit(3, AbstractQuantumGate[])
        add_gate!(circuit, SingleQubitGate(1, :H))
        add_gate!(circuit, SingleQubitGate(2, :X))
        add_gate!(circuit, ControlledGate(1, 3, :CNOT))

        # Should not throw errors
        latex = to_quantikz(circuit)
        @test occursin("\\begin{quantikz}", latex)
        @test occursin("\\end{quantikz}", latex)

        tp = to_tikz_picture(circuit)
        @test tp isa TikzPicture
    end
end
