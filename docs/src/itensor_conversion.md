# ITensor Conversion and Execution

量子回路をITensors.jlのMatrix Product State (MPS) 表現に変換し、シミュレーションを実行します。

## Operator Conversion

```@docs
to_itensor_op
```

### 使用例

```julia
using ITensors, ITensorMPS

# サイトインデックスの作成
sites = siteinds("Qubit", 3)

# 単一量子ビットゲートの変換
h_gate = SingleQubitGate(1, :H)
h_op = to_itensor_op(h_gate, sites)

# 制御ゲートの変換
cnot = ControlledGate(1, 2, :CNOT)
cnot_op = to_itensor_op(cnot, sites)

# パラメトリックゲートの変換
rx = ParametricSingleGate(2, :Rx, [π/4])
rx_op = to_itensor_op(rx, sites)
```

## Circuit Execution

```@docs
execute_circuit
```

### 基本的な使用例

```julia
# 2量子ビット回路の作成
circuit = QuantumCircuit(2, AbstractQuantumGate[])
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))

# ITensorsで実行
sites = siteinds("Qubit", 2)
psi = execute_circuit(circuit, sites)

# 状態の確認
println("Final state: ", psi)
```

### 初期状態の指定

#### デフォルト初期状態（回路の設定を使用）

```julia
# 回路にデフォルト初期状態が設定されている
circuit = QuantumCircuit(2, AbstractQuantumGate[])  # |00⟩
sites = siteinds("Qubit", 2)
psi = execute_circuit(circuit, sites)
```

#### カスタム初期状態（回路構造で指定）

```julia
# ProductStateを使用
initial = AbstractInitialState[ProductState(["1", "0"])]
circuit = QuantumCircuit(2, AbstractQuantumGate[], initial)
add_gate!(circuit, SingleQubitGate(1, :X))

sites = siteinds("Qubit", 2)
psi = execute_circuit(circuit, sites)
```

#### init_stateパラメータでオーバーライド（後方互換性）

```julia
circuit = QuantumCircuit(2, AbstractQuantumGate[])
sites = siteinds("Qubit", 2)

# 文字列で指定
psi = execute_circuit(circuit, sites; init_state="1")

# ベクトルで指定
psi = execute_circuit(circuit, sites; init_state=["1", "0"])

# AbstractInitialStateで指定
psi = execute_circuit(circuit, sites; init_state=BasisState("+"))
```

## 対応するゲート一覧

### 単一量子ビットゲート

| ゲート | シンボル | ITensors名 | 説明 |
|--------|----------|------------|------|
| Pauli X | `:X` | `"X"` | NOT ゲート |
| Pauli Y | `:Y` | `"Y"` | Pauli Y |
| Pauli Z | `:Z` | `"Z"` | 位相反転 |
| Hadamard | `:H` | `"H"` | 重ね合わせ生成 |
| Phase | `:S` | `"Phase"` | π/2 位相ゲート |
| π/8 | `:T` | `"π/8"` | π/4 位相ゲート |
| Rx(θ) | `:Rx` | `"Rx"` | X軸周り回転 |
| Ry(θ) | `:Ry` | `"Ry"` | Y軸周り回転 |
| Rz(θ) | `:Rz` | `"Rz"` | Z軸周り回転 |

### 2量子ビットゲート

| ゲート | シンボル | ITensors名 | 説明 |
|--------|----------|------------|------|
| CNOT | `:CNOT` | `"CNOT"` | 制御NOT |
| CZ | `:CZ` | `"CZ"` | 制御Z |
| SWAP | `:SWAP` | `"SWAP"` | 量子ビット交換 |
| iSWAP | `:iSWAP` | `"iSWAP"` | 虚数SWAP |
| CRx(θ) | `:CRx` | `"CRx"` | 制御X回転 |
| Rxx(ϕ) | `:Rxx` | `"Rxx"` | XX相互作用 |

### 多量子ビットゲート

| ゲート | シンボル | ITensors名 | 説明 |
|--------|----------|------------|------|
| Toffoli | `:Toffoli` | `"Toffoli"` | 2制御NOT |
| Fredkin | `:Fredkin` | `"Fredkin"` | 制御SWAP |
| CCCNOT | `:CCCNOT` | `"CCCNOT"` | 3制御NOT |

## 実践例

### Bell状態の生成

