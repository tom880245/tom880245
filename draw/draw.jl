using CairoMakie,Statistics


struct PlotConfig
    title::String
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
    "Time for each bachsize ",                #title::String               
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


function Data_Draw(cfg::PlotConfig,ys::Union{Array{Float64}, Array{Int}},bachsize::Array,bach_lenght::Int; x::Union{Int, Float64, Array, Nothing}=nothing)
    if x==nothing
        x=1:1:length(ys[1])
    end
    #x2
    x2=x 
    y2=ys ./ bachsize.*bach_lenght

    #訂刻度
    function Auto_Ticks(find_extreme_val::Array)
        
    
        minimum(find_extreme_val/10)==floor(minimum(find_extreme_val)/10) && (maximum(find_extreme_val/10)==floor(maximum(find_extreme_val)/10) ;true) ||return  Int(floor(minimum(find_extreme_val)/10)*10):10:Int(ceil(maximum(find_extreme_val)/10)*10+10)
     
        
    
        return  Int(minimum(find_extreme_val/10)*10-10):10:Int(maximum(find_extreme_val/10)*10+10)
    end
    function Auto_Ticks(find_extreme_val::Union{Int, Float64})
        return  0:10:Int(ceil(find_extreme_val/10)*10)
    end
    #判斷是要前面還是後面標記
    function Extr_Value(y::Array)
        mean[Int(ceil(length(y)/2)):end] > (minimum(y) + maximum(y)) /2    || return "down"

        return "up"
     
    end
    #確認要畫幾個ax
    if cfg.ax==1
        else
            print("參數錯誤 $(cfg.ax) 不是 1")
        end
    end

    fig = Figure()
    #確認有幾個y

    ax1 = Axis(fig[1, 1], title = cfg.title, xlabel = cfg.xlabel, ylabel = cfg.ylabel, 
    subtitle=cfg.subtitle,
    titlecolor= cfg.titlecolor,
    titlesize= cfg.titlesize,
    
    subtitlecolor= cfg.subtitlecolor ,
    subtitlesize=cfg.subtitlesize ,
    xlabelcolor=cfg.xlabelcolor,
    xlabelsize=cfg.xlabelsize,
    ylabelcolor=cfg.ylabelcolor,
    ylabelsize=cfg.ylabelsize,
    
    xgridvisible =cfg.xgridvisible, 
    ygridvisible =cfg.ygridvisible,
    xgridcolor = cfg.xgridcolor, 
    ygridcolor = cfg.ygridcolor, 
    xgridstyle =cfg.xgridstyle, 
    ygridstyle = cfg.ygridstyle,
    ylabelrotation=cfg.ylabelrotation,
    #劃出刻度
    xticks =Auto_Ticks(x)
    yticks =Auto_Ticks(y))
    #上面是ax1

    #ax2
    ax1 = Axis(fig[1, 1], title = cfg.title, xlabel = cfg.xlabel, ylabel = cfg.ylabel, 
    subtitle=cfg.subtitle,
    titlecolor= cfg.titlecolor,
    titlesize= cfg.titlesize,
    
    subtitlecolor= cfg.subtitlecolor ,
    subtitlesize=cfg.subtitlesize ,
    xlabelcolor=cfg.xlabelcolor,
    xlabelsize=cfg.xlabelsize,
    ylabelcolor=cfg.ylabelcolor,
    ylabelsize=cfg.ylabelsize,
    
    xgridvisible =cfg.xgridvisible, 
    ygridvisible =cfg.ygridvisible,
    xgridcolor = cfg.xgridcolor, 
    ygridcolor = cfg.ygridcolor, 
    xgridstyle =cfg.xgridstyle, 
    ygridstyle = cfg.ygridstyle,
    ylabelrotation=cfg.ylabelrotation,
    #劃出刻度
    xticks =Auto_Ticks(x2)
    yticks =Auto_Ticks(y2))

    #剩餘部分

    lines_dict = Dict{String, Line}()
    lengend_dict=String[]
    for (index, y_draw) in enumerate(ys)
        key = "l" * string(index)
        lines_dict[key] = scatter!(ax1, x, y_draw, color = cfg.targetcolor[index])

        push!(lengend_dict,key)

        
    end
    lengend_title=cfg.lengendtitle[1:2]
  
    if Extr_Value(y)=="down"
        ymin=minimum(y)
        index_of_maximum_y = argmax(ymin)
        corresponding_x = x[index_of_maximum_y]
        y_min=scatter!([x[index_of_maximum_y]], y[index_of_maximum_y], color=:cfg.targetcolor[index], label="Mini Value", marker = :circle, markersize = 10)
        push!(lengend_dict,y_min)
        push!(lengend_title,"Mini Value")
        else
        ymax=maximum(y)
        index_of_maximum_y = argmax(ymax)
        corresponding_x = x[index_of_maximum_y]
        y_max=scatter!([x[index_of_maximum_y]], y[index_of_maximum_y], color=:cfg.targetcolor[index], label="Max Value", marker = :circle, markersize = 10)
        push!(lengend_dict,y_max)
        push!(lengend_dict,"Max Value")
        end
    end


    Legend(fig[1, 2], lengend_dict, lengend_title)
    

    return fig



end






[]
# 紅色：
# 基本：:red
# 深色：:darkred

# 橙色：
# 基本：:orange
# 深色：:darkorange

# 黃色：
# 基本：:yellow
# 深色：:goldenrod (這是接近深黃的顏色，因為沒有明確的"darkyellow")

# 綠色：
# 基本：:green
# 深色：:darkgreen

# 藍色：
# 基本：:blue
# 深色：:darkblue

# 靛色 (或藍綠色)：
# 基本：:cyan
# 深色：:darkcyan

# 紫色：
# 基本：:purple
# 深色：:darkpurple 或 :mediumpurple


# 灰色：
# 基本：:gray 或 :grey
# 深色：:darkgray 或 :darkgrey

# 黑色：
# 基本：:black
# （黑色本身已經是最深的顏色，所以通常沒有“深黑色”。但你可以用深灰來代表一種較不飽和的黑。）
# 除此之外，還有各種灰階值可以使用，例如:lightgray或:lightgrey會給你一個更淺的灰色。
