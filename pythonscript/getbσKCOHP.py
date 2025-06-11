def read_all_lines(file_path):
    """读取文件所有行，不做处理"""
    with open(file_path, 'r') as f:
        return f.readlines()

def write_result_to_file(a_lines, sixth_columns, output_path):
    with open(output_path, 'w') as f:
        for i in range(len(a_lines)):
            line = a_lines[i].strip()
            if not line:  # 空行直接写空
                f.write('\n')
                continue

            parts = line.split()
            if len(parts) < 5:
                f.write('\n')  # 不足5列时也跳过或写空行
                continue

            first_five = parts[:5]
            try:
                summed_value = sum(col[i] for col in sixth_columns)
                output_line = '\t'.join(first_five + [str(summed_value)])
                f.write(output_line + '\n')
            except IndexError:
                f.write('\n')  # 某些文件行数不足时跳过这行

def read_sixth_column(file_path):
    col = []
    with open(file_path, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) >= 6:
                try:
                    col.append(float(parts[5]))
                except ValueError:
                    col.append(0.0)
            else:
                col.append(None)  # 用 None 占位，稍后处理时跳过
    return col

def main():
    input_files = ['b5c11-pxpx', 'b5c11-pypy', 'b5c11-ss', 'b5c11-spx', 'b5c11-spy', 'b5c11-pypx', 'b5c11-pxs', 'b5c11-pys', 'b5c11-pxpy']
    
    # A文件的所有原始行（包括空行）
    a_lines = read_all_lines('b5c11-pxpx')
    
    # 六个文件的第六列（有些行可能为 None）
    sixth_columns = [read_sixth_column(f) for f in input_files]

    # 写入
    write_result_to_file(a_lines, sixth_columns, 'bond-σ')
    print("已生成bond-σ")

if __name__ == "__main__":
    main()
