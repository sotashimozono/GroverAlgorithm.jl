"""
    get_involved_qubits(gate::AbstractQuantumGate) -> (Int, Int)

Returns the range of qubits that a gate visually occupies (min, max).
For gates like CNOT, this includes all qubits between control and target,
as the control line visually crosses intermediate qubits.
"""
function get_involved_qubits end

# for SingleQubitGate
function get_involved_qubits(gate::SingleQubitGate)
    return (gate.qubit, gate.qubit)
end

# for ParametricSingleGate
function get_involved_qubits(gate::ParametricSingleGate)
    return (gate.qubit, gate.qubit)
end

# for ControlledGate
function get_involved_qubits(gate::ControlledGate)
    q_min = min(gate.control, gate.target)
    q_max = max(gate.control, gate.target)
    return (q_min, q_max)
end

# for ParametricControlledGate
function get_involved_qubits(gate::ParametricControlledGate)
    q_min = min(gate.control, gate.target)
    q_max = max(gate.control, gate.target)
    return (q_min, q_max)
end

# for TwoQubitGate
function get_involved_qubits(gate::TwoQubitGate)
    q_min = min(gate.qubit1, gate.qubit2)
    q_max = max(gate.qubit1, gate.qubit2)
    return (q_min, q_max)
end

# for ParametricTwoQubitGate
function get_involved_qubits(gate::ParametricTwoQubitGate)
    q_min = min(gate.qubit1, gate.qubit2)
    q_max = max(gate.qubit1, gate.qubit2)
    return (q_min, q_max)
end

# for ThreeQubitGate
function get_involved_qubits(gate::ThreeQubitGate)
    qubits = [gate.qubit1, gate.qubit2, gate.qubit3]
    return (minimum(qubits), maximum(qubits))
end

# for FourQubitGate
function get_involved_qubits(gate::FourQubitGate)
    qubits = [gate.qubit1, gate.qubit2, gate.qubit3, gate.qubit4]
    return (minimum(qubits), maximum(qubits))
end

export get_involved_qubits

"""
    get_latex_commands(gate::AbstractQuantumGate, nqubits::Int) -> Vector{String}

Returns a vector of LaTeX commands for all qubits for the given gate.
The vector has length `nqubits`, where each element is the LaTeX command
for that qubit line (e.g., "\\gate{H}", "\\ctrl{2}", "\\qw", etc.).
"""
function get_latex_commands end

# for SingleQubitGate
function get_latex_commands(gate::SingleQubitGate, nqubits::Int)
    gate_symbol = gate_to_latex(gate.gate_type)
    commands = fill("\\qw", nqubits)
    commands[gate.qubit] = "\\gate{$gate_symbol}"
    return commands
end

# for ParametricSingleGate
function get_latex_commands(gate::ParametricSingleGate, nqubits::Int)
    gate_symbol = gate_to_latex(gate.gate_type, gate.params)
    commands = fill("\\qw", nqubits)
    commands[gate.qubit] = "\\gate{$gate_symbol}"
    return commands
end

# for ControlledGate
function get_latex_commands(gate::ControlledGate, nqubits::Int)
    ctrl = gate.control
    targ = gate.target
    offset = targ - ctrl
    target_symbol = controlled_gate_target(gate.gate_type)

    commands = fill("\\qw", nqubits)
    commands[ctrl] = "\\ctrl{$offset}"
    commands[targ] = target_symbol
    return commands
end

# for ParametricControlledGate
function get_latex_commands(gate::ParametricControlledGate, nqubits::Int)
    ctrl = gate.control
    targ = gate.target
    offset = targ - ctrl
    gate_symbol = gate_to_latex(gate.gate_type, gate.params)

    commands = fill("\\qw", nqubits)
    commands[ctrl] = "\\ctrl{$offset}"
    commands[targ] = "\\gate{$gate_symbol}"
    return commands
end

