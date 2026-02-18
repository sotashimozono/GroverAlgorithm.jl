# Quantum Gates and Circuit Structures

このページでは、量子ゲートと量子回路を表現するための構造体とデータ型について説明します。

## Abstract Types

```@docs
AbstractQuantumGate
```

## Single-Qubit Gates

1量子ビットゲートは、単一の量子ビットに作用するゲートです。

### Non-Parametric Gates

```@docs
SingleQubitGate
```

#### 利用可能なゲート

- **Pauli Gates**: `:X`, `:Y`, `:Z`
- **Hadamard Gate**: `:H`
- **Phase Gates**: `:S`, `:T`
- **Projection Operators**: `:Proj0`, `:Proj1`

#### 使用例

```julia
# Hadamardゲートを量子ビット1に適用
h_gate = SingleQubitGate(1, :H)

# Xゲート（NOT）を量子ビット2に適用
x_gate = SingleQubitGate(2, :X)
```

### Parametric Gates

```@docs
ParametricSingleGate
```

#### 利用可能なゲート

- **Rotation Gates**: `:Rx`, `:Ry`, `:Rz` - 回転角θを指定
- **Arbitrary Rotation**: `:Rn` - 3つのパラメータ (θ, ϕ, λ) を指定

#### 使用例

```julia
# X軸周りにπ/2回転
rx_gate = ParametricSingleGate(1, :Rx, [π/2])

# 任意軸周りの回転
rn_gate = ParametricSingleGate(2, :Rn, [π/4, π/3, π/6])
```

## Two-Qubit Gates

2量子ビットゲートは、2つの量子ビットに作用するゲートです。

### Controlled Gates

```@docs
ControlledGate
ParametricControlledGate
```

#### 使用例

```julia
# CNOT（制御NOT）ゲート
cnot = ControlledGate(1, 2, :CNOT)

# 制御Z ゲート
cz = ControlledGate(1, 3, :CZ)

# 制御回転ゲート
crx = ParametricControlledGate(2, 3, :CRx, [π/4])
```

### Two-Qubit Operations

```@docs
TwoQubitGate
ParametricTwoQubitGate
```

#### 使用例

```julia
# SWAPゲート
swap = TwoQubitGate(1, 2, :SWAP)

# Ising相互作用ゲート
rxx = ParametricTwoQubitGate(1, 2, :Rxx, [π/2])
```

## Multi-Qubit Gates

### Three-Qubit Gates

```@docs
ThreeQubitGate
```

#### 使用例

```julia
# Toffoliゲート（CCNOT）
toffoli = ThreeQubitGate(1, 2, 3, :Toffoli)

# Fredkinゲート（CSWAP）
fredkin = ThreeQubitGate(1, 2, 3, :Fredkin)
```

### Four-Qubit Gates

```@docs
FourQubitGate
```

#### 使用例

```julia
# 3制御NOTゲート
cccnot = FourQubitGate(1, 2, 3, 4, :CCCNOT)
```

## Quantum Circuit

```@docs
QuantumCircuit
add_gate!
```

### 使用例

```julia
# 2量子ビット回路の作成
circuit = QuantumCircuit(2, AbstractQuantumGate[])

# ゲートの追加
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))

# チェーン形式での記述
circuit = QuantumCircuit(3, AbstractQuantumGate[])
    |> c -> add_gate!(c, SingleQubitGate(1, :H))
    |> c -> add_gate!(c, SingleQubitGate(2, :H))
    |> c -> add_gate!(c, ControlledGate(1, 3, :CNOT))
```

### カスタム初期状態での回路作成

```julia
# すべての量子ビットを |0⟩ に初期化（デフォルト）
circuit1 = QuantumCircuit(2, AbstractQuantumGate[])

# すべての量子ビットを |+⟩ に初期化
initial = AbstractInitialState[BasisState("+")]
circuit2 = QuantumCircuit(2, AbstractQuantumGate[], initial)

# 各量子ビットに異なる初期状態を設定
initial = AbstractInitialState[BasisState("0"), BasisState("1"), BasisState("+")]
circuit3 = QuantumCircuit(3, AbstractQuantumGate[], initial)

# ProductStateを使用
initial = AbstractInitialState[ProductState(["0", "1", "+"])]
circuit4 = QuantumCircuit(3, AbstractQuantumGate[], initial)
```
