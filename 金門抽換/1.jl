# 讀取路徑下的 "1.txt" 文件
A_file_path = "1.txt"
script_path = dirname(Base.source_path())

# 使用 open 函式讀取文件中的內容並保存到變數 A
A = read(joinpath(script_path,A_file_path), String)

# # 使用 split 函式拆分字串 A 成為一個陣列
 A_elements = split(A, '、')

# # 使用單引號加上每個元素
 A_elements_quoted = map(element -> "'$element'", A_elements)

# # 使用 join 函式以逗號連接這些元素
 result = join(A_elements_quoted, ", ")

# 將結果輸出到 "2.txt" 文件
output_file_path = "2.txt"
open(joinpath(script_path,output_file_path), "w") do io
    println(io, result)
end

# 輸出完成消息
println("結果已經輸出到 $output_file_path")

#載入創建exe檔案
#C=joinpath(script_path,"3")
# using PackageCompiler  
#  create_app( C, Base.source_path(), force=true)   
create_app( C,Base.source_path(),  force=true)   