# for TwoQubitGate
function get_latex_commands(gate::TwoQubitGate, nqubits::Int)
    q1 = min(gate.qubit1, gate.qubit2)
    q2 = max(gate.qubit1, gate.qubit2)
    commands = fill("\\qw", nqubits)

    if gate.gate_type in [:SWAP, :Swap]
        commands[q1] = "\\swap{$(q2-q1)}"
        commands[q2] = "\\targX{}"
    elseif gate.gate_type in [
        Symbol("√SWAP"), Symbol("√Swap"), :iSWAP, :iSwap, Symbol("√iSWAP"), Symbol("√iSwap")
    ]
        gate_label = gate_to_latex(gate.gate_type)
        commands[q1] = "\\gate[2]{$gate_label}"
        commands[q2] = ""
    else
        gate_label = gate_to_latex(gate.gate_type)
        commands[q1] = "\\gate[2]{$gate_label}"
        commands[q2] = ""
    end
    return commands
end

# for ParametricTwoQubitGate
function get_latex_commands(gate::ParametricTwoQubitGate, nqubits::Int)
    q1 = min(gate.qubit1, gate.qubit2)
    q2 = max(gate.qubit1, gate.qubit2)
    gate_label = gate_to_latex(gate.gate_type, gate.params)

    commands = fill("\\qw", nqubits)
    commands[q1] = "\\gate[2]{$gate_label}"
    commands[q2] = ""
    return commands
end

# for ThreeQubitGate
function get_latex_commands(gate::ThreeQubitGate, nqubits::Int)
    qubits = sort([gate.qubit1, gate.qubit2, gate.qubit3])
    commands = fill("\\qw", nqubits)

    if gate.gate_type in [:Toffoli, :CCNOT, :CCX, :TOFF]
        # Toffoli: 最初の2つがコントロール、最後がターゲット
        ctrl1, ctrl2, targ = qubits
        commands[ctrl1] = "\\ctrl{$(ctrl2-ctrl1)}"
        commands[ctrl2] = "\\ctrl{$(targ-ctrl2)}"
        commands[targ] = "\\targ{}"
    elseif gate.gate_type in [:Fredkin, :CSWAP, :CSwap, :CS]
        # Fredkin: 最初がコントロール、後ろ2つがSWAP
        ctrl, swap1, swap2 = qubits
        commands[ctrl] = "\\ctrl{$(swap1-ctrl)}"
        commands[swap1] = "\\swap{$(swap2-swap1)}"
        commands[swap2] = "\\targX{}"
    else
        # デフォルト：3量子ビットゲートとして表示
        gate_label = gate_to_latex(gate.gate_type)
        commands[qubits[1]] = "\\gate[3]{$gate_label}"
        commands[qubits[2]] = ""
        commands[qubits[3]] = ""
    end
    return commands
end

# for FourQubitGate
function get_latex_commands(gate::FourQubitGate, nqubits::Int)
    qubits = sort([gate.qubit1, gate.qubit2, gate.qubit3, gate.qubit4])
    commands = fill("\\qw", nqubits)

    if gate.gate_type == :CCCNOT
        # CCCNOT: 最初の3つがコントロール、最後がターゲット
        ctrl1, ctrl2, ctrl3, targ = qubits
        commands[ctrl1] = "\\ctrl{$(ctrl2-ctrl1)}"
        commands[ctrl2] = "\\ctrl{$(ctrl3-ctrl2)}"
        commands[ctrl3] = "\\ctrl{$(targ-ctrl3)}"
        commands[targ] = "\\targ{}"
    else
        # デフォルト：4量子ビットゲートとして表示
        gate_label = gate_to_latex(gate.gate_type)
        commands[qubits[1]] = "\\gate[4]{$gate_label}"
        commands[qubits[2]] = ""
        commands[qubits[3]] = ""
        commands[qubits[4]] = ""
    end
    return commands
end

export get_latex_commands

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

# Default implementation using get_latex_commands
function add_gate_column!(qubit_lines, gate::AbstractQuantumGate, nqubits::Int)
    commands = get_latex_commands(gate, nqubits)
    for i in 1:nqubits
        push!(qubit_lines[i], commands[i])
    end
end

"""
    build_circuit_matrix_serial(circuit::QuantumCircuit) -> Vector{Vector{String}}

Builds the circuit representation using the serial layout (original behavior).
Each gate occupies its own column.
"""
function build_circuit_matrix_serial(circuit::QuantumCircuit)
    nqubits = circuit.nqubits
    qubit_lines = [String[] for _ in 1:nqubits]

    for gate in circuit.gates
        add_gate_column!(qubit_lines, gate, nqubits)
    end

    return qubit_lines
end

