"""
    add_gate_column!(qubit_lines::Vector{Vector{String}}, gate::AbstractQuantumGate, nqubits::Int)
Adds a single "time slice" (column) of the given `gate` to all qubit lines in the circuit.
- `qubit_lines`: A vector of string vectors, where each sub-vector represents the sequence of LaTeX commands for a specific qubit.
- `gate`: The quantum gate object to be converted and added.
- `nqubits`: Total number of qubits in the circuit.

the function determines the type of the gate and appends the appropriate LaTeX command to the corresponding qubit lines:
- For the qubit(s) acted upon by the gate, appropriate LaTeX commands (like `\\gate`, `\\ctrl`, `\\targ`) are appended.
- For all other qubits, a wire command (`\\qw`) is appended to maintain column alignment across the circuit.
"""
function add_gate_column! end
export add_gate_column!

# for SingleQubitGate
function add_gate_column!(qubit_lines, gate::SingleQubitGate, nqubits::Int)
    gate_symbol = gate_to_latex(gate.gate_type)
    for i in 1:nqubits
        if i == gate.qubit
            push!(qubit_lines[i], "\\gate{$gate_symbol}")
        else
            push!(qubit_lines[i], "\\qw")
        end
    end
end

# for ParametricSingleGate
function add_gate_column!(qubit_lines, gate::ParametricSingleGate, nqubits::Int)
    gate_symbol = gate_to_latex(gate.gate_type, gate.params)

    for i in 1:nqubits
        if i == gate.qubit
            push!(qubit_lines[i], "\\gate{$gate_symbol}")
        else
            push!(qubit_lines[i], "\\qw")
        end
    end
end

# for ControlledGate
function add_gate_column!(qubit_lines, gate::ControlledGate, nqubits::Int)
    ctrl = gate.control
    targ = gate.target

    for i in 1:nqubits
        if i == ctrl
            offset = targ - ctrl
            push!(qubit_lines[i], "\\ctrl{$offset}")
        elseif i == targ
            target_symbol = controlled_gate_target(gate.gate_type)
            push!(qubit_lines[i], target_symbol)
        else
            push!(qubit_lines[i], "\\qw")
        end
    end
end

# for ParametricControlledGate
function add_gate_column!(qubit_lines, gate::ParametricControlledGate, nqubits::Int)
    ctrl = gate.control
    targ = gate.target
    gate_symbol = gate_to_latex(gate.gate_type, gate.params)

    for i in 1:nqubits
        if i == ctrl
            offset = targ - ctrl
            push!(qubit_lines[i], "\\ctrl{$offset}")
        elseif i == targ
            push!(qubit_lines[i], "\\gate{$gate_symbol}")
        else
            push!(qubit_lines[i], "\\qw")
        end
    end
end

# for TwoQubitGate
function add_gate_column!(qubit_lines, gate::TwoQubitGate, nqubits::Int)
    q1 = min(gate.qubit1, gate.qubit2)
    q2 = max(gate.qubit1, gate.qubit2)

    if gate.gate_type in [:SWAP, :Swap]
        for i in 1:nqubits
            if i == q1
                push!(qubit_lines[i], "\\swap{$(q2-q1)}")
            elseif i == q2
                push!(qubit_lines[i], "\\targX{}")
            else
                push!(qubit_lines[i], "\\qw")
            end
        end
    elseif gate.gate_type in [
        Symbol("√SWAP"), Symbol("√Swap"), :iSWAP, :iSwap, Symbol("√iSWAP"), Symbol("√iSwap")
    ]
        gate_label = gate_to_latex(gate.gate_type)
        for i in 1:nqubits
            if i == q1
                push!(qubit_lines[i], "\\gate[2]{$gate_label}")
            elseif i == q2
                push!(qubit_lines[i], "")
            else
                push!(qubit_lines[i], "\\qw")
            end
        end
    else
        gate_label = gate_to_latex(gate.gate_type)
        for i in 1:nqubits
            if i == q1
                push!(qubit_lines[i], "\\gate[2]{$gate_label}")
            elseif i == q2
                push!(qubit_lines[i], "")
            else
                push!(qubit_lines[i], "\\qw")
            end
        end
    end
end

# for ParametricTwoQubitGate
function add_gate_column!(qubit_lines, gate::ParametricTwoQubitGate, nqubits::Int)
    q1 = min(gate.qubit1, gate.qubit2)
    q2 = max(gate.qubit1, gate.qubit2)
    gate_label = gate_to_latex(gate.gate_type, gate.params)

    for i in 1:nqubits
        if i == q1
            push!(qubit_lines[i], "\\gate[2]{$gate_label}")
        elseif i == q2
            push!(qubit_lines[i], "")
        else
            push!(qubit_lines[i], "\\qw")
        end
    end
end

