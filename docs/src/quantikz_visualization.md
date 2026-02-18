# Quantikz Visualization

量子回路をLaTeX/quantikzパッケージを使用して可視化します。

## Core Functions

### to_quantikz

```@docs
to_quantikz
```

#### 使用例

```julia
# 基本的な回路
circuit = QuantumCircuit(2, AbstractQuantumGate[])
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))

# LaTeXコードの生成
latex_code = to_quantikz(circuit)
println(latex_code)

# 出力:
# \begin{quantikz}
# \lstick{\ket{0}} & \gate{H} & \ctrl{1} & \qw \\
# \lstick{\ket{0}} & \qw & \targ{} & \qw
# \end{quantikz}
```

### to_tikz_picture

```@docs
to_tikz_picture
```

#### 使用例

```julia
using TikzPictures

circuit = QuantumCircuit(2, AbstractQuantumGate[])
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))

# TikzPictureオブジェクトの生成
tp = to_tikz_picture(circuit)

# PDFとして保存
save(PDF("bell_circuit"), tp)

# SVGとして保存
save(SVG("bell_circuit"), tp)
```

## LaTeX String Conversion

### gate_to_latex

```@docs
gate_to_latex(::Symbol)
gate_to_latex(::Symbol, ::AbstractVector{<:Real})
```

#### 使用例

```julia
# 非パラメトリックゲート
gate_to_latex(:H)        # "H"
gate_to_latex(:X)        # "X"
gate_to_latex(:CNOT)     # "X"

# パラメトリックゲート
gate_to_latex(:Rx, [π/2])        # "R_x(π/2)"
gate_to_latex(:Ry, [π])          # "R_y(π)"
gate_to_latex(:Rz, [π/4])        # "R_z(π/4)"
gate_to_latex(:Rn, [π, π/2, 0])  # "R_n(π, π/2, 0)"
```

### format_param

```@docs
format_param
```

#### 使用例

```julia
format_param(π)      # "\\pi"
format_param(π/2)    # "\\pi/2"
format_param(2π)     # "2\\pi"
format_param(-π/4)   # "-\\pi/4"
format_param(0.123)  # "0.123"
```

### controlled_gate_target

```@docs
controlled_gate_target
```

## 初期状態ラベルのカスタマイズ

### デフォルトラベル

```julia
# デフォルトは |0⟩
circuit = QuantumCircuit(2, AbstractQuantumGate[])
latex = to_quantikz(circuit)
# \lstick{\ket{0}} が使用される
```

### BasisStateでのカスタマイズ

```julia
# すべての量子ビットを |+⟩ で表示
initial = AbstractInitialState[BasisState("+")]
circuit = QuantumCircuit(2, AbstractQuantumGate[], initial)
latex = to_quantikz(circuit)
# \lstick{\ket{+}} が使用される
```

### NamedStateでのカスタマイズ

```julia
# カスタムLaTeXラベル
initial = AbstractInitialState[NamedState("0", "\\psi_0")]
circuit = QuantumCircuit(2, AbstractQuantumGate[], initial)
latex = to_quantikz(circuit)
# \lstick{\ket{\psi_0}} が使用される
```

### 各量子ビットに異なるラベル

```julia
initial = AbstractInitialState[
    BasisState("0"),
    BasisState("1"),
    BasisState("+")
]
circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)
latex = to_quantikz(circuit)
# 各行が \lstick{\ket{0}}, \lstick{\ket{1}}, \lstick{\ket{+}} となる
```

## 実践例

### Bell状態回路の可視化

```julia
circuit = QuantumCircuit(2, AbstractQuantumGate[])
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))

println(to_quantikz(circuit))
```

**出力:**
```latex
\begin{quantikz}
\lstick{\ket{0}} & \gate{H} & \ctrl{1} & \qw \\
\lstick{\ket{0}} & \qw & \targ{} & \qw
\end{quantikz}
```

### パラメトリックゲートの可視化

```julia
circuit = QuantumCircuit(3, AbstractQuantumGate[])
add_gate!(circuit, ParametricSingleGate(1, :Rx, [π/2]))
add_gate!(circuit, ParametricSingleGate(2, :Ry, [π/4]))
add_gate!(circuit, ParametricControlledGate(1, 3, :CRz, [π]))

println(to_quantikz(circuit))
```