"""
    build_circuit_matrix_packed(circuit::QuantumCircuit) -> Vector{Vector{String}}

Builds the circuit representation using the packed layout.
Gates that don't interfere with each other are placed in the same column.
"""
function build_circuit_matrix_packed(circuit::QuantumCircuit)
    nqubits = circuit.nqubits
    # Track the current depth (column) for each qubit
    depths = zeros(Int, nqubits)
    # Store gates with their assigned column
    gate_assignments = Tuple{Int,AbstractQuantumGate}[]

    for gate in circuit.gates
        # Get the range of qubits this gate occupies
        q_min, q_max = get_involved_qubits(gate)

        # Find the maximum depth among the qubits this gate affects
        max_depth = maximum(depths[q_min:q_max])

        # Place this gate in the next column after max_depth
        target_column = max_depth + 1
        push!(gate_assignments, (target_column, gate))

        # Update the depths for all affected qubits
        depths[q_min:q_max] .= target_column
    end

    # Determine the total number of columns needed
    max_columns = maximum(depths)

    # Build the circuit matrix
    circuit_matrix = [String[] for _ in 1:nqubits]
    for i in 1:nqubits
        circuit_matrix[i] = fill("\\qw", max_columns)
    end

    # Place each gate in its assigned column
    for (col, gate) in gate_assignments
        commands = get_latex_commands(gate, nqubits)
        for i in 1:nqubits
            # Only overwrite if the command is not \\qw or we're placing something other than \\qw
            # Empty strings from multi-qubit gates should not be overwritten
            if commands[i] != "\\qw" || circuit_matrix[i][col] == "\\qw"
                circuit_matrix[i][col] = commands[i]
            end
        end
    end

    return circuit_matrix
end

"""
    to_quantikz(circuit::QuantumCircuit; layout::Symbol=:packed) -> String

Generates a complete LaTeX string wrapped in a `quantikz` environment.

# Arguments
- `circuit::QuantumCircuit`: The quantum circuit to visualize.
- `layout::Symbol`: Layout mode for the circuit.
  - `:serial` (or `:horizontal`): One gate per column (original behavior).
  - `:packed` (or `:parallel`, `:vertical`): Pack non-overlapping gates in the same column (default).

This function:
1. Iterates through all gates in the `circuit`.
2. Builds an internal representation of columns for each qubit.
3. Uses initial state labels from `circuit.initial_states` for qubit labels.
4. Joins the commands with `&` separators and wraps them in LaTeX boilerplate.

# Returns
- A `String` containing the full LaTeX source code.
"""
function to_quantikz(circuit::QuantumCircuit; layout::Symbol=:packed)::String
    nqubits = circuit.nqubits

    # Build circuit matrix based on layout mode
    if layout in [:serial, :horizontal]
        qubit_lines = build_circuit_matrix_serial(circuit)
    elseif layout in [:packed, :parallel, :vertical]
        qubit_lines = build_circuit_matrix_packed(circuit)
    else
        throw(ArgumentError("Unknown layout mode: $layout. Use :serial or :packed."))
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
    to_tikz_picture(circuit::QuantumCircuit; layout::Symbol=:packed) -> TikzPicture

Convert a `QuantumCircuit` object into a `TikzPicture` that represents the quantum circuit diagram using the `quantikz` LaTeX package.

# Arguments
- `circuit::QuantumCircuit`: The quantum circuit to visualize.
- `layout::Symbol`: Layout mode for the circuit.
  - `:serial` (or `:horizontal`): One gate per column (original behavior).
  - `:packed` (or `:parallel`, `:vertical`): Pack non-overlapping gates in the same column (default).

The function processes each gate in the circuit and constructs the corresponding LaTeX code for each qubit line, 
using initial state labels from `circuit.initial_states`, ensuring proper alignment and formatting for multi-qubit gates.
The resulting `TikzPicture` can be rendered in LaTeX documents to visualize the quantum circuit.
"""
function to_tikz_picture(circuit::QuantumCircuit; layout::Symbol=:packed)::TikzPicture
    nqubits = circuit.nqubits

    # Build circuit matrix based on layout mode
    if layout in [:serial, :horizontal]
        qubit_lines = build_circuit_matrix_serial(circuit)
    elseif layout in [:packed, :parallel, :vertical]
        qubit_lines = build_circuit_matrix_packed(circuit)
    else
        throw(ArgumentError("Unknown layout mode: $layout. Use :serial or :packed."))
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
