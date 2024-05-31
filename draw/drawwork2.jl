using StatsBase
using CairoMakie

struct PlotConfig
    title::String
    title_size::Int
    file_path::String
    basic_path::String
    colors::Vector{Symbol}
    result::String
    xlabel::String
    ylabel::String
    subtitle::String
    titlecolor::Symbol
    titlesize::Int
    ax::Int
    subtitlecolor::Symbol
    subtitlesize::Int
    xlabelcolor::Symbol
    xlabelsize::Int
    ylabelcolor::Symbol
    ylabelsize::Int
    
    xgridvisible::Bool
    ygridvisible::Bool
    xgridcolor::Symbol 
    ygridcolor::Symbol
    xgridstyle::Symbol
    ygridstyle::Symbol
    ylabelrotation::Int
    targetcolor::Tuple
    lengendtitle::Array
end

default_config = PlotConfig(
    "城鄉都審12月問題統計",                #title::String  
    25, 
    "1223.txt",                           #file_path
    "basic.txt" ,                          #bascic_path
    [:purple,:darkblue,:blue ,:darkgreen,:green,:yellow], # colors
    "0104.png",                                     #result
    "bachsize",                                       #xlabel::String
    "Time(s)",                                     # ylabel::String
    "10 epochs",              # subtitle::String
    :black,                                     #titlecolor::Symbol
    28,                                         # titlesize::Int
    1,                                           #ax::Int  基本上要是1
    :darkgray ,                                   #subtitlecolor= :darkgray ,
    18 ,                                      #subtitlesize= 18 ,
    :darkcyan,                                       #xlabelcolor=:darkcyan,
    20,                                       #xlabelsize=20,
    :darkcyan,                                       #ylabelcolor=:darkcyan,
    20,                                      #ylabelsize=20,
    true,                                     #xgridvisible = true, 
    true,                                    #ygridvisible = true,
    :gray,                                     #xgridcolor = :gray, 
    :gray,                                     #ygridcolor = :gray, 
    :dash,                                     #xgridstyle = :dash, 
    :dash,                                    #ygridstyle = :dash,
    0,                                   #ylabelrotation=0,
    (:red,:darkred,:orange,:darkorange,:yellow,:drakyellow) ,                # targetcolor   1
    ["10 epoch", "Full epoch"]              #lengendtitle
    
)




# 指定Excel文件的路径
file2 = "1223.txt"  # 資料路徑
file1 = "basic.txt"  # 基本路徑(各種類別)
colors=[:purple,:darkblue,:blue ,:darkgreen,:green,:yellow] # 紫~黃


function draw2pic(cfg::PlotConfig)
    # 读取第一个文件，将问题出现次数存储在字典1中
    problem_counts1 = Dict{String, Int}()
    open(cfg.file_path) do file
        for line in eachline(file)
            problem_counts1[line] = get(problem_counts1, line, 0) + 1
        end
    end
    # 读取第二个文件，将问题出现次数存储在字典2中
    problem_counts2 = Dict{String, Int}()
    open(cfg.basic_path) do file
        for line in eachline(file)
            problem_counts2[line] = get(problem_counts2, line, 0) + 1
        end
    end
    # 将字典1和字典2中的问题出现次数相加，存储在新字典中
    merged_problem_counts = merge(+, problem_counts1, problem_counts2)
    # 遍历新字典，将每个问题的出现次数减去1
    for (problem, count) in pairs(merged_problem_counts)
        merged_problem_counts[problem] = count - 1
    end
    sorted_problem_counts = sort(collect(merged_problem_counts), by=x->x[2], rev=true)
    problems = [x[1] for x in sorted_problem_counts]
    frequencies = [x[2] for x in sorted_problem_counts]
    fig = Figure()
    values_vector = collect(frequencies )
    value=maximum(frequencies)
    label_vector = collect(problems)
    colors=cfg.colors[1:length(frequencies)]
    colors_length=length(cfg.colors)
    ax = Axis(fig[1, 1],xticks=(1:colors_length,label_vector ),yticks=0:value,title=cfg.title,titlesize=cfg.title_size)
    barplot!(fig[1,1],values_vector,color=colors )
    fig
    CairoMakie.save(cfg.result, fig)



    

end

# instantiate   PlotConfig

plotConfig=PlotConfig()

draw2pic(plotConfig)

 
