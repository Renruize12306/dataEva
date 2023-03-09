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

#=
    The opening 9:30 a.m. to 10:30 a.m. 
    Eastern time (ET) period is often one of the best hours of the day for day trading, 
    offering the biggest moves in the shortest amount of time.

    the stock market offers those most frequently in the hours after it opens, 
    from 9:30 a.m. to about noon ET, and then in the last hour of trading before the 
    close at 4 p.m. ET.

    The stock market is the most active market for day trading — particularly in the first 
    few hours and last hour of the trading day.
=# 