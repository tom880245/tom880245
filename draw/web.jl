#
using HTTP
using JSON
using DataFrames
# struct WebConfig

# end

    


# default_config = WebConfig(



# )


#url="https://mcgbm.taichung.gov.tw/opendata/OpenDataSearchUrl.do?d=OPENDATA&c=BUILDLIC&Start=1&%E8%B5%B7%E9%80%A0%E4%BA%BA%E4%BB%A3%E8%A1%A8%E4%BA%BA=%E7%8E%8B"

function json2DataFrame(url::String)
    response = HTTP.get(url)

    if response.status == 200
        json_data = JSON.parse(String(response.body))
        # 现在，json_data 包含了从网页上抓取的 JSON 数据
        # 你可以使用它来访问和操作数据
        
 
    else
        println("无法获取数据，状态码：", response.status)
    end
    data_array = json_data["data"]
    df = DataFrame()
    for item in data_array

        for i in item
            if !(typeof(i[2]) <: String || typeof(i[2]) <: Int64)
                item[i[1]] = string(i[2])
            end
            
        end
        #updated_item = Dict{String, Any}(pair for pair in item)
        field_values = (Symbol(key) => string(value) for (key, value) in item)
        updated_item = NamedTuple(field_values)
        push!(df, updated_item)
    end
     


    return df
end

# # 抓取第一个参数（键）
# key = i[1]  # 这将得到 "備註"

# # 抓取第二个参数（值）
# value = i[2]  # 这将得到空数组 Any[]
