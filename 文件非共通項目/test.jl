function read_file(file_path)
    data = readlines(file_path)
    return data
end

function find_unique_lines(file_path_A::AbstractString, file_path_B::AbstractString)
    lines_A = Set(read_file(file_path_A))
    lines_B = Set(read_file(file_path_B))
    unique_in_A = setdiff(lines_A, lines_B)
    unique_in_B = setdiff(lines_B, lines_A)
    return unique_in_A, unique_in_B
end

# 以您的檔案路徑為例

file_path_A = joinpath(@__DIR__,"check.txt")
file_path_B = joinpath(@__DIR__,"check2.txt")

unique_in_A, unique_in_B = find_unique_lines(file_path_A, file_path_B)

println("Unique lines in file A:")
println(unique_in_A)
println("Unique lines in file B:")
println(unique_in_B)

'朱振宇', '盛筱蓉', '廖家興', '邱彥菱', '陳韋豪', '莊智婷', '葉品宏', '張佑任', '許世坤'