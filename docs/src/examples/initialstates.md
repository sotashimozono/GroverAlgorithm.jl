# Initial States

量子回路の初期状態を抽象化し、ITensors.jlのMPS初期化とquantikz可視化の両方で一貫性のあるインターフェースを提供します。

## Abstract Type

```@docs
AbstractInitialState
```

## Concrete Types

### BasisState

```@docs
BasisState
```

#### 使用例

```julia
# 計算基底 |0⟩
state_0 = BasisState("0")

# 計算基底 |1⟩
state_1 = BasisState("1")

# 重ね合わせ状態 |+⟩ = (|0⟩ + |1⟩)/√2
state_plus = BasisState("+")

# 重ね合わせ状態 |-⟩ = (|0⟩ - |1⟩)/√2
state_minus = BasisState("-")
```

### NamedState

```@docs
NamedState
```

#### 使用例

```julia
# |0⟩として初期化するが、可視化では |ψ⟩ と表示
state = NamedState("0", "\\psi")

# |+⟩として初期化し、可視化では |φ₊⟩ と表示
state = NamedState("+", "\\phi_+")

# カスタムラベルでの可視化
state = NamedState("0", "\\text{init}")
```

### ProductState

```@docs
ProductState
```

#### 使用例

```julia
# 3量子ビットの積状態: |0⟩ ⊗ |1⟩ ⊗ |+⟩
state = ProductState(["0", "1", "+"])

# 4量子ビットすべてを |+⟩ に設定
state = ProductState(["+", "+", "+", "+"])
```

## Mapping Functions

### to_itensor_state

```@docs
to_itensor_state
```

#### 使用例

```julia
# BasisStateの変換
state = BasisState("0")
states = to_itensor_state(state, 3)  # ["0", "0", "0"]

# ProductStateの変換
state = ProductState(["0", "1", "+"])
states = to_itensor_state(state, 3)  # ["0", "1", "+"]

# NamedStateの変換
state = NamedState("0", "\\psi")
states = to_itensor_state(state, 2)  # ["0", "0"]
```

### to_latex_label

```@docs
to_latex_label
```

#### 使用例

```julia
# BasisStateのラベル
state = BasisState("0")
label = to_latex_label(state, 1)  # "\\ket{0}"

# NamedStateのラベル
state = NamedState("0", "\\psi")
label = to_latex_label(state, 1)  # "\\ket{\\psi}"

# ProductStateのラベル（各量子ビット）
state = ProductState(["0", "1", "+"])
label1 = to_latex_label(state, 1)  # "\\ket{0}"
label2 = to_latex_label(state, 2)  # "\\ket{1}"
label3 = to_latex_label(state, 3)  # "\\ket{+}"
```

## 回路での使用方法

### パターン1: 全量子ビットに同じ状態

```julia
# すべての量子ビットを |+⟩ に初期化
initial = AbstractInitialState[BasisState("+")]
circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)
```

### パターン2: 各量子ビットに異なる状態

```julia
# 量子ビットごとに異なる状態を設定
initial = AbstractInitialState[
    BasisState("0"),
    BasisState("1"),
    BasisState("+")
]
circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)
```

### パターン3: ProductStateを使用

```julia
# ProductStateで一括指定
initial = AbstractInitialState[ProductState(["0", "1", "+"])]
circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)
```

### パターン4: カスタムラベルでの可視化

```julia
# 実際の初期化は |0⟩ だが、ドキュメントでは |ψ₀⟩ と表示
initial = AbstractInitialState[NamedState("0", "\\psi_0")]
circuit = QuantumCircuit(2, AbstractQuantumGate[], initial)

println(to_quantikz(circuit))
# 出力: \\lstick{\\ket{\\psi_0}} & ...
```

## ITensorsとの統合例

```julia
using ITensors, ITensorMPS

# 初期状態を定義
initial = AbstractInitialState[ProductState(["0", "1", "+"])]
circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)

# ゲートを追加
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))

# ITensorsで実行
sites = siteinds("Qubit", 3)
psi = execute_circuit(circuit, sites)
```

## 後方互換性

従来の `init_state` パラメータも引き続き使用できます：

```julia
circuit = QuantumCircuit(2, AbstractQuantumGate[])
sites = siteinds("Qubit", 2)

# 従来の方法（文字列）
psi = execute_circuit(circuit, sites; init_state="0")

# 従来の方法（ベクトル）
psi = execute_circuit(circuit, sites; init_state=["0", "1"])

# 新しい方法（AbstractInitialState）
psi = execute_circuit(circuit, sites; init_state=BasisState("+"))
```
