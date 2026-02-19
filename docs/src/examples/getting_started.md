# Getting Started: Your First Quantum Circuit

このページでは、GroverAlgorithm.jlを使って最初の量子回路を作成し、ITensorsとQuantikzの両方でどのように表示されるかを学びます。

## インストール

```julia
using Pkg
Pkg.add("GroverAlgorithm")
Pkg.add("ITensors")
Pkg.add("ITensorMPS")
```

## 基本的なワークフロー

GroverAlgorithm.jlでは、以下の3つのステップで量子回路を扱います：

1. **回路の構築** - ゲートを追加して回路を定義
2. **ITensorsでのシミュレーション** - 量子状態を計算
3. **Quantikzでの可視化** - LaTeX形式で回路図を生成

## 例1: Hadamardゲート

最もシンプルな例から始めましょう。

### ステップ1: 回路の構築

```julia
using GroverAlgorithm

# 1量子ビット回路を作成
circuit = QuantumCircuit(1, AbstractQuantumGate[])

# Hadamardゲートを追加
add_gate!(circuit, SingleQubitGate(1, :H))

println("回路情報:")
println("  量子ビット数: ", circuit.nqubits)
println("  ゲート数: ", length(circuit.gates))
```

**出力:**
```
回路情報:
  量子ビット数: 1
  ゲート数: 1
```

### ステップ2: ITensorsでのシミュレーション

```julia
using ITensors, ITensorMPS

# サイトインデックスの作成
sites = siteinds("Qubit", 1)

# 回路を実行
psi = execute_circuit(circuit, sites)

# MPSの情報を表示
println("\nMPS (Matrix Product State):")
println(psi)
```

**出力:**
```
MPS (Matrix Product State):
MPS
[1] ((dim=2|id=252|"Qubit,Site,n=1"),)
```

MPSの構造を詳しく見る：

```julia
# 各基底状態との内積を計算
println("\n量子状態の振幅:")
amp_0 = inner(psi, MPS(sites, ["0"]))
amp_1 = inner(psi, MPS(sites, ["1"]))

println("  ⟨0|ψ⟩ = ", amp_0, " (確率: ", abs2(amp_0), ")")
println("  ⟨1|ψ⟩ = ", amp_1, " (確率: ", abs2(amp_1), ")")
```

**出力:**
```
量子状態の振幅:
  ⟨0|ψ⟩ = 0.7071067811865476 (確率: 0.5)
  ⟨1|ψ⟩ = 0.7071067811865476 (確率: 0.5)
```

これは |ψ⟩ = (|0⟩ + |1⟩)/√2 という重ね合わせ状態です！

### ステップ3: Quantikzでの可視化

```julia
# LaTeXコードを生成
latex_code = to_quantikz(circuit)
println("\nQuantikz LaTeXコード:")
println(latex_code)
```

**出力:**
```latex
\begin{quantikz}
\lstick{\ket{0}} & \gate{H} & \qw
\end{quantikz}
```

このLaTeXコードは以下のような回路図を生成します：

```
|0⟩ ——[H]——
```

## 例2: Bell状態（エンタングルメント）

次は2量子ビットのエンタングル状態を作ります。

### ステップ1: 回路の構築

```julia
# 2量子ビット回路
circuit = QuantumCircuit(2, AbstractQuantumGate[])

# Hadamardゲートを第1量子ビットに適用
add_gate!(circuit, SingleQubitGate(1, :H))

# CNOTゲート（制御: qubit 1, ターゲット: qubit 2）
add_gate!(circuit, ControlledGate(1, 2, :CNOT))

println("Bell状態回路:")
println("  ゲート1: H on qubit 1")
println("  ゲート2: CNOT (control: 1, target: 2)")
```

### ステップ2: ITensorsでのシミュレーション

```julia
sites = siteinds("Qubit", 2)
psi = execute_circuit(circuit, sites)

# 全ての基底状態との内積
println("\nBell状態の振幅:")
for s in ["00", "01", "10", "11"]
    basis = MPS(sites, collect(s))
    amp = inner(basis, psi)
    prob = abs2(amp)
    println("  ⟨$s|ψ⟩ = ", round(amp, digits=4), " (確率: ", round(prob, digits=4), ")")
end
```

**出力:**
```
Bell状態の振幅:
  ⟨00|ψ⟩ = 0.7071 (確率: 0.5)
  ⟨01|ψ⟩ = 0.0 (確率: 0.0)
  ⟨10|ψ⟩ = 0.0 (確率: 0.0)
  ⟨11|ψ⟩ = 0.7071 (確率: 0.5)
```

これは |Φ⁺⟩ = (|00⟩ + |11⟩)/√2 というBell状態です！

### ステップ3: Quantikzでの可視化

```julia
latex_code = to_quantikz(circuit)
println(latex_code)
```

**出力:**
```latex
\begin{quantikz}
\lstick{\ket{0}} & \gate{H} & \ctrl{1} & \qw \\
\lstick{\ket{0}} & \qw & \targ{} & \qw
\end{quantikz}
```

