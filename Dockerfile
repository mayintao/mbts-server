
# 1. OpenJDK 17 基础镜像
FROM eclipse-temurin:17-jdk-jammy

# 2. 工作目录
WORKDIR /app

# 3. 设置 OCR 语言包路径
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/5/tessdata/

# 4. 安装系统依赖及 PostgreSQL 16 客户端
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        wget \
        gnupg \
        ca-certificates \
        tesseract-ocr \
        libtesseract-dev \
        libreoffice \
        unzip; \
    mkdir -p /usr/share/keyrings; \
    wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] https://apt.postgresql.org/pub/repos/apt jammy-pgdg main" \
        > /etc/apt/sources.list.d/pgdg.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends postgresql-client-16; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# 5. 下载中文 OCR 高精度语言包
RUN mkdir -p "${TESSDATA_PREFIX}" && \
    wget -q -O "${TESSDATA_PREFIX}/chi_sim.traineddata" \
    https://raw.githubusercontent.com/tesseract-ocr/tessdata_best/main/chi_sim.traineddata && \
    wget -q -O "${TESSDATA_PREFIX}/chi_sim_vert.traineddata" \
    https://raw.githubusercontent.com/tesseract-ocr/tessdata_best/main/chi_sim_vert.traineddata

# 6. 下载 Spring Boot JAR
RUN wget -q -O app.jar \
    https://github.com/mayintao/mbts-server/releases/download/mbts-261112-4/app-0.0.1-SNAPSHOT.jar

# 7. 暴露端口
EXPOSE 10000

# 8. 启动应用
CMD ["java", "-Xms512m", "-Xmx512m", "-Xlog:gc*", "-jar", "app.jar"]
