declare module "scrollmonitor"

declare module "shader-canvas" {
  export interface ShaderErrorMessage {
    test: string;
    lineNumber: number;
  }

  export default class ShaderCanvas {
    constructor(options: {});

    domElement: HTMLElement;
    paused: boolean;

    // overridable for configuration
    buildTextureURL(url: string): string;
    onShaderLoad();
    onShaderError(messages: ShaderErrorMessage[]);
    onTextureLoad()
    onTextureError(textureURL: string);

    setSize(width: number, height: number);
    setShader(source: string, includeDefaultUniforms: boolean);
    togglePause();
    render();
  }
}

// Tell typescript what to expect when we import this webpack-generated module.
declare module "*.yaml" {
  const models: any[]
  export default models
}