# for ThreeQubitGate
function add_gate_column!(qubit_lines, gate::ThreeQubitGate, nqubits::Int)
    qubits = sort([gate.qubit1, gate.qubit2, gate.qubit3])

    if gate.gate_type in [:Toffoli, :CCNOT, :CCX, :TOFF]
        # Toffoli: 最初の2つがコントロール、最後がターゲット
        ctrl1, ctrl2, targ = qubits
        for i in 1:nqubits
            if i == ctrl1
                push!(qubit_lines[i], "\\ctrl{$(ctrl2-ctrl1)}")
            elseif i == ctrl2
                push!(qubit_lines[i], "\\ctrl{$(targ-ctrl2)}")
            elseif i == targ
                push!(qubit_lines[i], "\\targ{}")
            else
                push!(qubit_lines[i], "\\qw")
            end
        end
    elseif gate.gate_type in [:Fredkin, :CSWAP, :CSwap, :CS]
        # Fredkin: 最初がコントロール、後ろ2つがSWAP
        ctrl, swap1, swap2 = qubits
        for i in 1:nqubits
            if i == ctrl
                push!(qubit_lines[i], "\\ctrl{$(swap1-ctrl)}")
            elseif i == swap1
                push!(qubit_lines[i], "\\swap{$(swap2-swap1)}")
            elseif i == swap2
                push!(qubit_lines[i], "\\targX{}")
            else
                push!(qubit_lines[i], "\\qw")
            end
        end
    else
        # デフォルト：3量子ビットゲートとして表示
        gate_label = gate_to_latex(gate.gate_type)
        for i in 1:nqubits
            if i == qubits[1]
                push!(qubit_lines[i], "\\gate[3]{$gate_label}")
            elseif i in qubits[2:3]
                push!(qubit_lines[i], "")
            else
                push!(qubit_lines[i], "\\qw")
            end
        end
    end
end

# for FourQubitGate
function add_gate_column!(qubit_lines, gate::FourQubitGate, nqubits::Int)
    qubits = sort([gate.qubit1, gate.qubit2, gate.qubit3, gate.qubit4])

    if gate.gate_type == :CCCNOT
        # CCCNOT: 最初の3つがコントロール、最後がターゲット
        ctrl1, ctrl2, ctrl3, targ = qubits
        for i in 1:nqubits
            if i == ctrl1
                push!(qubit_lines[i], "\\ctrl{$(ctrl2-ctrl1)}")
            elseif i == ctrl2
                push!(qubit_lines[i], "\\ctrl{$(ctrl3-ctrl2)}")
            elseif i == ctrl3
                push!(qubit_lines[i], "\\ctrl{$(targ-ctrl3)}")
            elseif i == targ
                push!(qubit_lines[i], "\\targ{}")
            else
                push!(qubit_lines[i], "\\qw")
            end
        end
    else
        # デフォルト：4量子ビットゲートとして表示
        gate_label = gate_to_latex(gate.gate_type)
        for i in 1:nqubits
            if i == qubits[1]
                push!(qubit_lines[i], "\\gate[4]{$gate_label}")
            elseif i in qubits[2:4]
                push!(qubit_lines[i], "")
            else
                push!(qubit_lines[i], "\\qw")
            end
        end
    end
end

"""
    to_quantikz(circuit::QuantumCircuit) -> String

Generates a complete LaTeX string wrapped in a `quantikz` environment.

This function:
1. Iterates through all gates in the `circuit`.
2. Builds an internal representation of columns for each qubit.
3. Uses initial state labels from `circuit.initial_states` for qubit labels.
4. Joins the commands with `&` separators and wraps them in LaTeX boilerplate.

# Returns
- A `String` containing the full LaTeX source code.
"""
function to_quantikz(circuit::QuantumCircuit)::String
    nqubits = circuit.nqubits
    qubit_lines = [String[] for _ in 1:nqubits]

    for gate in circuit.gates
        add_gate_column!(qubit_lines, gate, nqubits)
    end

    lines = []
    push!(lines, "\\begin{quantikz}")
    for i in 1:nqubits
        # Get the label for this qubit from initial_states
        if length(circuit.initial_states) == 1
            # Single state for all qubits
            label = to_latex_label(circuit.initial_states[1], i)
        else
            # Individual state for each qubit
            if i <= length(circuit.initial_states)
                label = to_latex_label(circuit.initial_states[i], i)
            else
                # Fallback to default
                label = "\\ket{q_$i}"
            end
        end
        
        # 空文字列をフィルタ（マルチ量子ビットゲートのスパン部分）
        filtered = filter(s -> s != "", qubit_lines[i])
        line = join(filtered, " & ")
        push!(lines, "\\lstick{$label} & " * line * " & \\qw")
    end
    quantikz_code = join(lines, " \\\\\n")
    quantikz_code *= "\n\\end{quantikz}"

    return quantikz_code
end
export to_quantikz

"""
    to_tikz_picture(circuit::QuantumCircuit) -> TikzPicture

Convert a `QuantumCircuit` object into a `TikzPicture` that represents the quantum circuit diagram using the `quantikz` LaTeX package.
The function processes each gate in the circuit and constructs the corresponding LaTeX code for each qubit line, 
using initial state labels from `circuit.initial_states`, ensuring proper alignment and formatting for multi-qubit gates.
The resulting `TikzPicture` can be rendered in LaTeX documents to visualize the quantum circuit.
"""
function to_tikz_picture(circuit::QuantumCircuit)::TikzPicture
    nqubits = circuit.nqubits
    qubit_lines = [String[] for _ in 1:nqubits]

    for gate in circuit.gates
        add_gate_column!(qubit_lines, gate, nqubits)
    end

    processed_lines = []
    for i in 1:nqubits
        # Get the label for this qubit from initial_states
        if length(circuit.initial_states) == 1
            # Single state for all qubits
            label = to_latex_label(circuit.initial_states[1], i)
        else
            # Individual state for each qubit
            if i <= length(circuit.initial_states)
                label = to_latex_label(circuit.initial_states[i], i)
            else
                # Fallback to default
                label = "\\ket{q_$i}"
            end
        end
        
        filtered = filter(s -> s != "", qubit_lines[i])
        line_data = join(filtered, " \\& ")
        push!(processed_lines, "\\lstick{$label} \\& " * line_data * " \\& \\qw")
    end

    circuit_body = join(processed_lines, " \\\\\n")

    return TikzPicture(
        circuit_body;
        preamble="\\usepackage{quantikz}",
        options="ampersand replacement=\\&",
        environment="quantikz",
    )
end
export to_tikz_picture
