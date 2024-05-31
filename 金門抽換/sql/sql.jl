using Dates
using PyCall
using Gumbo
using Cascadia


struct Config
    headers::Dict{String, String}
    approve::String
    success::String

end

default_config = Config(
    Dict(
        "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
    ),
    "http://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=",
    "http://build.kinmen.gov.tw/upload/BDMfileok.jsp?index_key="
    
    )

try
    using HTTP
catch
    println("HTTP package not found. Installing...")
    import Pkg
    Pkg.add("HTTP")
    using HTTP
end


function split_and_operate(input_str::String)
    return split(input_str, "、")
  end
function format_dates(input_str::String)
    # 将字符串分割成日期部分
    date_parts = split(input_str, "、")
    
    # 使用列表推导式将每个日期部分包装在单引号中
    formatted_dates = ["'$date'" for date in date_parts]
    
    # 使用逗号和空格连接日期字符串
    formatted_string = join(formatted_dates, ", ")
    
    return formatted_string
end

#找異動序號 
function index_key2(index_key3)
    
    response = HTTP.get("$(default_config.approve)$(index_key3)")
    if HTTP.status(response) == 200
        # 请求成功
        body_content = HTTP.body(response)
        #println(body_content)
    else
        # 请求失败
        println("请求失败，状态码: ", HTTP.status(response))
    end
    pattern = r"value=\"(\d+)\""
    body_string = String(body_content)

    matches = eachmatch(pattern, body_string )

    if !isempty(matches)
        extracted_values = [m.match for m in matches]
        extracted_values=match(pattern, extracted_values[2])
    #println("提取的值为: ", extracted_values)
    else
        println("未找到匹配的值")
    end
    return "$(index_key3)"*"-"*extracted_values[1]

end

function today()
    today_date = Dates.today()
    year = Dates.year(today_date) - 1911
    month = lpad(Dates.month(today_date), 2, '0')
    day = lpad(Dates.day(today_date), 2, '0')
    return string(year, month, day)
end
function sql_update(index ,constant::String)
    index_key=index_key2(index)
    sleep(0.4)
    constant=format_dates(constant)
    data="update  bdmlist_reg set  reedit_date='$(today())' where index_key like '$(index_key)' and picnum in("
    data2=");"

    return println(data*constant*data2) 
end


function sql_insert(index ,constant::String)
    index_key=index_key2(index)
    sleep(0.4)
    constant=collect(split_and_operate(constant))
    for i in constant
        data="insert into  bdmlist_reg(sysid,index_key,picseq,picname,picnum,filename, reedit_date)  VALUES((select sysid from bdmlist_reg  where index_key like '$index_key' and rownum=1),'$index_key',(select max(picseq)+1 from bdmlist_reg  where index_key like '$index_key'),'新增圖說','$i','$i.pdf','$(today())');"
        println(data) 
    end
end

#沒在用

# function Text2indexkeynpic(text::AbstractString)
#     matches = collect(eachmatch(r"\b[A-Za-z\d、-]+", text))
#     filtered_matches = filter(m -> occursin(r"\d{13}", m.match), matches)
#     filtered_matches_pic = filter(m -> occursin(r"[-、A-Za-z]", m.match), matches)
#     index_key,pic=[m.match for m in filtered_matches],[m.match for m in filtered_matches_pic]
#     length(index_key) == length(pic) ? nothing : println("index & pic 長度錯誤")
#     try
#         for (i,_) in enumerate(index_key)
#             println("sql_update(\"$(index_key[i])\",\"$(pic[i])\")")
#         end
#     catch
#         println("輸入格式錯誤 麻煩檢查")

#     end
#     try
#         for (i,_) in enumerate(index_key)
#             println("start $(default_config.approve)$(index_key[i])")
#         end
#     catch
#         println("輸入網址錯誤")

#     end
# end



# https://build.kinmen.gov.tw/upload/BDMfileok.jsp?index_key=1130508145848  找最新異動序號
function Modifynumber(index_key::SubString{String})
    response = HTTP.get("$(default_config.success)$(index_key)",headers=default_config.headers)
    h = parsehtml(String(response.body))
    qs = nodeText(eachmatch(Selector("td[width='65%']"),h.root)[4])[1:19]
    return qs
end

