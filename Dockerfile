
# 1️⃣ 使用 OpenJDK 17 作为基础镜像（Temurin 版，官方推荐替代）
FROM eclipse-temurin:17-jdk-jammy

# 2️⃣ 设置工作目录
WORKDIR /app

# 3️⃣ 安装必要工具和 Tesseract OCR
RUN apt-get update && apt-get install -y \
    wget \
    tesseract-ocr \
    libtesseract-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*  # 清理无用缓存，减小镜像体积

# 安装 PostgreSQL 16 客户端
RUN apt-get update && apt-get install -y wget gnupg2 lsb-release \
  && wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && apt-get update && apt-get install -y postgresql-client-16 \
  && apt-get clean

# 4️⃣ 设置 OCR 语言包目录
ENV TESSDATA_PREFIX="/usr/share/tesseract-ocr/4.00/tessdata/"

# 5️⃣ 下载高精度 `chi_sim` 和 `chi_sim_vert` 语言包
RUN wget -q -O ${TESSDATA_PREFIX}/chi_sim.traineddata \
    "https://github.com/tesseract-ocr/tessdata_best/raw/main/chi_sim.traineddata" \
    && wget -q -O ${TESSDATA_PREFIX}/chi_sim_vert.traineddata \
    "https://github.com/tesseract-ocr/tessdata_best/raw/main/chi_sim_vert.traineddata"

# 2️⃣ 安装 LibreOffice 和必要工具
RUN apt-get update && \
    apt-get install -y libreoffice wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 6️⃣ 下载 JAR 文件
RUN wget -q -O app.jar \
    "https://github.com/mayintao/mbts-server/releases/download/mbts-260410-1/app-0.0.1-SNAPSHOT.jar"

# 7️⃣ 监听 10000 端口
EXPOSE 10000

# 8️⃣ 运行 JAR，并增加容器内存限制，防止 OOM
CMD ["java", "-Xms512m", "-Xmx512m", "-Xlog:gc*", "-jar", "app.jar"]
