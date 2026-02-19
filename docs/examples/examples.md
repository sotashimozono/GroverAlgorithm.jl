# Examples and Tutorials

このページでは、GroverAlgorithm.jlを使用した実践的な例とチュートリアルを提供します。

## Toffoliゲートの生成と使用

Toffoliゲート（CCNOTとも呼ばれる）は、2つの制御量子ビットと1つのターゲット量子ビットを持つ3量子ビットゲートです。両方の制御ビットが|1⟩の場合のみ、ターゲットビットにNOTが適用されます。

### 基本的な生成方法

```julia
using GroverAlgorithm
using ITensors, ITensorMPS

# 3量子ビット回路を作成
circuit = QuantumCircuit(3, AbstractQuantumGate[])

# Toffoliゲートを追加
# qubit1とqubit2が制御、qubit3がターゲット
add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))

# 可視化
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

### 様々な初期状態でのToffoliゲート

#### ケース1: |000⟩ → |000⟩（制御ビットが両方とも0）

```julia
circuit = QuantumCircuit(3, AbstractQuantumGate[])
add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))

sites = siteinds("Qubit", 3)
psi = execute_circuit(circuit, sites)  # 初期状態 |000⟩

# 測定
counts = measure(psi, Sampling(100))
println("結果: ", counts)
# 出力: Dict("000" => 100)
# 制御ビットが両方とも0なので、何も起こらない
```

#### ケース2: |110⟩ → |111⟩（制御ビットが両方とも1）

```julia
# 初期状態を |110⟩ に設定
initial = AbstractInitialState[ProductState(["1", "1", "0"])]
circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)
add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))

sites = siteinds("Qubit", 3)
psi = execute_circuit(circuit, sites)

# 測定
counts = measure(psi, Sampling(100))
println("結果: ", counts)
# 出力: Dict("111" => 100)
# 制御ビットが両方とも1なので、ターゲットビットが反転
```

#### ケース3: |101⟩ → |101⟩（制御ビットの一方が0）

```julia
initial = AbstractInitialState[ProductState(["1", "0", "1"])]
circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)
add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))

sites = siteinds("Qubit", 3)
psi = execute_circuit(circuit, sites)

counts = measure(psi, Sampling(100))
println("結果: ", counts)
# 出力: Dict("101" => 100)
# 制御ビットの一方が0なので、何も起こらない
```

### 真理値表の検証

Toffoliゲートの真理値表を完全に検証する例：

```julia
using Printf

println("Toffoliゲートの真理値表検証")
println("=" ^ 50)
println("入力  |  出力")
println("-" ^ 50)

# すべての入力パターンをテスト
for a in 0:1, b in 0:1, c in 0:1
    # 初期状態を設定
    initial = AbstractInitialState[ProductState([string(a), string(b), string(c)])]
    circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)
    
    # Toffoliゲートを適用
    add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))
    
    # シミュレーション実行
    sites = siteinds("Qubit", 3)
    psi = execute_circuit(circuit, sites)
    
    # 結果を測定
    counts = measure(psi, Sampling(1))
    output = collect(keys(counts))[1]
    
    @printf("|%d%d%d⟩ → |%s⟩\n", a, b, c, output)
end
```

**出力:**
```
Toffoliゲートの真理値表検証
==================================================
入力  |  出力
--------------------------------------------------
|000⟩ → |000⟩
|001⟩ → |001⟩
|010⟩ → |010⟩
|011⟩ → |011⟩
|100⟩ → |100⟩
|101⟩ → |101⟩
|110⟩ → |111⟩  ← 制御ビットが両方とも1の場合のみ反転
|111⟩ → |110⟩  ← 制御ビットが両方とも1の場合のみ反転
```

### Toffoliゲートの応用例

#### 例1: 3ビット加算器の一部として

```julia
# 全加算器（Full Adder）の桁上げビット計算
# Carry = (A AND B) OR (Cin AND (A XOR B))

function add_full_adder!(circuit::QuantumCircuit, a::Int, b::Int, cin::Int, sum::Int, cout::Int)
    # 簡略化した実装（完全な加算器ではない）
    
    # A AND B の計算（Toffoliを使用）
    add_gate!(circuit, ThreeQubitGate(a, b, cout, :Toffoli))
    
    # その他のロジック（省略）
    return circuit
end

# 使用例
circuit = QuantumCircuit(5, AbstractQuantumGate[])
# qubit 1, 2: 入力A, B
# qubit 3: キャリー入力
# qubit 4: 和の出力
# qubit 5: キャリー出力
```

#### 例2: 可逆論理ゲートとしての使用

```julia
# Toffoliゲートは普遍的な可逆ゲート
# 古典的なANDゲートをエミュレート

