using Dates
using PyCall
using Gumbo
using Cascadia
ENV["PYTHON"]=raw"C:\Users\Administrator\AppData\Local\Programs\Python\Python312\python.exe"

headers = Dict(
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
)

function pyimport_(input::String)
    @eval using Dates
    function install_package(input2::String)
        run(`cmd /C pip install $(input2)`)
        sleep(0.2)
    end
    try

        @eval pyimport(input)
    catch
        println("$input is not installed. Installing...")
        install_package(input)
        @eval import Pkg
        Pkg.build("PyCall")
        @eval using PyCall
        pyimport(input)
    end
end

try
    using HTTP
catch
    println("HTTP package not found. Installing...")
    import Pkg
    Pkg.add("HTTP")
    using HTTP
end
#ENV["SSL_CERT_FILE"] = "/etc/ssl/certs/ca-certificates.crt"

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


function index_key2(index_key3)
    
    response = HTTP.get("http://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=$(index_key3)")
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
    sleep(2)
    constant=format_dates(constant)
    data="update  bdmlist_reg set  reedit_date='$(today())' where index_key like '$(index_key)' and picnum in("
    data2=");"

    return println(data*constant*data2) 
end


function sql_insert(index ,constant::String)
    index_key=index_key2(index)
    sleep(2)
    constant=collect(split_and_operate(constant))
    for i in constant
        data="insert into  bdmlist_reg(sysid,index_key,picseq,picname,picnum,filename, reedit_date)  VALUES((select sysid from bdmlist_reg  where index_key like '$index_key' and rownum=1),'$index_key',(select max(picseq)+1 from bdmlist_reg  where index_key like '$index_key'),'新增圖說','$i','$i.pdf','$(today())');"
        println(data) 
    end
end



function Text2indexkeynpic(text::AbstractString)
    matches = collect(eachmatch(r"\b[A-Za-z\d、-]+", text))
    filtered_matches = filter(m -> occursin(r"\d{13}", m.match), matches)
    filtered_matches_pic = filter(m -> occursin(r"[-、A-Za-z]", m.match), matches)
    index_key,pic=[m.match for m in filtered_matches],[m.match for m in filtered_matches_pic]
    length(index_key) == length(pic) ? nothing : println("index & pic 長度錯誤")
    try
        for (i,_) in enumerate(index_key)
            println("sql_update(\"$(index_key[i])\",\"$(pic[i])\")")
        end
    catch
        println("輸入格式錯誤 麻煩檢查")

    end
    try
        for (i,_) in enumerate(index_key)
            println("start https://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=\"$(index_key[i])\"")
        end
    catch
        println("輸入網址錯誤")

    end
end

# #使用
# a="""
# 執照號碼:(112)府建造字第07603號
# 上傳編號:1120417114654
# 需修正圖說:54-01、A2-01、A2-02、A3-01、A3-02、A3-03、A3-04、A4-01、A4-02、A4-03、A4-04、A6-01、A6-02、A6-03、A7-01、A7-02
# 需新增圖說:A6-04

# 起造人:金門縣金湖鎮公所
# 執照號碼:(112)府建造字第07602號
# 上傳編號:1121120145348
# 需修正圖說:08-01、54-01、61-01、A0-02、A1-01、A2-01、A3-01、A4-01

# 起造人:張淑貞
# 執照號碼:(112)府建造字第07612號
# 上傳編號:1130105143821
# 需修正圖說:54-01、A1-01、A1-02、A1-03、A1-04、A3-01、A5-01、S1-01、S1-02、S1-03、S1-04、S1-05
# """
# Text2indexkeynpic(a)

# https://build.kinmen.gov.tw/upload/BDMfileok.jsp?index_key=1130508145848  找最新異動序號
function Modifynumber(index_key::SubString{String})
    response = HTTP.get("http://build.kinmen.gov.tw/upload/BDMfileok.jsp?index_key=$(index_key)",headers=headers)
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
        r = HTTP.get("http://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=$(index_key)",headers=headers)
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
        r = HTTP.get("http://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=$(index_key)",headers=headers)
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

