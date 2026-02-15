
"""
    gate_to_latex(gate_type::Symbol) -> String
Convert a gate type symbol to its corresponding LaTeX string representation for visualization in quantum circuit diagrams.
Supported gate types include:
- Single-qubit gates: `:X`, `:Y`, `:Z`, `:H`, `:T`, `:S`, `:Phase`, `:P`, `:Proj0`, `:Proj1`, etc.
- Two-qubit gates: `:CNOT`, `:CY`, `:CZ`, `:CPHASE`, `:SWAP`, `:iSWAP`, etc.
- Three-qubit gates: `:Toffoli`, `:Fredkin`, etc.
- Four-qubit gates: `:CCCNOT`, etc.
If the gate type is not recognized, it returns the string representation of the symbol itself.
"""
function gate_to_latex(gate_type::Symbol)::String
    gate_map = Dict(
        # Pauli gates
        :X => "X", :Y => "Y", :Z => "Z", :iY => "iY",
        :σx => "\\sigma_x", :σ1 => "\\sigma_1",
        :σy => "\\sigma_y", :σ2 => "\\sigma_2",
        :σz => "\\sigma_z", :σ3 => "\\sigma_3",
        :iσy => "i\\sigma_y", :iσ2 => "i\\sigma_2",
        
        # Standard gates
        :H => "H",
        :T => "T", Symbol("π/8") => "T",
        :Tdag => "T^\\dagger",
        :S => "S", :Phase => "S", :P => "S",
        :Sdag => "S^\\dagger",
        Symbol("√NOT") => "\\sqrt{X}",
        
        # Projection operators
        :Proj0 => "P_0", :ProjUp => "P_{\\uparrow}", :projUp => "P_{\\uparrow}",
        :Proj1 => "P_1", :ProjDn => "P_{\\downarrow}", :projDn => "P_{\\downarrow}",

        # Parameterized gates
        :Rx => "R_x", :Ry => "R_y", :Rz => "R_z", :Rn => "R_n",
        :RX => "R_x", :RY => "R_y", :RZ => "R_z", :Rn̂ => "R_n",
        :Rxx => "R_{xx}", :Ryy => "R_{yy}", :Rzz => "R_{zz}",
        :RXX => "R_{xx}", :RYY => "R_{yy}", :RZZ => "R_{zz}",

        # Spin operators
        :Sz => "S_z", :Sᶻ => "S_z",
        :Sx => "S_x", :Sˣ => "S_x",
        :Sy => "S_y", :Sʸ => "S_y",
        :iSy => "iS_y", :iSʸ => "iS_y",
        Symbol("S+") => "S_+", Symbol("S⁺") => "S_+", :Splus => "S_+",
        Symbol("S-") => "S_-", Symbol("S⁻") => "S_-", :Sminus => "S_-",
        :S2 => "S^2", Symbol("S²") => "S^2",
        
        # Two-qubit gates (for controlled versions)
        :CNOT => "X", :CX => "X",
        :CY => "Y",
        :CZ => "Z",
        :CPHASE => "P", :Cphase => "P",
        
        # Two-qubit non-controlled
        :SWAP => "\\times", :Swap => "\\times",
        Symbol("√SWAP") => "\\sqrt{SWAP}", Symbol("√Swap") => "\\sqrt{SWAP}",
        :iSWAP => "iSWAP", :iSwap => "iSWAP",
        Symbol("√iSWAP") => "\\sqrt{iSWAP}", Symbol("√iSwap") => "\\sqrt{iSWAP}",
        
        # Three-qubit gates
        :Toffoli => "\\text{TOF}", :CCNOT => "\\text{TOF}", :CCX => "\\text{TOF}", :TOFF => "\\text{TOF}",
        :Fredkin => "\\text{FRDKN}", :CSWAP => "\\text{CSWAP}", :CSwap => "\\text{CSWAP}", :CS => "\\text{CS}",
        
        # Four-qubit gates
        :CCCNOT => "\\text{CCCNOT}",
    )
    
    return get(gate_map, gate_type, String(gate_type))
end

