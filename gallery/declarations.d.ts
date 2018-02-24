declare module "scrollmonitor"
declare module "shader-canvas"

// Tell typescript what to expect when we import this webpack-generated module.
declare module "*.yaml" {
  const models: any[]
  export default models
}
