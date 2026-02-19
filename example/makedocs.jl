using Pkg
Pkg.activate("../")

using Literate, GroverAlgorithm, ITensors, ITensorMPS

base_dir = pkgdir(GroverAlgorithm)
output_dir = joinpath(base_dir, "docs", "src", "examples")
mkpath(output_dir)


Literate.markdown("toffoli.jl", output_dir; documenter= true)