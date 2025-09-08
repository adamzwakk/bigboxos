innoextract -s --extract ./src/*.exe -d ./src/extracted/
mkdir -p ./dist/package/files

GAME_NAME=""
GOG_INFO_FILE=$(find "./src/extracted" -maxdepth 1 -type f -name 'goggame*.info' | head -n 1 | tr -d '\r\n')
if [ -f "$GOG_INFO_FILE" ]; then
    GAME_NAME=$(cat $GOG_INFO_FILE | jq '.name' | tr -d '"')
fi

# Wolf3D GOG
if [ "$GAME_NAME" = "Wolfenstein 3D" ]; then
    
    cp ./src/extracted/*.WL6 ./dist/package/files/

    rm -r ./src/extracted/*

    cat << EOF > ./dist/package/cart.ini
[game]
program=ecwolf
cmd=cd /mnt/cart && ecwolf
args=
EOF
fi

(
    cd ./dist/package
    zip -rqo ../cart.zip ./*
)
rm -r ./dist/package/*

echo "cart.zip made in ./dist/"