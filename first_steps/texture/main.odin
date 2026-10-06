package texture

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"

SCR_WIDTH :: 800
SCR_HEIGHT :: 600

main :: proc() {
	if !glfw.Init() {
		fmt.println("Failed to initialize GLDW")
		return
	}
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	window := glfw.CreateWindow(SCR_WIDTH, SCR_HEIGHT, "Texture", nil, nil)
	assert(window != nil, "Failed to create GLFW window")

	glfw.SetWindowSizeLimits(window, SCR_WIDTH, SCR_HEIGHT, SCR_WIDTH, SCR_HEIGHT)
	glfw.SetWindowSize(window, SCR_WIDTH, SCR_HEIGHT)

	glfw.MakeContextCurrent(window)
	gl.load_up_to(3, 3, glfw.gl_set_proc_address)

	for !glfw.WindowShouldClose(window) {
		process_input(window)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}
}

process_input :: proc(window: glfw.WindowHandle) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}
