using GroverAlgorithm
using Documenter
using Downloads

using ITensors, ITensorMPS
using LaTeXStrings, TikzPictures

assets_dir = joinpath(@__DIR__, "src", "assets")
mkpath(assets_dir)
favicon_path = joinpath(assets_dir, "favicon.ico")
logo_path = joinpath(assets_dir, "logo.png")

Downloads.download("https://github.com/sotashimozono.png", favicon_path)
Downloads.download("https://github.com/sotashimozono.png", logo_path)

makedocs(;
    sitename="GroverAlgorithm.jl",
    format=Documenter.HTML(;
        canonical="https://codes.sota-shimozono.com/GroverAlgorithm.jl/stable/",
        prettyurls=get(ENV, "CI", "false") == "true",
        ansicolor=true,
        mathengine=MathJax3(
            Dict(
                :tex => Dict(
                    :inlineMath => [["\$", "\$"], ["\\(", "\\)"]],
                    :tags => "ams",
                    :packages => ["base", "ams", "autoload", "physics"],
                ),
            ),
        ),
        assets=["assets/favicon.ico", "assets/custom.css"],
        sidebar_sitename=true,
    ),
    modules=[GroverAlgorithm],
    pages=[
        "Home" => "index.md",
        "Getting Started" => "example/getting_started.md",
        "example" => ["toffoli" => "example/toffoli.md"],
        #"Core Concepts" => [
        #    "Quantum Gates and Circuits" => "structures.md",
        #    "Initial States" => "initialstates.md",
        #    "Measurements" => "measurements.md",
        #],
        #"Usage" => [
        #    "ITensor Conversion" => "itensor_conversion.md",
        #    "Quantikz Visualization" => "quantikz_visualization.md",
        #],
        #"Examples and Tutorials" => "examples.md",
        "API References" => [
            "structs" => [
                "qubit" => "api/core/qubit.md",
                "gates" => "api/core/gates.md",
                "measurement" => "api/core/measurement.md",
            ]
            "ITensors IO" => [
                "Get Gate" => "api/ITensorIO/get_gate.md",
                "Measurements" => "api/ITensorIO/measure.md",
            ]
            "Quantikz Visualization" => [
                "latex strings" => "api/QuantikzIO/latexstrings.md",
                "Quantikz Output" => "api/QuantikzIO/quantikz.md",
            ]
        ],
    ],
    checkdocs=:none,
)

deploydocs(; repo="github.com/sotashimozono/GroverAlgorithm.jl.git", devbranch="main")

