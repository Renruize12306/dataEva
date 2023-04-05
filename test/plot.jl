using Base, Plots, Dates

function make_cur_entry(filename, file, dict)
    # Get the file statistics
    st = stat(filename)
    arr = split(file, "_")
    # Print out the file size and permissions
    if size(arr)[1] >=3
        file_name = file
        type = string(arr[2])
        ticker_txt = string(arr[4])
        ticker = replace(ticker_txt, ".txt" => "")
        dt = DateTime(string(arr[1]))
        time = hour(dt) + minute(dt)/60
        sz = (st.size)/ 1024
        println("File: $file_name\t", ticker, "\tTime: ",  time,"\tSize: $(sz) K bytes")
        if haskey(dict, ticker) == false
            dict[ticker] = Dict{Any, Any}()
        end
        if haskey(dict[ticker], type) == false
            dict[ticker][type] = Vector{Vector{Any}}()
            push!(dict[ticker][type], Vector{Any}())
            push!(dict[ticker][type], Vector{Any}())
        end
        push!( dict[ticker][type][1], time)
        push!( dict[ticker][type][2], sz)
    end
end

function plot_dict(dict, folder_name)
    for (dict_key, dict_val) in dict
        ticker = dict_key # QQQ, SPY
        for (dict_val_key, dict_val_val) in dict_val
            type = dict_val_key # A, AM, Q, T
            value = dict_val_val # TIME - SIZE series
            
            
            x_array = value[1]
            y_array = value[2]


            scatter(x_array, y_array, label="Data Size", mc=:white, msc=colorant"#EF4035", legend=:best, 
            bg="floralwhite", background_color_outside="white", framestyle=:box, fg_legend=:transparent, lw=3)
            xlabel!("Hours", fontsize=18)
            ylabel!("Data size with 10 minutes window (Kb)", fontsize=18)
            savefig("data/$(folder_name)/$(ticker)_$(type)_fig.pdf")
        end
    end
end

function exec(curDir)
    dict = Dict{Any, Any}()
    folder_name = "size_time_statis"

    mkdir("data/$(folder_name)")
    
    for file in readdir(pwd()*curDir)
        f_dir = pwd()*curDir*"/"*file
        make_cur_entry(f_dir, file, dict)
    end
    plot_dict(dict, folder_name)
end

exec("/data/sv2")