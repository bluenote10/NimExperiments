#!/usr/bin/env nimrun

import opengl

# example using glfw
when true:
  import glfw/glfw

  # load extensions
  when not defined(useGlew):
    opengl.loadExtensions()

  # create context
  glfw.init()
  var win = newGlWin()

  # try to create a shader
  let shaderId = glCreateShader(GL_VERTEX_SHADER)
  echo "Shader ID: ", shaderId
  assert(shaderId.int != 0)

# example using glut
else:
  import glu, glut

  # load extensions
  loadExtensions()

  # create context
  glutInit()
  glutInitDisplayMode(GLUT_DOUBLE)
  glutInitWindowSize(640, 480)
  glutInitWindowPosition(50, 50)
  discard glutCreateWindow("OpenGL Example")

  # try to create a shader
  let shaderId = glCreateShader(GL_VERTEX_SHADER)
  echo "Shader ID: ", shaderId
  assert(shaderId.int != 0)
  
