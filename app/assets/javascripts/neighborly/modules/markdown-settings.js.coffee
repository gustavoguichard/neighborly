# ----------------------------------------------------------------------------
# markItUp!
# ----------------------------------------------------------------------------
# Copyright (C) 2008 Jay Salvat
# http://markitup.jaysalvat.com/
# ----------------------------------------------------------------------------
Neighborly.markdownSettings =
  nameSpace: "markdown" # Useful to prevent multi-instances CSS conflict
  #previewParserPath:  '~/sets/markdown/preview.php',
  onShiftEnter:
    keepDefault: false
    openWith: "\n\n"

  markupSet: [
    name: "Heading 1"
    key: "1"
    openWith: "# "
    placeHolder: "Your title here..."
  ,
    name: "Heading 2"
    key: "2"
    openWith: "## "
    placeHolder: "Your title here..."
  ,
    name: "Heading 3"
    key: "3"
    openWith: "### "
    placeHolder: "Your title here..."
  ,
    name: "Heading 4"
    key: "4"
    openWith: "#### "
    placeHolder: "Your title here..."
  ,
    separator: "---------------"
  ,
    name: "Bold"
    key: "B"
    openWith: "**"
    closeWith: "**"
  ,
    name: "Italic"
    key: "I"
    openWith: "_"
    closeWith: "_"
  ,
    separator: "---------------"
  ,
    name: "Bulleted List"
    openWith: "- "
  ,
    name: "Numeric List"
    openWith: (markItUp) ->
      markItUp.line + ". "
  ,
    separator: "---------------"
  ,
    name: "Picture"
    key: "P"
    replaceWith: "![]([![Url:!:http://]!] \"[![Title]!]\")"
  ,
    name: "Link"
    key: "L"
    openWith: "["
    closeWith: "]([![Url:!:http://]!] \"[![Title]!]\")"
    placeHolder: "Your text to link here..."
  ,
    separator: "---------------"
  ,
    name: "Quotes"
    openWith: "> "
  ]


#{separator:'---------------'},
#{name:'Preview', call:'preview', className:"preview"}

# mIu nameSpace to avoid conflict.
miu = markdownTitle: (markItUp, char) ->
  heading = ""
  n = $.trim(markItUp.selection or markItUp.placeHolder).length
  i = 0
  while i < n
    heading += char
    i++
  "\n" + heading + "\n"
