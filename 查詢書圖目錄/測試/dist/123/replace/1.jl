struct PlotConfig
    dic::Dict{String, String}
    pic_path::String
    bat_file_path::String
    bat_file_pathexe::String
    bat_file_path2::String
    bat_file_path3 ::String
    list_utf8::String
    list_utf8_output ::String
    fileout::String 
    fileout2::String 
    fileout3::String
    fileout4::String

 
end

default_config = PlotConfig(
     Dict(
    "参" => "參",
    "样" => "樣",
    "兴" => "興",
    "叁" => "參"
),                #Dict::Dict{String, String}
joinpath(@__DIR__, ".."), #pic_path
joinpath(@__DIR__, "..", "1檢查目錄檔名.bat"),  #bat_file_path
joinpath(@__DIR__, "..",  "123.exe") ,                        #bat_file_pathexe
joinpath(@__DIR__, "..",  "2檢查目錄檔名.bat"),                #bat_file_path2
joinpath(@__DIR__, "..",  "1檢查目錄檔名20.bat"),              #bat_file_path3 
joinpath(@__DIR__, "..","listutf8.txt")  ,                      #list_utf8
joinpath(@__DIR__, "utf8_output.txt"),                          #list_utf8_output 
joinpath(@__DIR__, "..",  "list3.txt"),                         #fileout                           
joinpath(@__DIR__, "..",  "list4.txt"),                         #fileout2 
joinpath(@__DIR__, "..",  "list5.txt"),                         #fileout3
joinpath(@__DIR__, "out.txt")                        #fileout4
)

function CD(default_config::PlotConfig)
    cd(default_config.pic_path)
end


CD(default_config)

bat_file_path = default_config.bat_file_path
run(`$bat_file_path`)
sleep(0.6)
#cd(joinpath(@__DIR__, ".."))
bat_file_pathexe = default_config.bat_file_pathexe
run(`$bat_file_pathexe`)
sleep(0.6)

bat_file_path2 = default_config.bat_file_path2
run(`$bat_file_path2`)
sleep(0.6)

bat_file_path3 =default_config.bat_file_path3
run(`$bat_file_path3`)
sleep(0.6)


json_file = default_config.dic
list_utf8=default_config.list_utf8
# fileB =joinpath(@__DIR__, "B.txt")
list_utf8_output =default_config.list_utf8_output



function read_and_filter(file_path, unique_lines)
    for line in eachline(file_path)
        if !(line in unique_lines)
            push!(unique_lines, line)
        end
    end
end
fileout =default_config.fileout
fileout2 =default_config.fileout2
fileout3 =default_config.fileout3
unique_lines = Set{String}()
read_and_filter(fileout, unique_lines)
read_and_filter(fileout2, unique_lines)
read_and_filter(fileout3, unique_lines)
fileout4 =default_config.fileout4
output_file = open(fileout4, "w")

for line in unique_lines
    println(output_file, line)
end
    
    # 關閉新文件
close(output_file)




open(list_utf8, "r") do file
    text2 = read(file, String)
    for (key, value) in json_file
        text2 = replace(text2, key => value)
    end
    open(list_utf8_output, "w") do outfile
        write(outfile, text2)
    end

end






