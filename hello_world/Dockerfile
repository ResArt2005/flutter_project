# Этап сборки
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Включаем веб-поддержку
RUN flutter config --enable-web

# Проверяем установку Flutter
RUN flutter doctor -v

# Копируем pubspec файлы для кэширования зависимостей
COPY pubspec.yaml ./
RUN flutter pub get

# Копируем исходный код
COPY . .

# Убедимся, что зависимости установлены
RUN flutter pub get --offline

# Собираем веб-приложение
RUN flutter build web --release --no-wasm-dry-run

# Этап запуска
FROM nginx:alpine

# Копируем собранные файлы в nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Экспонируем порт
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]