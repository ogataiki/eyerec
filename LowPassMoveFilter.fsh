varying highp vec2 textureCoordinate;
varying highp vec2 textureCoordinate2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

uniform highp float intensity;

void main()
{
    lowp vec3 currentImageColor = texture2D(inputImageTexture, textureCoordinate).rgb;
    lowp vec3 lowPassImageColor = texture2D(inputImageTexture2, textureCoordinate2).rgb;

    mediump float moveOffset = 0.02;
    mediump float threshold = 0.05;
    
    highp float moveX = 0.0;
    if (textureCoordinate.x - moveOffset > 0.0) {
        moveX = textureCoordinate.x - moveOffset;
    }
    highp vec2 moveCoordinate = vec2(moveX, textureCoordinate.y);
    lowp vec4 moveColor = texture2D(inputImageTexture, moveCoordinate).rgba;
    lowp vec3 moveColor3v = texture2D(inputImageTexture, moveCoordinate).rgb;
    
    mediump float rDistance = distance(currentImageColor.x, moveColor3v.x);
    mediump float gDistance = distance(currentImageColor.y, moveColor3v.y);
    mediump float bDistance = distance(currentImageColor.z, moveColor3v.z);
    
    mediump float maxDistance = max(rDistance, gDistance);
    maxDistance = max(maxDistance, bDistance);
    if (maxDistance > threshold) {
        
        highp vec2 leftCoordinate = texture2D(inputImageTexture, textureCoordinate);
        highp vec2 rightCoordinate = vec2(moveX, textureCoordinate.y);
        lowp vec4 moveColor = texture2D(inputImageTexture, moveCoordinate).rgba;

        gl_FragColor = moveColor;
        return;
    }
    
    /*
    mediump float moveOffsetBase = 0.015;
    highp float moveXBase = textureCoordinate.x;
    if (textureCoordinate.x - moveOffsetBase > 0.0) {
        moveXBase = textureCoordinate.x - moveOffsetBase;
    }
    highp vec2 moveCoordinateBase = vec2(moveXBase, textureCoordinate.y);
    lowp vec4 moveColorBase = texture2D(inputImageTexture, moveCoordinateBase).rgba;
    
    for ( mediump float moveOffset = moveOffsetBase; moveOffset > 0.0; moveOffset -= (moveOffsetBase/4.0)) {
        
        // 移動元の位置を取得
        highp float moveX = textureCoordinate.x;
        if (textureCoordinate.x - moveOffset > 0.0) {
            moveX = textureCoordinate.x - moveOffset;
        }
        
        highp vec2 moveCoordinate = vec2(moveX, textureCoordinate.y);
        highp vec2 moveCoordinate2 = vec2(moveX, textureCoordinate2.y);
        
        // 移動元の色を取得
        lowp vec4 moveColor = texture2D(inputImageTexture, moveCoordinate).rgba;
        lowp vec3 moveColorv3 = texture2D(inputImageTexture, moveCoordinate).rgb;
        
        // 現座標のローパスフィルタ後の色を取得
        lowp vec3 lowPassColorv3 = texture2D(inputImageTexture2, moveCoordinate2).rgb;
        
        // 座標が白(閾値超える)以外の場合はオフセット分左の領域の色を配置
        mediump float colorDistance = distance(moveColorv3, lowPassColorv3); // * 0.57735
        
        // 2値化
        lowp float movementThreshold = step(0.2, colorDistance);
        //lowp float v = moveColorv3.x * 0.298912 + moveColorv3.y * 0.586611 + moveColorv3.z * 0.114478;
        //lowp float movementThreshold = step(0.5, v);
        
        //if (movementThreshold > 0.5) {
        if (colorDistance > 0.5) {
            
            //gl_FragColor = movementThreshold * vec4(textureCoordinate2.x, textureCoordinate2.y, 1.0, 1.0);
            gl_FragColor = moveColor;
            return;
        }
    }
    */
    
    // 現座標の色のまま
    gl_FragColor = texture2D(inputImageTexture, textureCoordinate).rgba;
    
    //gl_FragColor = movementThreshold * vec4(textureCoordinate2.x, textureCoordinate2.y, 1.0, 1.0);
}