**出力:**
```latex
\begin{quantikz}
\lstick{\ket{0}} & \gate{R_x(\pi/2)} & \qw & \ctrl{2} & \qw \\
\lstick{\ket{0}} & \qw & \gate{R_y(\pi/4)} & \qw & \qw \\
\lstick{\ket{0}} & \qw & \qw & \gate{R_z(\pi)} & \qw
\end{quantikz}
```

### Toffoliゲートの可視化

```julia
circuit = QuantumCircuit(3, AbstractQuantumGate[])
add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))

println(to_quantikz(circuit))
```

**出力:**
```latex
\begin{quantikz}
\lstick{\ket{0}} & \ctrl{1} & \qw \\
\lstick{\ket{0}} & \ctrl{1} & \qw \\
\lstick{\ket{0}} & \targ{} & \qw
\end{quantikz}
```

### SWAPゲートの可視化

```julia
circuit = QuantumCircuit(3, AbstractQuantumGate[])
add_gate!(circuit, TwoQubitGate(1, 3, :SWAP))

println(to_quantikz(circuit))
```

**出力:**
```latex
\begin{quantikz}
\lstick{\ket{0}} & \swap{2} & \qw \\
\lstick{\ket{0}} & \qw & \qw \\
\lstick{\ket{0}} & \targX{} & \qw
\end{quantikz}
```

### 複雑な回路の可視化

```julia
# 量子フーリエ変換（3量子ビット）
circuit = QuantumCircuit(3, AbstractQuantumGate[])

# 最初の量子ビット
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ParametricControlledGate(2, 1, :CRz, [π/2]))
add_gate!(circuit, ParametricControlledGate(3, 1, :CRz, [π/4]))

# 2番目の量子ビット
add_gate!(circuit, SingleQubitGate(2, :H))
add_gate!(circuit, ParametricControlledGate(3, 2, :CRz, [π/2]))

# 3番目の量子ビット
add_gate!(circuit, SingleQubitGate(3, :H))

# SWAP
add_gate!(circuit, TwoQubitGate(1, 3, :SWAP))

println(to_quantikz(circuit))
```

### カスタムラベルでの可視化

```julia
# 論文用の記号
initial = AbstractInitialState[
    NamedState("0", "\\psi"),
    NamedState("0", "\\phi"),
    NamedState("0", "0")
]
circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))
add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))

println(to_quantikz(circuit))
```

## LaTeX文書への埋め込み

### スタンドアロンでの使用

```latex
\documentclass{article}
\usepackage{quantikz}

\begin{document}

% Juliaで生成したコードをここに貼り付け
\begin{quantikz}
\lstick{\ket{0}} & \gate{H} & \ctrl{1} & \qw \\
\lstick{\ket{0}} & \qw & \targ{} & \qw
\end{quantikz}

\end{document}
```

### Overleafでの使用

1. Juliaで`to_quantikz(circuit)`を実行
2. 出力されたLaTeXコードをコピー
3. Overleafの文書に貼り付け
4. プリアンブルに`\usepackage{quantikz}`を追加

### SVG/PDFとしてエクスポート

```julia
using TikzPictures

circuit = QuantumCircuit(2, AbstractQuantumGate[])
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))

tp = to_tikz_picture(circuit)

# ファイルとして保存
save(PDF("circuit"), tp)
save(SVG("circuit"), tp)
save(TEX("circuit"), tp)
```

## スタイリングのカスタマイズ

### ゲートスタイルの変更

quantikzパッケージのオプションを使用してスタイルをカスタマイズできます：

```latex
% 文書のプリアンブルで
\tikzset{
    operator/.append style={fill=blue!20},
    phase/.append style={fill=red!20}
}
```

### カラースキーム

```latex
\begin{quantikz}[color=blue]
% 回路コード
\end{quantikz}
```

## トラブルシューティング

### 長い回路の処理

```julia
# 非常に長い回路の場合、手動で改ページ
circuit = QuantumCircuit(10, AbstractQuantumGate[])
# ... 多数のゲートを追加 ...

# LaTeXコードを取得
latex = to_quantikz(circuit)

# 必要に応じて複数のquantikz環境に分割
```

### 日本語ラベルの使用

```julia
# NamedStateで日本語ラベルを使用する場合
# LaTeX側で日本語対応設定が必要

initial = AbstractInitialState[NamedState("0", "\\text{初期}")]
circuit = QuantumCircuit(1, AbstractQuantumGate[], initial)
```

LaTeX文書側:
```latex
\usepackage{xeCJK}  % または他の日本語パッケージ
```
