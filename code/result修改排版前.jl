try
    using PyCall
catch
    println("PyCall is not installed. Installing...")
    import Pkg
    Pkg.add("PyCall")
    using PyCall
end

struct PlotConfig
    dic::Dict{String, String}

end

default_config = PlotConfig(
     Dict(
    "参" => "參",
    "样" => "樣",
    "兴" => "興",
    "叁" => "參",
    "趗" => "起",
    "⾯" => "面",
    "⼟" => "土",
    "⽤" => "用",
    "⼀" => "一",
    "⾄" =>"至",
    "⾨" =>"門",
    "剰" =>"剩",
    "亖"=>"三" ,
    "内"=>"內" ,
    "碱"=>"鹼" ,
    "説"=>"說" ,
    "Α" =>"A"

)  )

function contains_fullwidth_english(s::String)
    for char in s
        # Check if the character is in the range of full-width English characters
        if '\uff01' <= char <= '\uff5e'
            return println("$s  錯誤: 圖檔名稱有英文全形")
        end
    end
    return false
end


#讀取檔案寫成list
cd(joinpath(@__DIR__,".."))
run(`cmd /C chcp 950 `)
sleep(0.5)
run(`cmd /C dir /b /on \> .\\code\\list.txt`)
#讀取list
cd(joinpath(@__DIR__))
sleep(0.5)
py"""
def file_not_exit():
    import os 
    path = os.path.dirname(os.getcwd())
    with open('list.txt', 'r') as f:
        file_list = f.read().splitlines()
    with open('list2.txt', 'w') as f2:
        for file in file_list:
            if os.path.isfile(os.path.join(path, file)):
                pass
            else:
                f2.write(file + '\n')
"""

py"file_not_exit()"
sleep(0.5)
file_list = readlines(joinpath(@__DIR__,"list.txt"))
file_list_12=readlines(joinpath(@__DIR__,"list2.txt"))


# 有空白或?加入indices
indices = Int[]

for (index, line) in enumerate(file_list)
    if occursin(r"\?", line)
        push!(indices, index)
    elseif occursin(r"\ ", line)
        push!(indices, index)
    end
end

#生成listutf8.txt
run(`cmd /C chcp 65001 `)
cd(joinpath(@__DIR__,".."))
sleep(1)
run(`cmd /C dir /b /on \> .\\code\\listutf8.txt`)
file_list2 = readlines(joinpath(@__DIR__,"listutf8.txt"))

path=joinpath(@__DIR__,"..")

#抓取？ 空白 的 UTF8list
result=map(x -> file_list2[x] ,indices)
json_file = default_config.dic
result2 = []  # 存储修改过的字符串
result3 = []  # 存储应修改而未修改的字符串
for input_string in result
    original_string = input_string
    # 对每个字符串应用替换规则
    for (key, value) in json_file
        input_string = replace(input_string, key => value)
    end
    if input_string != original_string
        push!(result2, input_string)  # 有修改
    else
        push!(result3, original_string)  # 无修改
    end
end

# 创建一个空的字典，用于存储行和其出现次数的对应关系
line_counts = Dict{String, Int}()

# 遍历 result 中的每个字符串
for line in file_list 
    # 将每行作为字典的键，如果存在则增加计数，否则初始化计数为1
    line_counts[line] = get(line_counts, line, 0) + 1
end


# #ascii
# println("ascii:")
# a=map(x -> file_list[x] ,indices)
# for i in a 
#     println(i)
# end




# 遍历字典，找出计数大于1的行
println("------------------------ 重複出現的:")
for (line, count) in line_counts
    if count > 1
        println("重複：$(line)，出现次数：$(count)")
    end
end

println("------------------------ 修正過的:")
for i in result2
    println(i)
end

println("------------------------ 應修改而未修改的:")
for i in result3
    println(i)
end

# function contains_fullwidth_english(s::String)
#     for char in s
#         # Check if the character is in the range of full-width English characters
#         if ('\uff01' <= char <= '\uff5e') || ('\uffe0' <= char <= '\uffe6') || ('\uff10' <= char <= '\uff19')
#             return println("$s  錯誤: 圖檔名稱有英文全形")
#         end
#     end
#     return false
# end

# for i in result
#     contains_fullwidth_english(i)""
# end

#檢查檔案有沒有全形
cd(joinpath(@__DIR__))
py"""
def file_cannot_load():
    import os 
    path = os.path.dirname(os.getcwd())
    with open('list.txt', 'r') as f:
        file_list = f.read().splitlines()
        for file in file_list:
            if '＿' in file :
                print(f'無法讀取 原因是 {file} 有全形')
            elif  ' ' in file:
                print(f'無法讀取 原因是 {file} 有空白')
"""

py"""
def get_file_from_list(num):
    import os
    
    # 获取当前目录的父目录
    path = os.path.dirname(os.getcwd())
    
    # 读取文件列表
    with open('list.txt', 'r') as f:
        file_list3 = f.read().splitlines()
    
    # 返回指定位置的文件名
    if num > 0 and num <= len(file_list3):
        print(file_list3[num - 1])
    else:
        return "指定的位置超出文件列表范围"
"""


py"file_cannot_load()"

println("------------------------ 不存在的檔案名稱:")
#先讀取list2 跟 list 
for  line in file_list_12
    if occursin(r"\?", line)
        nothing
        
    elseif occursin(r"\ ", line)
        nothing
        
    elseif line=="code"
        nothing
    else
        for (index, lines) in enumerate(file_list)
            if line==lines
                sleep(0.5)
                py"get_file_from_list($index)"
            end
        end
    end
end

#ascii 寫出原始檔案名稱 有問號或空白
println("************************")
println("------------------------ ascii has ? or space:")
for i in indices 
    py"get_file_from_list($i)"
end



#檢查該路徑有沒有檔案
# result = run(`cmd /C dir /b /a-d $(filename_to_check) \> nul 2\>\&1 \|\| echo $(filename_to_check)`, wait = true)





