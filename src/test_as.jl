using JSON, Dates
import HTTP.WebSockets as WSS

url = "wss://socket.polygon.io/stocks"
function instructions2json_string(instructions_tuple::Tuple)::String
    instructions_dict = Dict{Symbol, String}()
    instructions_dict[:action] = instructions_tuple[1]
    if length(instructions_tuple) == 2
        instructions_dict[:params] = instructions_tuple[2]
    else
        tickers = map(strip, split(instructions_tuple[3], ","))
        arr = map(x -> instructions_tuple[2] * "." * x, tickers)
        param_value = join(arr, ", ")
        instructions_dict[:params] = param_value
    end
    return JSON.json(instructions_dict)
end


function test_data(ticker::String, time)
    tuple_auth = ("auth", "");
    tuple_ticker = ("subscribe", "A", ticker);
    tuple_instructions = (tuple_auth, tuple_ticker);
    curDir = ""*"_$time"*"_$ticker"*".txt";
    io = open(curDir, "w");
    TIME = time
    WSS.open(url) do ws

        for tuple_single in tuple_instructions
            json_msg = instructions2json_string(tuple_single)
            WSS.send(ws, json_msg);
            println("Data Sent: ", json_msg)
        end
        time_before_store = Dates.value(now())
        while isopen(ws.io)
            # this part will receive message from websocket and save it to result Array
            received_data  = WSS.receive(ws)
            data = String(received_data)
            write(io, data*"\n");
            println("Data Rec: ", data)
            time_lasts = Dates.value(now())
            if time_lasts - time_before_store > TIME
                close(ws)
                break
            end
        end
    end

    close(io)
end

Tickers = ["TSLA", "META", "SPY", "QQQ"]


tims= [1, 2, 3, 4, 5, 9, 10, 20, 30, 40, 50]
second = 1000
for tim in tims 
    for Ticker in Tickers    
        test_data(Ticker, tim * second)
    end
end

tims= [1, 2, 3, 4, 5, 10, 15, 20, 25, 30, 50, 40, 60]
minutes = 60000

for tim in tims 
    for Ticker in Tickers    
        test_data(Ticker, tim * minutes)
    end
end