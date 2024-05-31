# import Pkg; Pkg.add("Encoding")
# using Encoding

struct PlotConfig
    dic::Dict{String, String}

end

default_config = PlotConfig(
     Dict(
    "参" => "參",
    "样" => "樣",
    "兴" => "興",
    "叁" => "參"
)                #Dict::Dict{String, String}
)


cd(joinpath(@__DIR__,".."))

#run(`dir \/b \/on \> C:\\Users\\Administrator\\Desktop\\test\\list.txt`)
#run(`/bin/bash -c 'echo "Hello, world!"'`)
#run(`echo hello`)
run(`cmd /C chcp 950 `)
sleep(1)
#run(`cmd /C for %i in (\*.\*) do @echo %cd%\\%i \>\> .\\code\\list111.txt`)
#run(`cmd /C dir /b /on \> list.txt`)
run(`cmd /C dir /b /on \> .\\code\\list.txt`)
#cmd_output = read(`cmd /C dir /b /on`, String)

file_list = readlines(joinpath(@__DIR__,"list.txt"))



#用utf8編碼來測試

# 開啟 list3.txt 檔案，用來儲存不存在的檔案名稱
# open(joinpath(@__DIR__, "..","list.txt"), "w") do f
#     # 逐一檢查每個檔案名稱是否存在於該路徑下
#     for file in file_list
#         if isfile(joinpath(path, file))
#             println("$file exists")
#         else
#             println("$file missing")
#             println(f, file)
#         end
#     end
# end
#isascii("xbch")



#file = open(joinpath(@__DIR__, "..","list.txt"), "r")

 #content = readlines(file)
# 關閉文件
#close(file)
# test="\xbch"
# ascii(test)

indices = Int[]

for (index, line) in enumerate(file_list)
    if occursin(r"\?", line)
        push!(indices, index)
    elseif occursin(r"\ ", line)
        push!(indices, index)
    end
end

# 打印包含 "? " 的行的索引
#println(indices)

#run(`cmd /C chcp 65001 \& dir /b /on \> listutf8.txt`)
run(`cmd /C chcp 65001 `)
sleep(1)
run(`cmd /C dir /b /on \> .\\code\\listutf8.txt`)
file_list2 = readlines(joinpath(@__DIR__,"listutf8.txt"))
file_list3_path = joinpath(@__DIR__,"listfilenotfound.txt")

path=joinpath(@__DIR__,"..")
open(file_list3_path , "w") do f
    # 逐一檢查每個檔案名稱是否存在於該路徑下
    for file in file_list2
        if isfile(joinpath(path, file))
            #println("$file exists")
        else
            #println("$file missing")
            println(f, file)
        end
    end
end
file_list3=readlines(joinpath(@__DIR__,"listfilenotfound.txt"))
#找出有?的  記錄在list有問號中
#map(x -> file_list[x] ,indices)

#替換

#[file_list2[i] for i in indices  ]

result=map(x -> file_list2[x] ,indices)
json_file = default_config.dic
result2 =[]
for input_string in result
    # 对每个字符串应用替换规则
    for (key, value) in json_file
        input_string = replace(input_string, key => value)
    end
    # 将替换后的字符串添加到 result2 中
    push!(result2, input_string)
end

# 创建一个空的字典，用于存储行和其出现次数的对应关系
line_counts = Dict{String, Int}()

# 遍历 result 中的每个字符串
for line in file_list 
    # 将每行作为字典的键，如果存在则增加计数，否则初始化计数为1
    line_counts[line] = get(line_counts, line, 0) + 1
end


#ascii
println("ascii:")
a=map(x -> file_list[x] ,indices)
for i in a 
    println(i)
end


#檔案，用來儲存不存在的檔案名稱
# run(`cmd /C chcp 950 `)
# sleep(1)
# println("不存在的檔案名稱:")
# # for i in file_list
# #     if i!="code"
# #         run(`cmd /C dir /b /a-d $(i) \> nul 2\>\&1 \|\| echo $(i)`, wait = true)
# #     end
# # end

# run(`cmd /C dir /b /on \>  nul 2\>\&1 \|\| echo 111`, wait = true)


println("還有問題尚未排除")
for i in file_list3
    if i!="code"
        println(i)
    end
end

# 遍历字典，找出计数大于1的行
println("重複出現的:")
for (line, count) in line_counts
    if count > 1
        println("重複：$(line)，出现次数：$(count)")
    end
end

println("修正過的:")
for i in  result2
     println(i)
end

#抓出完整路徑
# run(`cmd /C chcp 950 `)
# sleep(1)
run(`cmd /C for %i in \(\*.\*\) do @echo %cd%%i \>\> .\\code\\listallpath.txt`)
#讀取完整路徑

#判斷是否存在
println("加上檔案不存在:")
for (index, element) in enumerate(file_list2)
    run(`cmd /C dir /b /a-d $(element) \> nul 2\>\&1 \|\| echo $(file_list2[index])`, wait = true)
end


#檢查該路徑有沒有檔案
# result = run(`cmd /C dir /b /a-d $(filename_to_check) \> nul 2\>\&1 \|\| echo $(filename_to_check)`, wait = true)





