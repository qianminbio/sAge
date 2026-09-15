# 加载必备包
library(ggplot2)
library(dplyr)

# ==================== 1. 节点与绝对坐标 ====================
# ★ 严格按照你要求的基因顺序 (从上到下)
genes <- c("Ctsl", "Hspa8", "Rps10", "Rps28", "S100a6") # Y: 5, 4, 3, 2, 1
# 优化左侧组织顺序以尽量顺应右侧基因，减少打结
tissues <- c("Liver", "Muscle", "Kidney", "Skin", "BM")  # Y: 5, 4, 3, 2, 1

# 构建节点数据框
nodes <- data.frame(
  id = c(tissues, genes),
  label = c(tissues, genes),
  type = factor(c(rep("Tissue", 5), rep("Gene", 5)), levels = c("Tissue", "Gene")),
  x = c(rep(1, 5), rep(3, 5)), # 只有两列，X=1 和 X=3
  y = c(5, 4, 3, 2, 1,         # 组织 Y 坐标 (上下对齐)
        5, 4, 3, 2, 1)         # 基因 Y 坐标 (严格锁定你的顺序)
)

# ==================== 2. 定义真实映射连线 ====================
edges <- data.frame(
  from = c("Liver", "Muscle", "Kidney", "BM", "BM", "BM", "BM", "Skin", "Skin", "Skin"),
  to = c("Ctsl", "Ctsl", "Rps10", "Rps10", "Hspa8", "Rps28", "S100a6", "Hspa8", "Rps28", "S100a6")
) %>% mutate(edge_id = row_number())

# 映射连线两端的绝对坐标
edges <- edges %>%
  left_join(nodes %>% select(id, x, y), by = c("from" = "id")) %>% rename(x_start = x, y_start = y) %>%
  left_join(nodes %>% select(id, x, y), by = c("to" = "id")) %>% rename(x_end = x, y_end = y)

# ==================== 3. 生成平滑 S 型曲线 (Sigmoid) ====================
generate_sigmoid <- function(x0, x1, y0, y1, id, n = 100) {
  x <- seq(x0, x1, length.out = n)
  x_norm <- seq(-5, 5, length.out = n)
  y_norm <- 1 / (1 + exp(-x_norm))
  y <- y0 + (y1 - y0) * y_norm
  data.frame(x = x, y = y, edge_id = id)
}

paths_list <- lapply(1:nrow(edges), function(i) {
  generate_sigmoid(edges$x_start[i], edges$x_end[i], edges$y_start[i], edges$y_end[i], edges$edge_id[i])
})
paths <- do.call(rbind, paths_list)

# ==================== 4. 渲染极简主刊级网络图 ====================
p <- ggplot() +

  # 1. 丝滑曲线 (使用高级冷灰色，置于节点下方)
  geom_path(data = paths, aes(x = x, y = y, group = edge_id),
            color = "#C0C0C0", linewidth = 0.8, alpha = 0.6) +

  # 2. 绘制组织节点：灰色方块 + 黑色细边框
  geom_tile(data = filter(nodes, type == "Tissue"), aes(x = x, y = y),
            width = 0.6, height = 0.55, fill = "#F0F0F0", color = "black", linewidth = 0.6) +

  # 3. 绘制基因节点：科研蓝大圆圈 + 黑色细边框 (严格按要求顺序)
  geom_point(data = filter(nodes, type == "Gene"), aes(x = x, y = y),
             shape = 21, fill = "#4DBBD5", color = "black", size = 16, stroke = 0.6) +

  # 4. 文本层
  # 组织文本：黑色，加粗
  geom_text(data = filter(nodes, type == "Tissue"), aes(x = x, y = y, label = label),
            size = 3.5, color = "black", fontface = "bold", family = "sans") +
  # 基因文本：纯白，斜体 (严守生物学基因命名规范)
  geom_text(data = filter(nodes, type == "Gene"), aes(x = x, y = y, label = label),
            size = 3.5, color = "white", fontface = "italic", family = "sans") +

  # 5. 顶部表头
  annotate("text", x = c(1, 3), y = 5.8,
           label = c("Tested Tissues", "Conserved Targets"),
           size = 4, fontface = "bold", family = "sans", color = "#222222") +

  # 画布范围设置，预留边缘呼吸空间
  coord_cartesian(xlim = c(0.5, 3.5), ylim = c(0.5, 6.2)) +
  theme_void()

# ==================== 5. 导出矢量 PDF ====================
output_dir <- "E:/2-8.3-shanda/1-feature/1-figure/0-4-result-5-CR-leipameisu/2-CR"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
output_path <- file.path(output_dir, "Figure_8_Bipartite_Network_Sorted.pdf")

# 导出为紧凑的单列尺寸
ggsave(filename = output_path, plot = p,
       width = 4.0, height = 4.5, device = cairo_pdf)

cat("✅ 完美定制！严格按照截图基因排序的网络图已导出至:\n👉", output_path, "\n")
















###############################
# 加载必备包
library(ggplot2)
library(dplyr)

