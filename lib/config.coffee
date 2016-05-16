module.exports =
  config:
    apiEndPoint:
      type: "string"
      default: "https://api.imgur.com/3/image"
      title: "API End Point"
    authorizationHeader:
      type: "string"
      default: "Client-ID cf92c740bb37b86"
      title: "Authorization Header"
    insertNewLineBetweenMultipleFiles:
      type: "boolean"
      default: true
      title: "Insert New Line Between Multiple Files"
    format:
      type: "object"
      title: "Format"
      properties:
        loading:
          type: "string"
          default: "{{name}} ({{percent}}%)"
          title: "Loading"
          description: "`{{name}}` will be replaced with the actual file name\n`{{percent}}` will be replaced by the percentage uploaded"
        success:
          type: "string"
          default: "{{name}} ({{link}})"
          title: "Success"
          description: "`{{name}}` will be replaced with the actual file name\n`{{link}}` will be replaced by the final link to the image"

  preset:
    ".source.gfm":
      format:
        loading: "[uploading {{name}}...{{percent}}%]"
        success: "![{{name}}]({{link}})"
    ".text.html.basic":
      format:
        loading: "<!-- uploading {{name}}...{{percent}}% -->"
        success: "<img src=\"{{link}}\" alt=\"{{name}}\">"
    ".source.css":
      format:
        loading: "url(/* {{name}}...{{percent}}% */);"
        success: "url({{link}});"

  setPreset: (preset) ->
    for k, v of preset
      atom.config.set("drop-up", v, scopeSelector: k)
