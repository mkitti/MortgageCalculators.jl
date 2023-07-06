using MortgageCalculators
using Documenter

DocMeta.setdocmeta!(MortgageCalculators, :DocTestSetup, :(using MortgageCalculators); recursive=true)

makedocs(;
    modules=[MortgageCalculators],
    authors="Mark Kittisopikul <markkitt@gmail.com> and contributors",
    repo="https://github.com/mkitti/MortgageCalculators.jl/blob/{commit}{path}#{line}",
    sitename="MortgageCalculators.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mkitti.github.io/MortgageCalculators.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mkitti/MortgageCalculators.jl",
    devbranch="main",
)