```julia
using ITensors, ITensorMPS

# Bell状態回路: |Φ⁺⟩ = (|00⟩ + |11⟩)/√2
circuit = QuantumCircuit(2, AbstractQuantumGate[])
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))

sites = siteinds("Qubit", 2)
psi = execute_circuit(circuit, sites)

# 確率振幅の確認
prob_00 = abs(inner(psi, MPS(sites, ["0", "0"])))^2
prob_11 = abs(inner(psi, MPS(sites, ["1", "1"])))^2

println("P(|00⟩) = ", prob_00)  # ≈ 0.5
println("P(|11⟩) = ", prob_11)  # ≈ 0.5
```

### GHZ状態の生成

```julia
# GHZ状態: (|000⟩ + |111⟩)/√2
n = 3
circuit = QuantumCircuit(n, AbstractQuantumGate[])

# 最初の量子ビットをHadamard
add_gate!(circuit, SingleQubitGate(1, :H))

# 順次CNOTでエンタングル
for i in 1:n-1
    add_gate!(circuit, ControlledGate(i, i+1, :CNOT))
end

sites = siteinds("Qubit", n)
psi = execute_circuit(circuit, sites)
```

### 量子フーリエ変換（QFT）

```julia
function add_qft_gates!(circuit::QuantumCircuit, qubits::Vector{Int})
    n = length(qubits)
    
    for j in 1:n
        q = qubits[j]
        # Hadamard
        add_gate!(circuit, SingleQubitGate(q, :H))
        
        # 制御回転
        for k in (j+1):n
            q_ctrl = qubits[k]
            angle = π / 2^(k - j)
            add_gate!(circuit, ParametricControlledGate(q_ctrl, q, :CRz, [angle]))
        end
    end
    
    # SWAP（逆順に）
    for i in 1:(n÷2)
        add_gate!(circuit, TwoQubitGate(qubits[i], qubits[n-i+1], :SWAP))
    end
    
    return circuit
end

# 使用例
circuit = QuantumCircuit(3, AbstractQuantumGate[])
add_qft_gates!(circuit, [1, 2, 3])

sites = siteinds("Qubit", 3)
psi = execute_circuit(circuit, sites)
```

### パラメータスキャン

```julia
# Rx(θ)ゲートのパラメータをスキャン
results = Float64[]
angles = range(0, 2π, length=50)

for θ in angles
    circuit = QuantumCircuit(1, AbstractQuantumGate[])
    add_gate!(circuit, ParametricSingleGate(1, :Rx, [θ]))
    
    sites = siteinds("Qubit", 1)
    psi = execute_circuit(circuit, sites)
    
    # Z期待値を測定
    z_exp = measure(psi, ExpectationValue(:Z, [1]))
    push!(results, z_exp)
end

# プロット（別途Plotsパッケージが必要）
# using Plots
# plot(angles, results, xlabel="θ", ylabel="⟨Z⟩", label="Rx(θ)")
```

### カスタム初期状態からの進化

```julia
# |+⟩状態から開始
initial = AbstractInitialState[BasisState("+")]
circuit = QuantumCircuit(1, AbstractQuantumGate[], initial)
add_gate!(circuit, ParametricSingleGate(1, :Rz, [π/2]))

sites = siteinds("Qubit", 1)
psi = execute_circuit(circuit, sites)

# X, Y, Z期待値を測定
x_exp = measure(psi, ExpectationValue(:X, [1]))
y_exp = measure(psi, ExpectationValue(:Y, [1]))
z_exp = measure(psi, ExpectationValue(:Z, [1]))

println("Bloch vector: ($(x_exp), $(y_exp), $(z_exp))")
```

## エラーハンドリング

```julia
# 量子ビット数の不一致
circuit = QuantumCircuit(3, AbstractQuantumGate[])
sites = siteinds("Qubit", 2)  # 2量子ビットのサイト

try
    psi = execute_circuit(circuit, sites)
catch e
    println("Error: ", e)
    # ArgumentError: Circuit qubit count (3) must match sites count (2)
end
```

## パフォーマンスに関する注意

### MPS結合次元の管理

```julia
# cutoffパラメータ（デフォルト: 1e-15）
# 小さな特異値を切り捨ててMPSを圧縮

# 深い回路の場合、結合次元が大きくなる可能性あり
n = 10
circuit = QuantumCircuit(n, AbstractQuantumGate[])

# ランダムゲートを多数追加
for _ in 1:100
    add_gate!(circuit, ParametricSingleGate(rand(1:n), :Ry, [rand()*2π]))
end

sites = siteinds("Qubit", n)
psi = execute_circuit(circuit, sites)

# 結合次元の確認
max_link_dim = maximum(linkdim(psi, b) for b in 1:n-1)
println("Maximum link dimension: ", max_link_dim)
```