function Text2indexkeynpic2(text::AbstractString)
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
            # match(r"需修正圖說:(.*)",data[a+1]) == nothing ? nothing : println("sql_update(\"$(index_key_for_pic)\",\"$(match(r"需修正圖說:(.*)", data[a+1]).captures[1])\")")
            # match(r"需修正圖說:(.*)",data[a+2]) == nothing ? nothing : println("sql_update(\"$(index_key_for_pic)\",\"$(match(r"需修正圖說:(.*)", data[a+2]).captures[1])\")")
            # match(r"需新增圖說:(.*)",data[a+1]) == nothing ? nothing :  println("sql_inser(\"$(index_key_for_pic)\",\"$(match(r"需新增圖說:(.*)", data[a+1]).captures[1])\")")
            # match(r"需新增圖說:(.*)",data[a+2]) == nothing ? nothing : println("sql_insert(\"$(index_key_for_pic)\",\"$(match(r"需新增圖說:(.*)", data[a+2]).captures[1])\")")
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
            println("start https://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=\"$(index_key_for_url[i])\"")
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








# requests=pyimport_("requests")
# bs4=pyimport_( "bs4")
headers = Dict(
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
)
# response = HTTP.get("http://build.kinmen.gov.tw/upload/BDMfileok.jsp?index_key=$(index_key)",headers=headers)
# h = parsehtml(String(response.body))
# qs = nodeText(eachmatch(Selector("td[width='65%']"),h.root)[4])

# function Truepic(data::String)
#     let picdraW=[]
#     r = requests.get("http://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=$(data)",headers=headers)

#     soup = bs4.BeautifulSoup(r.text, "html.parser")
#     newanime_item = soup.select("tr > .form-headup-c")
#     function vectorstring2string(data)
#         f=data|>PyCall.pybuiltin("list")
#         return f[1]
#     end
#     rows = soup.find_all("tr")
#     for row in rows
#         # 在每个 <tr> 中查找第一个 <td class="form-headup-c">
    
#         first_id = row.find("td", class_="form-headup-c")
#         try picmap=vectorstring2string(first_id)
#             push!(picdraW,picmap)
    
#         catch 
#             nothing
#         end
#     end
#     pattern = r"(\w+)"
#     matches=[]
#     for i in picdraW
#         push!(matches,first(collect(eachmatch(r"\b[A-Za-z\d、-]+", i))).match)
#     end

#     Classification_A=String[]
#     Classification_D=String[]
#     Classification_S=String[]
#     Classification_number=String[]
#     patternA=r"A.*"
#     patternD=r"D.*"
#     patternS=r"S.*"

#     for i in matches
#         match(patternA,i) != nothing ? push!(Classification_A,i) :
#          (match(patternD,i) != nothing ? push!(Classification_D,i) : 
#          (match(patternS,i) !=nothing  ? push!(Classification_S,i) :
#          push!(Classification_number,i)))
#     end

#     println("A 類 :",Classification_A)

#     println("D 類 :",Classification_D)

#     println("S 類 :",Classification_S)

#     println("number 類 :",Classification_number)

#     end
# end


function Truepic(data::String)
    let picdraW=[]
    #r = requests.get("http://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=$(data)",headers=headers)
    r = HTTP.get("http://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=$(data)",headers=headers)
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





# """
# 起造人:陳天成
# 執照號碼:(112)府建造字第07448號
# 上傳編號:1110923174731
# 需修正圖說:A0-01、A0-02、A0-03、A0-04、A0-05、A0-08、A0-09、A0-10、A0-11、A1-01、A1-02、A1-03、A1-04、A1-05、A1-06、A1-07、A1-08、A1-09、A1-10、A2-01、A2-02、A2-03、A9-02、S1-01、S1-02、S1-03、S1-04、S1-05
# 需新增圖說:S2-01、S2-02、S2-03、S2-04、S2-05、S2-06、S2-07、S3-01、S4-01、S5-01、S7-01、S7-02、S7-03、S7-04
# """



