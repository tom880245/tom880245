import os

# 读取文件 "1.txt"
A_file_path = '1.txt'


with open(A_file_path, 'r') as file:
    A = file.read()

# 使用 split 函数拆分字符串 A 成为一个列表
A_elements = A.split('、')

# 使用单引号加上每个元素
A_elements_quoted = ["'" + element + "'" for element in A_elements]

# 使用逗号连接这些元素
result = ', '.join(A_elements_quoted)

# 将结果输出到 "2.txt" 文件
output_file_path = '2.txt'
with open(output_file_path, 'w') as file:
    file.write(result)

# 输出完成消息
print("结果已经输出到", output_file_path)