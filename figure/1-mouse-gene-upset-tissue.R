
# 确保安装了相关的包
if (!require("ComplexHeatmap")) BiocManager::install("ComplexHeatmap")
library(ComplexHeatmap)
library(tidyverse)
library(grid)

# 1. 自动化数据读取与名称清洗
folder_path <- "E:/2-8.3-shanda/1-feature/9-Final_Segmented_Genes/"
file_list <- list.files(path = folder_path, pattern = "\\.txt$", full.names = TRUE)

gene_list <- lapply(file_list, readLines)

# 名称清洗：移除冗余字符，替换下划线为空格
clean_names <- gsub("_Knee.*", "", basename(file_list))
clean_names <- gsub("_", " ", clean_names)

# 尊重原始命名，保留 "marrow"
names(gene_list) <- clean_names

# 2. 构建交集矩阵并进行筛选
m = make_comb_mat(gene_list)
m = m[comb_size(m) >= 3]

# 3. 定义主刊级色板
col_main = "#333333"
col_set  = "#0072B2"

# 4. 绘制合规的 UpSet 图 (宽 115mm, 高 75mm)
pdf("E:/2-8.3-shanda/1-feature/1-figure/1-mouse-gene-upset/1-Mouse_Tissue_Aging_UpSet.pdf",
    width = 4.53, height = 2.95)

ht = UpSet(m,
           # 顶部注释：交集大小
           top_annotation = upset_top_annotation(m,
                                                 add_numbers = TRUE,
                                                 numbers_rot = 0,
                                                 numbers_gp = gpar(fontsize = 5, fontfamily = "Helvetica"),
                                                 annotation_name_gp = gpar(fontsize = 6, fontfamily = "Helvetica"),
                                                 annotation_name_rot = 90,
                                                 # --- 核心修改：强制缩小左上角的纵坐标轴刻度数字 ---
                                                 axis_param = list(gp = gpar(fontsize = 5, fontfamily = "Helvetica")),
                                                 gp = gpar(fill = col_main, col = col_main),
                                                 height = unit(1.5, "cm")),

           # 右侧注释：各组织总基因数
           right_annotation = upset_right_annotation(m,
                                                     add_numbers = TRUE,
                                                     numbers_rot = 0,
                                                     numbers_gp = gpar(fontsize = 5, fontfamily = "Helvetica"),
                                                     annotation_name_gp = gpar(fontsize = 6, fontfamily = "Helvetica"),
                                                     axis_param = list(labels_rot = 0,
                                                                       gp = gpar(fontsize = 5, fontfamily = "Helvetica")),
                                                     gp = gpar(fill = col_set, col = "white"),
                                                     width = unit(1.8, "cm")),

           # 矩阵点阵设置
           comb_col = col_main,
           pt_size = unit(1.5, "mm"),
           lwd = 0.75,

           # 排序逻辑
           comb_order = order(comb_degree(m), -comb_size(m)),
           set_order = order(set_size(m), decreasing = TRUE),

           # 背景与字体微调
           row_names_side = "left",
           row_names_gp = gpar(fontsize = 6, fontfamily = "Helvetica"),
           bg_col = c("#F2F2F2", "#E6E6E6")
)

# 渲染图表
draw(ht)

# 安全关闭设备
dev.off()










#############################人类#################################
# 确保安装了最强大的绘图包
if (!require("ComplexHeatmap")) BiocManager::install("ComplexHeatmap")
library(ComplexHeatmap)
library(tidyverse)
library(RColorBrewer)
library(tools) # 用于首字母大写转换
library(grid)  # 调用 gpar 和 unit 必需

# ==========================================
# 1. 自动化数据读取与名称清洗 (针对人类数据适配)
# ==========================================
folder_path <- "E:/2-8.3-shanda/1-feature/1-human-guaidian-choose-gene/Gene_Lists/"
file_list <- list.files(path = folder_path, pattern = "\\.txt$", full.names = TRUE)

