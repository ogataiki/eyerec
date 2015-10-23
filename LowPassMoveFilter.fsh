varying highp vec2 textureCoordinate;
varying highp vec2 textureCoordinate2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

uniform highp float intensity;

void main()
{
    lowp vec3 currentImageColor = texture2D(inputImageTexture, textureCoordinate).rgb;
    lowp vec3 lowPassImageColor = texture2D(inputImageTexture2, textureCoordinate2).rgb;

    // 移動距離の比率
    lowp float moveOffset = 0.0075;

    highp float moveXBase = textureCoordinate.x;
    if (textureCoordinate.x - moveOffset > 0.0) {
        moveXBase = textureCoordinate.x - moveOffset;
    }
    highp float moveX2Base = textureCoordinate2.x;
    if (textureCoordinate2.x - moveOffset > 0.0) {
        moveX2Base = textureCoordinate2.x - moveOffset;
    }
    
    highp vec2 moveCoordinateBase = vec2(moveXBase, textureCoordinate.y);
    highp vec2 moveCoordinate2Base = vec2(moveX2Base, textureCoordinate2.y);

    // 移動元の色を取得
    lowp vec4 moveColorBase = texture2D(inputImageTexture, moveCoordinateBase).rgba;
    lowp vec3 moveColorv3Base = texture2D(inputImageTexture, moveCoordinate2Base).rgb;

    // 移動元のローパスフィルタ後の色を取得
    lowp vec3 lowPassMoveColorv3Base = texture2D(inputImageTexture2, moveCoordinate2Base).rgb;

    //オフセット分左の座標が白(閾値超える)以外の場合はその領域の色を配置
    mediump float colorDistanceBase = distance(moveColorv3Base, lowPassMoveColorv3Base); // * 0.57735
    lowp float movementThresholdBase = step(0.2, colorDistanceBase);
    if (movementThresholdBase < 0.75) {
        // 白くなる部分
        
        // 移動元の色で置き換え
        gl_FragColor = moveColorBase;
        
        return;
    }

    // 中間色を調整するため移動元までの全てを検索する
    for (lowp float m = 0.001; m < moveOffset; m += 0.001) {
    
        // 移動元の位置を取得
        highp float moveX = textureCoordinate.x;
        if (textureCoordinate.x - m > 0.0) {
            moveX = textureCoordinate.x - m;
        }
        highp float moveX2 = textureCoordinate2.x;
        if (textureCoordinate2.x - m > 0.0) {
            moveX2 = textureCoordinate2.x - m;
        }
        
        highp vec2 moveCoordinate = vec2(moveX, textureCoordinate.y);
        highp vec2 moveCoordinate2 = vec2(moveX2, textureCoordinate2.y);

        
        // 移動元の色を取得
        lowp vec4 moveColor = texture2D(inputImageTexture, moveCoordinate).rgba;
        lowp vec3 moveColorv3 = texture2D(inputImageTexture, moveCoordinate).rgb;
        
        // 移動元のローパスフィルタ後の色を取得
        lowp vec3 lowPassMoveColorv3 = texture2D(inputImageTexture2, moveCoordinate2).rgb;
        
        //オフセット分左の座標が白(閾値超える)以外の場合はその領域の色を配置
        mediump float colorDistance = distance(moveColorv3, lowPassMoveColorv3); // * 0.57735
        lowp float movementThreshold = step(0.2, colorDistance);
        if (movementThreshold < 0.75) {
            // 白くなる部分
            
            // 移動元の色で置き換え
            gl_FragColor = (moveColorBase + texture2D(inputImageTexture, textureCoordinate).rgba) / 2.0;
            
            return;
        }
    }
    
    // 現座標の色のまま
    gl_FragColor = texture2D(inputImageTexture, textureCoordinate).rgba;

    
    //gl_FragColor = movementThreshold * vec4(textureCoordinate2.x, textureCoordinate2.y, 1.0, 1.0);
}