"""
    gate_to_latex(gate_type::Symbol, params::AbstractVector{<:Real}) -> String
Convert a parameterized gate type symbol and its parameters to a LaTeX string representation for visualization in quantum circuit diagrams.
Supported parameterized gate types include:
- Single-qubit rotation gates: `:Rx`, `:Ry`, `:Rz`, `:Rn`
- Controlled rotation gates: `:CRx`, `:CRy`, `:CRz`, `:CRn`
- Two-qubit rotation gates: `:Rxx`, `:Ryy`, `:Rzz`
- Phase gates: `:Phase`, `:P`, `:S`
If the gate type is not recognized, it returns the string representation of the symbol along with its parameters in parentheses.
"""
function gate_to_latex(gate_type::Symbol, params::AbstractVector{<:Real})::String
    if gate_type in [:Rx, :RX]
        return "R_x($(format_param(params[1])))"
    elseif gate_type in [:Ry, :RY]
        return "R_y($(format_param(params[1])))"
    elseif gate_type in [:Rz, :RZ]
        return "R_z($(format_param(params[1])))"
    elseif gate_type in [:Rn, :Rn̂]
        return "R_n($(format_param(params[1])), $(format_param(params[2])), $(format_param(params[3])))"
    elseif gate_type in [:CRx, :CRX]
        return "R_x($(format_param(params[1])))"
    elseif gate_type in [:CRy, :CRY]
        return "R_y($(format_param(params[1])))"
    elseif gate_type in [:CRz, :CRZ]
        return "R_z($(format_param(params[1])))"
    elseif gate_type in [:CRn, :CRn̂]
        return "R_n($(format_param(params[1])), $(format_param(params[2])), $(format_param(params[3])))"
    elseif gate_type in [:Rxx, :RXX]
        return "R_{xx}($(format_param(params[1])))"
    elseif gate_type in [:Ryy, :RYY]
        return "R_{yy}($(format_param(params[1])))"
    elseif gate_type in [:Rzz, :RZZ]
        return "R_{zz}($(format_param(params[1])))"
    elseif gate_type in [:Phase, :P, :S]
        return "P($(format_param(params[1])))"
    else
        return String(gate_type) * "($(join(format_param.(params), ", ")))"
    end
end
export gate_to_latex

"""
    format_param(θ::Real) -> String
Convert a rotation angle θ (in radians) to a LaTeX-friendly string representation.
- If θ is a multiple of π, it returns a string like "π", "2π", "-π", etc.
- If θ is a rational multiple of π (e.g., π/2, π/4), it returns a string like "π/2", "π/4", etc.
- For other values, it returns a decimal representation rounded to 3 decimal places.
"""
function format_param(θ::Real)::String
    # πの倍数かチェック
    ratio = θ / π
    if abs(ratio - round(ratio)) < 1e-6
        r = round(Int, ratio)
        if r == 0
            return "0"
        elseif r == 1
            return "\\pi"
        elseif r == -1
            return "-\\pi"
        else
            return "$(r)\\pi"
        end
    end
    
    # π/nの形式かチェック
    for n in 2:16
        if abs(θ * n - π * round(θ * n / π)) < 1e-6
            num = round(Int, θ * n / π)
            if num == 1
                return "\\pi/$n"
            elseif num == -1
                return "-\\pi/$n"
            else
                return "$(num)\\pi/$n"
            end
        end
    end
    # それ以外は小数表記
    return string(round(θ, digits=3))
end
export format_param

"""
    controlled_gate_target(gate_type::Symbol) -> String
Given a gate type symbol, return the appropriate LaTeX string for the target part of a controlled gate in a quantum circuit diagram.
- For `:X`, `:CNOT`, `:CX`, it returns `\\targ{}`.
- For `:Z`, `:CZ`, it returns `\\ctrl{0}`.
- For `:Y`, `:CY`, it returns `\\gate{Y}`.
- For `:CPHASE`, `:Cphase`, it returns `\\ctrl{0}`.
- For other gate types, it returns `\\gate{<LaTeX representation of the gate>}` using the `gate_to_latex` function.
"""
function controlled_gate_target(gate_type::Symbol)::String
    if gate_type in [:X, :CNOT, :CX]
        return "\\targ{}"
    elseif gate_type in [:Z, :CZ]
        return "\\ctrl{0}"
    elseif gate_type in [:Y, :CY]
        return "\\gate{Y}"
    elseif gate_type in [:CPHASE, :Cphase]
        return "\\ctrl{0}"
    else
        return "\\gate{$(gate_to_latex(gate_type))}"
    end
end
export controlled_gate_target