回路図:
```
|0⟩ ——[H]——●——
              |
|0⟩ —————————⊕——
```

## 例3: Toffoliゲート

いよいよToffoliゲート（3量子ビット制御ゲート）を見てみましょう。

### ステップ1: 回路の構築

```julia
# 3量子ビット回路
circuit = QuantumCircuit(3, AbstractQuantumGate[])

# Toffoliゲートを追加
# 量子ビット1と2が制御、量子ビット3がターゲット
add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))

println("Toffoli回路:")
println("  制御ビット: qubit 1, 2")
println("  ターゲットビット: qubit 3")
```

### ステップ2: ITensorsでのシミュレーション

#### ケースA: 初期状態 |000⟩

```julia
sites = siteinds("Qubit", 3)
psi = execute_circuit(circuit, sites)  # デフォルトは |000⟩

println("\n初期状態 |000⟩ の場合:")
println("ITensor MPS構造:")
println("  リンク次元: ", [linkdim(psi, i) for i in 1:2])

# 測定結果
counts = measure(psi, Sampling(100))
println("  測定結果: ", counts)
```

**出力:**
```
初期状態 |000⟩ の場合:
ITensor MPS構造:
  リンク次元: [1, 1]
  測定結果: Dict("000" => 100)
```

制御ビットが両方とも0なので、何も変化しません。

#### ケースB: 初期状態 |110⟩

```julia
# 初期状態を |110⟩ に設定
initial = AbstractInitialState[ProductState(["1", "1", "0"])]
circuit_110 = QuantumCircuit(3, AbstractQuantumGate[], initial)
add_gate!(circuit_110, ThreeQubitGate(1, 2, 3, :Toffoli))

psi_110 = execute_circuit(circuit_110, sites)

println("\n初期状態 |110⟩ の場合:")

# ITensorの内部構造を見る
println("MPS詳細:")
for i in 1:3
    tensor = psi_110[i]
    println("  サイト $i: ", inds(tensor))
end

# 測定結果
counts_110 = measure(psi_110, Sampling(100))
println("  測定結果: ", counts_110)
```

**出力:**
```
初期状態 |110⟩ の場合:
MPS詳細:
  サイト 1: ((dim=2|id=252|"Qubit,Site,n=1"), (dim=1|id=253|"Link,l=1"))
  サイト 2: ((dim=1|id=253|"Link,l=1"), (dim=2|id=254|"Qubit,Site,n=2"), (dim=1|id=255|"Link,l=2"))
  サイト 3: ((dim=1|id=255|"Link,l=2"), (dim=2|id=256|"Qubit,Site,n=3"))
  測定結果: Dict("111" => 100)
```

制御ビットが両方とも1なので、ターゲットビットが反転！|110⟩ → |111⟩

#### ケースC: 重ね合わせ状態での動作

```julia
# 第1量子ビットを重ね合わせ状態に
circuit_superposition = QuantumCircuit(3, AbstractQuantumGate[])
add_gate!(circuit_superposition, SingleQubitGate(1, :H))  # |0⟩ → |+⟩
add_gate!(circuit_superposition, SingleQubitGate(2, :X))   # |0⟩ → |1⟩
# 今の状態: (|0⟩+|1⟩)/√2 ⊗ |1⟩ ⊗ |0⟩

add_gate!(circuit_superposition, ThreeQubitGate(1, 2, 3, :Toffoli))

psi_super = execute_circuit(circuit_superposition, sites)

println("\n重ね合わせ状態での Toffoli:")
for s in ["000", "001", "010", "011", "100", "101", "110", "111"]
    basis = MPS(sites, collect(s))
    amp = inner(basis, psi_super)
    prob = abs2(amp)
    if prob > 1e-10
        println("  ⟨$s|ψ⟩ = ", round(real(amp), digits=4), " (確率: ", round(prob, digits=4), ")")
    end
end
```

**出力:**
```
重ね合わせ状態での Toffoli:
  ⟨010|ψ⟩ = 0.7071 (確率: 0.5)
  ⟨111|ψ⟩ = 0.7071 (確率: 0.5)
```

重ね合わせ状態が維持されたまま、条件付きで反転します！

### ステップ3: Quantikzでの可視化

```julia
latex_code = to_quantikz(circuit)
println("\nQuantikz出力:")
println(latex_code)
```

**出力:**
```latex
\begin{quantikz}
\lstick{\ket{0}} & \ctrl{1} & \qw \\
\lstick{\ket{0}} & \ctrl{1} & \qw \\
\lstick{\ket{0}} & \targ{} & \qw
\end{quantikz}
```

回路図:
```
|0⟩ ——●——
      |
|0⟩ ——●——
      |
|0⟩ ——⊕——
```

#### カスタム初期状態ラベルでの可視化

