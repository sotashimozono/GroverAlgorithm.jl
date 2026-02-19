# Measurements

量子状態の測定を抽象化し、様々な測定手法を統一的なインターフェースで提供します。

## Abstract Type

```@docs
AbstractMeasurement
```

## Measurement Types

### ExpectationValue

```@docs
ExpectationValue
measure(::MPS, ::ExpectationValue)
```

#### 使用例

```julia
using ITensors, ITensorMPS

# 回路を実行
circuit = QuantumCircuit(2, AbstractQuantumGate[])
add_gate!(circuit, SingleQubitGate(1, :H))
sites = siteinds("Qubit", 2)
psi = execute_circuit(circuit, sites)

# 単一量子ビットの期待値測定
z_exp = measure(psi, ExpectationValue(:Z, [1]))
println("⟨Z₁⟩ = ", z_exp)

# X演算子の期待値
x_exp = measure(psi, ExpectationValue(:X, [1]))
println("⟨X₁⟩ = ", x_exp)

# 複数量子ビット（各ビットの平均）
multi_exp = measure(psi, ExpectationValue(:Z, [1, 2]))
```

#### 対応演算子

- Pauli演算子: `:X`, `:Y`, `:Z`
- スピン演算子: `:Sx`, `:Sy`, `:Sz`, `:S+`, `:S-`
- その他のITensors対応演算子

### Sampling

```@docs
Sampling
measure(::MPS, ::Sampling)
```

#### 使用例

```julia
# Bell状態の作成
circuit = QuantumCircuit(2, AbstractQuantumGate[])
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))

sites = siteinds("Qubit", 2)
psi = execute_circuit(circuit, sites)

# 1000回サンプリング
counts = measure(psi, Sampling(1000))

# 結果の表示
for (state, count) in sort(collect(counts))
    probability = count / 1000
    println("|$state⟩: $count 回 ($(round(probability*100, digits=1))%)")
end

# 期待される出力:
# |00⟩: ~500回 (50.0%)
# |11⟩: ~500回 (50.0%)
```

#### サンプリング結果の解析

```julia
# 最も頻繁に観測された状態
most_common = argmax(counts)
println("Most common state: |$most_common⟩")

# エントロピーの計算
total = sum(values(counts))
entropy = 0.0
for count in values(counts)
    p = count / total
    if p > 0
        entropy -= p * log2(p)
    end
end
println("Entropy: $entropy bits")
```

### ProjectiveMeasurement

```@docs
ProjectiveMeasurement
measure(::MPS, ::ProjectiveMeasurement)
```

#### 使用例

```julia
# 重ね合わせ状態の作成
circuit = QuantumCircuit(2, AbstractQuantumGate[])
add_gate!(circuit, SingleQubitGate(1, :H))
sites = siteinds("Qubit", 2)
psi = execute_circuit(circuit, sites)

# 量子ビット1を測定
outcome, collapsed_state = measure(psi, ProjectiveMeasurement(1))

println("Measured outcome: ", outcome)  # 0 または 1
# collapsed_stateは測定後の状態
```

#### 連続測定

```julia
# 複数の量子ビットを順次測定
psi = execute_circuit(circuit, sites)

# 最初の量子ビットを測定
outcome1, psi = measure(psi, ProjectiveMeasurement(1))

# 2番目の量子ビットを測定
outcome2, psi = measure(psi, ProjectiveMeasurement(2))

println("Final measurement: |$(outcome1)$(outcome2)⟩")
```

## 測定の組み合わせ例

### トモグラフィー的測定

```julia
# Pauli演算子の期待値をすべて測定
circuit = QuantumCircuit(1, AbstractQuantumGate[])
add_gate!(circuit, ParametricSingleGate(1, :Ry, [π/4]))
sites = siteinds("Qubit", 1)
psi = execute_circuit(circuit, sites)

x_exp = measure(psi, ExpectationValue(:X, [1]))
y_exp = measure(psi, ExpectationValue(:Y, [1]))
z_exp = measure(psi, ExpectationValue(:Z, [1]))

println("Bloch vector: ($(x_exp), $(y_exp), $(z_exp))")
```

### サンプリングと期待値の比較

```julia
# サンプリングから期待値を推定
counts = measure(psi, Sampling(10000))
total = sum(values(counts))

# |1⟩の確率からZ期待値を推定
p1 = get(counts, "1", 0) / total
z_sampled = 1 - 2*p1

# 直接計算との比較
z_exact = measure(psi, ExpectationValue(:Z, [1]))

println("Z (sampled): $z_sampled")
println("Z (exact):   $z_exact")
```

## エラーハンドリング

```julia
sites = siteinds("Qubit", 2)
psi = MPS(sites, ["0", "0"])

# 範囲外の量子ビット → ArgumentError
try
    measure(psi, ExpectationValue(:Z, [3]))
catch e
    println("Error: ", e)
end

# 負のショット数 → ArgumentError
try
    Sampling(-100)
catch e
    println("Error: ", e)
end

# 空の量子ビットリスト → ArgumentError
try
    measure(psi, ExpectationValue(:Z, Int[]))
catch e
    println("Error: ", e)
end
```

## 高度な使用例

### 量子状態の検証

```julia
# GHZ状態の作成
n = 3
circuit = QuantumCircuit(n, AbstractQuantumGate[])
add_gate!(circuit, SingleQubitGate(1, :H))
for i in 1:n-1
    add_gate!(circuit, ControlledGate(i, i+1, :CNOT))
end

sites = siteinds("Qubit", n)
psi = execute_circuit(circuit, sites)

# サンプリングで検証
counts = measure(psi, Sampling(1000))
println("GHZ state measurement results:")
for (state, count) in sort(collect(counts))
    println("  |$state⟩: $count")
end
# 期待: |000⟩ と |111⟩ のみが約50%ずつ
```

### 量子もつれの検証

```julia
# Bell状態での相関測定
circuit = QuantumCircuit(2, AbstractQuantumGate[])
add_gate!(circuit, SingleQubitGate(1, :H))
add_gate!(circuit, ControlledGate(1, 2, :CNOT))
sites = siteinds("Qubit", 2)
psi = execute_circuit(circuit, sites)

# 各量子ビットの個別測定
z1 = measure(psi, ExpectationValue(:Z, [1]))
z2 = measure(psi, ExpectationValue(:Z, [2]))

println("⟨Z₁⟩ = $z1")  # ≈ 0（重ね合わせ）
println("⟨Z₂⟩ = $z2")  # ≈ 0（重ね合わせ）

# サンプリングで相関を確認
counts = measure(psi, Sampling(1000))
# |00⟩ と |11⟩ のみが観測される（完全相関）
```