function classical_and_gate(a::Int, b::Int)
    # 初期状態: |a⟩|b⟩|0⟩
    initial = AbstractInitialState[ProductState([string(a), string(b), "0"])]
    circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)
    
    # Toffoliゲート: ターゲットに A AND B が格納される
    add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))
    
    # 実行
    sites = siteinds("Qubit", 3)
    psi = execute_circuit(circuit, sites)
    
    # 3番目の量子ビット（ターゲット）を測定
    counts = measure(psi, Sampling(1))
    result = collect(keys(counts))[1]
    
    return parse(Int, result[3])  # 3番目のビットがAND結果
end

# テスト
println("古典ANDゲートのエミュレーション:")
for a in 0:1, b in 0:1
    result = classical_and_gate(a, b)
    println("$a AND $b = $result")
end
```

**出力:**
```
古典ANDゲートのエミュレーション:
0 AND 0 = 0
0 AND 1 = 0
1 AND 0 = 0
1 AND 1 = 1
```

#### 例3: 量子エラー訂正における使用

```julia
# ビットフリップエラーを検出するための症候群測定

function add_syndrome_measurement!(circuit::QuantumCircuit, data_qubits::Vector{Int}, ancilla::Int)
    # データ量子ビット間のパリティチェック
    for i in 1:length(data_qubits)-1
        # Toffoliではなく、この場合はCNOTを使用するが、
        # より複雑なエラー訂正ではToffoliが必要
        add_gate!(circuit, ControlledGate(data_qubits[i], ancilla, :CNOT))
        add_gate!(circuit, ControlledGate(data_qubits[i+1], ancilla, :CNOT))
    end
    return circuit
end
```

### 複数のToffoliゲートの組み合わせ

```julia
# 4ビット制御NOTゲート（C³NOT）をToffoliゲートで構築
# 補助量子ビットを使用

circuit = QuantumCircuit(5, AbstractQuantumGate[])

# qubit 1,2,3,4 が制御、qubit 5 がターゲット
# 補助量子ビットは不要（FourQubitGateを直接使用）
add_gate!(circuit, FourQubitGate(1, 2, 3, 4, :CCCNOT))

# 可視化
println(to_quantikz(circuit))
```

### Toffoliゲートのデバッグ方法

```julia
using Printf

function debug_toffoli_gate(initial_state::String)
    println("\n初期状態: |$initial_state⟩")
    println("-" ^ 40)
    
    # 回路を構築
    initial = AbstractInitialState[ProductState(collect(initial_state))]
    circuit = QuantumCircuit(3, AbstractQuantumGate[], initial)
    add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))
    
    # 実行前の状態
    sites = siteinds("Qubit", 3)
    psi_before = MPS(sites, collect(initial_state))
    
    # Toffoli適用後
    psi_after = execute_circuit(circuit, sites)
    
    # 各基底状態の確率振幅を表示
    println("ゲート適用後の確率振幅:")
    for s in ["000", "001", "010", "011", "100", "101", "110", "111"]
        basis_state = MPS(sites, collect(s))
        amplitude = inner(basis_state, psi_after)
        prob = abs2(amplitude)
        if prob > 1e-10
            @printf("  |%s⟩: 振幅 = %.4f, 確率 = %.4f\n", s, real(amplitude), prob)
        end
    end
end

# 様々な初期状態でデバッグ
debug_toffoli_gate("000")
debug_toffoli_gate("110")
debug_toffoli_gate("111")
```

### Toffoliゲートの分解

Toffoliゲートは、より基本的なゲート（CNOT、T、H、Tdag）に分解できます：

```julia
function decompose_toffoli!(circuit::QuantumCircuit, c1::Int, c2::Int, t::Int)
    # 標準的なToffoli分解
    add_gate!(circuit, SingleQubitGate(t, :H))
    add_gate!(circuit, ControlledGate(c2, t, :CNOT))
    add_gate!(circuit, SingleQubitGate(t, :Tdag))
    add_gate!(circuit, ControlledGate(c1, t, :CNOT))
    add_gate!(circuit, SingleQubitGate(t, :T))
    add_gate!(circuit, ControlledGate(c2, t, :CNOT))
    add_gate!(circuit, SingleQubitGate(t, :Tdag))
    add_gate!(circuit, ControlledGate(c1, t, :CNOT))
    add_gate!(circuit, SingleQubitGate(c2, :T))
    add_gate!(circuit, SingleQubitGate(t, :T))
    add_gate!(circuit, SingleQubitGate(t, :H))
    add_gate!(circuit, ControlledGate(c1, c2, :CNOT))
    add_gate!(circuit, SingleQubitGate(c1, :T))
    add_gate!(circuit, SingleQubitGate(c2, :Tdag))
    add_gate!(circuit, ControlledGate(c1, c2, :CNOT))
    
    return circuit
end

# 使用例
circuit_native = QuantumCircuit(3, AbstractQuantumGate[])
add_gate!(circuit_native, ThreeQubitGate(1, 2, 3, :Toffoli))

