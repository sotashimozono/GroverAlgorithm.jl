using GroverAlgorithm
using Documenter
using Downloads

assets_dir = joinpath(@__DIR__, "src", "assets")
mkpath(assets_dir)
favicon_path = joinpath(assets_dir, "favicon.ico")

Downloads.download("https://github.com/sotashimozono.png", favicon_path)

makedocs(;
    sitename="GroverAlgorithm.jl",
    format=Documenter.HTML(;
        canonical="https://codes.sota-shimozono.com/GroverAlgorithm.jl/stable/",
        prettyurls=get(ENV, "CI", "false") == "true",
        ansicolor=true,
        themes=["light", "dark"],
        mathengine=MathJax3(
            Dict(
                :tex => Dict(
                    :inlineMath => [["\$", "\$"], ["\\(", "\\)"]],
                    :tags => "ams",
                    :packages => ["base", "ams", "autoload", "physics"],
                ),
            ),
        ),
        assets=["assets/favicon.ico"],
    ),
    modules=[GroverAlgorithm],
    pages=[
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "Core Concepts" => [
            "Quantum Gates and Circuits" => "structures.md",
            "Initial States" => "initialstates.md",
            "Measurements" => "measurements.md",
        ],
        "Usage" => [
            "ITensor Conversion" => "itensor_conversion.md",
            "Quantikz Visualization" => "quantikz_visualization.md",
        ],
        "Examples and Tutorials" => "examples.md",
    ],
)

deploydocs(; repo="github.com/sotashimozono/GroverAlgorithm.jl.git", devbranch="main")
