module MortgageCalculators

export Mortgage
export monthly_payment, total_interest, months

struct Mortgage
    principal::Float64
    annual_interest_rate::Float64
    months::Int64
    Mortgage(principal, annual_interest_rate, months=360) =
        new(principal, annual_interest_rate, months)
end

function monthly_payment(principal, annual_interest_rate, months=360)
    monthly_interest_rate = annual_interest_rate/12
    compounding = (1 + monthly_interest_rate)^months
    # principal * monthly_interest_rate / ( 1 - (1 + monthly_interest_rate)^-months )
    principal * monthly_interest_rate * compounding / (compounding - 1)
end

function monthly_payment(m::Mortgage)
    monthly_payment(m.principal, m.annual_interest_rate, m.months)
end

function total_interest(m::Mortgage)
    monthly_payment(m) * m.months - m.principal
end

function total_interest(m::Mortgage, extra_payment)
    simulate_extra_payment(m::Mortgage, extra_payment)[1]
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

function Base.getindex(m::Mortgage, months::Integer)
    if months == 0
        return m
    end
    mortgage = m
    _monthly_payment = monthly_payment(m)
    monthly_interest_rate = m.annual_interest_rate / 12
    for month in 1:months
        mortgage = Mortgage(mortgage.principal - _monthly_payment + mortgage.principal * monthly_interest_rate, m.annual_interest_rate, mortgage.months - 1)
    end
    return mortgage
end

end