circuit_decomposed = QuantumCircuit(3, AbstractQuantumGate[])
decompose_toffoli!(circuit_decomposed, 1, 2, 3)

# 両方の回路が同じ動作をすることを確認
initial = AbstractInitialState[ProductState(["1", "1", "0"])]

# ネイティブToffoli
circuit1 = QuantumCircuit(3, AbstractQuantumGate[], initial)
add_gate!(circuit1, ThreeQubitGate(1, 2, 3, :Toffoli))
sites = siteinds("Qubit", 3)
psi1 = execute_circuit(circuit1, sites)

# 分解されたToffoli
circuit2 = QuantumCircuit(3, AbstractQuantumGate[], initial)
decompose_toffoli!(circuit2, 1, 2, 3)
psi2 = execute_circuit(circuit2, sites)

# 結果の比較
counts1 = measure(psi1, Sampling(100))
counts2 = measure(psi2, Sampling(100))
println("ネイティブToffoli: ", counts1)
println("分解Toffoli: ", counts2)
```

### 実践的な応用: 量子オラクル

Groverアルゴリズムでの使用例：

```julia
# 3ビットの解を持つオラクルの構築
# 解: |110⟩ のみをマーク

function create_grover_oracle_3bit!(circuit::QuantumCircuit)
    # ターゲット状態 |110⟩ をマークする
    
    # qubit 3 を反転（0→1）して、すべてが1になるようにする
    add_gate!(circuit, SingleQubitGate(3, :X))
    
    # 補助量子ビット4を使用してフェーズキックバック
    # |111⟩|−⟩ → -|111⟩|−⟩
    add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Toffoli))
    
    # qubit 3 を元に戻す
    add_gate!(circuit, SingleQubitGate(3, :X))
    
    return circuit
end

# 完全なGroverアルゴリズムの例
n = 3
circuit = QuantumCircuit(n, AbstractQuantumGate[])

# 1. 初期化（均等な重ね合わせ）
for i in 1:n
    add_gate!(circuit, SingleQubitGate(i, :H))
end

# 2. Grover反復
for iter in 1:2  # 最適な反復回数 ≈ π√(2^n)/4
    # オラクル
    create_grover_oracle_3bit!(circuit)
    
    # 拡散演算子（省略）
end

# 実行と測定
sites = siteinds("Qubit", n)
psi = execute_circuit(circuit, sites)
counts = measure(psi, Sampling(1000))

println("Groverアルゴリズムの結果:")
for (state, count) in sort(collect(counts), by=x->x[2], rev=true)
    println("  |$state⟩: $count 回")
end
```

## その他の多量子ビットゲートの例

### Fredkinゲート（制御SWAP）

```julia
# Fredkinゲート: qubit 1 が制御、qubit 2 と 3 をSWAP
circuit = QuantumCircuit(3, AbstractQuantumGate[])
add_gate!(circuit, ThreeQubitGate(1, 2, 3, :Fredkin))

# テスト: |1⟩|0⟩|1⟩ → |1⟩|1⟩|0⟩（SWAPされる）
initial = AbstractInitialState[ProductState(["1", "0", "1"])]
circuit_test = QuantumCircuit(3, AbstractQuantumGate[], initial)
add_gate!(circuit_test, ThreeQubitGate(1, 2, 3, :Fredkin))

sites = siteinds("Qubit", 3)
psi = execute_circuit(circuit_test, sites)
counts = measure(psi, Sampling(100))
println("Fredkin結果: ", counts)
# 出力: Dict("110" => 100)
```

### 4量子ビット制御ゲート

```julia
# C³NOT（3制御NOT）
circuit = QuantumCircuit(4, AbstractQuantumGate[])
add_gate!(circuit, FourQubitGate(1, 2, 3, 4, :CCCNOT))

# すべての制御ビットが1の場合のみ動作
initial = AbstractInitialState[ProductState(["1", "1", "1", "0"])]
circuit_test = QuantumCircuit(4, AbstractQuantumGate[], initial)
add_gate!(circuit_test, FourQubitGate(1, 2, 3, 4, :CCCNOT))

sites = siteinds("Qubit", 4)
psi = execute_circuit(circuit_test, sites)
counts = measure(psi, Sampling(100))
println("C³NOT結果: ", counts)
# 出力: Dict("1111" => 100)
```

## まとめ

Toffoliゲートは量子コンピューティングにおける重要な要素であり、以下の特徴があります：

1. **可逆性**: 2回適用すると元に戻る（T² = I）
2. **普遍性**: 古典的な計算を可逆的に実装可能
3. **量子性**: 重ね合わせ状態にも作用可能
4. **応用**: 量子アルゴリズム、エラー訂正、算術演算など

GroverAlgorithm.jlでは、`ThreeQubitGate(c1, c2, t, :Toffoli)`で簡単にToffoliゲートを生成でき、ITensors.jlとquantikzの両方で一貫した動作を提供します。
