using MortageCalculators
using Documenter

DocMeta.setdocmeta!(MortageCalculators, :DocTestSetup, :(using MortageCalculators); recursive=true)

makedocs(;
    modules=[MortageCalculators],
    authors="Mark Kittisopikul <markkitt@gmail.com> and contributors",
    repo="https://github.com/mkitti/MortageCalculators.jl/blob/{commit}{path}#{line}",
    sitename="MortageCalculators.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mkitti.github.io/MortageCalculators.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mkitti/MortageCalculators.jl",
    devbranch="main",
)
