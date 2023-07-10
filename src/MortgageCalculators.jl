module MortgageCalculators

using FixedPointDecimals
using UnicodePlots

export Mortgage
export principal, annual_interest_rate, monthly_payment
export total_interest, months, monthly_interest_rate
export one_time_payment, add_monthly_payment
export change

struct Mortgage{T}
    principal::T
    annual_interest_rate::Float64
    monthly_payment::T
    function Mortgage{T}(principal, annual_interest_rate, monthly_payment) where T
        new{T}(principal, annual_interest_rate, monthly_payment)
    end
end
function Mortgage{T}(principal, annual_interest_rate; monthly_payment=nothing, months=nothing) where T
    xor(isnothing(monthly_payment), isnothing(months)) ||
        ArgumentError("Exactly one keyword, monthly_payment or months, must be specified.") |> throw
    if isnothing(monthly_payment)
        Mortgage{T}(principal, annual_interest_rate, MortgageCalculators.monthly_payment(principal, annual_interest_rate, months))
    else
        Mortgage{T}(principal, annual_interest_rate, monthly_payment)
    end
end
Mortgage(args...; kwargs...) = Mortgage{FixedDecimal{Int,2}}(args...; kwargs...)

principal(m::Mortgage) = m.principal
annual_interest_rate(m::Mortgage) = m.annual_interest_rate
monthly_interest_rate(m::Mortgage) = annual_interest_rate(m) / 12
monthly_payment(m::Mortgage) = m.monthly_payment
add_monthly_payment(m::Mortgage{T}, payment) where T = Mortgage{T}(principal(m), annual_interest_rate(m), monthly_payment(m) + payment)

function months_float(m::Mortgage)
    # Order is important if we are used FixedDecimal, divide by float interest rate first
    ratio = monthly_payment(m)  / monthly_interest_rate(m) / principal(m)
    compounding = ratio/(ratio-1)
    months = log(compounding) / log(1 + monthly_interest_rate(m))
end

function months(m::Mortgage)
    return ceil(Int, months_float(m))
end

function monthly_payment(principal, annual_interest_rate, months=360)
    monthly_interest_rate = annual_interest_rate/12
    compounding = (1 + monthly_interest_rate)^months
    # principal * monthly_interest_rate / ( 1 - (1 + monthly_interest_rate)^-months )
    principal * monthly_interest_rate * compounding / (compounding - 1)
end


function total_interest(m::Mortgage{T}) where T
    T(monthly_payment(m) * months_float(m) - principal(m))
end

function total_interest(m::Mortgage{T}, extra_payment) where T
    T(simulate_extra_payment(m::Mortgage, extra_payment)[1])
end

function simulate_extra_payment(m::Mortgage, extra_payment)
    principal = m.principal
    monthly_interest_rate = m.annual_interest_rate / 12
    _monthly_payment = monthly_payment(m)
    _total_interest = 0
    months = 0
    while principal > 0
        months += 1
        monthly_interest = monthly_interest_rate * principal
        _total_interest += monthly_interest
        principal = principal - _monthly_payment - extra_payment + monthly_interest
    end
    return _total_interest, months
end

function months(m::Mortgage, extra_payment)
    simulate_extra_payment(m::Mortgage, extra_payment)[2]
end

one_time_payment(m::Mortgage{T}, payment) where T = Mortgage{T}(principal(m) - payment, annual_interest_rate(m), monthly_payment(m))

function Base.getindex(m::Mortgage{T}, months::Integer) where T
    if months == 0
        return m
    end
    mortgage = m
    _monthly_payment = monthly_payment(m)
    for month in 1:months
        mortgage = Mortgage{T}(mortgage.principal - _monthly_payment + mortgage.principal * monthly_interest_rate(m), m.annual_interest_rate, _monthly_payment)
    end
    return mortgage
end

function change(f, m::Mortgage, m2::Mortgage)
    f(m) - f(m2)
end

function UnicodePlots.lineplot(m::Mortgage{T}; x_max = months(m), y_max = 0) where T
    _principal = principal(m)
    monthly_interest_rate = m.annual_interest_rate / 12
    _monthly_payment = monthly_payment(m)
    _total_interest = 0
    _months = 0
    #principal_over_time = Vector{T}(undef, months(m))
    #total_interest_over_time = Vector{T}(undef, months(m))
    principal_over_time = T[]
    total_interest_over_time = T[]
    while _principal > 0
        _months += 1
        monthly_interest = convert(T, monthly_interest_rate * _principal)
        _total_interest += monthly_interest
        _principal = _principal - _monthly_payment + monthly_interest
        # principal_over_time[_months] = principal
        # total_interest_over_time[_months] = _total_interest
        push!(principal_over_time, _principal)
        push!(total_interest_over_time, _total_interest)
    end
    h = lineplot(1:length(principal_over_time), [principal_over_time total_interest_over_time], name = ["Principal" "Total interest"], labels = true, xlim=(0,x_max), ylim=(0,max(principal(m), _total_interest, y_max)), title="Mortgage. Total Interest: $_total_interest")
    principal_over_time, total_interest_over_time
    println(_months)
    h
end

function Base.show(io::IO, ::MIME"text/plain", m::Mortgage)
    show(io, typeof(m))
    println(":")
    println("           Principal: ", principal(m))
    println("Annual Interest Rate: ", annual_interest_rate(m)*100, "%")
    println("     Monthly Payment: ", monthly_payment(m))
    println("      Total Interest: ", total_interest(m))
end

end
