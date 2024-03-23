using DifferentialEquations

#u = [s(t), I(t), R(t)]
function sirModel!(du, u, p, t)
    beta, gamma, N = p

    du[1] = -(beta * u[1] * u[2]) / N

    du[2] = ((beta * u[1] * u[2]) / N) - (gamma * u[2])

    du[3] = gamma * u[2]
end


# Boundary conditions
N = 1000
i0 = 1
r0 = 0
s0 = (N - i0 - r0)

u0 = [s0, i0, r0]
# constants
beta = 0.3
gamma = 0.1

p = (beta, gamma, N)

# time duration
tspan = (0.0, 160.0)

# Solving the ODE solution
problem = ODEProblem(sirModel!, u0, tspan, p)
sol = solve(problem)

using Plots
# Generate the animation
frame_duration = 0.5  # Duration for each frame in seconds
frames_per_step = 5  # Number of frames per time step
total_frames = length(sol.t) * frames_per_step

@gif for t_step in 1:length(sol.t)
    t = sol.t[t_step]
    infected_population = sol(t)[1]  # Extract infected population at time t

    # Plot frames_per_step frames for each time step
    for frame in 1:frames_per_step
        plot(sol.t[1:t_step], [sol(t)[1] for t in sol.t[1:t_step]], xlabel="Time", ylabel="Infected Population", title="Infected Population over Time", legend=false)

        frame == frames_per_step && sleep(frame_duration)  # Pause at the last frame of each time step
    end
end

# Save the animation as a gif
gif("Infected_Population_Animation.gif")

