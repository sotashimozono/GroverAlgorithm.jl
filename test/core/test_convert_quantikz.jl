using LaTeXStrings, TikzPictures

@testset "Visualization Logic (quantikz)" begin
    n = 3

    @testset "add_gate_column! - Single Qubit Gates" begin
        qlines = [String[] for _ in 1:n]
        
        # SingleQubitGate (X at q1)
        add_gate_column!(qlines, SingleQubitGate(1, :X), n)
        @test qlines[1][1] == "\\gate{X}"
        @test qlines[2][1] == "\\qw"
        @test qlines[3][1] == "\\qw"

        # ParametricSingleGate (Rx(π) at q2)
        add_gate_column!(qlines, ParametricSingleGate(2, :Rx, [π]), n)
        @test qlines[1][2] == "\\qw"
        @test qlines[2][2] == "\\gate{R_x(\\pi)}"
        @test qlines[3][2] == "\\qw"
    end

    @testset "add_gate_column! - Controlled Gates" begin
        qlines = [String[] for _ in 1:n]
        
        # CNOT (Control: 1, Target: 3) -> offset = 2
        add_gate_column!(qlines, ControlledGate(1, 3, :CNOT), n)
        @test qlines[1][1] == "\\ctrl{2}"
        @test qlines[2][1] == "\\qw"
        @test qlines[3][1] == "\\targ{}"

        # ParametricControlledGate (CRz(π/2) Control: 2, Target: 1) -> offset = -1
        add_gate_column!(qlines, ParametricControlledGate(2, 1, :CRz, [π/2]), n)
        @test qlines[1][2] == "\\gate{R_z(\\pi/2)}"
        @test qlines[2][2] == "\\ctrl{-1}"
        @test qlines[3][2] == "\\qw"
    end

    @testset "add_gate_column! - Multi-Qubit Gates" begin
        qlines = [String[] for _ in 1:n]
        
        # SWAP (q1, q3) -> offset = 2
        add_gate_column!(qlines, TwoQubitGate(1, 3, :SWAP), n)
        @test qlines[1][1] == "\\swap{2}"
        @test qlines[2][1] == "\\qw"
        @test qlines[3][1] == "\\targX{}"

        # iSWAP (q1, q2) -> \gate[2]
        add_gate_column!(qlines, TwoQubitGate(1, 2, :iSWAP), n)
        @test qlines[1][2] == "\\gate[2]{iSWAP}"
        @test qlines[2][2] == "" # スパン部分は空文字
    end

    @testset "add_gate_column! - 3 & 4 Qubit Gates" begin
        qlines = [String[] for _ in 1:n]
        
        # Toffoli (q1, q2 -> q3)
        add_gate_column!(qlines, ThreeQubitGate(1, 2, 3, :Toffoli), n)
        @test qlines[1][1] == "\\ctrl{1}"
        @test qlines[2][1] == "\\ctrl{1}"
        @test qlines[3][1] == "\\targ{}"

        # Fredkin (q1 control, q2-q3 swap)
        add_gate_column!(qlines, ThreeQubitGate(1, 2, 3, :Fredkin), n)
        @test qlines[1][2] == "\\ctrl{1}"
        @test qlines[2][2] == "\\swap{1}"
        @test qlines[3][2] == "\\targX{}"
    end

    @testset "Full Circuit Conversion" begin
        circ = QuantumCircuit(2, AbstractQuantumGate[])
        add_gate!(circ, SingleQubitGate(1, :H))
        add_gate!(circ, ControlledGate(1, 2, :CNOT))
        
        # to_quantikz
        latex = to_quantikz(circ)
        @test occursin("\\begin{quantikz}", latex)
        @test occursin("\\lstick{\\ket{q_1}}", latex)
        @test occursin("\\gate{H}", latex)
        @test occursin("\\ctrl{1}", latex)
        
        # to_tikz_picture
        tp = to_tikz_picture(circ)
        @test tp isa TikzPicture
        @test tp.options == "ampersand replacement=\\&"
        @test tp.environment == "quantikz"
    end
end