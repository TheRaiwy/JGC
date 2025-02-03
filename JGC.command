#!/bin/bash

response=$(osascript -e 'tell app "System Events" to display dialog "Необходимо ли установить Java 8 (для версий 1.7.10, 1.12.2)?" buttons {"Нет", "Да"} default button "Да"')

if [[ "$response" == "button returned:Да" ]]; then
    temp_dir=$(mktemp -d)
    cd "$temp_dir" || exit

    if ! curl -LO https://corretto.aws/downloads/resources/8.252.09.1/amazon-corretto-8.252.09.1-macosx-x64.tar.gz; then
        osascript -e 'tell app "System Events" to display dialog "Ошибка при скачивании архива." buttons {"OK"}'
        rm -rf "$temp_dir"
        exit 1
    fi

    if ! tar -xzf amazon-corretto-8.252.09.1-macosx-x64.tar.gz; then
        osascript -e 'tell app "System Events" to display dialog "Ошибка при распаковке архива." buttons {"OK"}'
        rm -rf "$temp_dir"
        exit 1
    fi

    contents_path="$temp_dir/amazon-corretto-8.jdk/Contents"

    if [ -d "$contents_path" ]; then
        username=$(whoami)
        target_dir="/Users/$username/minecraft/GravityCraft/updates/java8-macosx-64"
        target_contents="$target_dir/Contents"

        mkdir -p "$target_dir"

        # Удаление существующей папки Contents, если она есть
        if [ -d "$target_contents" ]; then
            rm -rf "$target_contents"
        fi

        if ! mv -f "$contents_path" "$target_dir/"; then
            osascript -e 'tell app "System Events" to display dialog "Ошибка при перемещении папки Contents." buttons {"OK"}'
            rm -rf "$temp_dir"
            exit 1
        fi

        osascript -e 'tell app "System Events" to display dialog "Java успешно установлена!" buttons {"OK"}'
    else
        osascript -e 'tell app "System Events" to display dialog "Ошибка: папка Contents не найдена." buttons {"OK"}'
        rm -rf "$temp_dir"
        exit 1
    fi

    rm -rf "$temp_dir"
else
    osascript -e 'tell app "System Events" to display dialog "Установка отменена." buttons {"OK"}'
fi
