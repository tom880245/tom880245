function process_file(input_file::AbstractString, output_file::AbstractString)
    open(input_file, "r") do file
        open(output_file, "w") do output
            for line in eachline(file)
                # 去掉行末的短划线和逗号，然后在前后添加单引号
                processed_line = "'" * replace(line, r"-\d+,$" => "") * "',"
                write(output, processed_line, "\n")
            end
        end
    end
end

# 使用示例
input_filename = joinpath(@__DIR__,"input.txt")
output_filename = joinpath(@__DIR__,"output.txt")

process_file(input_filename, output_filename)


function read_urls_from_file(file_path::AbstractString)
    urls = String[]
    open(file_path, "r") do file
        for line in eachline(file)
            push!(urls, strip(line))
        end
    end
    return urls
end

# 輸出網址 (貼上CMD)
function open_web_pages(urls::Vector{String})
    for url in urls
        run(`cmd /C start $url`)  # 使用xdg-open命令来打开网页，Linux系统通常支持该命令
        # 如果你使用其他操作系统，你可以使用适合的命令来打开网页，例如Windows下的start命令
        # run(`start $url`)
    end
end

# 使用示例
url_file_path = joinpath(@__DIR__,"urls.txt")  # 包含网址的文件路径
urls_to_open = read_urls_from_file(url_file_path)

#open_web_pages(urls_to_open)

file_path = input_filename  # 替换成你的文件路径
file_contents = readlines(file_path)

sql_query = "CREATE GLOBAL TEMPORARY TABLE tempTable113  ( search_index_key VARCHAR2(50))ON COMMIT PRESERVE ROWS;"

# 添加文件内容中的每一行
for line in file_contents

        sql_query *= "INSERT INTO tempTable113 SELECT '$line' FROM DUAL;\n"
   

end
println(sql_query)
println("""
select a.search_index_key,b.index_key,b.license_desc from tempTable113 a left join bm_base b on a.search_index_key=b.index_key
"""
)
println("drop table tempTable113")



