library(ggplot2)
library(showtext)
library(sentimentr)
library(lubridate)
library(dplyr)
library(forcats)

# 加载中文字体
font_add("myfont","/System/Library/Fonts/Supplemental/Arial Unicode.ttf")
font_families()

# 读取数据
Reviews_data <- read.csv("/Users/yangchaoran/Desktop/Now learnin'/2024-2025 Sp/文本挖掘/Final/源代码及数据/data/tap_reviews cleaned.csv", stringsAsFactors = FALSE)
Reviews_data %>% skim()
head(Reviews_data)
str(Reviews_data)

# 1.玩家设备使用情况分析
showtext_auto() 
device_counts <- Reviews_data %>%
  filter(device != "") %>%  # 不考虑数据中的设备空白值
  count(device) %>%
  arrange(desc(n)) %>%
  slice(1:10)

colors <- c("#DA70D6", "#f5688a", "#F08080", "#BA55D3", "#9467bd", "#9370DB", "#7B68EE", "#483D8B", "#cd0254", "#ff3184")

ggplot(device_counts, aes(x = fct_reorder(device, n), y = n, fill = device)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = colors) +
  labs(x = "Device", y = "number") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, family = "myfont"),
        plot.title = element_text(family = "myfont", size = 14)) +
  ggtitle("Vitality Knight user's favorite device Top10")

x# 2.用户评分分析
# 2.1 游戏星级分析
star_counts <- table(Reviews_data$stars) # 计算每个星级评分的数量
star_counts_df <- data.frame(score = as.factor(names(star_counts)), freq = as.vector(star_counts))
ggplot(data.frame(stars = names(star_counts), count = as.numeric(star_counts)), aes(x = "", y = count, fill = stars)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = count), position = position_stack(vjust = 0.5), size = 4, color = "white") + 
  coord_polar("y", start = 0) +
  labs(title = "Star rating distribution") +
  scale_fill_manual(values = c("5" = "#DB7093", "1" = "#9370DB", "2" = "#4B0082", "3" = "#C71585", "4" = "#B22222")) +
  theme_minimal()



# 2.2 游戏量化指标分析——星级与评分
score_counts <- table(Reviews_data$score) # 计算数量

score_counts_df <- data.frame(score = as.factor(names(score_counts)), freq = as.vector(score_counts)) # 转换数据为数df格式,便于可视化

ggplot(score_counts_df, aes(x = score, y = freq, group = 1)) +
  geom_line(colour = "#E7298A", size = 1.5) +
  geom_point(colour = "#807DBA", size = 3) + 
  labs(title = "Score Distribution") +
  scale_x_discrete(labels = as.character(score_counts_df$score), limits = as.character(score_counts_df$score)) +
  scale_y_continuous(breaks = seq(0, max(score_counts_df$freq), by = 100), limits = c(0, max(score_counts_df$freq))) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# 玩家评论分析

# 转换更新时间为日期格式
Reviews_data$updated_time <- as.Date(Reviews_data$updated_time)

# 按照更新时间进行计数
update_counts <- Reviews_data %>%
  filter(!is.na(updated_time)) %>%  # 删除缺失值
  count(updated_time) %>%
  arrange(updated_time)

# 绘制评论更新时间线图
ggplot(update_counts, aes(x = updated_time, y = n)) +
  geom_line(color = "#C71585") +
  geom_point(color = "#6A5ACD") +
  scale_x_date(date_labels = "%Y-%m", date_breaks = "1 month") +  # 设置横轴为月份显示
  labs(title = "Comments Update Frequency Over Time", x = "Update Time", y = "Frequency") +
  theme_minimal()

# 4.玩家游玩时间分析
non_empty_spent <- Reviews_data$spent[!is.na(Reviews_data$spent)]

# 计算平均值和中位数
mean_spent <- mean(non_empty_spent)
median_spent <- median(non_empty_spent)

# 游玩时间-小提琴图
ggplot(data.frame(spent = non_empty_spent), aes(x = "", y = spent)) +
  geom_violin(fill = "#6A5ACD", color = "lightgray") +
  geom_point(aes(y = 0), color = "red", size = 2) + 
  geom_text(aes(y = mean_spent, label = paste("Mean:", round(mean_spent, 2))), vjust = -0.5, color = "coral1") +  
  geom_text(aes(y = median_spent, label = paste("Median:", round(median_spent, 2))), vjust = 0.5, color = "#FF00FF") + 
  labs(title = "Distribution of Player Spent Time",
       y = "Spent Time (minutes)",
       x = "") +
  theme_minimal()


# 设备与游玩时间-热力图
device_counts <- Reviews_data %>%
  group_by(device) %>%
  summarise(count = n()) %>%
  arrange(desc(count))
top_devices <- device_counts$device[1:10]
filtered_data <- Reviews_data %>%
  filter(device %in% top_devices)
ggplot(data = filtered_data, aes(x = stars, y = device, fill = spent)) +
  geom_tile() +
  scale_fill_gradient2(low = "#C71585cd", mid = "#C71585cd" ,high = "#6A5ACD") + # 指定颜色范围
  labs(title = "Heatmap of Player Spent Time by Stars and Device (Top 10 Devices)",
       x = "Stars",
       y = "Device",
       fill = "Spent Time (minutes)") +
  theme_minimal()











