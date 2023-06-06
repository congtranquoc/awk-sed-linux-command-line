#!/bin/bash

#tải file 
wget -P data https://raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv

# Sort dữ liệu theo ngày phát hành giảm dần
csvsort -c release_date -r data/tmdb-movies.csv > data/tmdb_movies_sort_by_release_date.csv

# Chuyển dấu phân trang thành tab
csvformat -T data/tmdb-movies.csv > data/tmdb-movies-tab.csv

# Lọc danh sách chứa vote_average > 7.5
awk -F'\t' '$18 > 7.5 { print }' data/tmdb-movies-tab.csv > data/high-vote-average.csv

# Sắp xếp dữ liệu theo cột 'revenue' giảm dần
csvsort -c revenue -r data/tmdb-movies.csv > data/revenue_desc_movies.csv

# In ra thông tin của đối tượng có doanh thu cao nhất và lưu vào tệp highest-lowest-revenue.csv
{ head -n 2 data/revenue_desc_movies.csv; tail -n 1 data/revenue_desc_movies.csv; } > data/highest-lowest-revenue.csv

# Trích xuất cột "revenue" từ tệp tmdb-movies.csv và tính tổng
csvcut -c revenue data/tmdb-movies.csv | csvstat --sum > data/sum-revenue-movies.txt

# Top 10 lợi nhuận cao nhất
awk -F"," 'BEGIN {OFS=","} {if(NR==1) print $0, "profit"; else print $0, ($5+0)-($4+0)}' data/revenue_desc_movies.csv | csvsort -c profit -r | head -n 11 > data/top-10-highest-profit.csv

# Đạo diễn có nhiều bộ phim nhất
awk -F"," 'BEGIN {OFS=","} {split($9, directors, "|"); for(i in directors) print directors[i]}' data/tmdb-movies.csv | csvcut -c director | sort | uniq -c | sort -rn | head -n 1 > data/director.txt

# Diễn viên diễn nhiều bộ phim nhất
awk -F"," 'BEGIN {OFS=","} {split($7, actors, "|"); for(i in actors) print actors[i]}' data/tmdb-movies.csv | csvcut -c 1 | sort | uniq -c | sort -rn | head -n 1 > data/actors.txt

# Thống kê thể loại phim
csvcut -c genres data/tmdb-movies.csv | awk -F"," 'BEGIN {OFS=","} {split($1, genres, "|"); for(i in genres) print genres[i]}' | sort | uniq -c | sort -rn > data/static-genres.txt
