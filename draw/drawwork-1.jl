
# 指定Excel文件的路径
file_path = "1223.txt"
file = open(file_path, "r")
a::Vector{String} = []
# 逐行读取文件内容
for line in eachline(file)
    println(line)
    push!(a,String(line))
end

# 关闭文件
close(file)
using StatsBase
using CairoMakie



# 计算问题的频率
problem_counts = countmap(a)
sorted_problem_counts = sort(collect(problem_counts), by=x->x[2], rev=true)


problems = [x[1] for x in sorted_problem_counts]
frequencies = [x[2] for x in sorted_problem_counts]
# fig = Figure()

# # barplot(c)

# values_vector = collect(frequencies )
# label_vector = collect(problems)
# value=maximum(frequencies)
# ax = Axis(fig[1, 1],xticks=(1:5,label_vector ),yticks=0:value,title="城鄉都審12月問題統計",titlesize=25,titlefont ="Arial")
# #colors=[:green,:darkgreen,:blue ,:darkblue,:purple]
# colors=[:purple,:darkblue,:blue ,:darkgreen,:green,:yellow]
# colors=colors[1:length(frequencies)]
# barplot!(fig[1,1],values_vector,color=colors )
# fig
# CairoMakie.save("122502test.png", fig)
# 添加标题

# fig = Figure()
# ax = Axis(fig[1, 1],xticks=(1:5,d),yticks=0:8,title="12月問題統計",titlesize=20)
# barplot!(fig[1,1],values_vector,color=colors )
# CairoMakie.save("test.png", fig)
 # 设置X轴刻度
  # 设置Y轴刻度



#加上基本文件


# 读取第一个文件，将问题出现次数存储在字典1中
file1 = "basic.txt"  # 替换为第一个文件的路径
problem_counts1 = Dict{String, Int}()
open(file1) do file
    for line in eachline(file)
        problem_counts1[line] = get(problem_counts1, line, 0) + 1
    end
end

# 读取第二个文件，将问题出现次数存储在字典2中
file2 = "1223.txt"  # 替换为第二个文件的路径
problem_counts2 = Dict{String, Int}()
open(file2) do file
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

# barplot(c)

values_vector = collect(frequencies )
label_vector = collect(problems)
value=maximum(frequencies)
ax = Axis(fig[1, 1],xticks=(1:6,label_vector ),yticks=0:value,title="城鄉都審12月問題統計",titlesize=25)
#colors=[:green,:darkgreen,:blue ,:darkblue,:purple]
colors=[:purple,:darkblue,:blue ,:darkgreen,:green,:yellow]
colors=colors[1:length(frequencies)]
barplot!(fig[1,1],values_vector,color=colors )
fig
CairoMakie.save("122502test.png", fig)