# ==================== 1. 节点与绝对坐标 (改为上下排布) ====================
# ★ 严格按照你要求的顺序 (现在变为：从左到右)
genes <- c("Ctsl", "Hspa8", "Rps10", "Rps28", "S100a6") # X: 1, 2, 3, 4, 5
tissues <- c("Liver", "Muscle", "Kidney", "Skin", "BM")  # X: 1, 2, 3, 4, 5

# 构建节点数据框
nodes <- data.frame(
  id = c(tissues, genes),
  label = c(tissues, genes),
  type = factor(c(rep("Tissue", 5), rep("Gene", 5)), levels = c("Tissue", "Gene")),
  x = c(1, 2, 3, 4, 5,         # 组织 X 坐标 (从左往右排)
        1, 2, 3, 4, 5),        # 基因 X 坐标 (严格锁定你的顺序，从左往右)
  y = c(rep(2, 5),             # 组织 Y 坐标 (固定在上方，Y=2)
        rep(1, 5))             # 基因 Y 坐标 (固定在下方，Y=1)
)

# ==================== 2. 定义真实映射连线 ====================
edges <- data.frame(
  from = c("Liver", "Muscle", "Kidney", "BM", "BM", "BM", "BM", "Skin", "Skin", "Skin"),
  to = c("Ctsl", "Ctsl", "Rps10", "Rps10", "Hspa8", "Rps28", "S100a6", "Hspa8", "Rps28", "S100a6")
) %>% mutate(edge_id = row_number())

# 映射连线两端的绝对坐标
edges <- edges %>%
  left_join(nodes %>% select(id, x, y), by = c("from" = "id")) %>% rename(x_start = x, y_start = y) %>%
  left_join(nodes %>% select(id, x, y), by = c("to" = "id")) %>% rename(x_end = x, y_end = y)

# ==================== 3. 生成平滑垂直 S 型曲线 (Vertical Sigmoid) ====================
# ★ 核心修改：让 Y 轴线性下降，X 轴跟随 Sigmoid 函数进行平滑偏移
generate_vertical_sigmoid <- function(x0, x1, y0, y1, id, n = 100) {
  y <- seq(y0, y1, length.out = n)           # Y 轴匀速走
  y_norm <- seq(-5, 5, length.out = n)       # 构建 sigmoid 的自变量
  x_norm <- 1 / (1 + exp(-y_norm))           # sigmoid 变换 (0 到 1)
  x <- x0 + (x1 - x0) * x_norm               # 映射回 X 坐标
  data.frame(x = x, y = y, edge_id = id)
}

paths_list <- lapply(1:nrow(edges), function(i) {
  generate_vertical_sigmoid(edges$x_start[i], edges$x_end[i], edges$y_start[i], edges$y_end[i], edges$edge_id[i])
})
paths <- do.call(rbind, paths_list)

# ==================== 4. 渲染极简主刊级网络图 ====================
p <- ggplot() +

  # 1. 丝滑曲线 (使用高级冷灰色，置于节点下方)
  geom_path(data = paths, aes(x = x, y = y, group = edge_id),
            color = "#C0C0C0", linewidth = 0.8, alpha = 0.6) +

  # 2. 绘制组织节点：灰色方块 + 黑色细边框 (调整为横向更宽的矩形)
  geom_tile(data = filter(nodes, type == "Tissue"), aes(x = x, y = y),
            width = 0.8, height = 0.25, fill = "#F0F0F0", color = "black", linewidth = 0.6) +

  # 3. 绘制基因节点：科研蓝大圆圈 + 黑色细边框
  geom_point(data = filter(nodes, type == "Gene"), aes(x = x, y = y),
             shape = 21, fill = "#4DBBD5", color = "black", size = 16, stroke = 0.6) +

  # 4. 文本层
  # 组织文本：黑色，加粗
  geom_text(data = filter(nodes, type == "Tissue"), aes(x = x, y = y, label = label),
            size = 3.5, color = "black", fontface = "bold", family = "sans") +
  # 基因文本：纯白，斜体 (严守生物学基因命名规范)
  geom_text(data = filter(nodes, type == "Gene"), aes(x = x, y = y, label = label),
            size = 3.5, color = "white", fontface = "italic", family = "sans") +

  # 5. 顶部/底部表头 (居中在上方和下方)
  annotate("text", x = 3, y = c(2.35, 0.65),
           label = c("Tested Tissues", "Conserved Targets"),
           size = 4.5, fontface = "bold", family = "sans", color = "#222222") +

  # 画布范围设置，预留边缘呼吸空间
  coord_cartesian(xlim = c(0.4, 5.6), ylim = c(0.5, 2.5)) +
  theme_void()

# ==================== 5. 导出矢量 PDF ====================
output_dir <- "E:/2-8.3-shanda/1-feature/1-figure/0-4-result-5-CR-leipameisu/3-CR"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
output_path <- file.path(output_dir, "Figure_8.1_Bipartite_Network_TopBottom.pdf")

# ★ 导出尺寸调整：改为横向版幅 (width = 6.0, height = 3.5)
ggsave(filename = output_path, plot = p,
       width = 6.0, height = 3.5, device = cairo_pdf)

cat("✅ 完美定制！上下布局的网络图已导出至:\n👉", output_path, "\n")