function ChecknPrint(index_key::SubString{String},input;type=1)
    #先寫讀取turepic 
    local Classification_A=String[]
    local Classification_D=String[]
    local Classification_S=String[]
    local Classification_number=String[]
    patternA=r"A.*"
    patternD=r"D.*"
    patternS=r"S.*"
    let picdraW=[]
        r = HTTP.get("$(default_config.approve)$(index_key)",headers=default_config.headers)
        h = parsehtml(String(r.body))
        newanime_item=map(x->nodeText(x),eachmatch(Selector("td.form-headup-c"),h.root))
        for i in newanime_item
            pic=strip(strip(i,' '),'\n')
            push!(picdraW,pic)
        end
        pattern = r"(\w+)"
        matches=[]
        for i in picdraW
            if length(collect(eachmatch(r"\b[A-Za-z\d、-]+", i)))>0
                push!(matches,first(collect(eachmatch(r"\b[A-Za-z\d、-]+", i))).match)
            end
        end
    
    
        for i in matches
            if length(i) > 1
                match(patternA,i) != nothing ? push!(Classification_A,i) :
                (match(patternD,i) != nothing ? push!(Classification_D,i) : 
                (match(patternS,i) !=nothing  ? push!(Classification_S,i) :
                (length(i) !=7 ?          push!(Classification_number,i)  :
                nothing)))
            end
        end
    
    
    end

#驗證是否在 turpic 中 輸出 result result2
result,result2=[],[]
array=input |> x->split(x, '、')
for i in array
    check=(match(r"A",i), match(r"D",i), match(r"S",i))
    if check[1]!=nothing
        if i in  Classification_A
            push!(result,i)
        elseif occursin('-', i)
            parts = split(i, '-')
            if length(parts) == 2
                prefix, suffix = parts[1], parts[2]
                if length(suffix) == 2 && isdigit(suffix[1]) && isdigit(suffix[2])
                    push!(result, prefix * suffix)
                elseif length(suffix) == 1 && isdigit(suffix[1])
                    push!(result, prefix * "0" * suffix)
                else
                    push!(result, i)
                end
            else
                println("$i 有誤")
            end
        else
            push!(result2, i)
        end

    

    elseif check[2]!=nothing
        if i in  Classification_D
            push!(result,i)
        elseif occursin('-', i)
            parts = split(i, '-')
            if length(parts) == 2
                prefix, suffix = parts[1], parts[2]
                if length(suffix) == 2 && isdigit(suffix[1]) && isdigit(suffix[2])
                    push!(result, prefix * suffix)
                elseif length(suffix) == 1 && isdigit(suffix[1])
                    push!(result, prefix * "0" * suffix)
                else
                    push!(result, i)
                end
            else
                println("$i 有誤")
            end
        else
            push!(result2, i)
        end


    elseif check[3]!=nothing
        if i in  Classification_S
            push!(result,i)
        elseif occursin('-', i)
            parts = split(i, '-')
            if length(parts) == 2
                prefix, suffix = parts[1], parts[2]
                if length(suffix) == 2 && isdigit(suffix[1]) && isdigit(suffix[2])
                    push!(result, prefix * suffix)
                elseif length(suffix) == 1 && isdigit(suffix[1])
                    push!(result, prefix * "0" * suffix)
                else
                    push!(result, i)
                end
            else
                println("$i 有誤")
            end
        else
            push!(result2, i)
        end

    else
        if i in  Classification_number
            push!(result,i)
        elseif occursin('-', i)
            parts = split(i, '-')
            if length(parts) == 2
                prefix, suffix = parts[1], parts[2]
                if length(suffix) == 2 && isdigit(suffix[1]) && isdigit(suffix[2])
                    push!(result, prefix * suffix)
                elseif length(suffix) == 1 && isdigit(suffix[1])
                    push!(result, prefix * "0" * suffix)
                else
                    push!(result, i)
                end
            else
                println("$i 有誤")
            end
        else
            push!(result2, i)
        end
    
    end


end
resultUpdate=result |> x->join(x, '、')
resultInsert=result2 |> x->join(x, '、')

#輸出 turpic  
println("sql_update(\"$(index_key)\",\"$(resultUpdate)\")")

length(resultInsert) > 0 ? println("未在其中 手動確認:  sql_insert(\"$(index_key)\",\"$(resultInsert)\")") : nothing
end

