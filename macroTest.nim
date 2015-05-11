
import macros

when false:
  macro safePrintF(formatString: string{lit}, args: varargs[expr]): expr =
    var i = 0
    for c in formatChars(formatString):
      var expectedType = case c
        of 'c': char
        of 'd', 'i', 'x', 'X': int
        of 'f', 'e', 'E', 'g', 'G': float
        of 's': string
        of 'p': pointer
        else: EOutOfRange

      var actualType = args[i].getType
      inc i

      if expectedType == EOutOfRange:
        error c & " is not a valid format character"
      elif expectedType != actualType:
        error "type mismatch for argument ", i, ". expected type: ",
              expectedType.name, ", actual type: ", actualType.name

    # keep the original callsite, but use cprintf instead
    result = callsite()
    result[0] = newIdentNode(!"cprintf")

  safePrintf("%3d", 42)


macro debug(n: varargs[expr]): stmt =
  # `n` is a Nim AST that contains the whole macro invocation
  # this macro returns a list of statements:
  result = newNimNode(nnkStmtList, n)
  # iterate over any argument that is passed to this macro:
  for i in 0..n.len-1:
    # add a call to the statement list that writes the expression;
    # `toStrLit` converts an AST to its string representation:
    add(result, newCall("write", newIdentNode("stdout"), toStrLit(n[i])))
    # add a call to the statement list that writes ": "
    add(result, newCall("write", newIdentNode("stdout"), newStrLitNode(": ")))
    # add a call to the statement list that writes the expressions value:
    add(result, newCall("writeln", newIdentNode("stdout"), n[i]))


proc sprintf_raw(buffer: cstring, formatstr: cstring): int {.header: "<stdio.h>", importc: "sprintf", varargs.}

var bufferSize = 512
var buffer = newStringOfCap(bufferSize)
var length = sprintf_raw(buffer, "%.2f %3d %-5s\n", 1.0, 2, "3")
buffer.setLen(length)
echo "Length: ", length
echo "\"" & buffer & "\""
echo buffer
echo buffer.len

    
dumpTree:
  var bufferSize = 512
  var buffer = newStringOfCap(bufferSize)
  var length = sprintf_raw(buffer, "%.2f %3d %-5s\n", 1.0, 2, "3")



import parseutils
const
  Whitespace = {' ', '\t', '\v', '\r', '\l', '\f'}
  IdentChars = {'a'..'z', 'A'..'Z', '0'..'9', '_'}
  IdentStartChars = {'a'..'z', 'A'..'Z', '_'}
    ## copied from strutils

type
  ParseState = enum
    psNeutral, psOneDollar, psIdent, psExpr

proc isValidExpr(s: string): bool {.compileTime.} =
  try:
    discard parseExpr(s)
    return true
  except ValueError:
    return false



macro format(s: string): stmt =

  # An iterator itself cannot be {.compileTime.}
  # This is required to call isValidExpr (parseExpr)
  # to avoid manual parsing of {}-expressions.
  # Solution: An iterator can be nested in any
  # {.compileTime.} proc / template / macro
  iterator parseFormatString(s: string): string =

    var state = psNeutral
    var buffer = ""

    for i, c in s:
      echo c, " state: ", state
      case state

      of psNeutral:
        if c == '$':
          echo "yielding ", buffer
          yield buffer
          buffer.setlen(0)
          state = psOneDollar
        else:
          buffer.add(c)

      of psOneDollar:
        if c == '$':                  # second dollar -> yield "$", return to neutral
          echo "yielding $"
          yield "$"
          state = psNeutral
        elif c == '{':
          state = psExpr
        elif c in IdentStartChars:
          state = psIdent
          buffer.add(c)
        else:
          error "a '$' character must either be followed by '$', an identifier, or a {} expression"

      of psIdent:
        if c in IdentChars:
          buffer.add(c)
        else:
          echo "yielding ", buffer
          yield buffer
          buffer.setlen(0)
          state = psNeutral

      of psExpr:
        echo "current expr: ", buffer
        if c == '}' and buffer.isValidExpr:
          echo "yielding ", buffer
          echo "yielding ", parseExpr(buffer).toStrLit.strVal
          yield parseExpr(buffer).strVal
          buffer.setlen(0)
          state = psNeutral
        else:
          buffer.add(c)

  echo "Parsing s = ", s

  for x in parseFormatString(s.strVal):
    echo "iterator yielded: ", x

  result = quote do:
    echo "Hello World"
  
when true:

  let x = 1
  format("${x+1}")
  #format("$$ hallo $x = ${x+1}")
  #format("$.")

  #for x in interpolatedFragments("""${s & "local substring with {{{"}"""):
  #  echo x


# from parseutils
when false:
  type
    InterpolatedKind* = enum   ## describes for `interpolatedFragments`
                               ## which part of the interpolated string is
                               ## yielded; for example in "str$$$var${expr}"
      ikStr,                   ## ``str`` part of the interpolated string
      ikDollar,                ## escaped ``$`` part of the interpolated string
      ikVar,                   ## ``var`` part of the interpolated string
      ikExpr                   ## ``expr`` part of the interpolated string

  {.deprecated: [TInterpolatedKind: InterpolatedKind].}

  iterator interpolatedFragments*(s: string): tuple[kind: InterpolatedKind,
    value: string] =
    ## Tokenizes the string `s` into substrings for interpolation purposes.
    ##
    ## Example:
    ##
    ## .. code-block:: nim
    ##   for k, v in interpolatedFragments("  $this is ${an  example}  $$"):
    ##     echo "(", k, ", \"", v, "\")"
    ##
    ## Results in:
    ##
    ## .. code-block:: nim
    ##   (ikString, "  ")
    ##   (ikExpr, "this")
    ##   (ikString, " is ")
    ##   (ikExpr, "an  example")
    ##   (ikString, "  ")
    ##   (ikDollar, "$")
    var i = 0
    var kind: InterpolatedKind
    while true:
      var j = i
      if s[j] == '$':
        if s[j+1] == '{':
          inc j, 2
          var nesting = 0
          while true:
            case s[j]
            of '{': inc nesting
            of '}':
              if nesting == 0: 
                inc j
                break
              dec nesting
            of '\0':
              raise newException(ValueError, 
                "Expected closing '}': " & substr(s, i, s.high))
            else: discard
            inc j
          inc i, 2 # skip ${
          kind = ikExpr
        elif s[j+1] in IdentStartChars:
          inc j, 2
          while s[j] in IdentChars: inc(j)
          inc i # skip $
          kind = ikVar
        elif s[j+1] == '$':
          inc j, 2
          inc i # skip $
          kind = ikDollar
        else:
          raise newException(ValueError, 
            "Unable to parse a varible name at " & substr(s, i, s.high))
      else:
        while j < s.len and s[j] != '$': inc j
        kind = ikStr
      if j > i:
        # do not copy the trailing } for ikExpr:
        yield (kind, substr(s, i, j-1-ord(kind == ikExpr)))
      else:
        break
      i = j