#將字串拆成數組
input="54-01、A1-01、A1-02、A1-03、A1-04、A3-01、A5-01、S1-01、S1-02、S1-03、S1-04、S1-05"
array = split(input, '、')
array=input |> x->split(x, '、')
Classification_A=["A001", "A002", "A101", "A102", "A103", "A104", "A201", "A202", "A203", "A204", "A301", "A302", "A401", "A402", "A403", "A501", "A801", "A802", 
"A803"]
Classification_D=String[]
Classification_S=["S101", "S102", "S103", "S104", "S105", "S106"]
Classification_N=["05-01", "06-01", "08-01", "09-01", "10-01", "11-01", "12-01", "13-01", "14-01", "15-01", "16-01", "17-01", "18-01", "25-01", "26-01", "27-01", 
"30-01", "31-01", "44-01", "45-01", "46-01", "48-01", "54-01", "55-01", "61-01", "RF", "R1", "PF"]
# for i in input
#     check=(match(r"A",i).match, match(r"D",i), match(r"S",i))
#     if check[1]!=nothing
#         if i in  Classification_A
#             push!(result,i)
#         elseif occursin('-', i)
#             parts = split(i, '-')
#             if length(parts) == 2
#                 prefix, suffix = parts[1], parts[2]
#                 if length(suffix) == 2 && isdigit(suffix[1]) && isdigit(suffix[2])
#                     push!(result, prefix * suffix)
#                 elseif length(suffix) == 1 && isdigit(suffix[1])
#                     push!(result, prefix * "0" * suffix)
#                 else
#                     push!(result, i)
#                 end
#             else
#                 println("$i 有誤")
#             end
#         else
#             push!(result2, i)
#         end

    

#     elseif check[2]!=nothing
#         if i in  Classification_D
#             push!(result,i)
#         elseif occursin('-', i)
#             parts = split(i, '-')
#             if length(parts) == 2
#                 prefix, suffix = parts[1], parts[2]
#                 if length(suffix) == 2 && isdigit(suffix[1]) && isdigit(suffix[2])
#                     push!(result, prefix * suffix)
#                 elseif length(suffix) == 1 && isdigit(suffix[1])
#                     push!(result, prefix * "0" * suffix)
#                 else
#                     push!(result, i)
#                 end
#             else
#                 println("$i 有誤")
#             end
#         else
#             push!(result2, i)
#         end


#     elseif check[3]!=nothing
#         if i in  Classification_S
#             push!(result,i)
#         elseif occursin('-', i)
#             parts = split(i, '-')
#             if length(parts) == 2
#                 prefix, suffix = parts[1], parts[2]
#                 if length(suffix) == 2 && isdigit(suffix[1]) && isdigit(suffix[2])
#                     push!(result, prefix * suffix)
#                 elseif length(suffix) == 1 && isdigit(suffix[1])
#                     push!(result, prefix * "0" * suffix)
#                 else
#                     push!(result, i)
#                 end
#             else
#                 println("$i 有誤")
#             end
#         else
#             push!(result2, i)
#         end

#     else
#         if i in  Classification_N
#             push!(result,i)
#         elseif occursin('-', i)
#             parts = split(i, '-')
#             if length(parts) == 2
#                 prefix, suffix = parts[1], parts[2]
#                 if length(suffix) == 2 && isdigit(suffix[1]) && isdigit(suffix[2])
#                     push!(result, prefix * suffix)
#                 elseif length(suffix) == 1 && isdigit(suffix[1])
#                     push!(result, prefix * "0" * suffix)
#                 else
#                     push!(result, i)
#                 end
#             else
#                 println("$i 有誤")
#             end
#         else
#             push!(result2, i)
#         end
    
#     end


# end