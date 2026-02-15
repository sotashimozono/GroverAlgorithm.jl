using LaTeXStrings

@testset "LaTeX Conversion Logic" begin

    @testset "format_param" begin
        # π の整数倍
        @test format_param(0.0) == "0"
        @test format_param(π) == "\\pi"
        @test format_param(-π) == "-\\pi"
        @test format_param(2π) == "2\\pi"
        
        # π の分数倍
        @test format_param(π/2) == "\\pi/2"
        @test format_param(-π/4) == "-\\pi/4"
        @test format_param(3π/4) == "3\\pi/4"
        @test format_param(π/16) == "\\pi/16"
        
        # 一般的な小数
        @test format_param(1.23456) == "1.235"
        @test format_param(0.0001) == "0.0"
    end

    @testset "gate_to_latex (Standard)" begin
        # 基本的なゲート
        @test gate_to_latex(:X) == "X"
        @test gate_to_latex(:H) == "H"
        @test gate_to_latex(:S) == "S"
        
        # 特殊なシンボル名
        @test gate_to_latex(Symbol("π/8")) == "T"
        @test gate_to_latex(Symbol("√NOT")) == "\\sqrt{X}"
        @test gate_to_latex(:ProjUp) == "P_{\\uparrow}"
        
        # 未知のゲートは文字列として返るか
        @test gate_to_latex(:UnknownGate) == "UnknownGate"
    end

    @testset "gate_to_latex (Parameterized)" begin
        # 1量子ビット回転
        @test gate_to_latex(:Rx, [π]) == "R_x(\\pi)"
        @test gate_to_latex(:Ry, [π/2]) == "R_y(\\pi/2)"
        
        # 多パラメータ (Rn)
        @test gate_to_latex(:Rn, [π, π/2, π/4]) == "R_n(\\pi, \\pi/2, \\pi/4)"
        
        # 2量子ビット回転
        @test gate_to_latex(:Rzz, [0.1234]) == "R_{zz}(0.123)"
        
        # 未知のパラメータ付きゲート
        @test gate_to_latex(:Custom, [1.0, 2.0]) == "Custom(1.0, 2.0)"
    end

    @testset "controlled_gate_target" begin
        # 特殊な形状を持つターゲット
        @test controlled_gate_target(:X) == "\\targ{}"
        @test controlled_gate_target(:CNOT) == "\\targ{}"
        @test controlled_gate_target(:CZ) == "\\ctrl{0}"
        @test controlled_gate_target(:CPHASE) == "\\ctrl{0}"
        
        # 通常のゲートボックス
        @test controlled_gate_target(:Y) == "\\gate{Y}"
        @test controlled_gate_target(:H) == "\\gate{H}"
        
        # パラメータ付きゲートがターゲットになる場合（CRxなど）
        # gate_to_latex が内部で呼ばれることを確認
        @test controlled_gate_target(:Rx) == "\\gate{R_x}" 
        # ※ 注意: ここは gate_to_latex(:Rx) なので params がない場合の挙動に依存します
    end

end