#Insert 部分
function ChecknPrint(index_key::SubString{String},input,type::Bool)
    #先寫讀取turepic 
    local Classification_A=String[]
    local Classification_D=String[]
    local Classification_S=String[]
    local Classification_number=String[]
    patternA=r"A.*"
    patternD=r"D.*"
    patternS=r"S.*"
    let picdraW=[]
        r = HTTP.get("$(default_config.approve)$(index_key)",headers=default_config.headers)
        h = parsehtml(String(r.body))
        newanime_item=map(x->nodeText(x),eachmatch(Selector("td.form-headup-c"),h.root))
        for i in newanime_item
            pic=strip(strip(i,' '),'\n')
            push!(picdraW,pic)
        end
        pattern = r"(\w+)"
        matches=[]
        for i in picdraW
            if length(collect(eachmatch(r"\b[A-Za-z\d、-]+", i)))>0
                push!(matches,first(collect(eachmatch(r"\b[A-Za-z\d、-]+", i))).match)
            end
        end
    
    
        for i in matches
            if length(i) > 1
                match(patternA,i) != nothing ? push!(Classification_A,i) :
                (match(patternD,i) != nothing ? push!(Classification_D,i) : 
                (match(patternS,i) !=nothing  ? push!(Classification_S,i) :
                (length(i) !=7 ?          push!(Classification_number,i)  :
                nothing)))
            end
        end
    
    
    end

#驗證是否在 turpic 中 輸出 result result2
result,result2=[],[]
array=input |> x->split(x, '、')
for i in array
    check=(match(r"A",i), match(r"D",i), match(r"S",i))
    if check[1]!=nothing
        if i in  Classification_A
            push!(result,i)
        elseif occursin('-', i)
            parts = split(i, '-')
            if length(parts) == 2
                prefix, suffix = parts[1], parts[2]
                if length(suffix) == 2 && isdigit(suffix[1]) && isdigit(suffix[2])
                    push!(result, prefix * suffix)
                elseif length(suffix) == 1 && isdigit(suffix[1])
                    push!(result, prefix * "0" * suffix)
                else
                    push!(result, i)
                end
            else
                println("$i 有誤")
            end
        else
            push!(result2, i)
        end

    

    elseif check[2]!=nothing
        if i in  Classification_D
            push!(result,i)
        elseif occursin('-', i)
            parts = split(i, '-')
            if length(parts) == 2
                prefix, suffix = parts[1], parts[2]
                if length(suffix) == 2 && isdigit(suffix[1]) && isdigit(suffix[2])
                    push!(result, prefix * suffix)
                elseif length(suffix) == 1 && isdigit(suffix[1])
                    push!(result, prefix * "0" * suffix)
                else
                    push!(result, i)
                end
            else
                println("$i 有誤")
            end
        else
            push!(result2, i)
        end


    elseif check[3]!=nothing
        if i in  Classification_S
            push!(result,i)
        elseif occursin('-', i)
            parts = split(i, '-')
            if length(parts) == 2
                prefix, suffix = parts[1], parts[2]
                if length(suffix) == 2 && isdigit(suffix[1]) && isdigit(suffix[2])
                    push!(result, prefix * suffix)
                elseif length(suffix) == 1 && isdigit(suffix[1])
                    push!(result, prefix * "0" * suffix)
                else
                    push!(result, i)
                end
            else
                println("$i 有誤")
            end
        else
            push!(result2, i)
        end

    else
        if i in  Classification_number
            push!(result,i)
        elseif occursin('-', i)
            parts = split(i, '-')
            if length(parts) == 2
                prefix, suffix = parts[1], parts[2]
                if length(suffix) == 2 && isdigit(suffix[1]) && isdigit(suffix[2])
                    push!(result, prefix * suffix)
                elseif length(suffix) == 1 && isdigit(suffix[1])
                    push!(result, prefix * "0" * suffix)
                else
                    push!(result, i)
                end
            else
                println("$i 有誤")
            end
        else
            push!(result2, i)
        end
    
    end


end
#驗證是否在 turpic 中


resultUpdate=result |> x->join(x, '、')
resultInsert=result2 |> x->join(x, '、')


#輸出 turpic  
println("分類錯誤  有在其中 : sql_insert(\"$(index_key)\",\"$(resultUpdate)\")")

length(resultInsert) > 0 ? println("新增圖說 手動確認:  sql_insert(\"$(index_key)\",\"$(resultInsert_makesure)\")") : nothing

    
end