gene_list <- lapply(file_list, readLines)

# --- 核心修改：针对 "type_0_bladder_Knee..." 格式的清洗逻辑 ---
raw_names <- basename(file_list)

# 第一步：移除后缀 (从 _Knee 开始的内容)
clean_names <- gsub("_Knee.*", "", raw_names)

# 第二步：移除前缀 (type_数字_)
clean_names <- gsub("^type_[0-9]+_", "", clean_names)

# 第三步：美化格式 (将下划线改为空格，并首字母大写)
clean_names <- gsub("_", " ", clean_names)
clean_names <- tools::toTitleCase(clean_names)

names(gene_list) <- clean_names

# ==========================================
# 2. 构建交集矩阵并进行筛选
# ==========================================
m = make_comb_mat(gene_list)

# 过滤掉交集基因数小于 3 的组合（根据数据量可适当调整为 2 或 1）
m = m[comb_size(m) >= 3]

# ==========================================
# 3. 定义主刊级专业色板
# ==========================================
# 统一采用小鼠代码中极简且高度符合主刊标准的配色（高对比度、无杂色）
col_main = "#333333"      # 纯粹的高级深灰，代替纯黑，适合点阵与主柱
col_set  = "#0072B2"      # 色盲友好的经典蓝

# ==========================================
# 4. 绘制合规的 UpSet 图 (物理尺寸限定：宽 115mm, 高 75mm)
# ==========================================
pdf("E:/2-8.3-shanda/1-feature/1-figure/0-1-result-2-mouse-gene/1-mouse-gene-upset/1-Human_Tissue_Aging_UpSet.pdf",
    width = 4.53, height = 2.95)

ht = UpSet(m,
           # --- 顶部注释：交集大小 ---
           top_annotation = upset_top_annotation(m,
                                                 add_numbers = TRUE,
                                                 numbers_rot = 0,
                                                 # 主刊要求：无衬线字体 (Helvetica)，极小字号 (5-6pt)
                                                 numbers_gp = gpar(fontsize = 5, fontfamily = "Helvetica"),
                                                 annotation_name_gp = gpar(fontsize = 6, fontfamily = "Helvetica"),
                                                 annotation_name_rot = 90,
                                                 axis_param = list(gp = gpar(fontsize = 5, fontfamily = "Helvetica")),
                                                 gp = gpar(fill = col_main, col = col_main),
                                                 height = unit(1.5, "cm")),

           # --- 右侧注释：各组织总基因数 ---
           right_annotation = upset_right_annotation(m,
                                                     add_numbers = TRUE,
                                                     numbers_rot = 0,
                                                     numbers_gp = gpar(fontsize = 5, fontfamily = "Helvetica"),
                                                     annotation_name_gp = gpar(fontsize = 6, fontfamily = "Helvetica"),
                                                     axis_param = list(labels_rot = 0,
                                                                       gp = gpar(fontsize = 5, fontfamily = "Helvetica")),
                                                     gp = gpar(fill = col_set, col = "white"),
                                                     width = unit(1.8, "cm")),

           # --- 矩阵点阵设置 ---
           comb_col = col_main,
           pt_size = unit(1.5, "mm"), # 缩小点阵以匹配小画布
           lwd = 0.75,                # 缩小连线粗细

           # --- 排序逻辑 ---
           comb_order = order(comb_degree(m), -comb_size(m)),
           set_order = order(set_size(m), decreasing = TRUE),

           # --- 背景与字体微调 ---
           row_names_side = "left",
           row_names_gp = gpar(fontsize = 6, fontfamily = "Helvetica"),
           bg_col = c("#F2F2F2", "#E6E6E6") # 柔和的浅灰交错背景
)

# 渲染图表
draw(ht)

# 安全关闭设备
dev.off()

print("Human UpSet plot generated successfully at Top-Tier standards!")
