using OrdinaryDiffEq, ModelingToolkit, MethodOfLines, DomainSets
@parameters t, x
@variables psi(..)

Dt = Differential(t)
Dxx = Differential(x)^2

xmin = 0
xmax = 1

V(x) = 0.0

eq = [im * Dt(psi(t, x)) ~ Dxx(psi(t, x)) + V(x) * psi(t, x)] # You must enclose complex equations in a vector, even if there is only one equation

psi0 = x -> sin(2pi * x)

bcs = [psi(0, x) ~ psi0(x),
    psi(t, xmin) ~ 0,
    psi(t, xmax) ~ 0]

domains = [t ∈ Interval(0, 1), x ∈ Interval(xmin, xmax)]

@named sys = PDESystem(eq, bcs, domains, [t, x], [psi(t, x)])

disc = MOLFiniteDifference([x => 100], t)

prob = discretize(sys, disc)
sol = solve(prob, TRBDF2(), saveat=0.01)

discx = sol[x]
disct = sol[t]
sol[psi(t, x)]
using Plots

discPsi = sol[psi(t, x)]
anim = @animate for i in 1:length(disct)
    u = discPsi[i, :]
    plot(discx, [real.(u), imag.(u)], ylim=(-1.5, 1.5), title="t = $(disct[i])", xlabel="x", ylabel="psi(t,x)", label=["re(psi)" "im(psi)"], legend=:topleft)
end

gif(anim, "schroedinger.gif", fps=10)




