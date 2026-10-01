package triangle

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"

SCR_WIDTH :: 800
SCR_HEIGHT :: 600

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

main :: proc() {
	if !glfw.Init() {
		fmt.println("Failed to initialize GLFW")
		return
	}
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	when ODIN_OS == .Darwin {
		glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, gl.TRUE)
	}

	window := glfw.CreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", nil, nil)
	assert(window != nil, "Failed to create GLFW window")
	defer glfw.DestroyWindow(window)

	glfw.SetWindowSizeLimits(window, SCR_WIDTH, SCR_HEIGHT, SCR_WIDTH, SCR_HEIGHT)
	glfw.SetWindowSize(window, SCR_WIDTH, SCR_HEIGHT) // dispara o "resize" que aplica os limites

	glfw.MakeContextCurrent(window)
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback) // sempre que o valor de window for alterado, vai chamar framebuffer_size_callback

	vertex := [?]f32 {
		// bottom right
		0.5,
		-0.5,
		0.0,
		// colors
		1.0,
		0.0,
		0.0,
		// bottom left
		-0.5,
		-0.5,
		0.0,
		// colors
		0.0,
		1.0,
		0.0,
		// top
		0.0,
		0.5,
		0.0,
		// colors
		0.0,
		0.0,
		1.0,
	}

	success: i32
	info_log: [512]u8

	VBO: u32
	VAO: u32
	gl.GenBuffers(1, &VBO) // declaramos um buffer VBO com ID 1
	gl.GenVertexArrays(1, &VAO)

	gl.BindVertexArray(VAO)
	gl.BindBuffer(gl.ARRAY_BUFFER, VBO) // falamos qual o tipo desse buffer
	// Ao aplicar raw_data(), você descarta temporariamente os metadados de tamanho e segurança, obtendo apenas o endereço de memória do primeiro elemento
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertex), raw_data(&vertex), gl.STATIC_DRAW) // copia os dados do vertex para o buffer(GPU)

	// Leia os vertices de 24 a 24 bytes, sendo que cada vertice tem 4 bytes e temos 6 parametros por vertice entao 6 * 4 = 24
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 0) // dizendo como deve ser interpretado os dados brutos
	gl.EnableVertexAttribArray(0)

	// falamos para o ponteiro de cor que ele esta a partir da terceira posicao do vertice
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)

	shader, s_ok := shader_init("vertex_shader.glsl", "fragment_shader.glsl")
	if !s_ok do panic("Unable to load shaders")

	for !glfw.WindowShouldClose(window) {
		process_input(window)

		gl.ClearColor(1.0, 1.0, 1.0, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		shader_use(shader)
		gl.BindVertexArray(VAO)
		gl.DrawArrays(gl.TRIANGLES, 0, 3)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}

	gl.DeleteVertexArrays(1, &VAO)
	gl.DeleteBuffers(1, &VBO)
	gl.DeleteProgram(shader.id)
}

process_input :: proc(window: glfw.WindowHandle) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	gl.Viewport(0, 0, width, height)
}
