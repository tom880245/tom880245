json_data = Dict(
    "参" => "參",
    "样" => "樣",
    "兴" => "興"
)
bat_file_path = joinpath(@__DIR__, "..", "123", "1檢查目錄檔名.bat")
run(`$bat_file_path`)
sleep(0.6)
bat_file_path = joinpath(@__DIR__, "..", "123", "1檢查目錄檔名2.bat")
run(`$bat_file_path`)
sleep(0.6)

cd(raw"C:\Users\Administrator\Desktop\查詢書圖目錄\123")
#list=list.txt
bat_file_path2 = joinpath(@__DIR__, "..", "123", "2檢查目錄檔名.bat")

run(`$bat_file_path2`)
sleep(0.6)


json_file = "rules.json"
a=joinpath(@__DIR__, "..","123","list10.txt")
b=joinpath(@__DIR__, "..","123","list20.txt")
fileB =joinpath(@__DIR__, "B.txt")
fileC =raw"C:\Users\Administrator\Desktop\查詢書圖目錄\123\list.txt"
filecheck =raw"C:\Users\Administrator\Desktop\查詢書圖目錄\123\list_check.txt"
open(filecheck , "r") do file
    text = read(file, String)
    # 根据字符替代规则对文本进行替换
    for (key, value) in json_data
        text = replace(text, key => value)
    end
    open(fileC, "w") do outfile
        write(outfile, fileC)
    end
end

# open(b, "r") do file
#     text2 = read(file, String)
#     open(fileC, "w") do outfile
#         write(outfile, text2)
#     end

end


cd(raw"C:\Users\Administrator\Desktop\查詢書圖目錄\123")
#list=list.txt
bat_file_path2 = joinpath(@__DIR__, "..", "123", "2檢查目錄檔名.bat")

run(`$bat_file_path2`)
sleep(0.6)

open(a, "r") do file
    text = read(file, String)
    # 根据字符替代规则对文本进行替换
    for (key, value) in json_data
        text = replace(text, key => value)
    end
    open(fileB, "w") do outfile
        write(outfile, text)
    end
end
