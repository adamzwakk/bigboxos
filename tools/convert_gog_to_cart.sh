innoextract -s --extract ./src/*.exe -d ./src/extracted/
mkdir -p ./dist/package/files

GAME_NAME=""
SHORT_NAME="cart"
GOG_INFO_FILE=$(find "./src/extracted" -maxdepth 1 -type f -name 'goggame*.info' | head -n 1 | tr -d '\r\n')
if [ -f "$GOG_INFO_FILE" ]; then
    GAME_NAME=$(cat $GOG_INFO_FILE | jq '.name' | tr -d '"')
fi

if [ "$GAME_NAME" = "Wolfenstein 3D" ]; then
    cp ./src/extracted/*.WL6 ./dist/package/files/
    cp ./configs/wolf3d.ini ./dist/package/cart.ini
    SHORT_NAME="wolf3d"
fi

(
    cd ./dist/package
    zip -rqo ../$SHORT_NAME.zip ./*
)

rm -r ./src/extracted/*
rm -r ./dist/package/*

echo "$SHORT_NAME.zip made in ./dist/"