function Text2indexkeynpic(text::AbstractString)
    function further_filter(matches)
        filtered_matches = filter(m -> occursin(r"[-、A-Za-z]", m) || occursin(r"\d{13}", m)|| occursin(r"需修正圖說:(.*)", m)|| occursin(r"需新增圖說:(.*)", m), matches)
        return filtered_matches
    end
    match_word_regex=collect(eachmatch(r"\w+.*\w"m,text))
    match_word=map(x->x.match,match_word_regex)
    matches = collect(eachmatch(r"\b[A-Za-z\d、-]+", text))
    filtered_matches = filter(m -> occursin(r"\d{13}", m.match), matches)
    index_key_for_url=[m.match for m in filtered_matches]
    data=further_filter(match_word)
    for (index,values) in enumerate(data)
        a=index
        while match(r".*:(\d{13})",data[a]) !=nothing && a<=(length(data)-2)
            index_key_for_pic=match(r".*:(\d{13})",data[a]).captures[1]
            match(r"需修正圖說:(.*)",data[a+1]) == nothing ? nothing : ChecknPrint(index_key_for_pic,match(r"需修正圖說:(.*)", data[a+1]).captures[1])
            match(r"需修正圖說:(.*)",data[a+2]) == nothing ? nothing : ChecknPrint(index_key_for_pic,match(r"需修正圖說:(.*)", data[a+2]).captures[1])
            match(r"需新增圖說:(.*)",data[a+1]) == nothing ? nothing : ChecknPrint(index_key_for_pic,match(r"需新增圖說:(.*)", data[a+1]).captures[1],false)
            match(r"需新增圖說:(.*)",data[a+2]) == nothing ? nothing : ChecknPrint(index_key_for_pic,match(r"需新增圖說:(.*)", data[a+2]).captures[1],false)
            a+=1
        end
        while match(r".*:(\d{13})",data[a]) !=nothing && a==length(data)-1
            index_key_for_pic=match(r".*:(\d{13})",data[a]).captures[1]
            match(r"需修正圖說:(.*)",data[a+1]) == nothing ? nothing : ChecknPrint(index_key_for_pic,match(r"需修正圖說:(.*)", data[a+1]).captures[1])
            match(r"需新增圖說:(.*)",data[a+1]) == nothing ? nothing : ChecknPrint(index_key_for_pic,match(r"需新增圖說:(.*)", data[a+1]).captures[1],false)
            a+=1
        end 
        println("----------------------------------------")
    end

    try
        for (i,_) in enumerate(index_key_for_url)
            println("start $(default_config.approve)$(index_key_for_url[i])")
        end
        println("路徑:")
        #println("F:")
        for (i,_) in enumerate(index_key_for_url)
            data=index_key2(index_key_for_url[i])
            modify=Modifynumber(index_key_for_url[i])
            #println("CD F:\\nas\\reg\\$(data[1:3])\\$(data)")
            #println("mkdir upd\\$(today())")
            #println("CD F:\\nas\\bdmup\\$(data[1:3])\\$(data[4:5])")
            #println("dir $(data[1:13])*.PZIP")
            println("xcopy F:\\nas\\bdmup\\$(data[1:3])\\$(data[4:5])\\$(modify).PZIP  F:\\nas\\reg\\$(data[1:3])\\$(data)\\upd\\$(today())\\  /s /e /y")
            println("start  F:\\nas\\reg\\$(data[1:3])\\$(data)\\upd\\$(today())")
            println("Truepic(\"$(data[1:13])\")")
        end
    catch
        println("輸入網址錯誤")

    end
end



function Truepic(data::String)
    let picdraW=[]
    r = HTTP.get("$(default_config.approve)$(data)",headers=default_config.headers)
    h = parsehtml(String(r.body))
    newanime_item=map(x->nodeText(x),eachmatch(Selector("td.form-headup-c"),h.root))
    for i in newanime_item
        pic=strip(strip(i,' '),'\n')
        push!(picdraW,pic)
    end
    pattern = r"(\w+)"
    matches=[]
    for i in picdraW
        if length(collect(eachmatch(r"\b[A-Za-z\d、-]+", i)))>0
            push!(matches,first(collect(eachmatch(r"\b[A-Za-z\d、-]+", i))).match)
        end
    end

    Classification_A=String[]
    Classification_D=String[]
    Classification_S=String[]
    Classification_number=String[]
    patternA=r"A.*"
    patternD=r"D.*"
    patternS=r"S.*"

    for i in matches
        if length(i) > 1
            match(patternA,i) != nothing ? push!(Classification_A,i) :
            (match(patternD,i) != nothing ? push!(Classification_D,i) : 
            (match(patternS,i) !=nothing  ? push!(Classification_S,i) :
            (length(i) !=7 ?          push!(Classification_number,i)  :
            nothing)))
        end
    end

    println("A 類 :",Classification_A)

    println("D 類 :",Classification_D)

    println("S 類 :",Classification_S)

    println("number 類 :",Classification_number)

    end
end




# USE  include() 輸入a="""需要處裡的文字"""  Text2indexkeynpic2(a)   Truepic("1130123170733")  

#輸出
# sql_insert(index_key ,constant::String)
# sql_update(index_key ,constant::String)