```julia
# カスタムラベルを使用
initial_labeled = AbstractInitialState[
    NamedState("1", "\\psi_1"),
    NamedState("1", "\\psi_2"),
    NamedState("0", "\\text{ancilla}")
]
circuit_labeled = QuantumCircuit(3, AbstractQuantumGate[], initial_labeled)
add_gate!(circuit_labeled, ThreeQubitGate(1, 2, 3, :Toffoli))

latex_labeled = to_quantikz(circuit_labeled)
println("\nカスタムラベル版:")
println(latex_labeled)
```

**出力:**
```latex
\begin{quantikz}
\lstick{\ket{\psi_1}} & \ctrl{1} & \qw \\
\lstick{\ket{\psi_2}} & \ctrl{1} & \qw \\
\lstick{\ket{\text{ancilla}}} & \targ{} & \qw
\end{quantikz}
```

## 例4: 完全な比較表

異なる初期状態でのToffoliゲートの動作を一覧表示：

```julia
using Printf

println("=" ^ 60)
println("Toffoliゲート動作確認表")
println("=" ^ 60)
println(@sprintf("%-15s | %-15s | %-20s", "入力状態", "出力状態", "ITensor確率"))
println("-" ^ 60)

# 全ての3ビット状態をテスト
for a in 0:1, b in 0:1, c in 0:1
    input_state = "$a$b$c"
    
    # 回路を構築
    initial = AbstractInitialState[ProductState([string(a), string(b), string(c)])]
    circuit_test = QuantumCircuit(3, AbstractQuantumGate[], initial)
    add_gate!(circuit_test, ThreeQubitGate(1, 2, 3, :Toffoli))
    
    # ITensorsで実行
    sites = siteinds("Qubit", 3)
    psi = execute_circuit(circuit_test, sites)
    
    # 測定
    counts = measure(psi, Sampling(1))
    output_state = collect(keys(counts))[1]
    
    # 確率振幅を計算
    basis = MPS(sites, collect(output_state))
    amp = inner(basis, psi)
    prob = abs2(amp)
    
    @printf("%-15s | %-15s | %.4f\n", "|$input_state⟩", "|$output_state⟩", prob)
end

println("=" ^ 60)
```

**出力:**
```
============================================================
Toffoliゲート動作確認表
============================================================
入力状態        | 出力状態        | ITensor確率
------------------------------------------------------------
|000⟩           | |000⟩           | 1.0000
|001⟩           | |001⟩           | 1.0000
|010⟩           | |010⟩           | 1.0000
|011⟩           | |011⟩           | 1.0000
|100⟩           | |100⟩           | 1.0000
|101⟩           | |101⟩           | 1.0000
|110⟩           | |111⟩           | 1.0000  ← 反転！
|111⟩           | |110⟩           | 1.0000  ← 反転！
============================================================
```

## ITensor vs Quantikz: 一目でわかる比較

| 側面 | ITensors | Quantikz |
|------|----------|----------|
| **目的** | 量子状態の数値計算 | 回路の可視化 |
| **出力** | MPS（テンソルネットワーク） | LaTeX コード |
| **精度** | 浮動小数点精度 | 記号的表現 |
| **使い道** | シミュレーション・測定 | 論文・プレゼンテーション |
| **インタラクティブ性** | 状態を操作・測定可能 | 静的な図 |

### ITensorsの出力例

```julia
println(psi)
# MPS
# [1] ((dim=2|id=252|"Qubit,Site,n=1"), (dim=2|id=253|"Link,l=1"))
# [2] ((dim=2|id=253|"Link,l=1"), (dim=2|id=254|"Qubit,Site,n=2"), (dim=2|id=255|"Link,l=2"))
# [3] ((dim=2|id=255|"Link,l=2"), (dim=2|id=256|"Qubit,Site,n=3"))
```

### Quantikzの出力例

```latex
\begin{quantikz}
\lstick{\ket{0}} & \ctrl{1} & \qw \\
\lstick{\ket{0}} & \ctrl{1} & \qw \\
\lstick{\ket{0}} & \targ{} & \qw
\end{quantikz}
```

## まとめ：ワークフローのベストプラクティス

```julia
# 1. 回路を構築
circuit = QuantumCircuit(3, AbstractQuantumGate[])
add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))

# 2. ITensorsでシミュレーション
sites = siteinds("Qubit", 3)
psi = execute_circuit(circuit, sites)

# 3. 測定と解析
counts = measure(psi, Sampling(1000))
z_exp = measure(psi, ExpectationValue(:Z, [1]))

# 4. 可視化
latex_code = to_quantikz(circuit)
tp = to_tikz_picture(circuit)

# 5. エクスポート（必要に応じて）
using TikzPictures
save(PDF("my_circuit"), tp)
```

これで、GroverAlgorithm.jlを使った量子回路の作成、シミュレーション、可視化の基本がマスターできました！

## 次のステップ

- [Structures](structures.md) - 全てのゲート型の詳細
- [Initial States](initialstates.md) - 初期状態のカスタマイズ
- [Measurements](measurements.md) - 様々な測定手法
- [Examples](examples.md) - より高度な応用例
