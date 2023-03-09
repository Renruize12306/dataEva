include("../src/base_function.jl")

# schedule time to run
run_times = [
    DateTime("2023-03-09T13:23:00"),
    DateTime("2023-03-09T13:24:00"),
    ]

# The tickers to subscribe
Tickers = ["QQQ","SPY"]

# The event type to subscribe,
ets = ["A", "AM", "T", "Q"]

# the time interval to subscribe
tims= 10
# minutes = 60000
minutes = 600

start_group_functions(run_times, Tickers, ets, tims * minutes)