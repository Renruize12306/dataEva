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


function test_data(tickers::Array{String, 1}, time, v::Int, ets::Array{String, 1}, dt::DateTime)
    try
        ind = 1;
        mapping = Dict{String, Dict{String, Any}}()
        tuple_auth = ("auth", "t9aBscv_R5BGecynbrcTi7vnD5rSxt1I");
        instructions = Array{Tuple}([])
        push!(instructions, tuple_auth)
        for et in ets
            for ticker in tickers
                push!(instructions, ("subscribe", et, ticker))
                curDir = "\"" * pwd()*"/data/sv$(v)/$(dt)_$(et)_$(time)_$(ticker).txt\"";
                    eval(Meta.parse("io_$(et)_$(ticker) = open($(curDir), \"w\")"));
                if !(et in keys(mapping))
                    mapping[et] = Dict{String, Any}()
                end
                mapping[et][ticker] = eval(Meta.parse("io_$(et)_$(ticker)"));
            end
        end
        
        TIME = time
        WSS.open(url) do ws

            for instruction in instructions
                json_msg = instructions2json_string(instruction)
                WSS.send(ws, json_msg);
                println("Data Sent: ", json_msg)
            end
            time_before_store = Dates.value(now())
            while isopen(ws.io)
                # this part will receive message from websocket and save it to result Array
                received_data  = WSS.receive(ws)
                # ====================================================================
                data = String(received_data)
                for result_json in JSON.parse(data)
                    if ! ("status" in keys(result_json))
                        write(mapping[result_json["ev"]][result_json["sym"]], JSON.json(result_json)*"\n");
                    end
                end
                
                # ====================================================================
                println("$(ind) Data Rec : ", data)
                ind += 1
                time_lasts = Dates.value(now())
                if time_lasts - time_before_store > TIME
                    close(ws)
                    println("Finished Writing")
                    break
                end
            end
        end
        for et in ets
            for ticker in tickers
                close(mapping[et][ticker])
            end
        end
    catch ex
        println(ex)
        println(sprint(showerror, error, catch_backtrace()))
    end
end

function function_to_run_in_specific_time(time_until_run, Tickers, ets, interval)
    
    println("running in: ", time_until_run , " sec")
    sleep(time_until_run)
    test_data(Tickers, interval, 1, ets, now())

end

function start_group_functions(run_times, Tickers, ets, interval)
    for run_time in run_times
        time_until_run = Dates.value(run_time - now())/1000
        function_to_run_in_specific_time(time_until_run, Tickers, ets, interval)
    end
    println("\n================= Summary =================")
    println("Running times: ", run_times)
    println("Running tickers: ", Tickers)
    println("Running event types: ", ets)
    println("Running interval: ", interval, " sec")
end
